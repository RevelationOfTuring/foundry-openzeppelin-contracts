// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/structs/MockEnumerableMap.sol";

contract EnumerableMapTest is Test {
    MockBytes32ToBytes32Map mbtbm = new MockBytes32ToBytes32Map();
    MockUintToUintMap mutum = new MockUintToUintMap();
    MockUintToAddressMap mutam = new MockUintToAddressMap();
    MockAddressToUintMap matum = new MockAddressToUintMap();
    MockBytes32ToUintMap mbtum = new MockBytes32ToUintMap();

    function test_Bytes32ToBytes32Map_Operations() external {
        // empty
        assertEq(mbtbm.length(), 0);
        assertFalse(mbtbm.contains(0));

        // set
        assertTrue(mbtbm.set(0, 'v_0'));
        assertEq(mbtbm.length(), 1);
        assertTrue(mbtbm.set('a', 'v_a'));
        assertEq(mbtbm.length(), 2);
        // set key 'a' again
        assertFalse(mbtbm.set('a', 'v_a_new'));
        assertEq(mbtbm.length(), 2);
        (bytes32 key, bytes32 value) = mbtbm.at(0);
        assertEq(0, key);
        assertEq('v_0', value);
        (key, value) = mbtbm.at(1);
        assertEq('a', key);
        assertEq('v_a_new', value);

        assertTrue(mbtbm.set('b', 'v_b'));
        assertTrue(mbtbm.set('c', 'v_c'));
        assertEq(mbtbm.length(), 4);

        // remove
        // key array: [0,'a','b','c']
        assertTrue(mbtbm.contains('a'));
        assertTrue(mbtbm.remove('a'));
        assertFalse(mbtbm.contains('a'));
        assertEq(mbtbm.length(), 3);
        // remove key 'a' again
        assertFalse(mbtbm.remove('a'));
        assertEq(mbtbm.length(), 3);
        // key array after remove: [0,'c','b']
        (key, value) = mbtbm.at(0);
        assertEq(0, key);
        assertEq('v_0', value);
        (key, value) = mbtbm.at(1);
        assertEq('c', key);
        assertEq('v_c', value);
        (key, value) = mbtbm.at(2);
        assertEq('b', key);
        assertEq('v_b', value);

        // check tryGet()/get()/get() with error msg
        bytes32[3] memory keys = [bytes32(0), 'b', 'c'];
        bytes32[3] memory values = [bytes32('v_0'), 'v_b', 'v_c'];
        // case 1: key exists
        bool exist;
        for (uint i; i < 3; ++i) {
            // tryGet()
            (exist, value) = mbtbm.tryGet(keys[i]);
            assertTrue(exist);
            assertEq(value, values[i]);
            // get()
            assertEq(mbtbm.get(keys[i]), values[i]);
            // get() with error msg
            assertEq(mbtbm.get(keys[i], "revert msg: key not exist"), values[i]);
        }

        // case 2: key doesn't exist
        bytes32 keyNotExist = 'key not exist';
        (exist, value) = mbtbm.tryGet(keyNotExist);
        assertFalse(exist);
        assertEq(value, 0);
        // get()
        vm.expectRevert("EnumerableMap: nonexistent key");
        mbtbm.get(keyNotExist);
        // get() with error msg
        vm.expectRevert("revert msg: key not exist");
        mbtbm.get(keyNotExist, "revert msg: key not exist");

        // revert if out of bounds
        vm.expectRevert();
        mbtbm.at(1024);
    }

    function test_UintToUintMap_Operations() external {
        // empty
        assertEq(mutum.length(), 0);
        assertFalse(mutum.contains(0));

        // set
        assertTrue(mutum.set(0, 1));
        assertEq(mutum.length(), 1);
        assertTrue(mutum.set(1, 2));
        assertEq(mutum.length(), 2);
        // set key 1 again
        assertFalse(mutum.set(1, 2 + 1));
        assertEq(mutum.length(), 2);
        (uint key, uint value) = mutum.at(0);
        assertEq(0, key);
        assertEq(1, value);
        (key, value) = mutum.at(1);
        assertEq(1, key);
        assertEq(3, value);

        assertTrue(mutum.set(2, 4));
        assertTrue(mutum.set(3, 8));
        assertEq(mutum.length(), 4);

        // remove
        // key array: [0,1,2,3]
        assertTrue(mutum.contains(1));
        assertTrue(mutum.remove(1));
        assertFalse(mutum.contains(1));
        assertEq(mutum.length(), 3);
        // remove key 1 again
        assertFalse(mutum.remove(1));
        assertEq(mutum.length(), 3);
        // key array after remove: [0,3,2]
        (key, value) = mutum.at(0);
        assertEq(0, key);
        assertEq(1, value);
        (key, value) = mutum.at(1);
        assertEq(3, key);
        assertEq(8, value);
        (key, value) = mutum.at(2);
        assertEq(2, key);
        assertEq(4, value);

        // check tryGet()/get()/get() with error msg
        uint[3] memory keys = [uint(0), 2, 3];
        uint[3] memory values = [uint(1), 4, 8];
        // case 1: key exists
        bool exist;
        for (uint i; i < 3; ++i) {
            // tryGet()
            (exist, value) = mutum.tryGet(keys[i]);
            assertTrue(exist);
            assertEq(value, values[i]);
            // get()
            assertEq(mutum.get(keys[i]), values[i]);
            // get() with error msg
            assertEq(mutum.get(keys[i], "revert msg: key not exist"), values[i]);
        }

        // case 2: key doesn't exist
        uint keyNotExist = 1024;
        (exist, value) = mutum.tryGet(keyNotExist);
        assertFalse(exist);
        assertEq(value, 0);
        // get()
        vm.expectRevert("EnumerableMap: nonexistent key");
        mutum.get(keyNotExist);
        // get() with error msg
        vm.expectRevert("revert msg: key not exist");
        mutum.get(keyNotExist, "revert msg: key not exist");

        // revert if out of bounds
        vm.expectRevert();
        mutum.at(1024);
    }

    function test_UintToAddressMap_Operations() external {
        // empty
        assertEq(mutam.length(), 0);
        assertFalse(mutam.contains(0));

        // set
        assertTrue(mutam.set(0, address(0)));
        assertEq(mutam.length(), 1);
        assertTrue(mutam.set(1, address(1)));
        assertEq(mutam.length(), 2);
        // set key 1 again
        assertFalse(mutam.set(1, address(1 + 1)));
        assertEq(mutam.length(), 2);
        (uint key, address value) = mutam.at(0);
        assertEq(0, key);
        assertEq(address(0), value);
        (key, value) = mutam.at(1);
        assertEq(1, key);
        assertEq(address(2), value);

        assertTrue(mutam.set(2, address(2)));
        assertTrue(mutam.set(3, address(3)));
        assertEq(mutam.length(), 4);

        // remove
        // key array: [0,1,2,3]
        assertTrue(mutam.contains(1));
        assertTrue(mutam.remove(1));
        assertFalse(mutam.contains(1));
        assertEq(mutam.length(), 3);
        // remove key 1 again
        assertFalse(mutam.remove(1));
        assertEq(mutam.length(), 3);
        // key array after remove: [0,3,2]
        (key, value) = mutam.at(0);
        assertEq(0, key);
        assertEq(address(0), value);
        (key, value) = mutam.at(1);
        assertEq(3, key);
        assertEq(address(3), value);
        (key, value) = mutam.at(2);
        assertEq(2, key);
        assertEq(address(2), value);

        // check tryGet()/get()/get() with error msg
        uint[3] memory keys = [uint(0), 2, 3];
        address[3] memory values = [address(0), address(2), address(3)];
        // case 1: key exists
        bool exist;
        for (uint i; i < 3; ++i) {
            // tryGet()
            (exist, value) = mutam.tryGet(keys[i]);
            assertTrue(exist);
            assertEq(value, values[i]);
            // get()
            assertEq(mutam.get(keys[i]), values[i]);
            // get() with error msg
            assertEq(mutam.get(keys[i], "revert msg: key not exist"), values[i]);
        }

        // case 2: key doesn't exist
        uint keyNotExist = 1024;
        (exist, value) = mutam.tryGet(keyNotExist);
        assertFalse(exist);
        assertEq(value, address(0));
        // get()
        vm.expectRevert("EnumerableMap: nonexistent key");
        mutam.get(keyNotExist);
        // get() with error msg
        vm.expectRevert("revert msg: key not exist");
        mutam.get(keyNotExist, "revert msg: key not exist");

        // revert if out of bounds
        vm.expectRevert();
        mutam.at(1024);
    }

    function test_AddressToUintMap_Operations() external {
        // empty
        assertEq(matum.length(), 0);
        assertFalse(matum.contains(address(0)));

        // set
        assertTrue(matum.set(address(0), 0));
        assertEq(matum.length(), 1);
        assertTrue(matum.set(address(1), 1));
        assertEq(matum.length(), 2);
        // set key address(1) again
        assertFalse(matum.set(address(1), 1 + 1));
        assertEq(matum.length(), 2);
        (address key, uint value) = matum.at(0);
        assertEq(address(0), key);
        assertEq(0, value);
        (key, value) = matum.at(1);
        assertEq(address(1), key);
        assertEq(2, value);

        assertTrue(matum.set(address(2), 2));
        assertTrue(matum.set(address(3), 3));
        assertEq(matum.length(), 4);

        // remove
        // key array: [address(0),address(1),address(2),address(3)]
        assertTrue(matum.contains(address(1)));
        assertTrue(matum.remove(address(1)));
        assertFalse(matum.contains(address(1)));
        assertEq(matum.length(), 3);
        // remove key address(1) again
        assertFalse(matum.remove(address(1)));
        assertEq(matum.length(), 3);
        // key array after remove: [address(0),address(3),address(2)]
        (key, value) = matum.at(0);
        assertEq(address(0), key);
        assertEq(0, value);
        (key, value) = matum.at(1);
        assertEq(address(3), key);
        assertEq(3, value);
        (key, value) = matum.at(2);
        assertEq(address(2), key);
        assertEq(2, value);

        // check tryGet()/get()/get() with error msg
        address[3] memory keys = [address(0), address(2), address(3)];
        uint[3] memory values = [uint(0), 2, 3];
        // case 1: key exists
        bool exist;
        for (uint i; i < 3; ++i) {
            // tryGet()
            (exist, value) = matum.tryGet(keys[i]);
            assertTrue(exist);
            assertEq(value, values[i]);
            // get()
            assertEq(matum.get(keys[i]), values[i]);
            // get() with error msg
            assertEq(matum.get(keys[i], "revert msg: key not exist"), values[i]);
        }

        // case 2: key doesn't exist
        address keyNotExist = address(1024);
        (exist, value) = matum.tryGet(keyNotExist);
        assertFalse(exist);
        assertEq(value, 0);
        // get()
        vm.expectRevert("EnumerableMap: nonexistent key");
        matum.get(keyNotExist);
        // get() with error msg
        vm.expectRevert("revert msg: key not exist");
        matum.get(keyNotExist, "revert msg: key not exist");

        // revert if out of bounds
        vm.expectRevert();
        matum.at(1024);
    }

    function test_Bytes32ToUintMap_Operations() external {
        // empty
        assertEq(mbtum.length(), 0);
        assertFalse(mbtum.contains(0));

        // set
        assertTrue(mbtum.set(0, 0));
        assertEq(mbtum.length(), 1);
        assertTrue(mbtum.set('a', 1));
        assertEq(mbtum.length(), 2);
        // set key 'a' again
        assertFalse(mbtum.set('a', 97));
        assertEq(mbtum.length(), 2);
        (bytes32 key, uint value) = mbtum.at(0);
        assertEq(0, key);
        assertEq(0, value);
        (key, value) = mbtum.at(1);
        assertEq('a', key);
        assertEq(97, value);

        assertTrue(mbtum.set('b', 98));
        assertTrue(mbtum.set('c', 99));
        assertEq(mbtum.length(), 4);

        // remove
        // key array: [0,'a','b','c']
        assertTrue(mbtum.contains('a'));
        assertTrue(mbtum.remove('a'));
        assertFalse(mbtum.contains('a'));
        assertEq(mbtum.length(), 3);
        // remove key 'a' again
        assertFalse(mbtum.remove('a'));
        assertEq(mbtum.length(), 3);
        // key array after remove: [0,'c','b']
        (key, value) = mbtum.at(0);
        assertEq(0, key);
        assertEq(0, value);
        (key, value) = mbtum.at(1);
        assertEq('c', key);
        assertEq(99, value);
        (key, value) = mbtum.at(2);
        assertEq('b', key);
        assertEq(98, value);

        // check tryGet()/get()/get() with error msg
        bytes32[3] memory keys = [bytes32(0), 'b', 'c'];
        uint[3] memory values = [uint(0), 98, 99];
        // case 1: key exists
        bool exist;
        for (uint i; i < 3; ++i) {
            // tryGet()
            (exist, value) = mbtum.tryGet(keys[i]);
            assertTrue(exist);
            assertEq(value, values[i]);
            // get()
            assertEq(mbtum.get(keys[i]), values[i]);
            // get() with error msg
            assertEq(mbtum.get(keys[i], "revert msg: key not exist"), values[i]);
        }

        // case 2: key doesn't exist
        bytes32 keyNotExist = 'key not exist';
        (exist, value) = mbtum.tryGet(keyNotExist);
        assertFalse(exist);
        assertEq(value, 0);
        // get()
        vm.expectRevert("EnumerableMap: nonexistent key");
        mbtum.get(keyNotExist);
        // get() with error msg
        vm.expectRevert("revert msg: key not exist");
        mbtum.get(keyNotExist, "revert msg: key not exist");

        // revert if out of bounds
        vm.expectRevert();
        mbtum.at(1024);
    }
}