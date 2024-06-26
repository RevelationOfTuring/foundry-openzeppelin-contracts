// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/Clones.sol";

contract MockClones {
    using Clones for address;

    function clone(address implementation) external returns (address) {
        return implementation.clone();
    }

    function cloneDeterministic(address implementation, bytes32 salt) external returns (address) {
        return implementation.cloneDeterministic(salt);
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) external pure returns (address){
        return implementation.predictDeterministicAddress(salt, deployer);
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) external view returns (address){
        return implementation.predictDeterministicAddress(salt);
    }
}
