// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/structs/BitMaps.sol";

contract MockBitMaps {
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap _bitMap;

    function get(uint index) external view returns (bool) {
        return _bitMap.get(index);
    }

    function setTo(
        uint index,
        bool value
    ) external {
        _bitMap.setTo(index, value);
    }

    function set(uint index) external {
        _bitMap.set(index);
    }

    function unset(uint index) external {
        _bitMap.unset(index);
    }
}
