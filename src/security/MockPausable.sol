// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/Pausable.sol";

contract MockPausable is Pausable {
    constructor() Pausable() {}

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function doSomethingWhenPaused() external whenPaused {}

    function doSomethingWhenNotPaused() external whenNotPaused {}
}
