// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract MockERC20Permit is ERC20Permit {
    constructor(string memory name, string memory symbol)
    ERC20(name, symbol)
    ERC20Permit(name){}
}
