// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Snapshot.sol";

contract ERC20SnapshotTest is Test {
    MockERC20Snapshot private _testing = new MockERC20Snapshot("test name", "test symbol", address(this), 10000);
    address private holder1 = address(1);
    address private holder2 = address(2);

    event Snapshot(uint256 id);

    function test_SnapshotAndGetCurrentSnapshotId() external {
        assertEq(_testing.getCurrentSnapshotId(), 0);
        // increasing snapshots ids from 1
        for (uint id = 1; id < 10; ++id) {
            vm.expectEmit(address(_testing));
            emit Snapshot(id);
            _testing.snapshot();
            // check getCurrentSnapshotId()
            assertEq(_testing.getCurrentSnapshotId(), id);
        }
    }

    function test_TotalSupplyAt() external {
        // revert if snapshot id is 0`
        vm.expectRevert("ERC20Snapshot: id is 0");
        _testing.totalSupplyAt(0);

        // revert if snapshot id is not created
        vm.expectRevert("ERC20Snapshot: nonexistent id");
        _testing.totalSupplyAt(1);

        uint totalSupply = _testing.totalSupply();
        assertEq(totalSupply, 10000);
        _testing.snapshot();
        assertEq(_testing.totalSupplyAt(1), totalSupply);

        // mint
        _testing.mint(address(this), 1);
        _testing.mint(address(this), 2);
        _testing.mint(address(this), 3);
        totalSupply += 1 + 2 + 3;
        _testing.snapshot();
        // mint after snapshot
        _testing.mint(address(this), 4);
        assertEq(_testing.totalSupplyAt(2), totalSupply);
        totalSupply += 4;

        // burn
        _testing.burn(address(this), 5);
        _testing.burn(address(this), 6);
        _testing.burn(address(this), 7);
        totalSupply -= 5 + 6 + 7;
        _testing.snapshot();
        // burn after snapshot
        _testing.burn(address(this), 8);
        assertEq(_testing.totalSupplyAt(3), totalSupply);
        totalSupply -= 8;

        // transfer
        _testing.transfer(holder1, 9);
        _testing.transfer(holder2, 10);
        _testing.snapshot();
        // transfer after snapshot
        vm.prank(holder1);
        _testing.transfer(holder2, 1);
        // totalSupplyAt(4) not change
        assertEq(_testing.totalSupplyAt(4), totalSupply);
    }

    function test_BalanceOfAt() external {
        // revert if snapshot id is 0`
        vm.expectRevert("ERC20Snapshot: id is 0");
        _testing.balanceOfAt(address(this), 0);

        // revert if snapshot id is not created
        vm.expectRevert("ERC20Snapshot: nonexistent id");
        _testing.balanceOfAt(address(this), 1);

        uint balance = _testing.balanceOf(address(this));
        assertEq(balance, 10000);
        _testing.snapshot();
        assertEq(_testing.balanceOfAt(address(this), 1), balance);
        assertEq(_testing.balanceOfAt(holder1, 1), 0);
        assertEq(_testing.balanceOfAt(holder2, 1), 0);

        // mint
        _testing.mint(address(this), 1);
        _testing.mint(address(this), 2);
        _testing.mint(address(this), 3);
        balance += 1 + 2 + 3;
        _testing.snapshot();
        // mint after snapshot
        _testing.mint(address(this), 4);
        assertEq(_testing.balanceOfAt(address(this), 2), balance);
        assertEq(_testing.balanceOfAt(holder1, 2), 0);
        assertEq(_testing.balanceOfAt(holder2, 2), 0);
        balance += 4;

        // burn
        _testing.burn(address(this), 5);
        _testing.burn(address(this), 6);
        _testing.burn(address(this), 7);
        balance -= 5 + 6 + 7;
        _testing.snapshot();
        // burn after snapshot
        _testing.burn(address(this), 8);
        assertEq(_testing.balanceOfAt(address(this), 3), balance);
        assertEq(_testing.balanceOfAt(holder1, 3), 0);
        assertEq(_testing.balanceOfAt(holder2, 3), 0);
        balance -= 8;

        // transfer
        _testing.transfer(holder1, 9);
        _testing.transfer(holder2, 10);
        _testing.snapshot();
        // transfer after snapshot
        vm.prank(holder1);
        _testing.transfer(address(this), 1);
        assertEq(_testing.balanceOfAt(address(this), 4), balance - 9 - 10);
        assertEq(_testing.balanceOfAt(holder1, 4), 9);
        assertEq(_testing.balanceOfAt(holder2, 4), 10);
    }

    function test_MintAndBurnAndTransferInASnapshot() external {
        uint totalSupply = _testing.totalSupply();
        uint balanceHolder1;
        uint balanceHolder2;
        uint balanceHolderThis = _testing.balanceOf(address(this));

        // snapshot 1
        _testing.transfer(holder1, 1);
        _testing.mint(holder2, 2);
        _testing.burn(address(this), 3);
        _testing.snapshot();
        totalSupply = totalSupply + 2 - 3;
        balanceHolder1 += 1;
        balanceHolder2 += 2;
        balanceHolderThis -= 1 + 3;

        assertEq(_testing.totalSupplyAt(1), totalSupply);
        assertEq(_testing.balanceOfAt(holder1, 1), balanceHolder1);
        assertEq(_testing.balanceOfAt(holder2, 1), balanceHolder2);
        assertEq(_testing.balanceOfAt(address(this), 1), balanceHolderThis);

        // snapshot 2
        _testing.burn(holder1, 1);
        _testing.transfer(holder2, 4);
        _testing.mint(address(this), 5);
        _testing.snapshot();
        totalSupply = totalSupply + 5 - 1;
        balanceHolder1 -= 1;
        balanceHolder2 += 4;
        balanceHolderThis = balanceHolderThis - 4 + 5;

        assertEq(_testing.totalSupplyAt(2), totalSupply);
        assertEq(_testing.balanceOfAt(holder1, 2), balanceHolder1);
        assertEq(_testing.balanceOfAt(holder2, 2), balanceHolder2);
        assertEq(_testing.balanceOfAt(address(this), 2), balanceHolderThis);

        // snapshot 3
        _testing.mint(holder1, 6);
        _testing.burn(holder2, 2);
        vm.prank(holder2);
        _testing.transfer(address(this), 3);
        _testing.snapshot();
        totalSupply = totalSupply + 6 - 2;
        balanceHolder1 += 6;
        balanceHolder2 -= 2 + 3;
        balanceHolderThis += 3;

        assertEq(_testing.totalSupplyAt(3), totalSupply);
        assertEq(_testing.balanceOfAt(holder1, 3), balanceHolder1);
        assertEq(_testing.balanceOfAt(holder2, 3), balanceHolder2);
        assertEq(_testing.balanceOfAt(address(this), 3), balanceHolderThis);
    }
}
