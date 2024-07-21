// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./Implementation.sol";

import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract ProxyAdminTest is Test, IERC1967, IImplementation {
    ProxyAdmin private _testing = new ProxyAdmin();
    Implementation private _implementation1 = new Implementation();
    Implementation private _implementation2 = new Implementation();
    TransparentUpgradeableProxy private _transparentUpgradeableProxy1 = new TransparentUpgradeableProxy(
        address(_implementation1),
        address(_testing),
        abi.encodeCall(
            _implementation1.__Implementation_init,
            (1024)
        )
    );
    TransparentUpgradeableProxy private _transparentUpgradeableProxy2 = new TransparentUpgradeableProxy(
        address(_implementation2),
        address(_testing),
        abi.encodeCall(
            _implementation2.__Implementation_init,
            (2048)
        )
    );
    ImplementationNew private _implementationNew = new ImplementationNew();


    function test_GetProxyImplementation() external {
        assertEq(
            _testing.getProxyImplementation(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1))
            ),
            address(_implementation1)
        );
        assertEq(
            _testing.getProxyImplementation(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2))
            ),
            address(_implementation2)
        );
    }

    function test_GetProxyAdminAndChangeProxyAdmin() external {
        assertEq(
            _testing.getProxyAdmin(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1))
            ),
            address(_testing)
        );
        assertEq(
            _testing.getProxyAdmin(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2))
            ),
            address(_testing)
        );

        // deploy another ProxyAdmin
        ProxyAdmin newProxyAdmin = new ProxyAdmin();
        // test changeProxyAdmin(ITransparentUpgradeableProxy,address)
        vm.expectEmit(address(_transparentUpgradeableProxy1));
        emit IERC1967.AdminChanged(address(_testing), address(newProxyAdmin));

        _testing.changeProxyAdmin(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1)), address(newProxyAdmin));

        vm.expectEmit(address(_transparentUpgradeableProxy2));
        emit IERC1967.AdminChanged(address(_testing), address(newProxyAdmin));

        _testing.changeProxyAdmin(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2)), address(newProxyAdmin));

        assertEq(
            newProxyAdmin.getProxyAdmin(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1))
            ),
            address(newProxyAdmin)
        );
        assertEq(
            newProxyAdmin.getProxyAdmin(
                ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2))
            ),
            address(newProxyAdmin)
        );

        // revert if not owner calls
        assertEq(newProxyAdmin.owner(), address(this));
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        newProxyAdmin.changeProxyAdmin(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1)),
            address(1)
        );
    }

    function test_Upgrade() external {
        // upgrade one transparent upgradeable proxy
        vm.expectEmit(address(_transparentUpgradeableProxy1));
        emit IERC1967.Upgraded(address(_implementationNew));

        _testing.upgrade(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1)),
            address(_implementationNew)
        );

        // check the result of upgrade
        assertEq(
            _testing.getProxyImplementation(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1))),
            address(_implementationNew)
        );

        ImplementationNew transparentUpgradeableProxy1AsNew = ImplementationNew(address(_transparentUpgradeableProxy1));
        assertEq(transparentUpgradeableProxy1AsNew.i(), 1024);
        vm.expectEmit(address(transparentUpgradeableProxy1AsNew));
        emit IImplementation.ChangeStorageUint(1024 + 1, 0);

        transparentUpgradeableProxy1AsNew.addI(1);
        assertEq(transparentUpgradeableProxy1AsNew.i(), 1024 + 1);

        // upgrade another transparent upgradeable proxy
        vm.expectEmit(address(_transparentUpgradeableProxy2));
        emit IERC1967.Upgraded(address(_implementationNew));

        _testing.upgrade(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2)),
            address(_implementationNew)
        );

        // check the result of upgrade
        assertEq(
            _testing.getProxyImplementation(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2))),
            address(_implementationNew)
        );

        ImplementationNew transparentUpgradeableProxy2AsNew = ImplementationNew(address(_transparentUpgradeableProxy2));
        assertEq(transparentUpgradeableProxy2AsNew.i(), 2048);
        vm.expectEmit(address(transparentUpgradeableProxy2AsNew));
        emit IImplementation.ChangeStorageUint(2048 + 2, 0);

        transparentUpgradeableProxy2AsNew.addI(2);
        assertEq(transparentUpgradeableProxy2AsNew.i(), 2048 + 2);

        // revert if not owner calls
        assertEq(_testing.owner(), address(this));
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        _testing.upgrade(
            ITransparentUpgradeableProxy(address(transparentUpgradeableProxy1AsNew)),
            address(_implementationNew)
        );
    }

    function test_UpgradeAndCall() external {
        // upgrade one transparent upgradeable proxy and delegatecall the added function in new implementation
        uint ethValue = 1024;
        vm.expectEmit(address(_transparentUpgradeableProxy1));
        emit IERC1967.Upgraded(address(_implementationNew));
        vm.expectEmit(address(_transparentUpgradeableProxy1));
        emit IImplementation.ChangeStorageUint(1024 + 1, ethValue);

        _testing.upgradeAndCall{value: ethValue}(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1)),
            address(_implementationNew),
            abi.encodeCall(
                _implementationNew.addI,
                (1)
            )
        );

        // check the result of upgrade
        assertEq(
            _testing.getProxyImplementation(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1))),
            address(_implementationNew)
        );

        assertEq(ImplementationNew(address(_transparentUpgradeableProxy1)).i(), 1024 + 1);
        assertEq(address(_transparentUpgradeableProxy1).balance, ethValue);

        // upgrade another transparent upgradeable proxy and delegatecall the added function in new implementation
        vm.expectEmit(address(_transparentUpgradeableProxy2));
        emit IERC1967.Upgraded(address(_implementationNew));
        vm.expectEmit(address(_transparentUpgradeableProxy2));
        emit IImplementation.ChangeStorageUint(2048 + 2, ethValue);

        _testing.upgradeAndCall{value: ethValue}(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2)),
            address(_implementationNew),
            abi.encodeCall(
                _implementationNew.addI,
                (2)
            )
        );

        // check the result of upgrade
        assertEq(
            _testing.getProxyImplementation(ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy2))),
            address(_implementationNew)
        );

        assertEq(ImplementationNew(address(_transparentUpgradeableProxy2)).i(), 2048 + 2);
        assertEq(address(_transparentUpgradeableProxy2).balance, ethValue);

        // revert if not owner calls
        assertEq(_testing.owner(), address(this));
        address nonOwner = address(1);
        vm.deal(nonOwner, ethValue);
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");

        _testing.upgradeAndCall{value: ethValue}(
            ITransparentUpgradeableProxy(address(_transparentUpgradeableProxy1)),
            address(_implementationNew),
            abi.encodeCall(
                _implementationNew.addI,
                (1)
            )
        );
    }
}