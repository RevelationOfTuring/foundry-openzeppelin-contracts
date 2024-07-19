// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/transparent/MockTransparentUpgradeableProxy.sol";
import "./Implementation.sol";

contract TransparentUpgradeableProxyTest is Test, IMockTransparentUpgradeableProxy, IImplementation, IERC1967 {
    Implementation private _implementation = new Implementation();
    ImplementationNew private _implementationNew = new ImplementationNew();
    MockTransparentUpgradeableProxy private _testing = new MockTransparentUpgradeableProxy(
        address(_implementation),
        address(this),
        abi.encodeCall(_implementation.__Implementation_init, (1024))
    );

    address private _nonAdmin = address(1);

    function test_Constructor() external {
        // check implementation
        ITransparentUpgradeableProxy proxyAsITransparentUpgradeableProxy = ITransparentUpgradeableProxy(address(_testing));
        assertEq(proxyAsITransparentUpgradeableProxy.implementation(), address(_implementation));

        // check admin
        assertEq(proxyAsITransparentUpgradeableProxy.admin(), address(this));

        // check storage
        Implementation proxyAsImplementation = Implementation(address(_testing));
        vm.prank(_nonAdmin);
        assertEq(proxyAsImplementation.i(), 1024);
    }

    function test_IfAdmin() external {
        // case 1: admin call
        uint arg = 1024;
        vm.expectEmit(address(_testing));
        emit IMockTransparentUpgradeableProxy.DoIfAdmin(arg);

        _testing.doIfAdmin(arg);

        // case 2: non-admin call
        vm.expectEmit(address(_testing));
        emit IImplementation.ChangeStorageUint(arg);

        address nonAdmin = address(1);
        vm.prank(nonAdmin);

        _testing.doIfAdmin(arg);

        // case 3: why is IfAdmin deprecated?
        // Functions in proxy and implementation have the same selector but differ in arguments
        // NOTE:
        //      Functions `proxy71997(uint256)`(in proxy) and `implementation49979()`(in implementation) have the same
        //      selector `0x2daa064d` and different arguments

        // case 3.1 admin call
        vm.expectEmit(address(_testing));
        emit IMockTransparentUpgradeableProxy.DoIfAdmin(arg);

        _testing.proxy71997(arg);

        // case 3.2 revert if non-admin call
        Implementation proxyAsImplementation = Implementation(address(_testing));
        vm.prank(nonAdmin);
        vm.expectRevert();

        proxyAsImplementation.implementation49979();
    }

    function test_Fallback() external {
        // case 1: admin can only call the functions in ITransparentUpgradeableProxy
        ITransparentUpgradeableProxy proxyAsITransparentUpgradeableProxy = ITransparentUpgradeableProxy(address(_testing));
        // case 1.1: upgradeTo(address)
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(address(_implementationNew));

        proxyAsITransparentUpgradeableProxy.upgradeTo(address(_implementationNew));
        // revert if admin calls with eth value
        uint ethValue = 1 wei;
        vm.expectRevert();
        (bool ok,) = address(_testing).call{value: ethValue}(
            abi.encodeCall(
                proxyAsITransparentUpgradeableProxy.upgradeTo,
                (address(_implementationNew))
            )
        );
        assertTrue(ok);

        // case 1.2: implementation()
        assertEq(proxyAsITransparentUpgradeableProxy.implementation(), address(_implementationNew));
        // revert if admin calls with eth value
        vm.expectRevert();
        (ok,) = address(_testing).call{value: ethValue}(
            abi.encodeCall(
                proxyAsITransparentUpgradeableProxy.implementation,
                ()
            )
        );
        assertTrue(ok);

        // case 1.3: changeAdmin(address)
        address newAdmin = address(1024);
        vm.expectEmit(address(_testing));
        emit IERC1967.AdminChanged(address(this), newAdmin);

        proxyAsITransparentUpgradeableProxy.changeAdmin(newAdmin);
        // revert if admin calls with eth value
        vm.startPrank(newAdmin);
        vm.expectRevert();
        (ok,) = address(_testing).call{value: ethValue}(
            abi.encodeCall(
                proxyAsITransparentUpgradeableProxy.changeAdmin,
                (newAdmin)
            )
        );
        assertTrue(ok);

        // case 1.4: admin()
        assertEq(proxyAsITransparentUpgradeableProxy.admin(), newAdmin);
        // revert if admin calls with eth value
        vm.expectRevert();
        (ok,) = address(_testing).call{value: ethValue}(
            abi.encodeCall(
                proxyAsITransparentUpgradeableProxy.admin,
                ()
            )
        );
        assertTrue(ok);
        vm.stopPrank();

        // case 1.5: upgradeToAndCall(address,bytes)
        // deploy a new proxy with Implementation as implementation
        proxyAsITransparentUpgradeableProxy = ITransparentUpgradeableProxy(address(
            new MockTransparentUpgradeableProxy(
                address(_implementation),
                address(this),
                abi.encodeCall(_implementation.__Implementation_init, (1024))
            )
        ));

        vm.expectEmit(address(proxyAsITransparentUpgradeableProxy));
        emit IERC1967.Upgraded(address(_implementationNew));

        proxyAsITransparentUpgradeableProxy.upgradeToAndCall(
            address(_implementationNew),
            abi.encodeCall(_implementationNew.__Implementation_init, (2048))
        );

        assertEq(proxyAsITransparentUpgradeableProxy.implementation(), address(_implementationNew));
        // check the storage by non-admin call
        vm.prank(_nonAdmin);
        ImplementationNew proxyAsImplementationNew = ImplementationNew(address(proxyAsITransparentUpgradeableProxy));
        assertEq(proxyAsImplementationNew.i(), 2048);

        // case 1.6: revert if admin calls function out of ITransparentUpgradeableProxy
        vm.expectRevert("TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        proxyAsImplementationNew.i();

        // case 2: non-admin can't call the function in ITransparentUpgradeableProxy
        vm.startPrank(_nonAdmin);
        // case 2.1: revert to call upgradeTo(address)
        vm.expectRevert();
        proxyAsITransparentUpgradeableProxy.upgradeTo(address(_implementationNew));
        // case 2.2: revert to call implementation()
        vm.expectRevert();
        proxyAsITransparentUpgradeableProxy.implementation();
        // case 2.3: revert to call changeAdmin(address)
        vm.expectRevert();
        proxyAsITransparentUpgradeableProxy.changeAdmin(address(this));
        // case 2.4: revert to call admin()
        vm.expectRevert();
        proxyAsITransparentUpgradeableProxy.admin();
        // case 2.5: revert to call upgradeToAndCall(address,bytes)
        vm.expectRevert();
        proxyAsITransparentUpgradeableProxy.upgradeToAndCall(
            address(_implementationNew),
            abi.encodeCall(_implementationNew.__Implementation_init, (4096))
        );

        // case 3: all non-admin calls will be delegated to the implementation
        // case 3.1: addI(uint) in ImplementationNew
        vm.expectEmit(address(proxyAsImplementationNew));
        emit IImplementation.ChangeStorageUint(2048 + 1);

        proxyAsImplementationNew.addI(1);
        // case 3.2: doIfAdmin(uint) in ImplementationNew
        vm.expectEmit(address(proxyAsImplementationNew));
        emit IImplementation.ChangeStorageUint(1);

        proxyAsImplementationNew.doIfAdmin(1);
    }
}