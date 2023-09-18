// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MockOwnable is Ownable {
    uint public i;

    function checkOwner() external view {
        _checkOwner();
    }

    function transferOwnershipInternal(address newOwner) external {
        _transferOwnership(newOwner);
    }

    function setI(uint value) external onlyOwner {
        i = value;
    }
}
