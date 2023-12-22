// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract MockERC20Pausable is ERC20Pausable {
    constructor(string memory name, string memory symbol)
    ERC20(name, symbol)
    Pausable(){}

    function pause() external {
        _pause();
    }

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint amount) external {
        _burn(account, amount);
    }
}
