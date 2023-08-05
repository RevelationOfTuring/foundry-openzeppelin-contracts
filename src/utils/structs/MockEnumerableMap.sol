// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol";

contract MockBytes32ToBytes32Map {
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    EnumerableMap.Bytes32ToBytes32Map _bytes32ToBytes32Map;

    function set(bytes32 key, bytes32 value) external returns (bool) {
        return _bytes32ToBytes32Map.set(key, value);
    }

    function remove(bytes32 key) external returns (bool) {
        return _bytes32ToBytes32Map.remove(key);
    }

    function contains(bytes32 key) external view returns (bool) {
        return _bytes32ToBytes32Map.contains(key);
    }

    function length() external view returns (uint) {
        return _bytes32ToBytes32Map.length();
    }

    function at(uint index) external view returns (bytes32, bytes32) {
        return _bytes32ToBytes32Map.at(index);
    }

    function tryGet(bytes32 key) external view returns (bool, bytes32){
        return _bytes32ToBytes32Map.tryGet(key);
    }

    function get(bytes32 key) external view returns (bytes32) {
        return _bytes32ToBytes32Map.get(key);
    }

    function get(bytes32 key, string memory errorMessage) external view returns (bytes32) {
        return _bytes32ToBytes32Map.get(key, errorMessage);
    }
}

contract MockUintToUintMap {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    EnumerableMap.UintToUintMap _uintToUintMap;

    function set(uint key, uint value) external returns (bool) {
        return _uintToUintMap.set(key, value);
    }

    function remove(uint key) external returns (bool) {
        return _uintToUintMap.remove(key);
    }

    function contains(uint key) external view returns (bool) {
        return _uintToUintMap.contains(key);
    }

    function length() external view returns (uint) {
        return _uintToUintMap.length();
    }

    function at(uint index) external view returns (uint, uint) {
        return _uintToUintMap.at(index);
    }

    function tryGet(uint key) external view returns (bool, uint){
        return _uintToUintMap.tryGet(key);
    }

    function get(uint key) external view returns (uint) {
        return _uintToUintMap.get(key);
    }

    function get(uint key, string memory errorMessage) external view returns (uint) {
        return _uintToUintMap.get(key, errorMessage);
    }
}

contract MockUintToAddressMap {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    EnumerableMap.UintToAddressMap _uintToAddressMap;

    function set(uint key, address value) external returns (bool) {
        return _uintToAddressMap.set(key, value);
    }

    function remove(uint key) external returns (bool) {
        return _uintToAddressMap.remove(key);
    }

    function contains(uint key) external view returns (bool) {
        return _uintToAddressMap.contains(key);
    }

    function length() external view returns (uint) {
        return _uintToAddressMap.length();
    }

    function at(uint index) external view returns (uint, address) {
        return _uintToAddressMap.at(index);
    }

    function tryGet(uint key) external view returns (bool, address){
        return _uintToAddressMap.tryGet(key);
    }

    function get(uint key) external view returns (address) {
        return _uintToAddressMap.get(key);
    }

    function get(uint key, string memory errorMessage) external view returns (address) {
        return _uintToAddressMap.get(key, errorMessage);
    }
}

contract MockAddressToUintMap {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    EnumerableMap.AddressToUintMap _addressToUintMap;

    function set(address key, uint value) external returns (bool) {
        return _addressToUintMap.set(key, value);
    }

    function remove(address key) external returns (bool) {
        return _addressToUintMap.remove(key);
    }

    function contains(address key) external view returns (bool) {
        return _addressToUintMap.contains(key);
    }

    function length() external view returns (uint) {
        return _addressToUintMap.length();
    }

    function at(uint index) external view returns (address, uint) {
        return _addressToUintMap.at(index);
    }

    function tryGet(address key) external view returns (bool, uint){
        return _addressToUintMap.tryGet(key);
    }

    function get(address key) external view returns (uint) {
        return _addressToUintMap.get(key);
    }

    function get(address key, string memory errorMessage) external view returns (uint) {
        return _addressToUintMap.get(key, errorMessage);
    }
}

contract MockBytes32ToUintMap {
    using EnumerableMap for EnumerableMap.Bytes32ToUintMap;

    EnumerableMap.Bytes32ToUintMap _bytes32ToUintMap;

    function set(bytes32 key, uint value) external returns (bool) {
        return _bytes32ToUintMap.set(key, value);
    }

    function remove(bytes32 key) external returns (bool) {
        return _bytes32ToUintMap.remove(key);
    }

    function contains(bytes32 key) external view returns (bool) {
        return _bytes32ToUintMap.contains(key);
    }

    function length() external view returns (uint) {
        return _bytes32ToUintMap.length();
    }

    function at(uint index) external view returns (bytes32, uint) {
        return _bytes32ToUintMap.at(index);
    }

    function tryGet(bytes32 key) external view returns (bool, uint){
        return _bytes32ToUintMap.tryGet(key);
    }

    function get(bytes32 key) external view returns (uint) {
        return _bytes32ToUintMap.get(key);
    }

    function get(bytes32 key, string memory errorMessage) external view returns (uint) {
        return _bytes32ToUintMap.get(key, errorMessage);
    }
}
