// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../../src/token/ERC20/extensions/MockERC20Wrapper.sol";
import "./MockERC20.sol";

contract ERC20WrapperTest is Test {
    MockERC20 private _underlyingToken = new MockERC20("test name", "test symbol");
    MockERC20Wrapper private _testing = new MockERC20Wrapper("test name", "test symbol", _underlyingToken);
    address private account = address(1);

    function setUp() external {
        _underlyingToken.mint(address(this), 100);
    }

    function test_Decimals() external {
        // case 1: underlying token with 1 decimals
        MockERC20WithDecimals mockERC20WithDecimals = new MockERC20WithDecimals(1);
        _testing = new MockERC20Wrapper("test name", "test symbol", IERC20(address(mockERC20WithDecimals)));
        assertEq(_testing.decimals(), mockERC20WithDecimals.decimals());

        // case 2: underlying token without decimals
        MockERC20WithoutDecimals mockERC20WithoutDecimals = new MockERC20WithoutDecimals();
        _testing = new MockERC20Wrapper("test name", "test symbol", IERC20(address(mockERC20WithoutDecimals)));
        assertEq(_testing.decimals(), 18);
    }

    function test_DepositFor() external {
        assertEq(_testing.balanceOf(account), 0);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_underlyingToken.balanceOf(address(this)), 100);
        assertEq(_underlyingToken.balanceOf(address(_testing)), 0);

        _underlyingToken.approve(address(_testing), 100);
        uint amountToDeposit = 10;
        assertTrue(_testing.depositFor(account, amountToDeposit));
        // check balances
        assertEq(_testing.balanceOf(account), 0 + amountToDeposit);
        assertEq(_testing.totalSupply(), 0 + amountToDeposit);
        assertEq(_underlyingToken.balanceOf(address(this)), 100 - amountToDeposit);
        assertEq(_underlyingToken.balanceOf(address(_testing)), 0 + amountToDeposit);
    }

    function test_WithdrawTo() external {
        _underlyingToken.approve(address(_testing), 100);
        _testing.depositFor(account, 100);

        assertEq(_underlyingToken.balanceOf(address(_testing)), 100);
        assertEq(_underlyingToken.balanceOf(address(account)), 0);
        assertEq(_underlyingToken.balanceOf(address(this)), 0);
        assertEq(_testing.balanceOf(address(account)), 100);
        assertEq(_testing.totalSupply(), 100);

        uint amountToWithdraw = 10;
        vm.prank(account);
        assertTrue(_testing.withdrawTo(address(this), amountToWithdraw));
        assertEq(_underlyingToken.balanceOf(address(_testing)), 100 - amountToWithdraw);
        assertEq(_underlyingToken.balanceOf(address(account)), 0);
        assertEq(_underlyingToken.balanceOf(address(this)), 0 + amountToWithdraw);
        assertEq(_testing.balanceOf(address(account)), 100 - amountToWithdraw);
        assertEq(_testing.totalSupply(), 100 - amountToWithdraw);
    }

    function test_Recover() external {
        // transfer underlying token into ERC20Wrapper directly
        _underlyingToken.transfer(address(_testing), 20);
        assertEq(_underlyingToken.balanceOf(address(_testing)), 20);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.balanceOf(account), 0);

        uint difference = _underlyingToken.balanceOf(address(_testing)) - _testing.totalSupply();
        _testing.recover(account);
        assertEq(_underlyingToken.balanceOf(address(_testing)), 20);
        assertEq(_testing.totalSupply(), 0 + difference);
        assertEq(_testing.balanceOf(account), 0 + difference);
    }
}
