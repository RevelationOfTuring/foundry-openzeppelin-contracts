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
    }

    // has the same selector with function `proxy71997(uint)` in proxy
    // NOTE: no one has access to this function
    // CAUTION: to explain why `ifAdmin` is deprecated
    function implementation49979() external {}

    function doIfAdmin(uint arg) external {
        emit ChangeStorageUint(arg);
    }
}

contract ImplementationNew is Implementation {
    // add a function
    function addI(uint i_) external {
        i += i_;
        emit ChangeStorageUint(i);
    }
}
