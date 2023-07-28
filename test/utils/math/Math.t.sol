// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/math/MockMath.sol";

contract MathTest is Test {
    MockMath mm = new MockMath();

    function test_Max() external {
        uint max = 1024;
        uint min = max - 1;
        assertEq(mm.max(max, min), max);
        assertEq(mm.max(min, max), max);
        assertEq(mm.max(min, min), min);
    }

    function test_Min() external {
        uint min = 1024;
        uint max = min + 1;
        assertEq(mm.min(max, min), min);
        assertEq(mm.min(min, max), min);
        assertEq(mm.min(max, max), max);
    }

    function test_Average() external {
        uint odd = 1023;
        uint even = 1024;
        // odd + odd
        assertEq(mm.average(odd, odd + 2), odd + 1);
        // even + even
        assertEq(mm.average(even, even + 2), even + 1);
        // odd + even
        assertEq(mm.average(even, odd), (even + odd) / 2);
        // a+b will cause overflow
        assertEq(mm.average(type(uint).max, type(uint).max - 2), type(uint).max - 1);
    }

    function test_CeilDiv() external {
        // exact division
        assertEq(mm.ceilDiv(1024, 2), 512);
        // rounds up on division with remainders
        assertEq(mm.ceilDiv(1024, 10), 103);
        // exact division without overflow
        assertEq(mm.ceilDiv(type(uint).max, 1), type(uint).max);
        // rounds up without overflow
        assertEq(mm.ceilDiv(type(uint).max, type(uint).max - 1), 2);
    }

    function test_MulDiv() external {
        // 1. x*y without overflow with rounding options
        assertEq(mm.mulDiv(2, 3, 4, Math.Rounding.Down), 1);
        assertEq(mm.mulDiv(2, 3, 3, Math.Rounding.Down), 2);
        assertEq(mm.mulDiv(2, 3, 4, Math.Rounding.Up), 2);
        assertEq(mm.mulDiv(2, 3, 3, Math.Rounding.Up), 2);
        // revert if denominator==0
        vm.expectRevert();
        mm.mulDiv(1, 2, 0, Math.Rounding.Down);

        // 2. x*y overflow with rounding options
        uint uintMax = type(uint).max;
        assertEq(mm.mulDiv(uintMax - 2, uintMax - 1, uintMax, Math.Rounding.Down), uintMax - 3);
        assertEq(mm.mulDiv(uintMax - 1, uintMax, uintMax, Math.Rounding.Down), uintMax - 1);
        assertEq(mm.mulDiv(uintMax - 2, uintMax - 1, uintMax, Math.Rounding.Up), uintMax - 2);
        assertEq(mm.mulDiv(uintMax, uintMax - 1, uintMax, Math.Rounding.Up), uintMax - 1);
        // revert if denominator==0
        vm.expectRevert();
        mm.mulDiv(uintMax - 1, uintMax, 0, Math.Rounding.Down);

        // 3. x*y without overflow without rounding options
        assertEq(mm.mulDiv(2, 3, 4), 1);
        assertEq(mm.mulDiv(2, 3, 3), 2);
        // revert if denominator==0
        vm.expectRevert();
        mm.mulDiv(1, 2, 0);

        // 4. x*y overflow without rounding options
        assertEq(mm.mulDiv(uintMax - 2, uintMax - 1, uintMax), uintMax - 3);
        assertEq(mm.mulDiv(uintMax - 1, uintMax, uintMax), uintMax - 1);
        // revert if denominator==0
        vm.expectRevert();
        mm.mulDiv(uintMax - 1, uintMax, 0);
    }

    function test_Sqrt() external {
        uint sqrtMaxUintRoundingDown = 340282366920938463463374607431768211455;
        // without rounding option
        assertEq(mm.sqrt(0), 0);
        assertEq(mm.sqrt(1), 1);
        assertEq(mm.sqrt(2), 1);
        assertEq(mm.sqrt(3), 1);
        assertEq(mm.sqrt(4), 2);
        assertEq(mm.sqrt(101), 10);
        assertEq(mm.sqrt(120), 10);
        assertEq(mm.sqrt(type(uint).max), sqrtMaxUintRoundingDown);

        // with rounding down option
        assertEq(mm.sqrt(0, Math.Rounding.Down), 0);
        assertEq(mm.sqrt(1, Math.Rounding.Down), 1);
        assertEq(mm.sqrt(2, Math.Rounding.Down), 1);
        assertEq(mm.sqrt(3, Math.Rounding.Down), 1);
        assertEq(mm.sqrt(4, Math.Rounding.Down), 2);
        assertEq(mm.sqrt(101, Math.Rounding.Down), 10);
        assertEq(mm.sqrt(120, Math.Rounding.Down), 10);
        assertEq(mm.sqrt(type(uint).max, Math.Rounding.Down), sqrtMaxUintRoundingDown);

        // with rounding up option
        assertEq(mm.sqrt(0, Math.Rounding.Up), 0);
        assertEq(mm.sqrt(1, Math.Rounding.Up), 1);
        assertEq(mm.sqrt(2, Math.Rounding.Up), 2);
        assertEq(mm.sqrt(3, Math.Rounding.Up), 2);
        assertEq(mm.sqrt(4, Math.Rounding.Up), 2);
        assertEq(mm.sqrt(101, Math.Rounding.Up), 11);
        assertEq(mm.sqrt(120, Math.Rounding.Up), 11);
        assertEq(mm.sqrt(type(uint).max, Math.Rounding.Up), sqrtMaxUintRoundingDown + 1);
    }

    function test_Log2() external {
        // without rounding option
        assertEq(mm.log2(0), 0);
        assertEq(mm.log2(1), 0);
        assertEq(mm.log2(2), 1);
        assertEq(mm.log2(3), 1);
        assertEq(mm.log2(4), 2);
        assertEq(mm.log2(5), 2);
        assertEq(mm.log2(6), 2);
        assertEq(mm.log2(7), 2);
        assertEq(mm.log2(8), 3);
        assertEq(mm.log2(9), 3);
        assertEq(mm.log2(type(uint).max), 255);

        // with rounding down option
        assertEq(mm.log2(0, Math.Rounding.Down), 0);
        assertEq(mm.log2(1, Math.Rounding.Down), 0);
        assertEq(mm.log2(2, Math.Rounding.Down), 1);
        assertEq(mm.log2(3, Math.Rounding.Down), 1);
        assertEq(mm.log2(4, Math.Rounding.Down), 2);
        assertEq(mm.log2(5, Math.Rounding.Down), 2);
        assertEq(mm.log2(6, Math.Rounding.Down), 2);
        assertEq(mm.log2(7, Math.Rounding.Down), 2);
        assertEq(mm.log2(8, Math.Rounding.Down), 3);
        assertEq(mm.log2(9, Math.Rounding.Down), 3);
        assertEq(mm.log2(type(uint).max, Math.Rounding.Down), 255);

        // with rounding up option
        assertEq(mm.log2(0, Math.Rounding.Up), 0);
        assertEq(mm.log2(1, Math.Rounding.Up), 0);
        assertEq(mm.log2(2, Math.Rounding.Up), 1);
        assertEq(mm.log2(3, Math.Rounding.Up), 2);
        assertEq(mm.log2(4, Math.Rounding.Up), 2);
        assertEq(mm.log2(5, Math.Rounding.Up), 3);
        assertEq(mm.log2(6, Math.Rounding.Up), 3);
        assertEq(mm.log2(7, Math.Rounding.Up), 3);
        assertEq(mm.log2(8, Math.Rounding.Up), 3);
        assertEq(mm.log2(9, Math.Rounding.Up), 4);
        assertEq(mm.log2(type(uint).max, Math.Rounding.Up), 256);
    }

    function test_Log10() external {
        // without rounding option
        assertEq(mm.log10(0e1), 0);
        assertEq(mm.log10(0e1 + 1), 0);
        assertEq(mm.log10(1e1 - 1), 0);
        assertEq(mm.log10(1e1), 1);
        assertEq(mm.log10(1e1 + 1), 1);
        assertEq(mm.log10(1e2 - 1), 1);
        assertEq(mm.log10(1e2), 2);
        assertEq(mm.log10(1e2 + 1), 2);
        assertEq(mm.log10(1e3 - 1), 2);
        assertEq(mm.log10(1e3), 3);
        assertEq(mm.log10(1e3 + 1), 3);
        assertEq(mm.log10(type(uint).max), 77);

        // with rounding down option
        assertEq(mm.log10(0e1, Math.Rounding.Down), 0);
        assertEq(mm.log10(0e1 + 1, Math.Rounding.Down), 0);
        assertEq(mm.log10(1e1 - 1, Math.Rounding.Down), 0);
        assertEq(mm.log10(1e1, Math.Rounding.Down), 1);
        assertEq(mm.log10(1e1 + 1, Math.Rounding.Down), 1);
        assertEq(mm.log10(1e2 - 1, Math.Rounding.Down), 1);
        assertEq(mm.log10(1e2, Math.Rounding.Down), 2);
        assertEq(mm.log10(1e2 + 1, Math.Rounding.Down), 2);
        assertEq(mm.log10(1e3 - 1, Math.Rounding.Down), 2);
        assertEq(mm.log10(1e3, Math.Rounding.Down), 3);
        assertEq(mm.log10(1e3 + 1, Math.Rounding.Down), 3);
        assertEq(mm.log10(type(uint).max, Math.Rounding.Down), 77);

        // with rounding up option
        assertEq(mm.log10(0e1, Math.Rounding.Up), 0);
        assertEq(mm.log10(0e1 + 1, Math.Rounding.Up), 0);
        assertEq(mm.log10(1e1 - 1, Math.Rounding.Up), 1);
        assertEq(mm.log10(1e1, Math.Rounding.Up), 1);
        assertEq(mm.log10(1e1 + 1, Math.Rounding.Up), 2);
        assertEq(mm.log10(1e2 - 1, Math.Rounding.Up), 2);
        assertEq(mm.log10(1e2, Math.Rounding.Up), 2);
        assertEq(mm.log10(1e2 + 1, Math.Rounding.Up), 3);
        assertEq(mm.log10(1e3 - 1, Math.Rounding.Up), 3);
        assertEq(mm.log10(1e3, Math.Rounding.Up), 3);
        assertEq(mm.log10(1e3 + 1, Math.Rounding.Up), 4);
        assertEq(mm.log10(type(uint).max, Math.Rounding.Up), 78);
    }

    function test_Log256() external {
        // without rounding option
        assertEq(mm.log256(0), 0);
        assertEq(mm.log256(1), 0);
        assertEq(mm.log256(1 << 8 - 1), 0);
        assertEq(mm.log256(1 << 8), 1);
        assertEq(mm.log256(1 << 8 + 1), 1);
        assertEq(mm.log256(1 << 8 * 2 - 1), 1);
        assertEq(mm.log256(1 << 8 * 2), 2);
        assertEq(mm.log256(1 << 8 * 2 + 1), 2);
        assertEq(mm.log256(1 << 8 * 3 - 1), 2);
        assertEq(mm.log256(1 << 8 * 3), 3);
        assertEq(mm.log256(1 << 8 * 3 + 1), 3);
        assertEq(mm.log256(type(uint).max), 31);

        // with rounding down option
        assertEq(mm.log256(0, Math.Rounding.Down), 0);
        assertEq(mm.log256(1, Math.Rounding.Down), 0);
        assertEq(mm.log256(1 << 8 - 1, Math.Rounding.Down), 0);
        assertEq(mm.log256(1 << 8, Math.Rounding.Down), 1);
        assertEq(mm.log256(1 << 8 + 1, Math.Rounding.Down), 1);
        assertEq(mm.log256(1 << 8 * 2 - 1, Math.Rounding.Down), 1);
        assertEq(mm.log256(1 << 8 * 2, Math.Rounding.Down), 2);
        assertEq(mm.log256(1 << 8 * 2 + 1, Math.Rounding.Down), 2);
        assertEq(mm.log256(1 << 8 * 3 - 1, Math.Rounding.Down), 2);
        assertEq(mm.log256(1 << 8 * 3, Math.Rounding.Down), 3);
        assertEq(mm.log256(1 << 8 * 3 + 1, Math.Rounding.Down), 3);
        assertEq(mm.log256(type(uint).max, Math.Rounding.Down), 31);

        // with rounding up option
        assertEq(mm.log256(0, Math.Rounding.Up), 0);
        assertEq(mm.log256(1, Math.Rounding.Up), 0);
        assertEq(mm.log256(1 << 8 - 1, Math.Rounding.Up), 1);
        assertEq(mm.log256(1 << 8, Math.Rounding.Up), 1);
        assertEq(mm.log256(1 << 8 + 1, Math.Rounding.Up), 2);
        assertEq(mm.log256(1 << 8 * 2 - 1, Math.Rounding.Up), 2);
        assertEq(mm.log256(1 << 8 * 2, Math.Rounding.Up), 2);
        assertEq(mm.log256(1 << 8 * 2 + 1, Math.Rounding.Up), 3);
        assertEq(mm.log256(1 << 8 * 3 - 1, Math.Rounding.Up), 3);
        assertEq(mm.log256(1 << 8 * 3, Math.Rounding.Up), 3);
        assertEq(mm.log256(1 << 8 * 3 + 1, Math.Rounding.Up), 4);
        assertEq(mm.log256(type(uint).max, Math.Rounding.Up), 32);
    }
}