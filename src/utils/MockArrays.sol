// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Arrays.sol";

contract MockArrays {
    using Arrays for uint[];
    using Arrays for bytes32[];
    using Arrays for address[];

    uint[] public arrUint = [1, 2, 11, 19, 21, 22, 100, 201, 224, 999];
    bytes32[] public arrBytes32 = [bytes32('a'), bytes32('b'), bytes32('c'), bytes32('d'), bytes32('e')];
    address[] public arrAddress = [address(0xff), address(0xee), address(0xdd), address(0xcc), address(0xbb), address(0xaa)];

    function findUpperBound(uint element) external view returns (uint){
        return arrUint.findUpperBound(element);
    }

    function unsafeAccessUintArrays(uint pos) external view returns (uint){
        return arrUint.unsafeAccess(pos).value;
    }

    function unsafeAccessBytes32Arrays(uint pos) external view returns (bytes32){
        return arrBytes32.unsafeAccess(pos).value;
    }

    function unsafeAccessAddressArrays(uint pos) external view returns (address){
        return arrAddress.unsafeAccess(pos).value;
    }

    function clearArrUint() external {
        delete arrUint;
    }

    function addArrUint(uint element) external {
        arrUint.push(element);
    }

    function getLength(uint slotNumber) external view returns (uint){
        if (slotNumber == 0) {
            return arrUint.length;
        } else if (slotNumber == 1) {
            return arrBytes32.length;
        } else if (slotNumber == 2) {
            return arrAddress.length;
        } else {
            return 0;
        }
    }
}
