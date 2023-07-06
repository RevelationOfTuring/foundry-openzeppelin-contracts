// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockBase64.sol";

contract Base64Test is Test {
    MockBase64 mb = new MockBase64();

    function test_Encode() external {

        // case 1: 尾部补4个0 (字节长度 % 3==1)
        // data:        0x01
        // 8 bits split: 00000001
        // 6 bits split: 000000| 01 0000 (补4个0)
        // base64 bytes:    A  |    Q==
        assertEq("AQ==", mb.encode(hex"01"));

        // case 2: 尾部补2个0 (字节长度 % 3==2)
        // data:        0x0102
        // 8 bits split: 00000001 | 00000010
        // 6 bits split: 000000 | 010000 | 0010 00 (补2个0)
        // base64 bytes:    A   |    Q   |     I=
        assertEq("AQI=", mb.encode(hex"0102"));

        // case 3: 尾部不补0 (字节长度 % 3==0)
        // data:       0x010203
        // 8 bits split: 00000001 | 00000010 | 00000011
        // 6 bits split: 000000| 010000 | 0001000 | 000011
        // base64 bytes:    A  |    Q   |    I   |    D
        assertEq("AQID", mb.encode(hex"010203"));
    }
}