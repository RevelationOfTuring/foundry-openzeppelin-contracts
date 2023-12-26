// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/interfaces/IERC3156FlashBorrower.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ERC3156FlashBorrower is IERC3156FlashBorrower {
    bytes32 private constant _RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");

    bool private _enableApprove;
    bool private _enableValidReturnValue;

    event ParamsIn(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes data
    );

    event Monitor(
        address owner,
        uint balance,
        uint totalSupply
    );

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){
        IERC20 erc20Token = IERC20(token);
        // show the params input
        emit ParamsIn(
            initiator,
            token,
            amount,
            fee,
            data
        );

        // show the token status during IERC3156FlashBorrower.onFlashLoan()
        emit Monitor(
            address(this),
            erc20Token.balanceOf(address(this)),
            erc20Token.totalSupply()
        );

        if (data.length != 0) {
            (bool ok,) = token.call(data);
            require(ok, "fail to call");
        }

        if (_enableApprove) {
            erc20Token.approve(token, amount + fee);
        }

        return _enableValidReturnValue ? _RETURN_VALUE : bytes32(0);
    }

    function flipApprove() external {
        _enableApprove = !_enableApprove;
    }

    function flipValidReturnValue() external {
        _enableValidReturnValue = !_enableValidReturnValue;
    }
}
