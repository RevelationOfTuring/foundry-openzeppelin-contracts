// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/proxy/MockProxy.sol";
import "./Implement.sol";

contract ProxyTest is Test {
    Implement private _implement = new Implement();
    address payable private _testingAddress = payable(address(new MockProxy(address(_implement), false)));

    event ImplementFallback(uint value);
    event ImplementReceive(uint value);

    function test_Call() external {
        Implement proxy = Implement(_testingAddress);
        // case 1: set uint256
        assertEq(proxy.i(), 0);
        assertEq(_implement.i(), 0);

        proxy.setUint(1024);
        // check storage by static call
        assertEq(proxy.i(), 1024);
        assertEq(_implement.i(), 0);
        // check storage by slot number
        bytes32 slotNumber = bytes32(uint(0));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(uint(1024)));

        // case 2: set address
        assertEq(proxy.addr(), address(0));
        assertEq(_implement.addr(), address(0));

        proxy.setAddress(address(2048));
        // check storage by static call
        assertEq(proxy.addr(), address(2048));
        assertEq(_implement.addr(), address(0));
        // check storage by slot number
        slotNumber = bytes32(uint(1));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(uint(2048)));

        // case 3: set fixed array
        assertEq(proxy.fixedArray(0), 0);
        assertEq(_implement.fixedArray(0), 0);
        uint[3] memory targetFixedArray = [uint(1024), 2048, 4096];

        proxy.setFixedArray(targetFixedArray);
        for (uint i; i < 3; ++i) {
            // check storage by static call
            assertEq(proxy.fixedArray(i), targetFixedArray[i]);
            assertEq(_implement.fixedArray(i), 0);
            // check storage by slot number
            slotNumber = bytes32(uint(2 + i));
            assertEq(vm.load(_testingAddress, slotNumber), bytes32(targetFixedArray[i]));
        }

        // case 4: set dynamic array
        // revert during static call because dynamic array isn't initialized
        vm.expectRevert();
        proxy.dynamicArray(0);
        vm.expectRevert();
        _implement.dynamicArray(0);
        // build dynamic array as input
        uint[] memory targetDynamicArray = new uint[](3);
        targetDynamicArray[0] = 1024;
        targetDynamicArray[1] = 2048;
        targetDynamicArray[2] = 4096;

        proxy.setDynamicArray(targetDynamicArray);
        for (uint i; i < 3; ++i) {
            // check storage by static call
            assertEq(proxy.dynamicArray(i), targetDynamicArray[i]);
            vm.expectRevert();
            assertEq(_implement.dynamicArray(i), 0);
            // check storage by slot number
            slotNumber = bytes32(uint(keccak256(abi.encodePacked(uint(5)))) + i);
            assertEq(vm.load(_testingAddress, slotNumber), bytes32(targetDynamicArray[i]));
        }

        // case 5: set mapping
        uint key = 1024;
        uint value = 2048;
        assertEq(proxy.map(key), 0);
        assertEq(_implement.map(key), 0);

        proxy.setMapping(key, value);
        // check storage by static call
        assertEq(proxy.map(key), value);
        assertEq(_implement.map(key), 0);
        // check storage by slot number
        slotNumber = bytes32(uint(keccak256(abi.encodePacked(key, uint(6)))));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(value));

        // case 6: revert with msg
        vm.expectRevert("Implement: revert");
        proxy.triggerRevert();

        // case 7: call pure (staticcall)
        assertEq(proxy.getPure(), "pure return value");

        // case 8: call the function not exists in the implement
        // and delegate call to the fallback function of implement
        vm.expectEmit(_testingAddress);
        emit ImplementFallback(0);
        bytes memory calldata_ = abi.encodeWithSignature("unknown()");
        (bool ok,) = _testingAddress.call(calldata_);
        assertTrue(ok);

        // case 9: call without value and calldata
        // and delegate call to the receive function of implement
        vm.expectEmit(_testingAddress);
        emit ImplementReceive(0);
        (ok,) = _testingAddress.call("");
        assertTrue(ok);
    }

    function test_PayableCall() external {
        Implement proxy = Implement(_testingAddress);
        uint proxyBalance = _testingAddress.balance;
        assertEq(proxyBalance, 0);

        // case 1: set uint256 payable
        assertEq(proxy.i(), 0);
        assertEq(_implement.i(), 0);

        uint ethValue = 1 wei;
        proxy.setUintPayable{value: ethValue}(1024);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // check storage by static call
        assertEq(proxy.i(), 1024);
        assertEq(_implement.i(), 0);
        // check storage by slot number
        bytes32 slotNumber = bytes32(uint(0));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(uint(1024)));

        // case 2: set address payble
        assertEq(proxy.addr(), address(0));
        assertEq(_implement.addr(), address(0));

        proxy.setAddressPayable{value: ethValue}(address(2048));
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // check storage by static call
        assertEq(proxy.addr(), address(2048));
        assertEq(_implement.addr(), address(0));
        // check storage by slot number
        slotNumber = bytes32(uint(1));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(uint(2048)));

        // case 3: set fixed array payable
        assertEq(proxy.fixedArray(0), 0);
        assertEq(_implement.fixedArray(0), 0);
        uint[3] memory targetFixedArray = [uint(1024), 2048, 4096];

        proxy.setFixedArrayPayable{value: ethValue}(targetFixedArray);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;
        for (uint i; i < 3; ++i) {
            // check storage by static call
            assertEq(proxy.fixedArray(i), targetFixedArray[i]);
            assertEq(_implement.fixedArray(i), 0);
            // check storage by slot number
            slotNumber = bytes32(uint(2 + i));
            assertEq(vm.load(_testingAddress, slotNumber), bytes32(targetFixedArray[i]));
        }

        // case 4: set dynamic array payable
        // revert during static call because dynamic array isn't initialized
        vm.expectRevert();
        proxy.dynamicArray(0);
        vm.expectRevert();
        _implement.dynamicArray(0);
        // build dynamic array as input
        uint[] memory targetDynamicArray = new uint[](3);
        targetDynamicArray[0] = 1024;
        targetDynamicArray[1] = 2048;
        targetDynamicArray[2] = 4096;

        proxy.setDynamicArrayPayable{value: ethValue}(targetDynamicArray);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;
        for (uint i; i < 3; ++i) {
            // check storage by static call
            assertEq(proxy.dynamicArray(i), targetDynamicArray[i]);
            vm.expectRevert();
            assertEq(_implement.dynamicArray(i), 0);
            // check storage by slot number
            slotNumber = bytes32(uint(keccak256(abi.encodePacked(uint(5)))) + i);
            assertEq(vm.load(_testingAddress, slotNumber), bytes32(targetDynamicArray[i]));
        }

        // case 5: set mapping payable
        uint key = 1024;
        uint value = 2048;
        assertEq(proxy.map(key), 0);
        assertEq(_implement.map(key), 0);

        proxy.setMappingPayable{value: ethValue}(key, value);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;
        // check storage by static call
        assertEq(proxy.map(key), value);
        assertEq(_implement.map(key), 0);
        // check storage by slot number
        slotNumber = bytes32(uint(keccak256(abi.encodePacked(key, uint(6)))));
        assertEq(vm.load(_testingAddress, slotNumber), bytes32(value));

        // case 6: revert with msg payable
        vm.expectRevert("Implement: revert");
        proxy.triggerRevertPayable{value: ethValue}();

        // case 7: call the function not exists in the implement with value
        // and delegate call to the fallback function of implement
        vm.expectEmit(_testingAddress);
        emit ImplementFallback(ethValue);
        bytes memory calldata_ = abi.encodeWithSignature("unknown()");
        (bool ok,) = _testingAddress.call{value: ethValue}(calldata_);
        assertTrue(ok);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 8: call with value and empty callata
        // and delegate call to the receive function of implement
        vm.expectEmit(_testingAddress);
        emit ImplementReceive(ethValue);
        (ok,) = _testingAddress.call{value: ethValue}("");
        assertTrue(ok);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
    }

    event ProxyBeforeFallback(uint value);

    function test_beforeFallback() external {
        _testingAddress = payable(address(new MockProxy(address(_implement), true)));
        Implement proxy = Implement(_testingAddress);
        uint proxyBalance = _testingAddress.balance;
        assertEq(proxyBalance, 0);
        uint ethValue = 1 wei;

        // case 1: test setUint()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        proxy.setUint(1024);

        // case 2:test setUintPayable()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        proxy.setUintPayable{value: ethValue}(1024);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 3: test setAddress()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        proxy.setAddress(address(1));

        // case 4: test setAddressPayable()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        proxy.setAddressPayable{value: ethValue}(address(1));
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 5: test setFixedArray()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        uint[3] memory targetFixedArray = [uint(1024), 2048, 4096];
        proxy.setFixedArray(targetFixedArray);

        // case 6: test setFixedArrayPayable()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        proxy.setFixedArrayPayable{value: ethValue}(targetFixedArray);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 7: test setDynamicArray()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        // build dynamic array as input
        uint[] memory targetDynamicArray = new uint[](3);
        targetDynamicArray[0] = 1024;
        targetDynamicArray[1] = 2048;
        targetDynamicArray[2] = 4096;
        proxy.setDynamicArray(targetDynamicArray);

        // case 8: test setDynamicArrayPayable()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        proxy.setDynamicArrayPayable{value: ethValue}(targetDynamicArray);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 9: test setMapping()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        proxy.setMapping(1024, 2048);

        // case 10: test setMapping()
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        proxy.setMappingPayable{value: ethValue}(1024, 2048);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 11: revert with any static call because it emits event in _beforeFallback()
        // and causes the evm error: "StateChangeDuringStaticCall"
        vm.expectRevert();
        proxy.i();
        vm.expectRevert();
        proxy.addr();
        vm.expectRevert();
        proxy.fixedArray(0);
        vm.expectRevert();
        proxy.dynamicArray(0);
        vm.expectRevert();
        proxy.map(1024);
        vm.expectRevert();
        proxy.triggerRevert();
        vm.expectRevert();
        proxy.getPure();

        // case 12: revert in the function of implement during a call
        vm.expectRevert("Implement: revert");
        proxy.triggerRevertPayable{value: ethValue}();

        // case 13: call the function not exists in the implement
        // and delegate call to the fallback function of implement
        // without value
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        emit ImplementFallback(0);
        bytes memory calldata_ = abi.encodeWithSignature("unknown()");
        (bool ok,) = _testingAddress.call(calldata_);
        assertTrue(ok);
        // with value
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        emit ImplementFallback(ethValue);
        (ok,) = _testingAddress.call{value: ethValue}(calldata_);
        assertTrue(ok);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
        proxyBalance += ethValue;

        // case 14: call the proxy with empty call data
        // and delegate call to the receive function of implement
        // without value
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(0);
        emit ImplementReceive(0);
        (ok,) = _testingAddress.call("");
        assertTrue(ok);
        // with value
        vm.expectEmit(_testingAddress);
        emit ProxyBeforeFallback(ethValue);
        emit ImplementReceive(ethValue);
        (ok,) = _testingAddress.call{value: ethValue}("");
        assertTrue(ok);
        assertEq(_testingAddress.balance, proxyBalance + ethValue);
    }
}
