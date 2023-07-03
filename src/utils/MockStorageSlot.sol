// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/StorageSlot.sol";

contract MockStorageSlot {
    using StorageSlot for bytes32;

    bytes32 public constant _ADDRESS_SLOT = keccak256("address slot");
    bytes32 public constant _BOOLEAN_SLOT = keccak256("boolean slot");
    bytes32 public constant _BYTES32_SLOT = keccak256("bytes32 slot");
    bytes32 public constant _UINT256_SLOT = keccak256("uint256 slot");

    uint public slot0 = 0;
    uint public slot1 = 10;
    uint public slot2 = 20;

    function setAddressSlot(address newAddr) external {
        _ADDRESS_SLOT.getAddressSlot().value = newAddr;
    }

    function getAddressSlot() external view returns (address){
        return _ADDRESS_SLOT.getAddressSlot().value;
    }

    function setBooleanSlot(bool newBool) external {
        _BOOLEAN_SLOT.getBooleanSlot().value = newBool;
    }

    function getBooleanSlot() external view returns (bool){
        return _BOOLEAN_SLOT.getBooleanSlot().value;
    }

    function setBytes32Slot(bytes32 newBytes32) external {
        _BYTES32_SLOT.getBytes32Slot().value = newBytes32;
    }

    function getBytes32Slot() external view returns (bytes32){
        return _BYTES32_SLOT.getBytes32Slot().value;
    }

    function setUint256Slot(uint newUint) external {
        _UINT256_SLOT.getUint256Slot().value = newUint;
    }

    function getUint256Slot() external view returns (uint){
        return _UINT256_SLOT.getUint256Slot().value;
    }

    function setUintValueBySlotNumber(bytes32 implementation, uint newUint) external {
        implementation.getUint256Slot().value = newUint;
    }

    function getUintValueBySlotNumber(bytes32 implementation) external view returns (uint){
        return implementation.getUint256Slot().value;
    }
}
