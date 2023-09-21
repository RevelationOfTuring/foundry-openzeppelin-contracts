// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract MockOwnable2Step is Ownable2Step {
    uint public i;

    function transferOwnershipInternal(address newOwner) external {
        _transferOwnership(newOwner);
    }

    function setI(uint value) external onlyOwner {
        i = value;
    }
}
