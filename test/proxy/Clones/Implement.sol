// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Implement {
    uint public i;
    address public addr;
    uint[3] public fixedArray;
    uint[] public dynamicArray;
    mapping(uint => uint) public map;

    event ImplementReceive(uint value);
    event ImplementFallback(uint value);

    function setUint(uint target) external {
        i = target;
    }

    function setUintPayable(uint target) external payable {
        i = target;
    }

    function setAddress(address target) external {
        addr = target;
    }

    function setAddressPayable(address target) external payable {
        addr = target;
    }

    function setFixedArray(uint[3] memory target) external {
        fixedArray = target;
    }

    function setFixedArrayPayable(uint[3] memory target) external payable {
        fixedArray = target;
    }

    function setDynamicArray(uint[] memory target) external {
        dynamicArray = target;
    }

    function setDynamicArrayPayable(uint[] memory target) external payable {
        dynamicArray = target;
    }

    function setMapping(uint key, uint value) external {
        map[key] = value;
    }

    function setMappingPayable(uint key, uint value) external payable {
        map[key] = value;
    }

    function triggerRevert() external pure {
        revert("Implement: revert");
    }

    function triggerRevertPayable() external payable {
        revert("Implement: revert");
    }

    function getPure() external pure returns (string memory){
        return "pure return value";
    }

    receive() external payable {
        emit ImplementReceive(msg.value);
    }

    fallback() external payable {
        emit ImplementFallback(msg.value);
    }
}