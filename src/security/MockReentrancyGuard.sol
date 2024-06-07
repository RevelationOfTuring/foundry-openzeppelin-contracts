// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract MockReentrancyGuard is ReentrancyGuard {
    uint public counter;

    function addWithoutNonReentrant() external {
        _add();
    }

    function callWithoutNonReentrant(address target, bytes calldata calldata_) external {
        _call(target, calldata_);
    }

    function addWithNonReentrant() external nonReentrant {
        _add();
    }

    function callWithNonReentrant(address target, bytes calldata calldata_) external nonReentrant {
        _call(target, calldata_);
    }

    function _call(address target, bytes calldata calldata_) private {
        (bool ok, bytes memory returnData) = target.call(calldata_);
        require(ok, string(returnData));
        counter += 10;
    }

    function _add() private {
        ++counter;
    }
}
