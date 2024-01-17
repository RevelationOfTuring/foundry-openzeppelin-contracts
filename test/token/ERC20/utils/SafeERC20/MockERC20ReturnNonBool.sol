// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MockERC20ReturnNonBool {
    // avoid compiling warnings
    uint private _slotValue;

    function transfer(address, uint) external returns (address){
        _slotValue = 1024;
        // neither 0 nor 1
        return address(2);
    }

    function approve(address, uint) external returns (uint){
        _slotValue = 1024;
        // neither 0 nor 1
        return 2;
    }

    function transferFrom(
        address,
        address,
        uint
    ) external returns (string memory){
        _slotValue = 1024;
        return "MockERC20ReturnNonBool: transferFrom";
    }

    function allowance(address, address spender) external view returns (uint){
        if (spender == address(1024)) {
            // return non-zero
            return _slotValue + 1;
        }

        return 0;
    }

    function totalSupply() external view returns (uint){
        return _slotValue;
    }

    function balanceOf(address) external view returns (uint){
        return _slotValue;
    }
}