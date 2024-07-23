// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/beacon/BeaconProxy/MockBeaconProxy.sol";
import "./Implementation.sol";
import "./Beacon.sol";

contract BeaconProxyTest is Test, IERC1967, IImplementation {
    Implementation private _implementation = new Implementation();
    Beacon private _beacon = new Beacon(address(_implementation));
    MockBeaconProxy private _testing = new MockBeaconProxy(
        address(_beacon),
        abi.encodeCall(
            _implementation.__Implementation_init,
            (1024)
        )
    );

    function test_ConstructorWithEmptyData() external {
        vm.expectEmit();
        emit IERC1967.BeaconUpgraded(address(_beacon));

        _testing = new MockBeaconProxy(address(_beacon), "");
        assertEq(Implementation(address(_testing)).i(), 0);

        // revert if beacon is not an contract
        vm.expectRevert("ERC1967: new beacon is not a contract");
        new MockBeaconProxy(address(1024), "");

        // revert if implementation is not an contract
        _beacon = new Beacon(address(1024));
        vm.expectRevert("ERC1967: beacon implementation is not a contract");
        new MockBeaconProxy(address(_beacon), "");

        // revert if beacon isn't an IBeacon contract
        vm.expectRevert();
        new MockBeaconProxy(address(this), "");
    }

    function test_ConstructorWithData() external {
        uint ethValue = 1024;
        bytes memory data = abi.encodeCall(
            _implementation.addI,
            (2048)
        );

        vm.expectEmit();
        emit IERC1967.BeaconUpgraded(address(_beacon));
        vm.expectEmit();
        emit IImplementation.ChangeStorageUint(2048, ethValue);

        _testing = new MockBeaconProxy{value: ethValue}(
            address(_beacon),
            data
        );
        assertEq(Implementation(address(_testing)).i(), 2048);
        assertEq(address(_testing).balance, ethValue);

        // revert if beacon is not an contract
        vm.expectRevert("ERC1967: new beacon is not a contract");
        new MockBeaconProxy{value: ethValue}(
            address(1024),
            data
        );

        // revert if implementation is not an contract
        _beacon = new Beacon(address(1024));
        vm.expectRevert("ERC1967: beacon implementation is not a contract");
        new MockBeaconProxy{value: ethValue}(
            address(_beacon),
            data
        );

        // revert if beacon isn't an IBeacon contract
        vm.expectRevert();
        new MockBeaconProxy{value: ethValue}(
            address(this),
            data
        );
    }

    function test_Implementation() external {
        assertEq(_testing.implementation(), _beacon.implementation());
        assertEq(_testing.implementation(), address(_implementation));
    }

    function test_Beacon() external {
        assertEq(_testing.beacon(), address(_beacon));
    }

    function test_SetBeacon() external {
        Implementation proxyAsImplementation = Implementation(address(_testing));
        assertEq(proxyAsImplementation.i(), 1024);

        Implementation newImplementation = new Implementation();
        Beacon newBeacon = new Beacon(address(newImplementation));

        // case 1: with empty data
        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(address(newBeacon));

        _testing.setBeacon(address(newBeacon), "");
        // check
        assertEq(proxyAsImplementation.i(), 1024);
        assertEq(_testing.beacon(), address(newBeacon));
        assertEq(_testing.implementation(), newBeacon.implementation());
        assertEq(_testing.implementation(), address(newImplementation));

        // case 2: with data
        uint ethValue = 1024;
        assertEq(address(_testing).balance, 0);

        vm.expectEmit(address(_testing));
        emit IERC1967.BeaconUpgraded(address(_beacon));
        vm.expectEmit(address(_testing));
        emit IImplementation.ChangeStorageUint(1024 + 2048, ethValue);

        _testing.setBeacon{value: ethValue}(
            address(_beacon),
            abi.encodeCall(
                _implementation.addI,
                (2048)
            )
        );
        // check
        assertEq(proxyAsImplementation.i(), 1024 + 2048);
        assertEq(_testing.beacon(), address(_beacon));
        assertEq(_testing.implementation(), _beacon.implementation());
        assertEq(_testing.implementation(), address(_implementation));
        assertEq(address(_testing).balance, ethValue);

        // case 3: revert if beacon is not an contract
        vm.expectRevert("ERC1967: new beacon is not a contract");
        _testing.setBeacon(
            address(1024),
            ""
        );

        // case 4: revert if implementation is not an contract
        newBeacon = new Beacon(address(1024));
        vm.expectRevert("ERC1967: beacon implementation is not a contract");
        _testing.setBeacon(
            address(newBeacon),
            ""
        );

        // case 5: revert if beacon isn't an IBeacon contract
        vm.expectRevert();
        _testing.setBeacon(
            address(this),
            ""
        );
    }
}