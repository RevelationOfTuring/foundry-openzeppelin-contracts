// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/beacon/IBeacon.sol";

contract Beacon is IBeacon {
    address public implementation;

    constructor(address newImplementation){
        implementation = newImplementation;
    }
}