// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract MockBytes32Set {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set _bytes32Set;

    function add(bytes32 value) external returns (bool) {
        return _bytes32Set.add(value);
    }

    function remove(bytes32 value) external returns (bool){
        return _bytes32Set.remove(value);
    }

    function contains(bytes32 value) external view returns (bool) {
        return _bytes32Set.contains(value);
    }

    function length() external view returns (uint) {
        return _bytes32Set.length();
    }

    function at(uint index) external view returns (bytes32){
        return _bytes32Set.at(index);
    }

    function values() external view returns (bytes32[] memory){
        return _bytes32Set.values();
    }
}

contract MockAddressSet {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet _addressSet;

    function add(address value) external returns (bool) {
        return _addressSet.add(value);
    }

    function remove(address value) external returns (bool){
        return _addressSet.remove(value);
    }

    function contains(address value) external view returns (bool) {
        return _addressSet.contains(value);
    }

    function length() external view returns (uint) {
        return _addressSet.length();
    }

    function at(uint index) external view returns (address){
        return _addressSet.at(index);
    }

    function values() external view returns (address[] memory){
        return _addressSet.values();
    }
}

contract MockUintSet {
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet _uintSet;

    function add(uint value) external returns (bool) {
        return _uintSet.add(value);
    }

    function remove(uint value) external returns (bool){
        return _uintSet.remove(value);
    }

    function contains(uint value) external view returns (bool) {
        return _uintSet.contains(value);
    }

    function length() external view returns (uint) {
        return _uintSet.length();
    }

    function at(uint index) external view returns (uint){
        return _uintSet.at(index);
    }

    function values() external view returns (uint[] memory){
        return _uintSet.values();
    }
}
