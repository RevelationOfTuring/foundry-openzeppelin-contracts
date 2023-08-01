// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/structs/DoubleEndedQueue.sol";

contract MockDoubleEndedQueue {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    DoubleEndedQueue.Bytes32Deque _deque;

    function pushBack(bytes32 value) external {
        _deque.pushBack(value);
    }

    function popBack() external returns (bytes32){
        return _deque.popBack();
    }

    function pushFront(bytes32 value) external {
        _deque.pushFront(value);
    }

    function popFront() external returns (bytes32) {
        return _deque.popFront();
    }

    function front() external view returns (bytes32){
        return _deque.front();
    }

    function back() external view returns (bytes32){
        return _deque.back();
    }

    function at(uint index) external view returns (bytes32){
        return _deque.at(index);
    }

    function clear() external {
        _deque.clear();
    }

    function length() external view returns (uint){
        return _deque.length();
    }

    function empty() external view returns (bool){
        return _deque.empty();
    }
}
