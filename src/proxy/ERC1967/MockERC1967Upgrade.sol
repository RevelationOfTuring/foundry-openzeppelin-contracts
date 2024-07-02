// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

contract MockERC1967Upgrade is ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = bytes32(uint(keccak256("eip1967.proxy.rollback")) - 1);

    function setRollbackSlot(bool value) external {
        StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value = value;
    }

    function getImplementation() external view returns (address){
        return _getImplementation();
    }

    function upgradeTo(address newImplementation) external {
        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) external {
        _upgradeToAndCall(newImplementation, data, forceCall);
    }

    function upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) external {
        _upgradeToAndCallUUPS(newImplementation, data, forceCall);
    }

    function getAdmin() external view returns (address) {
        return _getAdmin();
    }


    function changeAdmin(address newAdmin) external {
        _changeAdmin(newAdmin);
    }

    function getBeacon() external view returns (address) {
        return _getBeacon();
    }

    function upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) external {
        _upgradeBeaconToAndCall(newBeacon, data, forceCall);
    }
}
