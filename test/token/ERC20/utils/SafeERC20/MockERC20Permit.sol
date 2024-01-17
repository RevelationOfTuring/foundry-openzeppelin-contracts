// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

contract MockERC20Permit is IERC20Permit {
    uint private _nonce;
    bool private _nonceIncreases = true;
    bool private _revertInPermit;
    bool private _revertInNonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function permit(
        address owner,
        address spender,
        uint value,
        uint,
        uint8,
        bytes32,
        bytes32
    ) external {
        require(!_revertInPermit, "MockERC20Permit: permit");
        if (_nonceIncreases) {
            _nonce += 1;
        }

        emit Approval(owner, spender, value);
    }

    function nonces(address) external view returns (uint){
        require(!_revertInNonces, "MockERC20Permit: nonces");
        return _nonce;
    }

    function setNonceIncreases(bool b) external {
        _nonceIncreases = b;
    }

    function setRevertInNonces(bool b) external {
        _revertInNonces = b;
    }

    function setRevertInPermit(bool b) external {
        _revertInPermit = b;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32){
        return bytes32(_nonce);
    }
}