// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/ERC1967/MockERC1967Upgrade.sol";
import "./Implement.sol";
import "./Beacon.sol";

contract ERC1967UpgradeTest is Test, IERC1967, IImplement {
    MockERC1967Upgrade private _testing = new MockERC1967Upgrade();
    Implement private _implement = new Implement();

    function test_GetImplementationAndUpgradeTo() external {
        assertEq(_testing.getImplementation(), address(0));
        address newImplementationAddress = address(_implement);
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);

        _testing.upgradeTo(newImplementationAddress);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeTo(address(1024));
    }

    function test_UpgradeToAndCall() external {
        assertEq(_testing.getImplementation(), address(0));
        address newImplementationAddress = address(_implement);
        // case 1: no call
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);

        _testing.upgradeToAndCall(newImplementationAddress, '', false);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeToAndCall(address(1024), '', false);

        // case 2: call with no argument
        newImplementationAddress = address(new Implement());
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithoutArgs();

        bytes memory data = abi.encodeCall(_implement.initialCallWithoutArgs, ());
        _testing.upgradeToAndCall(newImplementationAddress, data, false);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeToAndCall(address(1024), data, false);

        // case 3: call with arguments
        newImplementationAddress = address(new Implement());
        uint arg1 = 1024;
        address arg2 = address(1024);
        string memory arg3 = "1024";
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithArgs(arg1, arg2, arg3);

        data = abi.encodeCall(
            _implement.initialCallWithArgs,
            (arg1, arg2, arg3)
        );
        _testing.upgradeToAndCall(newImplementationAddress, data, false);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeToAndCall(address(1024), data, false);

        // case 4: with forceCall and no data
        // NOTE: force call to the receive function of Implement
        newImplementationAddress = address(new Implement());
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Receive();

        _testing.upgradeToAndCall(newImplementationAddress, '', true);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeToAndCall(address(1024), '', true);

        // case 5: with forceCall and data
        // NOTE: it will enter the fallback function of Implement with non-selector data
        newImplementationAddress = address(new Implement());
        data = 'unknown';
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementationAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Fallback(data);

        _testing.upgradeToAndCall(newImplementationAddress, data, true);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // revert if new implementation address is not a contract
        vm.expectRevert("ERC1967: new implementation is not a contract");
        _testing.upgradeToAndCall(address(1024), data, true);
    }

    function test_UpgradeToAndCallUUPS() external {
        assertEq(_testing.getImplementation(), address(0));
        address newImplementationAddress = address(_implement);

        // case 1: in rollback test
        // NOTE: only change implementation address no matter what the data and forceCall arguments are
        _testing.setRollbackSlot(true);
        _testing.upgradeToAndCallUUPS(newImplementationAddress, '', false);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        newImplementationAddress = address(new Implement());
        _testing.upgradeToAndCallUUPS(newImplementationAddress, '1024', false);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        newImplementationAddress = address(new Implement());
        _testing.upgradeToAndCallUUPS(newImplementationAddress, '', true);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        newImplementationAddress = address(new Implement());
        _testing.upgradeToAndCallUUPS(newImplementationAddress, '1024', true);
        assertEq(_testing.getImplementation(), newImplementationAddress);

        // case 2: out of rollback test
        _testing.setRollbackSlot(false);

        // case 2.1: with supported proxiableUUID
        bytes32 proxiableUUID = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

        // case 2.1.1: no call
        address payable newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementERC1822ProxiableAddress);

        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, '', false);
        assertEq(_testing.getImplementation(), newImplementERC1822ProxiableAddress);

        // case 2.1.2: call with no argument
        newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementERC1822ProxiableAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithoutArgs();

        bytes memory data = abi.encodeCall(
            ImplementERC1822Proxiable(newImplementERC1822ProxiableAddress).initialCallWithoutArgs,
            ()
        );
        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, data, false);
        assertEq(_testing.getImplementation(), newImplementERC1822ProxiableAddress);

        // case 2.1.3: call with arguments
        newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));
        uint arg1 = 1024;
        address arg2 = address(1024);
        string memory arg3 = "1024";
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementERC1822ProxiableAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithArgs(arg1, arg2, arg3);

        data = abi.encodeCall(
            ImplementERC1822Proxiable(newImplementERC1822ProxiableAddress).initialCallWithArgs,
            (arg1, arg2, arg3)
        );
        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, data, false);
        assertEq(_testing.getImplementation(), newImplementERC1822ProxiableAddress);

        // case 2.1.4: with forceCall and no data
        // NOTE: force call to the receive function of Implement
        newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementERC1822ProxiableAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Receive();

        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, '', true);
        assertEq(_testing.getImplementation(), newImplementERC1822ProxiableAddress);

        // case 2.1.5: with forceCall and data
        // NOTE: it will enter the fallback function of Implement with non-selector data
        newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));
        data = 'unknown';
        vm.expectEmit(address(_testing));
        emit IERC1967.Upgraded(newImplementERC1822ProxiableAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Fallback(data);

        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, data, true);
        assertEq(_testing.getImplementation(), newImplementERC1822ProxiableAddress);

        // case 2.2: revert with unsupported proxiableUUID
        proxiableUUID = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 2);
        newImplementERC1822ProxiableAddress = payable(address(new ImplementERC1822Proxiable(proxiableUUID)));

        vm.expectRevert("ERC1967Upgrade: unsupported proxiableUUID");
        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, '', false);

        // case 2.3: revert if the new implementation was a non-ERC1822 compliant
        proxiableUUID = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
        newImplementERC1822ProxiableAddress = payable(address(new Implement()));
        vm.expectRevert("ERC1967Upgrade: new implementation is not UUPS");
        _testing.upgradeToAndCallUUPS(newImplementERC1822ProxiableAddress, '', false);

        // case 2.4: revert without msg if the new implementation address is not a contract
        vm.expectRevert();
        _testing.upgradeToAndCallUUPS(address(1024), '', false);
    }

    function test_GetAdminAndChangeAdmin() external {
        address currentAdmin = address(0);
        assertEq(_testing.getAdmin(), currentAdmin);
        address newAdminAddress = address(1024);
        vm.expectEmit(address(_testing));
        emit IERC1967.AdminChanged(currentAdmin, newAdminAddress);

        _testing.changeAdmin(newAdminAddress);
        assertEq(_testing.getAdmin(), newAdminAddress);
    }

    function test_GetBeaconAndUpgradeBeaconToAndCall() external {
        assertEq(_testing.getBeacon(), address(0));

        // case 1: no call
        address newBeaconAddress = address(new Beacon(address(_implement)));
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(newBeaconAddress);

        _testing.upgradeBeaconToAndCall(newBeaconAddress, '', false);
        assertEq(_testing.getBeacon(), newBeaconAddress);

        // case 2: call with no argument
        newBeaconAddress = address(new Beacon(address(_implement)));
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(newBeaconAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithoutArgs();

        bytes memory data = abi.encodeCall(
            _implement.initialCallWithoutArgs,
            ()
        );
        _testing.upgradeBeaconToAndCall(newBeaconAddress, data, false);
        assertEq(_testing.getBeacon(), newBeaconAddress);

        // case 3: call with arguments
        newBeaconAddress = address(new Beacon(address(_implement)));
        uint arg1 = 1024;
        address arg2 = address(1024);
        string memory arg3 = "1024";
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(newBeaconAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.InitialCallWithArgs(arg1, arg2, arg3);

        data = abi.encodeCall(
            _implement.initialCallWithArgs,
            (arg1, arg2, arg3)
        );
        _testing.upgradeBeaconToAndCall(newBeaconAddress, data, false);
        assertEq(_testing.getBeacon(), newBeaconAddress);

        // case 4: with forceCall and no data
        // NOTE: force call to the receive function of Implement
        newBeaconAddress = address(new Beacon(address(_implement)));
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(newBeaconAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Receive();

        _testing.upgradeBeaconToAndCall(newBeaconAddress, '', true);
        assertEq(_testing.getBeacon(), newBeaconAddress);

        // case 5: with forceCall and data
        // NOTE: it will enter the fallback function of Implement with non-selector data
        newBeaconAddress = address(new Beacon(address(_implement)));
        data = 'unknown';
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(newBeaconAddress);
        vm.expectEmit(address(_testing));
        emit IImplement.Fallback(data);

        _testing.upgradeBeaconToAndCall(newBeaconAddress, data, true);
        assertEq(_testing.getBeacon(), newBeaconAddress);

        // revert if new beacon address is not a contract
        vm.expectRevert("ERC1967: new beacon is not a contract");
        _testing.upgradeBeaconToAndCall(address(1024), '', false);

        // revert if the implementation address in the new beacon is not a contract
        newBeaconAddress = address(new Beacon(address(1024)));
        vm.expectRevert("ERC1967: beacon implementation is not a contract");
        _testing.upgradeBeaconToAndCall(newBeaconAddress, '', false);
    }
}