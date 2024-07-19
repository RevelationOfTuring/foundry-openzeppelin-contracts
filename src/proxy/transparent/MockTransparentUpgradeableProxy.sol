// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

interface IMockTransparentUpgradeableProxy {
    event DoIfAdmin(uint);
}

contract MockTransparentUpgradeableProxy is TransparentUpgradeableProxy, IMockTransparentUpgradeableProxy {
    constructor(
        address logic,
        address adminAddress,
        bytes memory data
    )
    TransparentUpgradeableProxy(logic, adminAddress, data)
    {}

    function doIfAdmin(uint arg) external ifAdmin {
        emit DoIfAdmin(arg);
    }

    // has the same selector with function `implementation49979()` in implementation
    // CAUTION: to explain why `ifAdmin` is deprecated
    function proxy71997(uint arg) external ifAdmin {
        emit DoIfAdmin(arg);
    }
}
