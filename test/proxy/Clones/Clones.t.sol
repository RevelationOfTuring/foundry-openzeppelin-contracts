// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/proxy/MockClones.sol";
import "./Implement.sol";

contract ClonesTest is Test {
    MockClones private _testing = new MockClones();
    Implement private _implement = new Implement();

    function test_Clone() external {
        address minimalProxyAddrCloneByOpCreate = _testing.clone(address(_implement));
        testsForMinimalProxyClone(minimalProxyAddrCloneByOpCreate);
    }

    function test_CloneDeterministic() external {
        bytes32 salt = keccak256("salt");
        address minimalProxyAddrCloneByOpCreate2 = _testing.cloneDeterministic(address(_implement), salt);
        testsForMinimalProxyClone(minimalProxyAddrCloneByOpCreate2);

        // revert if clone by opcode CREATE2 with the same salt again
        vm.expectRevert("ERC1167: create2 failed");
        _testing.cloneDeterministic(address(_implement), salt);
    }

    event ImplementReceive(uint value);
    event ImplementFallback(uint value);

    function testsForMinimalProxyClone(address minimalProxyAddress) private {
        Implement minimalProxy = Implement(payable(minimalProxyAddress));
        uint proxyBalance = minimalProxyAddress.balance;
        uint ethValue = 1 wei;
        assertEq(proxyBalance, 0);

        // case 1: test for both writing slot and return data in type uint256
        assertEq(minimalProxy.i(), 0);
        assertEq(_implement.i(), 0);

        // call without eth value
        minimalProxy.setUint(1024);
        assertEq(minimalProxy.i(), 1024);
        assertEq(_implement.i(), 0);

        // call with eth value
        minimalProxy.setUintPayable{value: ethValue}(2048);
        assertEq(minimalProxy.i(), 2048);
        assertEq(_implement.i(), 0);
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // case 2: test for both writing slot and return data in type address
        assertEq(minimalProxy.addr(), address(0));
        assertEq(_implement.addr(), address(0));

        // call without eth value
        minimalProxy.setAddress(address(1024));
        assertEq(minimalProxy.addr(), address(1024));
        assertEq(_implement.addr(), address(0));

        // call with eth value
        minimalProxy.setAddressPayable{value: ethValue}(address(2048));
        assertEq(minimalProxy.addr(), address(2048));
        assertEq(_implement.addr(), address(0));
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // case 3: test for both writing slot and return data in type fixed array
        assertEq(minimalProxy.fixedArray(0), 0);
        assertEq(_implement.fixedArray(0), 0);

        // call without eth value
        uint[3] memory targetFixedArray = [uint(1024), 2048, 4096];
        minimalProxy.setFixedArray(targetFixedArray);
        for (uint i; i < targetFixedArray.length; ++i) {
            assertEq(minimalProxy.fixedArray(i), targetFixedArray[i]);
            assertEq(_implement.fixedArray(i), 0);
        }

        // call with eth value
        targetFixedArray = [uint(2048), 4096, 8192];
        minimalProxy.setFixedArrayPayable{value: ethValue}(targetFixedArray);
        for (uint i; i < targetFixedArray.length; ++i) {
            assertEq(minimalProxy.fixedArray(i), targetFixedArray[i]);
            assertEq(_implement.fixedArray(i), 0);
        }
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // case 4: test for both writing slot and return data in type dynamic array
        // revert when make a staticcall to an uninitialized dynamic array with the length 0
        vm.expectRevert();
        minimalProxy.dynamicArray(0);
        vm.expectRevert();
        _implement.dynamicArray(0);

        // call without eth value
        uint[] memory targetDynamicArray = new uint[](3);
        targetDynamicArray[0] = 1024;
        targetDynamicArray[1] = 2048;
        targetDynamicArray[2] = 4096;

        minimalProxy.setDynamicArray(targetDynamicArray);
        for (uint i; i < targetDynamicArray.length; ++i) {
            assertEq(minimalProxy.dynamicArray(i), targetDynamicArray[i]);
            vm.expectRevert();
            assertEq(_implement.dynamicArray(i), 0);
        }

        // call with eth value
        targetDynamicArray[0] = 2048;
        targetDynamicArray[1] = 4096;
        targetDynamicArray[2] = 8192;

        minimalProxy.setDynamicArrayPayable{value: ethValue}(targetDynamicArray);
        for (uint i; i < targetDynamicArray.length; ++i) {
            assertEq(minimalProxy.dynamicArray(i), targetDynamicArray[i]);
            vm.expectRevert();
            assertEq(_implement.dynamicArray(i), 0);
        }
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // case 5: test for both writing slot and return data in type mapping
        uint key = 1024;
        uint value = 2048;
        assertEq(minimalProxy.map(key), 0);
        assertEq(_implement.map(key), 0);

        // call without eth value
        minimalProxy.setMapping(key, value);
        assertEq(minimalProxy.map(key), value);
        assertEq(_implement.map(key), 0);

        // call with eth value
        key += 1024;
        minimalProxy.setMappingPayable{value: ethValue}(key, value);
        assertEq(minimalProxy.map(key), value);
        assertEq(_implement.map(key), 0);
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // case 6: test for reverting with msg
        // call without eth value
        vm.expectRevert("Implement: revert");
        minimalProxy.triggerRevert();
        vm.expectRevert("Implement: revert");
        _implement.triggerRevert();

        // call with eth value
        vm.expectRevert("Implement: revert");
        minimalProxy.triggerRevertPayable{value: ethValue}();
        vm.expectRevert("Implement: revert");
        _implement.triggerRevertPayable{value: ethValue}();

        // case 7: test for calling pure (staticcall)
        assertEq(minimalProxy.getPure(), "pure return value");
        assertEq(_implement.getPure(), "pure return value");

        // case 8: test call with eth value
        // go into receive() without calldata
        vm.expectEmit(minimalProxyAddress);
        emit ImplementReceive(ethValue);
        (bool ok,) = minimalProxyAddress.call{value: ethValue}("");
        assertTrue(ok);
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);
        proxyBalance = minimalProxyAddress.balance;

        // go into fallback() with calldata of unknown function selector
        vm.expectEmit(minimalProxyAddress);
        emit ImplementFallback(ethValue);
        bytes memory calldata_ = abi.encodeWithSignature("unknown()");
        (ok,) = minimalProxyAddress.call{value: ethValue}(calldata_);
        assertTrue(ok);
        assertEq(minimalProxyAddress.balance, proxyBalance + ethValue);

        // case 9: test call without eth value
        // go into receive() without calldata
        vm.expectEmit(minimalProxyAddress);
        emit ImplementReceive(0);
        (ok,) = minimalProxyAddress.call("");
        assertTrue(ok);

        // go into fallback() with calldata of unknown function selector
        vm.expectEmit(minimalProxyAddress);
        emit ImplementFallback(0);
        (ok,) = minimalProxyAddress.call(calldata_);
        assertTrue(ok);
    }

    function test_PredictDeterministicAddress() external {
        address implementationAddr = address(_implement);
        bytes32 salt = keccak256("salt");
        // test for predictDeterministicAddress(address,bytes32)
        assertEq(
            _testing.predictDeterministicAddress(implementationAddr, salt),
            _testing.cloneDeterministic(implementationAddr, salt)
        );

        // test for predictDeterministicAddress(address,bytes32,address)
        salt = keccak256("other salt");
        assertEq(
            _testing.predictDeterministicAddress(implementationAddr, salt, address(_testing)),
            _testing.cloneDeterministic(implementationAddr, salt)
        );
    }
}