// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./Implementation.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC1967.sol";

contract BeaconProxyTest is Test, IERC1967, IImplementation {
    Implementation private _implementation = new Implementation();
    UpgradeableBeacon private _testing = new UpgradeableBeacon(address(_implementation));
    ImplementationNew private _implementationNew = new ImplementationNew();

    function test_Constructor() external {
        assertEq(_testing.owner(), address(this));
    }

    function test_UpgradeToAndImplementation() external {
        // test for implementation()
        assertEq(_testing.implementation(), address(_implementation));

        // deploy beacon proxies
        BeaconProxy beaconProxy1 = new BeaconProxy(
            address(_testing),
            abi.encodeCall(
                Implementation.__Implementation_init,
                (1024)
            )
        );

        BeaconProxy beaconProxy2 = new BeaconProxy(
            address(_testing),
            abi.encodeCall(
                Implementation.__Implementation_init,
                (2048)
            )
        );

        // check beacon proxies
        assertEq(Implementation(address(beaconProxy1)).i(), 1024);
        assertEq(Implementation(address(beaconProxy2)).i(), 2048);
        // no function addI()
        vm.expectRevert();
        ImplementationNew(address(beaconProxy1)).addI(1);
        vm.expectRevert();
        ImplementationNew(address(beaconProxy2)).addI(1);

        // test for upgradeTo()
        vm.expectEmit();
        emit IERC1967.Upgraded(address(_implementationNew));

        _testing.upgradeTo(address(_implementationNew));
        assertEq(_testing.implementation(), address(_implementationNew));

        // check the upgrade for beacon proxy
        uint i = 4096;
        // function addI() is available for beaconProxy1
        vm.expectEmit(address(beaconProxy1));
        emit IImplementation.ChangeStorageUint(i);

        ImplementationNew(address(beaconProxy1)).addI(i);
        assertEq(ImplementationNew(address(beaconProxy1)).i(), 1024 + i);
        // function addI() is available for beaconProxy2
        vm.expectEmit(address(beaconProxy2));
        emit IImplementation.ChangeStorageUint(i);

        ImplementationNew(address(beaconProxy2)).addI(i);
        assertEq(ImplementationNew(address(beaconProxy2)).i(), 2048 + i);
    }
}