// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

contract MockSafeERC20 {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Permit;

    function safeTransfer(
        IERC20 token,
        address to,
        uint value
    ) external {
        token.safeTransfer(to, value);
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint value
    ) external {
        token.safeTransferFrom(from, to, value);
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint value
    ) external {
        token.safeApprove(spender, value);
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint value
    ) external {
        token.safeIncreaseAllowance(spender, value);
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) external {
        token.safeDecreaseAllowance(spender, value);
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        token.safePermit(owner, spender, value, deadline, v, r, s);
    }
}
