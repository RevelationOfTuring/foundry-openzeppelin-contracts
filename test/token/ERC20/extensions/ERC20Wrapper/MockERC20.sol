// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol)
    ERC20(name, symbol) {}

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }
}

contract MockERC20WithDecimals {
    uint8 private _decimals;

    constructor(uint8 dec){
        _decimals = dec;
    }

    function decimals() external view returns (uint8){
        return _decimals;
    }
}

contract MockERC20WithoutDecimals {}
