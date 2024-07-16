// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

interface IImplementation {
    event StorageChanged(uint preValue, uint newValue);
}

// specific logic of implementation
contract Implementation is Ownable, IImplementation {
    // storage
    uint public i;

    // initializer
    function __Implementation_init(address owner) external {
        _transferOwnership(owner);
    }

    // logic function
    function setI(uint newI) external virtual {
        emit StorageChanged(i, newI);
        i = newI;
    }
}

contract MockUUPSUpgradeable is UUPSUpgradeable, Implementation {
    // modified by `onlyOwner`
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

contract MockUUPSUpgradeableNew is MockUUPSUpgradeable {
    // change the logic
    function setI(uint newI) external override {
        uint currentI = i;
        i = currentI + newI;
        emit StorageChanged(currentI, newI);
    }
}

contract MockUUPSUpgradeableWithWrongProxiableUUID is MockUUPSUpgradeable {
    // inconsistent proxiable uuid
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return bytes32(uint(_IMPLEMENTATION_SLOT) - 1);
    }
}

contract MockUUPSUpgradeableWithRollbackTest is UUPSUpgradeable, Implementation {
    bytes32 private constant _ROLLBACK_SLOT = bytes32(uint(keccak256("eip1967.proxy.rollback")) - 1);

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function upgradeTo(address newImplementation) external override onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPSWithRollbackTest(
            newImplementation,
            "",
            false
        );
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable override onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPSWithRollbackTest(
            newImplementation,
            data,
            false
        );
    }

    function _upgradeToAndCallUUPSWithRollbackTest(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) private {
        address preImplementation = _getImplementation();
        // upgrade to and check UUPS on the new implementation with setup call first
        _upgradeToAndCallUUPS(newImplementation, data, forceCall);

        StorageSlot.BooleanSlot storage isInRollbackTest = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        // go into rollback test
        isInRollbackTest.value = true;
        // upgrade to the pre-implementation from the new implementation without setup call
        _upgradeToAndCallUUPS(preImplementation, "", false);
        require(preImplementation == _getImplementation(), "fail to recover pre-implementation in rollback test");
        // upgrade to the new implementation again without setup call
        _upgradeToAndCallUUPS(newImplementation, "", false);
        // get out of rollback test
        isInRollbackTest.value = false;
    }
}

contract MockUUPSUpgradeableWithRollbackTestNew is MockUUPSUpgradeableWithRollbackTest {
    // change the logic
    function setI(uint newI) external override {
        uint currentI = i;
        i = currentI + newI;
        emit StorageChanged(currentI, newI);
    }
}