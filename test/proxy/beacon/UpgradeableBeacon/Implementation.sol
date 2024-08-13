// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IImplementation {
    event ChangeStorageUint(uint);
}

contract Implementation is IImplementation {
    // storage
    uint public i;

    function __Implementation_init(uint i_) external {
        i = i_;
        emit ChangeStorageUint(i_);
    }
}

contract ImplementationNew is Implementation {
    // add a function
    function addI(uint i_) external {
        i += i_;
        emit ChangeStorageUint(i_);
    }
}
