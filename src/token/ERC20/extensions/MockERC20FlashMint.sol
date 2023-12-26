// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract MockERC20FlashMint is ERC20FlashMint {
    bool private _customizedFlashFeeAndReceiver;

    constructor(
        string memory name,
        string memory symbol,
        address richer,
        uint totalSupply
    )
    ERC20(name, symbol)
    {
        _mint(richer, totalSupply);
    }

    function customizedFlashFeeAndReceiver() external {
        _customizedFlashFeeAndReceiver = true;
    }

    // customized flash fee 10% amount
    function _flashFee(address token, uint amount) internal view override returns (uint) {
        return _customizedFlashFeeAndReceiver ?
            amount / 10 : ERC20FlashMint._flashFee(token, amount);
    }

    // customized fee receiver address(1024)
    function _flashFeeReceiver() internal view override returns (address) {
        return _customizedFlashFeeAndReceiver ?
            address(1024) : ERC20FlashMint._flashFeeReceiver();
    }
}
