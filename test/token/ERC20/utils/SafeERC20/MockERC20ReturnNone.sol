// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MockERC20ReturnNone {
    // avoid compiling warnings
    uint private _slotValue;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address to, uint amount) external {
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint amount) external {
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external {
        emit Transfer(from, to, amount);
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