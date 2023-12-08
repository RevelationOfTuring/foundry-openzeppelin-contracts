// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract MockERC20Capped is ERC20Capped {
    constructor(string memory name, string memory symbol, uint cap)
    ERC20(name, symbol)
    ERC20Capped(cap){}

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }
}
