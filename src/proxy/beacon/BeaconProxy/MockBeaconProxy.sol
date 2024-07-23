// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";

contract MockBeaconProxy is BeaconProxy {

    constructor(address beacon_, bytes memory data) payable
    BeaconProxy(beacon_, data)
    {}

    function beacon() external view returns (address) {
        return _beacon();
    }

    function implementation() external view returns (address) {
        return _implementation();
    }

    // deprecated
    function setBeacon(address beacon_, bytes memory data) external payable {
        _setBeacon(beacon_, data);
    }
}
