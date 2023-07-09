// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockStrings.sol";

contract StringsTest is Test {
    MockStrings testing = new MockStrings();

    function test_StringMemoryLayout() external {
        string memory str = "ab";
        bytes32 first32BytesInMemory;
        uint8 firstByteForStringData;
        uint8 secondByteForStringData;
        uint8 thirdByteForStringData;
        assembly{
            first32BytesInMemory := mload(str)
            // 取str的第33个字节内容
            firstByteForStringData := byte(0, mload(add(str, 0x20)))
            // 取str的第34个字节内容
            secondByteForStringData := byte(1, mload(add(str, 0x20)))
            // 取str的第35个字节内容
            thirdByteForStringData := byte(2, mload(add(str, 0x20)))
        }

        // 前32字节存放string的字节长度
        assertEq(bytes32(uint(2)), first32BytesInMemory);
        // "a"
        assertEq(97, firstByteForStringData);
        // "b"
        assertEq(98, secondByteForStringData);
        // 第三个字节没有内容
        assertEq(0, thirdByteForStringData);
    }

    function test_ToString() external {
        assertEq(testing.toString(type(uint).min), "0");
        assertEq(testing.toString(1), "1");
        assertEq(testing.toString(23), "23");
        assertEq(testing.toString(456), "456");
        assertEq(testing.toString(7890), "7890");
        assertEq(testing.toString(type(uint).max), "115792089237316195423570985008687907853269984665640564039457584007913129639935");
    }

    function test_ToHexString_WithLength() external {
        assertEq(testing.toHexString(type(uint).min, 1), "0x00");
        assertEq(testing.toHexString(255, 1), "0xff");
        assertEq(testing.toHexString(256, 2), "0x0100");
        assertEq(testing.toHexString(16777215, 3), "0xffffff");
        assertEq(testing.toHexString(16777216, 4), "0x01000000");
        assertEq(testing.toHexString(type(uint).max, 32), "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");

        // revert for insufficient length
        vm.expectRevert("Strings: hex length insufficient");
        testing.toHexString(type(uint).max, 32 - 1);
    }

    function test_ToHexString_WithoutLength() external {
        assertEq(testing.toHexString(type(uint).min), "0x00");
        assertEq(testing.toHexString(255), "0xff");
        assertEq(testing.toHexString(256), "0x0100");
        assertEq(testing.toHexString(16777215), "0xffffff");
        assertEq(testing.toHexString(16777216), "0x01000000");
        assertEq(testing.toHexString(type(uint).max), "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
    }

    function test_ToHexString_FromAddress() external {
        assertEq(testing.toHexString(address(0)), "0x0000000000000000000000000000000000000000");
        // not checksummed
        assertEq(testing.toHexString(address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)), "0xffffffffffffffffffffffffffffffffffffffff");
        assertEq(testing.toHexString(address(2 ** 160 - 1)), "0xffffffffffffffffffffffffffffffffffffffff");
    }
}
