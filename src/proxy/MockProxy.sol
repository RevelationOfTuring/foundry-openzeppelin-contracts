// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/Proxy.sol";

contract MockProxy is Proxy {
    address immutable private _IMPLEMENTATION_ADDR;
    bool immutable private _ENABLE_BEFORE_FALLBACK;

    event ProxyBeforeFallback(uint value);

    constructor(
        address implementationAddress,
        bool enableBeforeFallback
    ){
        _IMPLEMENTATION_ADDR = implementationAddress;
        _ENABLE_BEFORE_FALLBACK = enableBeforeFallback;
    }

    function _implementation() internal view override returns (address){
        return _IMPLEMENTATION_ADDR;
    }

    function _beforeFallback() internal override {
        if (_ENABLE_BEFORE_FALLBACK) {
            emit ProxyBeforeFallback(msg.value);
        }
    }
}
