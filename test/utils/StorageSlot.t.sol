// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockStorageSlot.sol";

contract StorageSlotTest is Test {
    MockStorageSlot testing = new MockStorageSlot();

    function test_SetAndGetAddressSlot() external {
        assertEq(testing.getAddressSlot(), address(0));
        testing.setAddressSlot(address(1024));
        assertEq(testing.getAddressSlot(), address(1024));

        // check the slot value by the slot number
        bytes32 slotNumber = testing._ADDRESS_SLOT();
        address valueInSlot = address(uint160(uint(vm.load(address(testing), slotNumber))));
        assertEq(testing.getAddressSlot(), valueInSlot);
    }

    function test_SetAndGetBooleanSlot() external {
        assertFalse(testing.getBooleanSlot());
        testing.setBooleanSlot(true);
        assertTrue(testing.getBooleanSlot());

        // check the slot value by the slot number
        bytes32 slotNumber = testing._BOOLEAN_SLOT();
        bool valueInSlot = vm.load(address(testing), slotNumber) == bytes32(0) ? false : true;
        assertEq(testing.getBooleanSlot(), valueInSlot);
    }

    function test_SetAndGetBytes32Slot() external {
        assertEq(testing.getBytes32Slot(), "");
        testing.setBytes32Slot("a");
        assertEq(testing.getBytes32Slot(), "a");

        // check the slot value by the slot number
        bytes32 slotNumber = testing._BYTES32_SLOT();
        bytes32 valueInSlot = vm.load(address(testing), slotNumber);
        assertEq(testing.getBytes32Slot(), valueInSlot);
    }

    function test_SetAndGetUint256Slot() external {
        assertEq(testing.getUint256Slot(), 0);
        testing.setUint256Slot(1024);
        assertEq(testing.getUint256Slot(), 1024);

        // check the slot value by the slot number
        bytes32 slotNumber = testing._UINT256_SLOT();
        uint valueInSlot = uint(vm.load(address(testing), slotNumber));
        assertEq(testing.getUint256Slot(), valueInSlot);
    }

    function test_SetAndGetUintSlotForTheDefaultStorageVariable() external {
        assertEq(testing.slot0(), 0);
        // set the slot0 by slot number
        testing.setUintValueBySlotNumber(bytes32(0), 1024);
        // check the query by testing.slot0() and slot number
        assertEq(testing.getUintValueBySlotNumber(bytes32(0)), 1024);
        assertEq(testing.getUintValueBySlotNumber(bytes32(0)), testing.slot0());

        // check the value of slot1 and slot2
        assertEq(testing.slot1(), 10);
        assertEq(testing.slot1(), testing.getUintValueBySlotNumber(bytes32(uint(1))));
        assertEq(testing.slot2(), 20);
        assertEq(testing.slot2(), testing.getUintValueBySlotNumber(bytes32(uint(2))));
    }
}
