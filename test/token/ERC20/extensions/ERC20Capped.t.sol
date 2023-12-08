// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Capped.sol";

contract ERC20CappedTest is Test {
    MockERC20Capped private _testing = new MockERC20Capped("test name", "test symbol", 100);
    address private user = address(1);

    function test_Constructor() external {
        assertEq(_testing.cap(), 100);

        // revert with 0 cap in constructor
        vm.expectRevert("ERC20Capped: cap is 0");
        new MockERC20Capped("test name", "test symbol", 0);
    }

    function test_Mint() external {
        _testing.mint(user, 100);
        assertEq(_testing.totalSupply(), 100);

        vm.expectRevert("ERC20Capped: cap exceeded");
        _testing.mint(user, 1);
    }
}
