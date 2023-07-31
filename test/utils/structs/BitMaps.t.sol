// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/structs/MockBitMaps.sol";

contract BitMapsTest is Test {
    MockBitMaps mb = new MockBitMaps();

    function test_SetAndUnset() external {
        uint[3] memory keys = [1, 1024, type(uint).max];

        for (uint i = 0; i < 3; ++i) {
            uint key = keys[i];
            // before set
            assertFalse(mb.get(key));
            // set
            mb.set(key);
            // after set
            assertTrue(mb.get(key));
            // unset
            mb.unset(key);
            // after unset
            assertFalse(mb.get(key));
        }

        // test consecutive keys operations
        for (uint16 i; i < type(uint16).max; ++i) {
            assertFalse(mb.get(i));
        }

        for (uint16 i; i < type(uint16).max; ++i) {
            mb.set(i);
        }

        for (uint16 i; i < type(uint16).max; ++i) {
            assertTrue(mb.get(i));
        }

        for (uint16 i; i < type(uint16).max; ++i) {
            mb.unset(i);
        }

        for (uint16 i; i < type(uint16).max; ++i) {
            assertFalse(mb.get(i));
        }
    }

    function test_SetTo() external {
        for (uint16 i; i < type(uint16).max; ++i) {
            if (i % 2 == 0) {
                mb.setTo(i, true);
            } else {
                mb.setTo(i, false);
            }
        }

        // check
        for (uint16 i; i < type(uint16).max; ++i) {
            if (i % 2 == 0) {
                assertTrue(mb.get(i));
            } else {
                assertFalse(mb.get(i));
            }
        }
    }
}