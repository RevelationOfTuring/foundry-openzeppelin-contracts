// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Address.sol";

contract MockAddress {
    using Address for address;
    using Address for address payable;

    uint public slot0;
    address public slot1;

    function isContract(address target) external view returns (bool){
        return target.isContract();
    }

    function sendValue(address payable recipient, uint amount) external {
        recipient.sendValue(amount);
    }

    function functionCall(address target, bytes memory data) external returns (bytes memory){
        return target.functionCall(data);
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory) {
        return target.functionCall(data, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value
    ) external returns (bytes memory){
        return target.functionCallWithValue(data, value);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint value,
        string memory errorMessage
    ) external returns (bytes memory){
        return target.functionCallWithValue(data, value, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) external view returns (bytes memory){
        return target.functionStaticCall(data);
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external view returns (bytes memory) {
        return target.functionStaticCall(data, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) external returns (bytes memory) {
        return target.functionDelegateCall(data);
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) external returns (bytes memory){
        return target.functionDelegateCall(data, errorMessage);
    }
}
