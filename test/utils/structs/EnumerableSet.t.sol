// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/structs/MockEnumerableSet.sol";

contract EnumerableSetTest is Test {
    MockBytes32Set mbs = new MockBytes32Set();
    MockAddressSet mas = new MockAddressSet();
    MockUintSet mus = new MockUintSet();

    function test_Bytes32Set_Operations() external {
        // empty
        assertEq(mbs.length(), 0);
        assertEq(mbs.values().length, 0);
        assertFalse(mbs.contains('a'));

        // add
        assertTrue(mbs.add('a'));
        assertTrue(mbs.contains('a'));
        assertEq(mbs.length(), 1);
        assertTrue(mbs.add('b'));
        assertEq(mbs.length(), 2);
        // add 'a' again
        assertFalse(mbs.add('a'));
        assertEq(mbs.length(), 2);
        bytes32[] memory values = mbs.values();
        assertEq('a', values[0]);
        assertEq('b', values[1]);

        assertTrue(mbs.add('c'));
        assertTrue(mbs.add('d'));
        assertEq(mbs.length(), 4);

        // remove
        // inner array: ['a','b','c','d']
        assertTrue(mbs.contains('b'));
        assertTrue(mbs.remove('b'));
        assertFalse(mbs.contains('b'));
        assertEq(mbs.length(), 3);
        // remove 'b' again
        assertFalse(mbs.remove('b'));
        assertEq(mbs.length(), 3);
        // inner array after remove: ['a','d','c']
        assertEq(mbs.at(0), 'a');
        assertEq(mbs.at(1), 'd');
        assertEq(mbs.at(2), 'c');
        // check values()
        values = mbs.values();
        assertEq('a', values[0]);
        assertEq('d', values[1]);
        assertEq('c', values[2]);

        // revert if out of bounds
        vm.expectRevert();
        mbs.at(1024);
    }

    function test_AddressSet_Operations() external {
        // empty
        assertEq(mas.length(), 0);
        assertEq(mas.values().length, 0);
        assertFalse(mas.contains(address(1)));

        // add
        assertTrue(mas.add(address(1)));
        assertTrue(mas.contains(address(1)));
        assertEq(mas.length(), 1);
        assertTrue(mas.add(address(2)));
        assertEq(mas.length(), 2);
        // add address(1) again
        assertFalse(mas.add(address(1)));
        assertEq(mas.length(), 2);
        address[] memory values = mas.values();
        assertEq(address(1), values[0]);
        assertEq(address(2), values[1]);

        assertTrue(mas.add(address(4)));
        assertTrue(mas.add(address(8)));
        assertEq(mas.length(), 4);

        // remove
        // inner array: [address(1),address(2),address(4),address(8)]
        assertTrue(mas.contains(address(2)));
        assertTrue(mas.remove(address(2)));
        assertFalse(mas.contains(address(2)));
        assertEq(mas.length(), 3);
        // remove address(2) again
        assertFalse(mas.remove(address(2)));
        assertEq(mas.length(), 3);
        // inner array after remove: [address(1),address(8),address(4)]
        assertEq(mas.at(0), address(1));
        assertEq(mas.at(1), address(8));
        assertEq(mas.at(2), address(4));
        // check values()
        values = mas.values();
        assertEq(address(1), values[0]);
        assertEq(address(8), values[1]);
        assertEq(address(4), values[2]);

        // revert if out of bounds
        vm.expectRevert();
        mas.at(1024);
    }

    function test_UintSet_Operations() external {
        // empty
        assertEq(mus.length(), 0);
        assertEq(mus.values().length, 0);
        assertFalse(mus.contains(1));

        // add
        assertTrue(mus.add(1));
        assertTrue(mus.contains(1));
        assertEq(mus.length(), 1);
        assertTrue(mus.add(2));
        assertEq(mus.length(), 2);
        // add 1 again
        assertFalse(mus.add(1));
        assertEq(mus.length(), 2);
        uint[] memory values = mus.values();
        assertEq(1, values[0]);
        assertEq(2, values[1]);

        assertTrue(mus.add(4));
        assertTrue(mus.add(8));
        assertEq(mus.length(), 4);

        // remove
        // inner array: [1,2,4,8]
        assertTrue(mus.contains(2));
        assertTrue(mus.remove(2));
        assertFalse(mus.contains(2));
        assertEq(mus.length(), 3);
        // remove 2 again
        assertFalse(mus.remove(2));
        assertEq(mus.length(), 3);
        // inner array after remove: [1,8,4]
        assertEq(mus.at(0), 1);
        assertEq(mus.at(1), 8);
        assertEq(mus.at(2), 4);
        // check values()
        values = mus.values();
        assertEq(1, values[0]);
        assertEq(8, values[1]);
        assertEq(4, values[2]);

        // revert if out of bounds
        vm.expectRevert();
        mus.at(1024);
    }
}