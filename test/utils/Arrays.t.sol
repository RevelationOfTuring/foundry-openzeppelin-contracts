// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockArrays.sol";

contract ArraysTest is Test {
    ArrayLayoutChecker alc = new ArrayLayoutChecker();
    MockArrays ma = new MockArrays();

    function test_LayoutForDynamicAndStaticArrays() external {
        // 向动态数组内增添新的元素
        alc.pushArr(0xabcd);

        // 通过slot号读取对应slot中存储的值
        // slot0: 状态变量a的值——2
        uint valueSlot0 = uint(vm.load(address(alc), bytes32(0)));
        assertEq(alc.a(), valueSlot0);
        // slot1: 存放的是动态数组arr中的元素数量，即arr.length
        uint valueSlot1 = uint(vm.load(address(alc), bytes32(uint(1))));
        assertEq(alc.getArrLength(), valueSlot1);
        // slot2: 状态变量addr的值——address(1024)
        address valueSlot2 = address(uint160(uint(vm.load(address(alc), bytes32(uint(2))))));
        assertEq(alc.addr(), valueSlot2);
        // slot3~slot6: 静态数组address[4] addrs 按顺序排布的四个元素
        address valueSlot3 = address(uint160(uint(vm.load(address(alc), bytes32(uint(3))))));
        address valueSlot4 = address(uint160(uint(vm.load(address(alc), bytes32(uint(4))))));
        address valueSlot5 = address(uint160(uint(vm.load(address(alc), bytes32(uint(5))))));
        address valueSlot6 = address(uint160(uint(vm.load(address(alc), bytes32(uint(6))))));
        assertEq(alc.addrs(0), valueSlot3);
        assertEq(alc.addrs(1), valueSlot4);
        assertEq(alc.addrs(2), valueSlot5);
        assertEq(alc.addrs(3), valueSlot6);

        // 动态数组的元素存储的slot号：keccak256(动态数组本位的slot号) + 索引值
        // 本案例中动态数组的本位slot为slot1，即本位slot号为bytes32(uint(1))
        bytes32 startSlot = keccak256(abi.encodePacked(uint(1)));
        // 动态数组的第1个元素的slot号，即startSlotNumber + 0
        assertEq(alc.arr(0), uint(vm.load(address(alc), bytes32(uint(startSlot) + 0))));
        // 动态数组的第2个元素的slot号，即startSlotNumber + 1
        assertEq(alc.arr(1), uint(vm.load(address(alc), bytes32(uint(startSlot) + 1))));
        // 动态数组的第3个元素的slot号，即startSlotNumber + 2
        assertEq(alc.arr(2), uint(vm.load(address(alc), bytes32(uint(startSlot) + 2))));
        // 动态数组的第4个元素的slot号，即startSlotNumber + 3
        assertEq(alc.arr(3), uint(vm.load(address(alc), bytes32(uint(startSlot) + 3))));
        // 注： 动态数组和静态数组的元素在slot中都是按照顺序依次紧密地向后存储在slot中
    }

    function test_UnsafeAccess() external {
        uint l = ma.getLength(0);
        for (uint i = 0; i < l; ++i) {
            assertEq(ma.arrUint(i), ma.unsafeAccessUintArrays(i));
        }

        // revert if out of index with []
        vm.expectRevert();
        ma.arrUint(l);
        // not revert with unsafeAccess(), but get zero value
        assertEq(0, ma.unsafeAccessUintArrays(l));

        l = ma.getLength(1);
        for (uint i = 0; i < l; ++i) {
            assertEq(ma.arrBytes32(i), ma.unsafeAccessBytes32Arrays(i));
        }

        // revert if out of index with []
        vm.expectRevert();
        ma.arrBytes32(l);
        // not revert with unsafeAccess(), but get zero value
        assertEq(0, ma.unsafeAccessBytes32Arrays(l));

        l = ma.getLength(2);
        for (uint i = 0; i < l; ++i) {
            assertEq(ma.arrAddress(i), ma.unsafeAccessAddressArrays(i));
        }

        // revert if out of index with []
        vm.expectRevert();
        ma.arrAddress(l);
        // not revert with unsafeAccess(), but get zero value
        assertEq(address(0), ma.unsafeAccessAddressArrays(l));
    }

    function test_FindUpperBound_WithEvenLength() external {
        // arrUint: [1, 2, 11, 19, 21, 22, 100, 201, 224, 999]
        assertEq(ma.getLength(0), 10);
        assertEq(0, ma.findUpperBound(0));
        assertEq(0, ma.findUpperBound(1));
        assertEq(1, ma.findUpperBound(2));
        assertEq(2, ma.findUpperBound(3));
        assertEq(2, ma.findUpperBound(10));
        assertEq(2, ma.findUpperBound(11));
        assertEq(3, ma.findUpperBound(12));
        assertEq(3, ma.findUpperBound(19));
        assertEq(4, ma.findUpperBound(21));
        assertEq(5, ma.findUpperBound(22));
        assertEq(6, ma.findUpperBound(100));
        assertEq(7, ma.findUpperBound(201));
        assertEq(8, ma.findUpperBound(224));
        assertEq(9, ma.findUpperBound(999));
        // greater than all elements in the array, it will return the length of the array
        assertEq(10, ma.findUpperBound(1000));
    }

    function test_FindUpperBound_WithOddLength() external {
        ma.addArrUint(2000);
        // arrUint: [1, 2, 11, 19, 21, 22, 100, 201, 224, 999, 2000]
        assertEq(ma.getLength(0), 11);
        assertEq(0, ma.findUpperBound(0));
        assertEq(0, ma.findUpperBound(1));
        assertEq(1, ma.findUpperBound(2));
        assertEq(2, ma.findUpperBound(3));
        assertEq(2, ma.findUpperBound(10));
        assertEq(2, ma.findUpperBound(11));
        assertEq(3, ma.findUpperBound(12));
        assertEq(3, ma.findUpperBound(19));
        assertEq(4, ma.findUpperBound(21));
        assertEq(5, ma.findUpperBound(22));
        assertEq(6, ma.findUpperBound(100));
        assertEq(7, ma.findUpperBound(201));
        assertEq(8, ma.findUpperBound(224));
        assertEq(9, ma.findUpperBound(999));
        assertEq(10, ma.findUpperBound(2000));
        // greater than all elements in the array, it will return the length of the array
        assertEq(11, ma.findUpperBound(2001));
    }

    function test_FindUpperBound_WithZeroLength() external {
        ma.clearArrUint();
        assertEq(ma.getLength(0), 0);
        // return 0 when the target array is empty
        assertEq(0, ma.findUpperBound(0));
        assertEq(0, ma.findUpperBound(1));
    }
}

contract ArrayLayoutChecker {
    uint public a = 2;
    uint[] public arr = [0xdddd, 0xeeee, 0xffff];
    address public addr = address(1024);
    address[4] public addrs = [address(0xa), address(0xb), address(0xc), address(0xd)];

    function pushArr(uint v) external {
        arr.push(v);
    }

    function getArrLength() external view returns (uint){
        return arr.length;
    }
}