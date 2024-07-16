// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/utils/MockUUPSUpgradeable.sol";

import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UUPSUpgradeableTest is Test, IImplementation, IERC1967 {
    bytes32 private constant _IMPLEMENTATION_SLOT = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
    MockUUPSUpgradeable private _testing = new MockUUPSUpgradeable();
    MockUUPSUpgradeableNew private _implementationNew = new MockUUPSUpgradeableNew();
    MockUUPSUpgradeableWithWrongProxiableUUID private _implementationNewWithWrongProxiableUUID = new MockUUPSUpgradeableWithWrongProxiableUUID();
    MockUUPSUpgradeableWithRollbackTest private _implementationWithRollbackTest = new MockUUPSUpgradeableWithRollbackTest();
    MockUUPSUpgradeableWithRollbackTestNew private _implementationWithRollbackTestNew = new MockUUPSUpgradeableWithRollbackTestNew();

    function test_ProxiableUUID() external {
        assertEq(_testing.proxiableUUID(), _IMPLEMENTATION_SLOT);

        // revert with a delegatecall
        MockUUPSUpgradeable proxy = MockUUPSUpgradeable(address(new ERC1967Proxy(address(_testing), "")));
        vm.expectRevert("UUPSUpgradeable: must not be called through delegatecall");
        proxy.proxiableUUID();
    }

    function test_UpgradeTo() external {
        // case 1: pass
        // deploy proxy with a setup call
        address proxyAddress = address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (address(this)))
            )
        );

        MockUUPSUpgradeable proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(proxyAddress);
        // check setup call
        assertEq(proxyAsMockUUPSUpgradeable.owner(), address(this));
        // call on proxy
        uint newI = 1024;
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(0, newI);

        proxyAsMockUUPSUpgradeable.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeable.i(), newI);

        // upgrade to new implementation
        vm.expectEmit(proxyAddress);
        emit IERC1967.Upgraded(address(_implementationNew));

        proxyAsMockUUPSUpgradeable.upgradeTo(address(_implementationNew));
        MockUUPSUpgradeableNew proxyAsMockUUPSUpgradeableNew = MockUUPSUpgradeableNew(proxyAddress);
        // check storage
        assertEq(proxyAsMockUUPSUpgradeableNew.i(), newI);
        // call new logic
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(newI, newI);

        proxyAsMockUUPSUpgradeableNew.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableNew.i(), newI + newI);

        // case 2: revert if not pass {_authorizeUpgrade}
        address auth = address(1024);
        proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (auth))
            )
        ));

        vm.expectRevert("Ownable: caller is not the owner");
        proxyAsMockUUPSUpgradeable.upgradeTo(address(_implementationNew));

        // case 3: revert if the new implementation has an inconsistent proxiable uuid
        proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (address(this)))
            )
        ));

        vm.expectRevert("ERC1967Upgrade: unsupported proxiableUUID");
        proxyAsMockUUPSUpgradeable.upgradeTo(address(_implementationNewWithWrongProxiableUUID));

        // case 4: revert if the new implementation has no {proxiableUUID}
        vm.expectRevert("ERC1967Upgrade: new implementation is not UUPS");
        proxyAsMockUUPSUpgradeable.upgradeTo(address(this));

        // case 5: revert with no msg if the new implementation address is an EOA
        vm.expectRevert();
        proxyAsMockUUPSUpgradeable.upgradeTo(address(1024));

        // case 6: revert if call {upgradeTo} directly
        vm.expectRevert("Function must be called through delegatecall");
        _testing.upgradeTo(address(this));

        // case 7: revert if the context of delegatecall is not an active proxy
        vm.expectRevert("Function must be called through active proxy");
        Address.functionDelegateCall(
            address(_testing),
            abi.encodeCall(_testing.upgradeTo, (address(_implementationNew)))
        );
    }

    function test_UpgradeToAndCall() external {
        // case 1: pass
        // deploy proxy with a setup call
        address proxyAddress = address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (address(this)))
            )
        );

        MockUUPSUpgradeable proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(proxyAddress);
        assertEq(proxyAsMockUUPSUpgradeable.owner(), address(this));
        uint newI = 1024;
        proxyAsMockUUPSUpgradeable.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeable.i(), newI);

        // upgrade to new implementation with a setup call
        vm.expectEmit(proxyAddress);
        emit IERC1967.Upgraded(address(_implementationNew));
        emit IImplementation.StorageChanged(newI, newI);

        bytes memory data = abi.encodeCall(
            _implementationNew.setI,
            (newI)
        );
        proxyAsMockUUPSUpgradeable.upgradeToAndCall(
            address(_implementationNew),
            data
        );
        MockUUPSUpgradeableNew proxyAsMockUUPSUpgradeableNew = MockUUPSUpgradeableNew(proxyAddress);
        // check storage
        assertEq(proxyAsMockUUPSUpgradeableNew.i(), newI + newI);
        // call new logic
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(newI + newI, newI);

        proxyAsMockUUPSUpgradeableNew.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableNew.i(), newI + newI + newI);

        // case 2: revert if not pass {_authorizeUpgrade}
        address auth = address(1024);
        proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (auth))
            )
        ));

        vm.expectRevert("Ownable: caller is not the owner");
        proxyAsMockUUPSUpgradeable.upgradeToAndCall(
            address(_implementationNew),
            data
        );

        // case 3: revert if the new implementation has an inconsistent proxiable uuid
        proxyAsMockUUPSUpgradeable = MockUUPSUpgradeable(address(
            new ERC1967Proxy(
                address(_testing),
                abi.encodeCall(_testing.__Implementation_init, (address(this)))
            )
        ));

        vm.expectRevert("ERC1967Upgrade: unsupported proxiableUUID");
        proxyAsMockUUPSUpgradeable.upgradeToAndCall(
            address(_implementationNewWithWrongProxiableUUID),
            data
        );

        // case 4: revert if the new implementation has no {proxiableUUID}
        vm.expectRevert("ERC1967Upgrade: new implementation is not UUPS");
        proxyAsMockUUPSUpgradeable.upgradeToAndCall(
            address(this),
            data
        );

        // case 5: revert with no msg if the new implementation address is an EOA
        vm.expectRevert();
        proxyAsMockUUPSUpgradeable.upgradeToAndCall(
            address(1024),
            data
        );

        // case 6: revert if call {upgradeToAndCall} directly
        vm.expectRevert("Function must be called through delegatecall");
        _testing.upgradeToAndCall(
            address(this),
            data
        );

        // case 7: revert if the context of delegatecall is not an active proxy
        vm.expectRevert("Function must be called through active proxy");
        Address.functionDelegateCall(
            address(_testing),
            abi.encodeCall(
                _testing.upgradeToAndCall,
                (address(_implementationNew), data)
            )
        );
    }

    function test_UpgradeWithUUPSRollbackTest() external {
        // case 1: test {upgradeTo} with UUPS rollback test
        // deploy proxy with a setup call
        address proxyAddress = address(
            new ERC1967Proxy(
                address(_implementationWithRollbackTest),
                abi.encodeCall(_implementationWithRollbackTest.__Implementation_init, (address(this)))
            )
        );

        MockUUPSUpgradeableWithRollbackTest proxyAsMockUUPSUpgradeableWithRollbackTest = MockUUPSUpgradeableWithRollbackTest(proxyAddress);
        // check setup call
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTest.owner(), address(this));
        // call on proxy
        uint newI = 1024;
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(0, newI);

        proxyAsMockUUPSUpgradeableWithRollbackTest.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTest.i(), newI);

        // upgrade to new implementation
        vm.expectEmit(proxyAddress);
        emit IERC1967.Upgraded(address(_implementationWithRollbackTestNew));

        proxyAsMockUUPSUpgradeableWithRollbackTest.upgradeTo(address(_implementationWithRollbackTestNew));
        MockUUPSUpgradeableWithRollbackTestNew proxyAsMockUUPSUpgradeableWithRollbackTestNew = MockUUPSUpgradeableWithRollbackTestNew(proxyAddress);
        // check storage
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTestNew.i(), newI);
        // call new logic
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(newI, newI);

        proxyAsMockUUPSUpgradeableWithRollbackTestNew.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTestNew.i(), newI + newI);

        // case 2: test {upgradeToAndCall} with UUPS rollback test
        // deploy proxy with a setup call
        proxyAddress = address(
            new ERC1967Proxy(
                address(_implementationWithRollbackTest),
                abi.encodeCall(_implementationWithRollbackTest.__Implementation_init, (address(this)))
            )
        );

        proxyAsMockUUPSUpgradeableWithRollbackTest = MockUUPSUpgradeableWithRollbackTest(proxyAddress);
        // check setup call
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTest.owner(), address(this));
        // call on proxy
        newI = 1024;
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(0, newI);

        proxyAsMockUUPSUpgradeableWithRollbackTest.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTest.i(), newI);

        // upgrade to new implementation with a setup call
        vm.expectEmit(proxyAddress);
        emit IERC1967.Upgraded(address(_implementationWithRollbackTestNew));
        emit IImplementation.StorageChanged(newI, newI);

        proxyAsMockUUPSUpgradeableWithRollbackTest.upgradeToAndCall(
            address(_implementationWithRollbackTestNew),
            abi.encodeCall(
                _implementationWithRollbackTestNew.setI,
                (newI)
            )
        );
        proxyAsMockUUPSUpgradeableWithRollbackTestNew = MockUUPSUpgradeableWithRollbackTestNew(proxyAddress);
        // check storage
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTestNew.i(), newI + newI);
        // call new logic
        vm.expectEmit(proxyAddress);
        emit IImplementation.StorageChanged(newI + newI, newI);

        proxyAsMockUUPSUpgradeableWithRollbackTestNew.setI(newI);
        assertEq(proxyAsMockUUPSUpgradeableWithRollbackTestNew.i(), newI + newI + newI);
    }
}