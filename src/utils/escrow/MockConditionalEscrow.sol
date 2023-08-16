// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/escrow/ConditionalEscrow.sol";

contract MockConditionalEscrow is ConditionalEscrow {

    mapping(address => uint) _latestDepositBlockNumber;

    function deposit(address payee) public payable override {
        _latestDepositBlockNumber[payee] = block.number;
        super.deposit(payee);
    }

    function withdrawalAllowed(address payee) public view override returns (bool){
        return block.number - _latestDepositBlockNumber[payee] >= 1000;
    }
}
