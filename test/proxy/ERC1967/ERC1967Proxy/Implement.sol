// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IImplement {
    event Initialize(address);
    event Receive();
    event Fallback(bytes);
}

contract Implement is IImplement {
    uint public i;
    address public addr;

    function initialize(uint i_, address addr_) external {
        i = i_;
        addr = addr_;
        emit Initialize(msg.sender);
    }

    receive() external payable {
        emit Receive();
    }

    fallback() external {
        emit Fallback(msg.data);
    }
}