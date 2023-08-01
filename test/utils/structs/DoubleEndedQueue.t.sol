// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/structs/MockDoubleEndedQueue.sol";
import "openzeppelin-contracts/contracts/utils/structs/DoubleEndedQueue.sol";

contract DoubleEndedQueueTest is Test {
    MockDoubleEndedQueue mdeq = new MockDoubleEndedQueue();

    function test_PushBackAndPopBackAndBack() external {
        // empty deque
        assertTrue(mdeq.empty());
        assertEq(mdeq.length(), 0);
        // revert if back()/popBack() from an empty deque
        vm.expectRevert(DoubleEndedQueue.Empty.selector);
        mdeq.back();
        vm.expectRevert(DoubleEndedQueue.Empty.selector);
        mdeq.popBack();

        // push back a,b,c
        mdeq.pushBack('a');
        assertEq(mdeq.length(), 1);
        assertEq(mdeq.back(), 'a');
        mdeq.pushBack('b');
        assertEq(mdeq.length(), 2);
        assertEq(mdeq.back(), 'b');
        mdeq.pushBack('c');
        assertEq(mdeq.length(), 3);
        assertEq(mdeq.back(), 'c');
        assertFalse(mdeq.empty());

        // pop back
        assertEq(mdeq.popBack(), 'c');
        assertEq(mdeq.length(), 2);
        assertEq(mdeq.popBack(), 'b');
        assertEq(mdeq.length(), 1);
        assertEq(mdeq.popBack(), 'a');
        assertEq(mdeq.length(), 0);
        assertTrue(mdeq.empty());
    }

    function test_PushFrontAndPopFrontAndFront() external {
        // empty deque
        assertTrue(mdeq.empty());
        assertEq(mdeq.length(), 0);
        // revert if front()/popFront() from an empty deque
        vm.expectRevert(DoubleEndedQueue.Empty.selector);
        mdeq.front();
        vm.expectRevert(DoubleEndedQueue.Empty.selector);
        mdeq.popFront();

        // push front a,b,c
        mdeq.pushFront('a');
        assertEq(mdeq.length(), 1);
        assertEq(mdeq.front(), 'a');
        mdeq.pushFront('b');
        assertEq(mdeq.length(), 2);
        assertEq(mdeq.front(), 'b');
        mdeq.pushFront('c');
        assertEq(mdeq.length(), 3);
        assertEq(mdeq.front(), 'c');
        assertFalse(mdeq.empty());

        // pop back
        assertEq(mdeq.popFront(), 'c');
        assertEq(mdeq.length(), 2);
        assertEq(mdeq.popFront(), 'b');
        assertEq(mdeq.length(), 1);
        assertEq(mdeq.popFront(), 'a');
        assertEq(mdeq.length(), 0);
        assertTrue(mdeq.empty());
    }

    function test_DoubleDirectionsPushAndAt() external {
        mdeq.pushFront('a');
        mdeq.pushBack('b');
        mdeq.pushFront('c');
        mdeq.pushBack('e');
        mdeq.pushBack('f');
        mdeq.pushFront('g');

        // status in deque [g,c,a,b,e,f]
        assertEq(mdeq.length(), 6);
        assertEq(mdeq.at(0), 'g');
        assertEq(mdeq.at(1), 'c');
        assertEq(mdeq.at(2), 'a');
        assertEq(mdeq.at(3), 'b');
        assertEq(mdeq.at(4), 'e');
        assertEq(mdeq.at(5), 'f');
        vm.expectRevert(DoubleEndedQueue.OutOfBounds.selector);
        mdeq.at(5 + 1);

        // pop front and pop back in turn
        assertEq(mdeq.front(), 'g');
        assertEq(mdeq.popFront(), 'g');
        assertEq(mdeq.length(), 5);

        assertEq(mdeq.back(), 'f');
        assertEq(mdeq.popBack(), 'f');
        assertEq(mdeq.length(), 4);

        assertEq(mdeq.front(), 'c');
        assertEq(mdeq.popFront(), 'c');
        assertEq(mdeq.length(), 3);

        assertEq(mdeq.back(), 'e');
        assertEq(mdeq.popBack(), 'e');
        assertEq(mdeq.length(), 2);

        assertEq(mdeq.front(), 'a');
        assertEq(mdeq.popFront(), 'a');
        assertEq(mdeq.length(), 1);

        assertEq(mdeq.back(), 'b');
        assertEq(mdeq.popBack(), 'b');
        assertEq(mdeq.length(), 0);
    }

    function test_Clear() external {
        for (uint16 i; i < type(uint16).max; ++i) {
            bytes32 content = bytes32(uint(i));
            mdeq.pushFront(content);
            mdeq.pushBack(content);
        }

        assertEq(mdeq.length(), uint(type(uint16).max) * 2);
        assertFalse(mdeq.empty());
        // clear
        mdeq.clear();

        // check
        assertEq(mdeq.length(), 0);
        assertTrue(mdeq.empty());
    }
}