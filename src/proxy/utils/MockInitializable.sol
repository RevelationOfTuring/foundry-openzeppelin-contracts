// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

interface IMockInitializable {
    enum ConstructorLogic{
        NO_LOGIC,
        DO_WITH_SINGLE_INITIALIZER,
        DO_WITH_NESTED_INITIALIZER,
        DO_WITH_INITIALIZERS_IN_SEQUENCE
    }

    event DoWithInitializer(uint counter);
    event DoInNestedInitializer(uint counter);
    event DoWithReinitializer(uint counter);
    event DoWithOnlyInitializing(uint8 version, bool isInitializing, uint counter);
}

contract MockInitializable is Initializable, IMockInitializable {
    uint public counter;

    constructor(ConstructorLogic flag){
        if (flag == ConstructorLogic.NO_LOGIC) {
            return;
        } else if (flag == ConstructorLogic.DO_WITH_SINGLE_INITIALIZER) {
            doWithInitializer();
        }
        else if (flag == ConstructorLogic.DO_WITH_NESTED_INITIALIZER) {
            doWithNestedInitializer();
        } else if (flag == ConstructorLogic.DO_WITH_INITIALIZERS_IN_SEQUENCE) {
            doWithInitializer();
            doWithInitializer();
        } else {
            revert("unsupported flag");
        }
    }


    function getInitializedVersion() external view returns (uint8){
        return _getInitializedVersion();
    }

    function isInitializing() external view returns (bool){
        return _isInitializing();
    }

    function doWithInitializer() public initializer {
        uint currentCounter = counter;
        counter += 1;
        emit DoWithInitializer(currentCounter);
    }

    function doWithNestedInitializer() public initializer {
        doWithInitializer();
        uint currentCounter = counter;
        counter += 1;
        emit DoInNestedInitializer(currentCounter);
    }

    function doWithReinitializer(uint8 version) public reinitializer(version) {
        counter = version;
        emit DoWithReinitializer(version);
    }

    function doWithReinitializersInSequence(uint8 version) external {
        doWithReinitializer(version);
        doWithReinitializer(version + 1);
    }

    // revert
    function doWithNestedReinitializer(uint8 version) external reinitializer(version) {
        doWithReinitializer(version);
        counter = version + 1;
    }

    // revert
    function doWithOnlyInitializing() public onlyInitializing {
        uint currentCounter = counter;
        counter += 1;
        emit DoWithOnlyInitializing(
            _getInitializedVersion(),
            _isInitializing(),
            currentCounter
        );
    }

    function doWithNestedOnlyInitializing() public onlyInitializing {
        doWithOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithOnlyInitializing(
            _getInitializedVersion(),
            _isInitializing(),
            currentCounter
        );
    }

    function doWithOnlyInitializingInInitializer() external initializer {
        doWithOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithInitializer(currentCounter);
    }

    function doWithOnlyInitializingInSequenceInInitializer() external initializer {
        doWithOnlyInitializing();
        doWithOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithInitializer(currentCounter);
    }

    function doWithNestedOnlyInitializingInInitializer() external initializer {
        doWithNestedOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithInitializer(currentCounter);
    }

    function doWithOnlyInitializingInReinitializer(uint8 version) external reinitializer(version) {
        doWithOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithReinitializer(currentCounter);
    }

    function doWithOnlyInitializingInSequenceInReinitializer(uint8 version) external reinitializer(version) {
        doWithOnlyInitializing();
        doWithOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithReinitializer(currentCounter);
    }

    function doWithNestedOnlyInitializingInReinitializer(uint8 version) external reinitializer(version) {
        doWithNestedOnlyInitializing();
        uint currentCounter = counter;
        counter += 1;
        emit DoWithReinitializer(currentCounter);
    }

    function disableInitializers() external {
        _disableInitializers();
    }

    // revert
    function disableInitializersInInitializer() external initializer {
        _disableInitializers();
    }

    // revert
    function disableInitializersInReinitializer(uint8 version) external reinitializer(version) {
        _disableInitializers();
    }
}