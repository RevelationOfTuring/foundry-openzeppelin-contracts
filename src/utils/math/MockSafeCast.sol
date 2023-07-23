// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/SafeCast.sol";

contract MockSafeCast {
    using SafeCast for uint;
    using SafeCast for int;

    function toUint248(uint256 value) external pure returns (uint248) {
        return value.toUint248();
    }

    function toUint240(uint256 value) external pure returns (uint240) {
        return value.toUint240();
    }

    function toUint232(uint256 value) external pure returns (uint232){
        return value.toUint232();
    }

    function toUint224(uint256 value) external pure returns (uint224){
        return value.toUint224();
    }

    function toUint216(uint256 value) external pure returns (uint216){
        return value.toUint216();
    }

    function toUint208(uint256 value) external pure returns (uint208){
        return value.toUint208();
    }

    function toUint200(uint256 value) external pure returns (uint200){
        return value.toUint200();
    }

    function toUint192(uint256 value) external pure returns (uint192) {
        return value.toUint192();
    }

    function toUint184(uint256 value) external pure returns (uint184){
        return value.toUint184();
    }

    function toUint176(uint256 value) external pure returns (uint176){
        return value.toUint176();
    }

    function toUint168(uint256 value) external pure returns (uint168){
        return value.toUint168();
    }

    function toUint160(uint256 value) external pure returns (uint160){
        return value.toUint160();
    }

    function toUint152(uint256 value) external pure returns (uint152){
        return value.toUint152();
    }

    function toUint144(uint256 value) external pure returns (uint144){
        return value.toUint144();
    }

    function toUint136(uint256 value) external pure returns (uint136){
        return value.toUint136();
    }

    function toUint128(uint256 value) external pure returns (uint128) {
        return value.toUint128();
    }

    function toUint120(uint256 value) external pure returns (uint120) {
        return value.toUint120();
    }

    function toUint112(uint256 value) external pure returns (uint112) {
        return value.toUint112();
    }

    function toUint104(uint256 value) external pure returns (uint104) {
        return value.toUint104();
    }

    function toUint96(uint256 value) external pure returns (uint96){
        return value.toUint96();
    }

    function toUint88(uint256 value) external pure returns (uint88){
        return value.toUint88();
    }

    function toUint80(uint256 value) external pure returns (uint80){
        return value.toUint80();
    }

    function toUint72(uint256 value) external pure returns (uint72){
        return value.toUint72();
    }

    function toUint64(uint256 value) external pure returns (uint64){
        return value.toUint64();
    }

    function toUint56(uint256 value) external pure returns (uint56) {
        return value.toUint56();
    }

    function toUint48(uint256 value) external pure returns (uint48){
        return value.toUint48();
    }

    function toUint40(uint256 value) external pure returns (uint40){
        return value.toUint40();
    }

    function toUint32(uint256 value) external pure returns (uint32) {
        return value.toUint32();
    }

    function toUint24(uint256 value) external pure returns (uint24){
        return value.toUint24();
    }

    function toUint16(uint256 value) external pure returns (uint16){
        return value.toUint16();
    }

    function toUint8(uint256 value) external pure returns (uint8){
        return value.toUint8();
    }

    function toUint256(int256 value) external pure returns (uint256) {
        return value.toUint256();
    }

    function toInt248(int256 value) external pure returns (int248){
        return value.toInt248();
    }

    function toInt240(int256 value) external pure returns (int240){
        return value.toInt240();
    }

    function toInt232(int256 value) external pure returns (int232){
        return value.toInt232();
    }

    function toInt224(int256 value) external pure returns (int224) {
        return value.toInt224();
    }

    function toInt216(int256 value) external pure returns (int216) {
        return value.toInt216();
    }

    function toInt208(int256 value) external pure returns (int208) {
        return value.toInt208();
    }

    function toInt200(int256 value) external pure returns (int200) {
        return value.toInt200();
    }

    function toInt192(int256 value) external pure returns (int192) {
        return value.toInt192();
    }

    function toInt184(int256 value) external pure returns (int184) {
        return value.toInt184();
    }

    function toInt176(int256 value) external pure returns (int176) {
        return value.toInt176();
    }

    function toInt168(int256 value) external pure returns (int168) {
        return value.toInt168();
    }

    function toInt160(int256 value) external pure returns (int160) {
        return value.toInt160();
    }

    function toInt152(int256 value) external pure returns (int152) {
        return value.toInt152();
    }

    function toInt144(int256 value) external pure returns (int144) {
        return value.toInt144();
    }

    function toInt136(int256 value) external pure returns (int136) {
        return value.toInt136();
    }

    function toInt128(int256 value) external pure returns (int128) {
        return value.toInt128();
    }

    function toInt120(int256 value) external pure returns (int120) {
        return value.toInt120();
    }

    function toInt112(int256 value) external pure returns (int112) {
        return value.toInt112();
    }

    function toInt104(int256 value) external pure returns (int104) {
        return value.toInt104();
    }

    function toInt96(int256 value) external pure returns (int96) {
        return value.toInt96();
    }

    function toInt88(int256 value) external pure returns (int88) {
        return value.toInt88();
    }

    function toInt80(int256 value) external pure returns (int80) {
        return value.toInt80();
    }

    function toInt72(int256 value) external pure returns (int72) {
        return value.toInt72();
    }

    function toInt64(int256 value) external pure returns (int64) {
        return value.toInt64();
    }

    function toInt56(int256 value) external pure returns (int56) {
        return value.toInt56();
    }

    function toInt48(int256 value) external pure returns (int48) {
        return value.toInt48();
    }

    function toInt40(int256 value) external pure returns (int40) {
        return value.toInt40();
    }

    function toInt32(int256 value) external pure returns (int32){
        return value.toInt32();
    }

    function toInt24(int256 value) external pure returns (int24){
        return value.toInt24();
    }

    function toInt16(int256 value) external pure returns (int16) {
        return value.toInt16();
    }

    function toInt8(int256 value) external pure returns (int8){
        return value.toInt8();
    }

    function toInt256(uint256 value) external pure returns (int256) {
        return value.toInt256();
    }
}
