// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/math/MockSafeCast.sol";

contract SafeCastTest is Test {
    MockSafeCast msf = new MockSafeCast();

    function test_ToUint248() external {
        uint maxUint248 = type(uint248).max;
        assertEq(msf.toUint248(0), 0);
        assertEq(msf.toUint248(1), 1);
        assertEq(msf.toUint248(maxUint248), uint248(maxUint248));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 248 bits");
        msf.toUint248(maxUint248 + 1);
    }

    function test_ToUint240() external {
        uint maxUint240 = type(uint240).max;
        assertEq(msf.toUint240(0), 0);
        assertEq(msf.toUint240(1), 1);
        assertEq(msf.toUint240(maxUint240), uint240(maxUint240));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 240 bits");
        msf.toUint240(maxUint240 + 1);
    }

    function test_ToUint232() external {
        uint maxUint232 = type(uint232).max;
        assertEq(msf.toUint232(0), 0);
        assertEq(msf.toUint232(1), 1);
        assertEq(msf.toUint232(maxUint232), uint232(maxUint232));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 232 bits");
        msf.toUint232(maxUint232 + 1);
    }

    function test_ToUint224() external {
        uint maxUint224 = type(uint224).max;
        assertEq(msf.toUint224(0), 0);
        assertEq(msf.toUint224(1), 1);
        assertEq(msf.toUint224(maxUint224), uint224(maxUint224));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 224 bits");
        msf.toUint224(maxUint224 + 1);
    }

    function test_ToUint216() external {
        uint maxUint216 = type(uint216).max;
        assertEq(msf.toUint216(0), 0);
        assertEq(msf.toUint216(1), 1);
        assertEq(msf.toUint216(maxUint216), uint216(maxUint216));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 216 bits");
        msf.toUint216(maxUint216 + 1);
    }

    function test_ToUint208() external {
        uint maxUint208 = type(uint208).max;
        assertEq(msf.toUint208(0), 0);
        assertEq(msf.toUint208(1), 1);
        assertEq(msf.toUint208(maxUint208), uint208(maxUint208));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 208 bits");
        msf.toUint208(maxUint208 + 1);
    }

    function test_ToUint200() external {
        uint maxUint200 = type(uint200).max;
        assertEq(msf.toUint200(0), 0);
        assertEq(msf.toUint200(1), 1);
        assertEq(msf.toUint200(maxUint200), uint200(maxUint200));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 200 bits");
        msf.toUint200(maxUint200 + 1);
    }

    function test_ToUint192() external {
        uint maxUint192 = type(uint192).max;
        assertEq(msf.toUint192(0), 0);
        assertEq(msf.toUint192(1), 1);
        assertEq(msf.toUint192(maxUint192), uint192(maxUint192));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 192 bits");
        msf.toUint192(maxUint192 + 1);
    }

    function test_ToUint184() external {
        uint maxUint184 = type(uint184).max;
        assertEq(msf.toUint184(0), 0);
        assertEq(msf.toUint184(1), 1);
        assertEq(msf.toUint184(maxUint184), uint184(maxUint184));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 184 bits");
        msf.toUint184(maxUint184 + 1);
    }

    function test_ToUint176() external {
        uint maxUint176 = type(uint176).max;
        assertEq(msf.toUint176(0), 0);
        assertEq(msf.toUint176(1), 1);
        assertEq(msf.toUint176(maxUint176), uint176(maxUint176));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 176 bits");
        msf.toUint176(maxUint176 + 1);
    }

    function test_ToUint168() external {
        uint maxUint168 = type(uint168).max;
        assertEq(msf.toUint168(0), 0);
        assertEq(msf.toUint168(1), 1);
        assertEq(msf.toUint168(maxUint168), uint168(maxUint168));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 168 bits");
        msf.toUint168(maxUint168 + 1);
    }

    function test_ToUint160() external {
        uint maxUint160 = type(uint160).max;
        assertEq(msf.toUint160(0), 0);
        assertEq(msf.toUint160(1), 1);
        assertEq(msf.toUint160(maxUint160), uint160(maxUint160));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 160 bits");
        msf.toUint160(maxUint160 + 1);
    }

    function test_ToUint152() external {
        uint maxUint152 = type(uint152).max;
        assertEq(msf.toUint152(0), 0);
        assertEq(msf.toUint152(1), 1);
        assertEq(msf.toUint152(maxUint152), uint152(maxUint152));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 152 bits");
        msf.toUint152(maxUint152 + 1);
    }

    function test_ToUint144() external {
        uint maxUint144 = type(uint144).max;
        assertEq(msf.toUint144(0), 0);
        assertEq(msf.toUint144(1), 1);
        assertEq(msf.toUint144(maxUint144), uint144(maxUint144));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 144 bits");
        msf.toUint144(maxUint144 + 1);
    }

    function test_ToUint136() external {
        uint maxUint136 = type(uint136).max;
        assertEq(msf.toUint136(0), 0);
        assertEq(msf.toUint136(1), 1);
        assertEq(msf.toUint136(maxUint136), uint136(maxUint136));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 136 bits");
        msf.toUint136(maxUint136 + 1);
    }

    function test_ToUint128() external {
        uint maxUint128 = type(uint128).max;
        assertEq(msf.toUint128(0), 0);
        assertEq(msf.toUint128(1), 1);
        assertEq(msf.toUint128(maxUint128), uint128(maxUint128));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 128 bits");
        msf.toUint128(maxUint128 + 1);
    }

    function test_ToUint120() external {
        uint maxUint120 = type(uint120).max;
        assertEq(msf.toUint120(0), 0);
        assertEq(msf.toUint120(1), 1);
        assertEq(msf.toUint120(maxUint120), uint120(maxUint120));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 120 bits");
        msf.toUint120(maxUint120 + 1);
    }

    function test_ToUint112() external {
        uint maxUint112 = type(uint112).max;
        assertEq(msf.toUint112(0), 0);
        assertEq(msf.toUint112(1), 1);
        assertEq(msf.toUint112(maxUint112), uint112(maxUint112));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 112 bits");
        msf.toUint112(maxUint112 + 1);
    }

    function test_ToUint104() external {
        uint maxUint104 = type(uint104).max;
        assertEq(msf.toUint104(0), 0);
        assertEq(msf.toUint104(1), 1);
        assertEq(msf.toUint104(maxUint104), uint104(maxUint104));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 104 bits");
        msf.toUint104(maxUint104 + 1);
    }

    function test_ToUint96() external {
        uint maxUint96 = type(uint96).max;
        assertEq(msf.toUint96(0), 0);
        assertEq(msf.toUint96(1), 1);
        assertEq(msf.toUint96(maxUint96), uint96(maxUint96));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        msf.toUint96(maxUint96 + 1);
    }

    function test_ToUint88() external {
        uint maxUint88 = type(uint88).max;
        assertEq(msf.toUint88(0), 0);
        assertEq(msf.toUint88(1), 1);
        assertEq(msf.toUint88(maxUint88), uint88(maxUint88));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 88 bits");
        msf.toUint88(maxUint88 + 1);
    }

    function test_ToUint80() external {
        uint maxUint80 = type(uint80).max;
        assertEq(msf.toUint80(0), 0);
        assertEq(msf.toUint80(1), 1);
        assertEq(msf.toUint80(maxUint80), uint80(maxUint80));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 80 bits");
        msf.toUint80(maxUint80 + 1);
    }

    function test_ToUint72() external {
        uint maxUint72 = type(uint72).max;
        assertEq(msf.toUint72(0), 0);
        assertEq(msf.toUint72(1), 1);
        assertEq(msf.toUint72(maxUint72), uint72(maxUint72));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 72 bits");
        msf.toUint72(maxUint72 + 1);
    }

    function test_ToUint64() external {
        uint maxUint64 = type(uint64).max;
        assertEq(msf.toUint64(0), 0);
        assertEq(msf.toUint64(1), 1);
        assertEq(msf.toUint64(maxUint64), uint64(maxUint64));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 64 bits");
        msf.toUint64(maxUint64 + 1);
    }

    function test_ToUint56() external {
        uint maxUint56 = type(uint56).max;
        assertEq(msf.toUint56(0), 0);
        assertEq(msf.toUint56(1), 1);
        assertEq(msf.toUint56(maxUint56), uint56(maxUint56));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 56 bits");
        msf.toUint56(maxUint56 + 1);
    }

    function test_ToUint48() external {
        uint maxUint48 = type(uint48).max;
        assertEq(msf.toUint48(0), 0);
        assertEq(msf.toUint48(1), 1);
        assertEq(msf.toUint48(maxUint48), uint48(maxUint48));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 48 bits");
        msf.toUint48(maxUint48 + 1);
    }

    function test_ToUint40() external {
        uint maxUint40 = type(uint40).max;
        assertEq(msf.toUint40(0), 0);
        assertEq(msf.toUint40(1), 1);
        assertEq(msf.toUint40(maxUint40), uint40(maxUint40));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 40 bits");
        msf.toUint40(maxUint40 + 1);
    }

    function test_ToUint32() external {
        uint maxUint32 = type(uint32).max;
        assertEq(msf.toUint32(0), 0);
        assertEq(msf.toUint32(1), 1);
        assertEq(msf.toUint32(maxUint32), uint32(maxUint32));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 32 bits");
        msf.toUint32(maxUint32 + 1);
    }

    function test_ToUint24() external {
        uint maxUint24 = type(uint24).max;
        assertEq(msf.toUint24(0), 0);
        assertEq(msf.toUint24(1), 1);
        assertEq(msf.toUint24(maxUint24), uint24(maxUint24));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 24 bits");
        msf.toUint24(maxUint24 + 1);
    }

    function test_ToUint16() external {
        uint maxUint16 = type(uint16).max;
        assertEq(msf.toUint16(0), 0);
        assertEq(msf.toUint16(1), 1);
        assertEq(msf.toUint16(maxUint16), uint16(maxUint16));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 16 bits");
        msf.toUint16(maxUint16 + 1);
    }

    function test_ToUint8() external {
        uint maxUint8 = type(uint8).max;
        assertEq(msf.toUint8(0), 0);
        assertEq(msf.toUint8(1), 1);
        assertEq(msf.toUint8(maxUint8), uint8(maxUint8));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        msf.toUint8(maxUint8 + 1);
    }

    function test_ToInt248() external {
        int maxInt248 = type(int248).max;
        int minInt248 = type(int248).min;
        assertEq(msf.toInt248(0), 0);
        assertEq(msf.toInt248(1), 1);
        assertEq(msf.toInt248(maxInt248), int248(maxInt248));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 248 bits");
        msf.toInt248(maxInt248 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 248 bits");
        msf.toInt248(minInt248 - 1);
    }

    function test_ToInt240() external {
        int maxInt240 = type(int240).max;
        int minInt240 = type(int240).min;
        assertEq(msf.toInt240(0), 0);
        assertEq(msf.toInt240(1), 1);
        assertEq(msf.toInt240(maxInt240), int240(maxInt240));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 240 bits");
        msf.toInt240(maxInt240 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 240 bits");
        msf.toInt240(minInt240 - 1);
    }

    function test_ToInt232() external {
        int maxInt232 = type(int232).max;
        int minInt232 = type(int232).min;
        assertEq(msf.toInt232(0), 0);
        assertEq(msf.toInt232(1), 1);
        assertEq(msf.toInt232(maxInt232), int232(maxInt232));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 232 bits");
        msf.toInt232(maxInt232 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 232 bits");
        msf.toInt232(minInt232 - 1);
    }

    function test_ToInt224() external {
        int maxInt224 = type(int224).max;
        int minInt224 = type(int224).min;
        assertEq(msf.toInt224(0), 0);
        assertEq(msf.toInt224(1), 1);
        assertEq(msf.toInt224(maxInt224), int224(maxInt224));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 224 bits");
        msf.toInt224(maxInt224 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 224 bits");
        msf.toInt224(minInt224 - 1);
    }

    function test_ToInt216() external {
        int maxInt216 = type(int216).max;
        int minInt216 = type(int216).min;
        assertEq(msf.toInt216(0), 0);
        assertEq(msf.toInt216(1), 1);
        assertEq(msf.toInt216(maxInt216), int216(maxInt216));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 216 bits");
        msf.toInt216(maxInt216 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 216 bits");
        msf.toInt216(minInt216 - 1);
    }

    function test_ToInt208() external {
        int maxInt208 = type(int208).max;
        int minInt208 = type(int208).min;
        assertEq(msf.toInt208(0), 0);
        assertEq(msf.toInt208(1), 1);
        assertEq(msf.toInt208(maxInt208), int208(maxInt208));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 208 bits");
        msf.toInt208(maxInt208 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 208 bits");
        msf.toInt208(minInt208 - 1);
    }

    function test_ToInt200() external {
        int maxInt200 = type(int200).max;
        int minInt200 = type(int200).min;
        assertEq(msf.toInt200(0), 0);
        assertEq(msf.toInt200(1), 1);
        assertEq(msf.toInt200(maxInt200), int200(maxInt200));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 200 bits");
        msf.toInt200(maxInt200 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 200 bits");
        msf.toInt200(minInt200 - 1);
    }

    function test_ToInt192() external {
        int maxInt192 = type(int192).max;
        int minInt192 = type(int192).min;
        assertEq(msf.toInt192(0), 0);
        assertEq(msf.toInt192(1), 1);
        assertEq(msf.toInt192(maxInt192), int192(maxInt192));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 192 bits");
        msf.toInt192(maxInt192 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 192 bits");
        msf.toInt192(minInt192 - 1);
    }

    function test_ToInt184() external {
        int maxInt184 = type(int184).max;
        int minInt184 = type(int184).min;
        assertEq(msf.toInt184(0), 0);
        assertEq(msf.toInt184(1), 1);
        assertEq(msf.toInt184(maxInt184), int184(maxInt184));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 184 bits");
        msf.toInt184(maxInt184 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 184 bits");
        msf.toInt184(minInt184 - 1);
    }

    function test_ToInt176() external {
        int maxInt176 = type(int176).max;
        int minInt176 = type(int176).min;
        assertEq(msf.toInt176(0), 0);
        assertEq(msf.toInt176(1), 1);
        assertEq(msf.toInt176(maxInt176), int176(maxInt176));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 176 bits");
        msf.toInt176(maxInt176 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 176 bits");
        msf.toInt176(minInt176 - 1);
    }

    function test_ToInt168() external {
        int maxInt168 = type(int168).max;
        int minInt168 = type(int168).min;
        assertEq(msf.toInt168(0), 0);
        assertEq(msf.toInt168(1), 1);
        assertEq(msf.toInt168(maxInt168), int168(maxInt168));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 168 bits");
        msf.toInt168(maxInt168 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 168 bits");
        msf.toInt168(minInt168 - 1);
    }

    function test_ToInt160() external {
        int maxInt160 = type(int160).max;
        int minInt160 = type(int160).min;
        assertEq(msf.toInt160(0), 0);
        assertEq(msf.toInt160(1), 1);
        assertEq(msf.toInt160(maxInt160), int160(maxInt160));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 160 bits");
        msf.toInt160(maxInt160 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 160 bits");
        msf.toInt160(minInt160 - 1);
    }

    function test_ToInt152() external {
        int maxInt152 = type(int152).max;
        int minInt152 = type(int152).min;
        assertEq(msf.toInt152(0), 0);
        assertEq(msf.toInt152(1), 1);
        assertEq(msf.toInt152(maxInt152), int152(maxInt152));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 152 bits");
        msf.toInt152(maxInt152 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 152 bits");
        msf.toInt152(minInt152 - 1);
    }

    function test_ToInt144() external {
        int maxInt144 = type(int144).max;
        int minInt144 = type(int144).min;
        assertEq(msf.toInt144(0), 0);
        assertEq(msf.toInt144(1), 1);
        assertEq(msf.toInt144(maxInt144), int144(maxInt144));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 144 bits");
        msf.toInt144(maxInt144 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 144 bits");
        msf.toInt144(minInt144 - 1);
    }

    function test_ToInt136() external {
        int maxInt136 = type(int136).max;
        int minInt136 = type(int136).min;
        assertEq(msf.toInt136(0), 0);
        assertEq(msf.toInt136(1), 1);
        assertEq(msf.toInt136(maxInt136), int136(maxInt136));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 136 bits");
        msf.toInt136(maxInt136 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 136 bits");
        msf.toInt136(minInt136 - 1);
    }

    function test_ToInt128() external {
        int maxInt128 = type(int128).max;
        int minInt128 = type(int128).min;
        assertEq(msf.toInt128(0), 0);
        assertEq(msf.toInt128(1), 1);
        assertEq(msf.toInt128(maxInt128), int128(maxInt128));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 128 bits");
        msf.toInt128(maxInt128 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 128 bits");
        msf.toInt128(minInt128 - 1);
    }

    function test_ToInt120() external {
        int maxInt120 = type(int120).max;
        int minInt120 = type(int120).min;
        assertEq(msf.toInt120(0), 0);
        assertEq(msf.toInt120(1), 1);
        assertEq(msf.toInt120(maxInt120), int120(maxInt120));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 120 bits");
        msf.toInt120(maxInt120 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 120 bits");
        msf.toInt120(minInt120 - 1);
    }

    function test_ToInt112() external {
        int maxInt112 = type(int112).max;
        int minInt112 = type(int112).min;
        assertEq(msf.toInt112(0), 0);
        assertEq(msf.toInt112(1), 1);
        assertEq(msf.toInt112(maxInt112), int112(maxInt112));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 112 bits");
        msf.toInt112(maxInt112 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 112 bits");
        msf.toInt112(minInt112 - 1);
    }

    function test_ToInt104() external {
        int maxInt104 = type(int104).max;
        int minInt104 = type(int104).min;
        assertEq(msf.toInt104(0), 0);
        assertEq(msf.toInt104(1), 1);
        assertEq(msf.toInt104(maxInt104), int104(maxInt104));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 104 bits");
        msf.toInt104(maxInt104 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 104 bits");
        msf.toInt104(minInt104 - 1);
    }

    function test_ToInt96() external {
        int maxInt96 = type(int96).max;
        int minInt96 = type(int96).min;
        assertEq(msf.toInt96(0), 0);
        assertEq(msf.toInt96(1), 1);
        assertEq(msf.toInt96(maxInt96), int96(maxInt96));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        msf.toInt96(maxInt96 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        msf.toInt96(minInt96 - 1);
    }

    function test_ToInt88() external {
        int maxInt88 = type(int88).max;
        int minInt88 = type(int88).min;
        assertEq(msf.toInt88(0), 0);
        assertEq(msf.toInt88(1), 1);
        assertEq(msf.toInt88(maxInt88), int88(maxInt88));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 88 bits");
        msf.toInt88(maxInt88 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 88 bits");
        msf.toInt88(minInt88 - 1);
    }

    function test_ToInt80() external {
        int maxInt80 = type(int80).max;
        int minInt80 = type(int80).min;
        assertEq(msf.toInt80(0), 0);
        assertEq(msf.toInt80(1), 1);
        assertEq(msf.toInt80(maxInt80), int80(maxInt80));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 80 bits");
        msf.toInt80(maxInt80 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 80 bits");
        msf.toInt80(minInt80 - 1);
    }

    function test_ToInt72() external {
        int maxInt72 = type(int72).max;
        int minInt72 = type(int72).min;
        assertEq(msf.toInt72(0), 0);
        assertEq(msf.toInt72(1), 1);
        assertEq(msf.toInt72(maxInt72), int72(maxInt72));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 72 bits");
        msf.toInt72(maxInt72 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 72 bits");
        msf.toInt72(minInt72 - 1);
    }

    function test_ToInt64() external {
        int maxInt64 = type(int64).max;
        int minInt64 = type(int64).min;
        assertEq(msf.toInt64(0), 0);
        assertEq(msf.toInt64(1), 1);
        assertEq(msf.toInt64(maxInt64), int64(maxInt64));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 64 bits");
        msf.toInt64(maxInt64 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 64 bits");
        msf.toInt64(minInt64 - 1);
    }

    function test_ToInt56() external {
        int maxInt56 = type(int56).max;
        int minInt56 = type(int56).min;
        assertEq(msf.toInt56(0), 0);
        assertEq(msf.toInt56(1), 1);
        assertEq(msf.toInt56(maxInt56), int56(maxInt56));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 56 bits");
        msf.toInt56(maxInt56 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 56 bits");
        msf.toInt56(minInt56 - 1);
    }

    function test_ToInt48() external {
        int maxInt48 = type(int48).max;
        int minInt48 = type(int48).min;
        assertEq(msf.toInt48(0), 0);
        assertEq(msf.toInt48(1), 1);
        assertEq(msf.toInt48(maxInt48), int48(maxInt48));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 48 bits");
        msf.toInt48(maxInt48 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 48 bits");
        msf.toInt48(minInt48 - 1);
    }

    function test_ToInt40() external {
        int maxInt40 = type(int40).max;
        int minInt40 = type(int40).min;
        assertEq(msf.toInt40(0), 0);
        assertEq(msf.toInt40(1), 1);
        assertEq(msf.toInt40(maxInt40), int40(maxInt40));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 40 bits");
        msf.toInt40(maxInt40 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 40 bits");
        msf.toInt40(minInt40 - 1);
    }

    function test_ToInt32() external {
        int maxInt32 = type(int32).max;
        int minInt32 = type(int32).min;
        assertEq(msf.toInt32(0), 0);
        assertEq(msf.toInt32(1), 1);
        assertEq(msf.toInt32(maxInt32), int32(maxInt32));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 32 bits");
        msf.toInt32(maxInt32 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 32 bits");
        msf.toInt32(minInt32 - 1);
    }

    function test_ToInt24() external {
        int maxInt24 = type(int24).max;
        int minInt24 = type(int24).min;
        assertEq(msf.toInt24(0), 0);
        assertEq(msf.toInt24(1), 1);
        assertEq(msf.toInt24(maxInt24), int24(maxInt24));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 24 bits");
        msf.toInt24(maxInt24 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 24 bits");
        msf.toInt24(minInt24 - 1);
    }

    function test_ToInt16() external {
        int maxInt16 = type(int16).max;
        int minInt16 = type(int16).min;
        assertEq(msf.toInt16(0), 0);
        assertEq(msf.toInt16(1), 1);
        assertEq(msf.toInt16(maxInt16), int16(maxInt16));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 16 bits");
        msf.toInt16(maxInt16 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 16 bits");
        msf.toInt16(minInt16 - 1);
    }

    function test_ToInt8() external {
        int maxInt8 = type(int8).max;
        int minInt8 = type(int8).min;
        assertEq(msf.toInt8(0), 0);
        assertEq(msf.toInt8(1), 1);
        assertEq(msf.toInt8(maxInt8), int8(maxInt8));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        msf.toInt8(maxInt8 + 1);
        vm.expectRevert("SafeCast: value doesn't fit in 8 bits");
        msf.toInt8(minInt8 - 1);
    }

    function test_toUint256() external {
        int maxInt256 = type(int).max;
        assertEq(msf.toUint256(0), 0);
        assertEq(msf.toUint256(1), 1);
        assertEq(msf.toUint256(maxInt256), uint(maxInt256));
        // revert with overflow
        vm.expectRevert("SafeCast: value must be positive");
        msf.toUint256(- 1);
    }

    function test_toInt256() external {
        uint maxInt256 = uint(type(int).max);
        assertEq(msf.toInt256(0), 0);
        assertEq(msf.toInt256(1), 1);
        assertEq(msf.toInt256(maxInt256), int(maxInt256));
        // revert with overflow
        vm.expectRevert("SafeCast: value doesn't fit in an int256");
        msf.toInt256(maxInt256 + 1);
    }
}