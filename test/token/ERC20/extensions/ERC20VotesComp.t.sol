// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20VotesComp.sol";

contract ERC20VotesTest is Test {
    MockERC20VotesComp private _testing = new MockERC20VotesComp("test name", "test symbol");
    address private user1 = address(1);

    function test_MaxSupply() external {
        assertEq(_testing.maxSupply(), type(uint96).max);
    }

    function test_GetCurrentVotes() external {
        _testing.mint(address(this), 100);
        assertEq(_testing.getCurrentVotes(user1), 0);
        _testing.delegate(user1);
        assertEq(_testing.getCurrentVotes(user1), 100);

        _testing.transfer(user1, 1);
        assertEq(_testing.getCurrentVotes(user1), 100 - 1);
        _testing.transfer(user1, 2);
        assertEq(_testing.getCurrentVotes(user1), 100 - 1 - 2);
        _testing.transfer(user1, 3);
        assertEq(_testing.getCurrentVotes(user1), 100 - 1 - 2 - 3);
        _testing.transfer(user1, 4);
        assertEq(_testing.getCurrentVotes(user1), 100 - 1 - 2 - 3 - 4);
        _testing.transfer(user1, 5);
        assertEq(_testing.getCurrentVotes(user1), 100 - 1 - 2 - 3 - 4 - 5);
    }

    function test_GetPriorVotes() external {
        // 6 Checkpoints of user1:
        //       block             votes             index
        //          2                10                0
        //          3                15                1
        //          6                19                2
        //          10               20                3
        //          11               23                4
        //          13               31                5

        _testing.delegate(user1);
        vm.roll(2);
        _testing.mint(address(this), 10);
        vm.roll(3);
        _testing.mint(address(this), 15 - 10);
        vm.roll(6);
        _testing.mint(address(this), 19 - 15);
        vm.roll(10);
        _testing.mint(address(this), 20 - 19);
        vm.roll(11);
        _testing.mint(address(this), 23 - 20);
        vm.roll(13);
        _testing.mint(address(this), 31 - 23);
        vm.roll(20);

        assertEq(_testing.getPriorVotes(user1, 1), 0);
        assertEq(_testing.getPriorVotes(user1, 2), 10);
        assertEq(_testing.getPriorVotes(user1, 3), 15);
        assertEq(_testing.getPriorVotes(user1, 5), 15);
        assertEq(_testing.getPriorVotes(user1, 6), 19);
        assertEq(_testing.getPriorVotes(user1, 7), 19);
        assertEq(_testing.getPriorVotes(user1, 9), 19);
        assertEq(_testing.getPriorVotes(user1, 10), 20);
        assertEq(_testing.getPriorVotes(user1, 11), 23);
        assertEq(_testing.getPriorVotes(user1, 12), 23);
        assertEq(_testing.getPriorVotes(user1, 13), 31);
        assertEq(_testing.getPriorVotes(user1, 19), 31);

        // revert if block not mined
        vm.expectRevert("ERC20Votes: block not yet mined");
        _testing.getPriorVotes(user1, 20);
    }
}
