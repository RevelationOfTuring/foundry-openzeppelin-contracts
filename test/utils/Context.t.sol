// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockContext.sol";

contract ContextTest is Test {
    MockContext mc;

    event MsgContext(address msgSender, bytes msgData, uint number);

    function workerCall(address user, bytes memory inputBytes) external {
        // build metadata into calldata
        bytes memory callData = abi.encodePacked(inputBytes, user);

        (bool ok,) = address(mc).call(callData);
        require(ok, "failed");
    }

    function test_MsgSenderAndMsgData() external {
        mc = new MockContext();
        bytes memory callData = abi.encodeCall(mc.targetFunction, (2048));

        // worker operation
        vm.expectEmit(address(mc));
        emit MsgContext(
            address(1024),
            callData,
            2048
        );
        this.workerCall(address(1024), callData);

        // common user operation
        vm.expectEmit(address(mc));
        emit MsgContext(
            address(1024),
            callData,
            2048
        );
        vm.prank(address(1024));
        mc.targetFunction(2048);
    }
}
