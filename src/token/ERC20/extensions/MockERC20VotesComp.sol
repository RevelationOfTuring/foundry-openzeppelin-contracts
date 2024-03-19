// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20VotesComp.sol";

contract MockERC20VotesComp is ERC20VotesComp {
    constructor(
        string memory name,
        string memory symbol
    )
    ERC20Permit(name)
    ERC20(name, symbol)
    {}

    function maxSupply() external view returns (uint224){
        return _maxSupply();
    }

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }
}
