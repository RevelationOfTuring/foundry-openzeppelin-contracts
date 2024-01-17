// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MockERC20ReturnFalse is IERC20 {
    // avoid compiling warnings
    uint private _slotValue;

    function transfer(address to, uint amount) external returns (bool){
        emit Transfer(msg.sender, to, amount);
        return false;
    }

    function approve(address spender, uint amount) external returns (bool){
        emit Approval(msg.sender, spender, amount);
        return false;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool){
        emit Transfer(from, to, amount);
        return false;
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