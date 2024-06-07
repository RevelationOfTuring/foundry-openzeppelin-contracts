// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/security/MockReentrancyGuard.sol";
import "./Reentrant.sol";

contract ReentrancyGuardTest is Test {
    MockReentrancyGuard private _testing = new MockReentrancyGuard();
    Reentrant private _reentrant = new Reentrant(address(_testing));

    function test_LocalCall() external {
        // A and B are both local external methods in one contract

        // case 1: A without nonReentrant -> B without nonReentrant
        // [PASS]
        // call {addWithoutNonReentrant} in {callWithoutNonReentrant}
        assertEq(_testing.counter(), 0);
        bytes memory calldata_ = abi.encodeCall(_testing.addWithoutNonReentrant, ());
        _testing.callWithoutNonReentrant(address(_testing), calldata_);
        uint counterValue = _testing.counter();
        assertEq(counterValue, 1 + 10);

        // case 2: A without nonReentrant -> B with nonReentrant
        // [PASS]
        // call {addWithNonReentrant} in {callWithoutNonReentrant}
        calldata_ = abi.encodeCall(_testing.addWithNonReentrant, ());
        _testing.callWithoutNonReentrant(address(_testing), calldata_);
        assertEq(_testing.counter(), counterValue + 1 + 10);
        counterValue = _testing.counter();

        // case 3: A with nonReentrant -> B without nonReentrant
        // [PASS]
        // call {addWithoutNonReentrant} in {callWithNonReentrant}
        calldata_ = abi.encodeCall(_testing.addWithoutNonReentrant, ());
        _testing.callWithNonReentrant(address(_testing), calldata_);
        assertEq(_testing.counter(), counterValue + 1 + 10);

        // case 4: A with nonReentrant -> B with nonReentrant
        // [REVERT]
        // call {addWithNonReentrant} in {callWithNonReentrant}
        calldata_ = abi.encodeCall(_testing.addWithNonReentrant, ());
        // the provided string in `require(bool,string)` is abi-encoded as if it were a call to a function `Error(string)`
        bytes memory encodedRevertMsg = abi.encodeWithSignature("Error(string)", "ReentrancyGuard: reentrant call");
        vm.expectRevert(encodedRevertMsg);
        _testing.callWithNonReentrant(address(_testing), calldata_);
    }

    function test_ExternalCall() external {
        // A and B are both local external methods in one contract
        // C is an external method in another contract

        // case 1: A without nonReentrant -> B -> C without nonReentrant
        // [PASS]
        // {callWithoutNonReentrant} -> {Reentrant.callback} -> {addWithoutNonReentrant}
        assertEq(_testing.counter(), 0);
        bytes memory calldata_ = abi.encodeCall(
            _reentrant.callback,
            (
                abi.encodeCall(_testing.addWithoutNonReentrant, ())
            )
        );
        _testing.callWithoutNonReentrant(address(_reentrant), calldata_);
        uint counterValue = _testing.counter();
        assertEq(counterValue, 1 + 10);

        // case 2: A without nonReentrant -> B -> C with nonReentrant
        // [PASS]
        // {callWithoutNonReentrant} -> {Reentrant.callback} -> {addWithNonReentrant}
        calldata_ = abi.encodeCall(
            _reentrant.callback,
            (
                abi.encodeCall(_testing.addWithNonReentrant, ())
            )
        );
        _testing.callWithoutNonReentrant(address(_reentrant), calldata_);
        assertEq(_testing.counter(), counterValue + 1 + 10);
        counterValue = _testing.counter();

        // case 3: A with nonReentrant -> B -> C without nonReentrant
        // [PASS]
        // {callWithNonReentrant} -> {Reentrant.callback} -> {addWithoutNonReentrant}
        calldata_ = abi.encodeCall(
            _reentrant.callback,
            (
                abi.encodeCall(_testing.addWithoutNonReentrant, ())
            )
        );
        _testing.callWithNonReentrant(address(_reentrant), calldata_);
        assertEq(_testing.counter(), counterValue + 1 + 10);

        // case 4: A with nonReentrant -> B -> C with nonReentrant
        // [REVERT]
        // {callWithNonReentrant} -> {Reentrant.callback} -> {addWithNonReentrant}
        calldata_ = abi.encodeCall(
            _reentrant.callback,
            (
                abi.encodeCall(_testing.addWithNonReentrant, ())
            )
        );
        // the provided string in `require(bool,string)` is abi-encoded as if it were a call to a function `Error(string)`
        bytes memory encodedRevertMsg = abi.encodeWithSignature("Error(string)", "ReentrancyGuard: reentrant call");
        vm.expectRevert(encodedRevertMsg);
        _testing.callWithNonReentrant(address(_reentrant), calldata_);
    }
}
