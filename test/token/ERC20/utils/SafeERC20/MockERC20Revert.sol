// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MockERC20Revert is IERC20 {
    address private constant _REVERT_FLAG = address(1024);
    // avoid compiling warnings
    uint private _slotValue;

    function transfer(address to, uint amount) external returns (bool){
        require(to != _REVERT_FLAG, "MockERC20ReturnRevert: transfer");
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool){
        require(spender != _REVERT_FLAG, "MockERC20ReturnRevert: approve");
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool){
        emit Transfer(from, to, amount);
        require(from != _REVERT_FLAG, "MockERC20ReturnRevert: transferFrom");
        return true;
    }

    function allowance(address, address) external view returns (uint){
        return _slotValue + 1;
    }

    function totalSupply() external view returns (uint){
        return _slotValue;
    }

    function balanceOf(address) external view returns (uint){
        return _slotValue;
    }
}