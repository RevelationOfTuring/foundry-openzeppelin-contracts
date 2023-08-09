// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract STATICCALLTest is Test {
    Target t = new Target();

    function test_Staticcall_ReturnUint() external {
        bytes memory encodedParams = abi.encodeCall(t.getN, ());
        address targetAddr = address(t);
        bytes32 outPtr;
        // case 1: right outsize for return data (uint)
        uint outSize = 0x20;
        bool success;
        uint returnSize;
        bytes32 originalValueOnOutPtr;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
            originalValueOnOutPtr := mload(outPtr)
        }
        assertTrue(success);
        assertEq(returnSize, 0x20);
        uint n = t.getN();
        assertEq(n, uint(originalValueOnOutPtr));

        // case 2: insufficient outsize for return data
        outSize = 0x00;
        bytes32 outValueFromReturnDataCopy;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
            originalValueOnOutPtr := mload(outPtr)
        // copy return data (returnSize bytes) with returndatacopy() to the outPtr
            returndatacopy(outPtr, 0x00, returnSize)
            outValueFromReturnDataCopy := mload(outPtr)
        }
        assertTrue(success);
        assertEq(returnSize, 0x20);
        assertNotEq(n, uint(originalValueOnOutPtr));
        assertEq(n, uint(outValueFromReturnDataCopy));

        // case 3: outsize more than the size of return data
        outSize = 0x40;
        bytes32 restBytesInOutSize;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
            originalValueOnOutPtr := mload(outPtr)
        // outsize中多余出来的未使用的内容
            restBytesInOutSize := mload(add(outPtr, returnSize))
        }

        assertTrue(success);
        assertEq(returnSize, 0x20);
        assertEq(n, uint(originalValueOnOutPtr));
        // untouched
        assertEq(0, restBytesInOutSize);
    }

    function test_Staticcall_ReturnUintAndAddress() external {
        bytes memory encodedParams = abi.encodeCall(t.getNAndAddr, ());
        address targetAddr = address(t);
        bytes32 outPtr;
        // case 1: right outsize for return data (uint and address)
        uint outSize = 0x40;
        bool success;
        uint returnSize;
        bytes32 originalValueOnOutPtr;
        bytes32 nextWordOfOutPtr;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为2个字，即32*2=64个字节（即0x40）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
        // outPtr开始，第一个字为第一个uint返回值，第二个字为第二个address返回值
            originalValueOnOutPtr := mload(outPtr)
            nextWordOfOutPtr := mload(add(outPtr, 0x20))
        }
        assertTrue(success);
        assertEq(returnSize, 0x40);
        (uint n, address addr) = t.getNAndAddr();
        assertEq(n, uint(originalValueOnOutPtr));
        assertEq(addr, address(uint160(uint(nextWordOfOutPtr))));

        // case 2: insufficient outsize for return data
        outSize = 0x20;
        bytes32 outValueFromReturnDataCopy;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为1个字，即32*1=32个字节（即0x20）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
        // outPtr开始，第一个字为第一个uint返回值
            originalValueOnOutPtr := mload(outPtr)
        // 第二个字不再是第二个address返回值，因为outSize不够
            nextWordOfOutPtr := mload(add(outPtr, 0x20))
        // 从returndata中复制第二个字到outPtr指向的内存中
            returndatacopy(outPtr, 0x20, 0x20)
        // 从outPtr指向的内存中取出内容（即returndata中的第二个address返回值）
            outValueFromReturnDataCopy := mload(outPtr)
        }
        assertTrue(success);
        assertEq(returnSize, 0x40);
        assertEq(n, uint(originalValueOnOutPtr));
        // 由于outSize设置过小，outPtr开始的第二个字内容不是returndata中的第二个address返回值
        assertNotEq(addr, address(uint160(uint(nextWordOfOutPtr))));
        assertEq(addr, address(uint160(uint(outValueFromReturnDataCopy))));

        // case 3: outsize more than the size of return data
        outSize = 0x60;
        bytes32 restBytesInOutSize;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为3个字，即32*3=96个字节（即0x60）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
            originalValueOnOutPtr := mload(outPtr)
            nextWordOfOutPtr := mload(add(outPtr, 0x20))
        // outsize中多余出来的未使用的内容
            restBytesInOutSize := mload(add(outPtr, returnSize))
        }
        assertTrue(success);
        assertEq(returnSize, 0x40);
        assertEq(n, uint(originalValueOnOutPtr));
        assertEq(addr, address(uint160(uint(nextWordOfOutPtr))));
        // untouched
        assertEq(0, restBytesInOutSize);
    }

    function test_Staticcall_ReturnUintArr() external {
        bytes memory encodedParams = abi.encodeCall(t.getArr, ());
        address targetAddr = address(t);
        bytes32 outPtr;
        // case 1: right outsize for return data
        // (uint[] with 2 members —— 1(offset to start the array) + 1(length of array) + 2(2 words for 3 members) = 4)
        uint outSize = 0x80;
        bool success;
        uint returnSize;
        bytes32 originalValueOnOutPtr;
        bytes32 secondWordOfOutPtr;
        bytes32 thirdWordOfOutPtr;
        bytes32 forthWordOfOutPtr;
        bytes32 fifthWordOfOutPtr;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为5个字，即32*4=128个字节（即0x80）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
        // outPtr开始，第一个字为动态数组真实数据的偏移值
            originalValueOnOutPtr := mload(outPtr)
        // 第二个字为动态数组长度
            secondWordOfOutPtr := mload(add(outPtr, 0x20))
        // 第三个字为第一个元素值
            thirdWordOfOutPtr := mload(add(outPtr, 0x40))
        // 第四个字为第二个元素值
            forthWordOfOutPtr := mload(add(outPtr, 0x60))
        }
        assertTrue(success);
        assertEq(0x80, returnSize);
        uint[] memory arr = t.getArr();
        // offset to start the uint array is 0x20
        assertEq(0x20, uint(originalValueOnOutPtr));
        // 动态数组长度
        assertEq(arr.length, uint(secondWordOfOutPtr));
        // 依次为2个元素的值
        assertEq(arr[0], uint(thirdWordOfOutPtr));
        assertEq(arr[1], uint(forthWordOfOutPtr));


        // case 2: insufficient outsize for return data
        // (uint[] with 2 members —— 1(offset to start the array) + 1(length of array) + 2(2 words for 3 members) = 4)
        outSize = 0x20;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为1个字，即32*1=32个字节（即0x20）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
        // outPtr开始，第一个字为动态数组真实数据的偏移值
            originalValueOnOutPtr := mload(outPtr)
        // 第二个字不再是动态数组的长度，因为outSize不够
            secondWordOfOutPtr := mload(add(outPtr, 0x20))
        }
        assertTrue(success);
        assertEq(0x80, returnSize);
        // offset to start the uint array is 0x20
        assertEq(0x20, uint(originalValueOnOutPtr));
        // returndatacopy()之前，outPtr后的第二个字内容不是数组长度
        assertNotEq(arr.length, uint(secondWordOfOutPtr));

        assembly{
        // 从returndata中复制第二个至第四个字到outPtr+0x20开始的内存中
            returndatacopy(add(outPtr, 0x20), 0x20, sub(returnSize, 0x20))
        // outPtr后的第二个字为数组长度
            secondWordOfOutPtr := mload(add(outPtr, 0x20))
        // 第三个字为第一个元素值
            thirdWordOfOutPtr := mload(add(outPtr, 0x40))
        // 第四个字为第二个元素值
            forthWordOfOutPtr := mload(add(outPtr, 0x60))
        }
        // returndatacopy()之后，outPtr后的第二个字内容为数组长度
        assertEq(arr.length, uint(secondWordOfOutPtr));
        // returndatacopy()之后，outPtr后的第三个至第五个字内容依次为数组元素值
        assertEq(arr[0], uint(thirdWordOfOutPtr));
        assertEq(arr[1], uint(forthWordOfOutPtr));

        // case 3: outsize more than the size of return data
        // (uint[] with 2 members —— 1(offset to start the array) + 1(length of array) + 2(2 words for 3 members) = 4)
        outSize = (4 + 1) * 0x20;
        assembly{
            outPtr := mload(0x40)  // free memory pointer
        // outsize为5个字，即32*5=160个字节（即0xa0）
            success := staticcall(100000, targetAddr, add(encodedParams, 0x20), mload(encodedParams), outPtr, outSize)
            returnSize := returndatasize()
        // outPtr开始，第一个字为动态数组真实数据的偏移值
            originalValueOnOutPtr := mload(outPtr)
        // 第二个字为动态数组长度
            secondWordOfOutPtr := mload(add(outPtr, 0x20))
        // 第三个字为第一个元素值
            thirdWordOfOutPtr := mload(add(outPtr, 0x40))
        // 第四个字为第二个元素值
            forthWordOfOutPtr := mload(add(outPtr, 0x60))
        // 第五个字为outsize中未使用的空间
            fifthWordOfOutPtr := mload(add(outPtr, 0x80))
        }
        assertTrue(success);
        assertEq(0x80, returnSize);
        // offset to start the uint array is 0x20
        assertEq(0x20, uint(originalValueOnOutPtr));
        // 动态数组长度
        assertEq(arr.length, uint(secondWordOfOutPtr));
        // 依次为2个元素的值
        assertEq(arr[0], uint(thirdWordOfOutPtr));
        assertEq(arr[1], uint(forthWordOfOutPtr));
        // 第五个字为untouched
        assertEq(0, fifthWordOfOutPtr);
    }
}

contract Target {
    uint _n = 1024;
    address _addr = address(1);
    uint[] _arr = [1, 2];

    function getN() external view returns (uint){
        return _n;
    }

    function getNAndAddr() external view returns (uint, address){
        return (_n, _addr);
    }

    function getArr() external view returns (uint[] memory){
        return _arr;
    }
}