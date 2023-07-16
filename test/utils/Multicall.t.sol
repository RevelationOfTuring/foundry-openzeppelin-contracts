// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockMulticall.sol";

contract MulticallTest is Test {
    MockMulticall mc = new MockMulticall();

    function test_Multicall() external {
        // a batch of 4 function calls:
        // 1. add(5): return ""
        // 2. getNumber(): return 0+5
        // 3. mul(10): return ""
        // 4. getNumber(): return (0+5)*10

        bytes[] memory calldatas = new bytes[](4);
        calldatas[0] = abi.encodeCall(mc.add, (5));
        calldatas[1] = abi.encodeCall(mc.getNumber, ());
        calldatas[2] = abi.encodeCall(mc.mul, (10));
        calldatas[3] = calldatas[1];

        bytes[] memory results = mc.multicall(calldatas);
        assertEq(results[0], "");
        assertEq(results[1], abi.encode(0 + 5));
        assertEq(results[2], "");
        assertEq(results[3], abi.encode(5 * 10));
    }
}
