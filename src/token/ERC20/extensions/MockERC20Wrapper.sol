// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

contract MockERC20Wrapper is ERC20Wrapper {
    constructor(
        string memory name,
        string memory symbol,
        IERC20 underlyingToken
    )
    ERC20Wrapper(underlyingToken)
    ERC20(name, symbol)
    {}

    function recover(address account) external {
        _recover(account);
    }
}
