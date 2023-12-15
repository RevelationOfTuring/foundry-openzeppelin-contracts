// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Permit.sol";

contract ERC20PermitTest is Test {
    using ECDSA for bytes32;

    MockERC20Permit private _testing = new MockERC20Permit("test name", "test symbol");

    bytes32 private _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function test_PermitAndNonces() external {
        uint privateKey = 1;
        address owner = vm.addr(privateKey);
        address spender = address(1);
        assertEq(_testing.allowance(owner, spender), 0);
        assertEq(_testing.nonces(owner), 0);

        // approve with permit()
        (uint8 v, bytes32 r, bytes32 s) = _getTypedDataSignature(
            privateKey,
            owner,
            spender,
            1024,
            _testing.nonces(owner),
            block.timestamp
        );

        _testing.permit(owner, spender, 1024, block.timestamp, v, r, s);
        assertEq(_testing.allowance(owner, spender), 1024);
        assertEq(_testing.nonces(owner), 1);

        // revert if expired
        vm.expectRevert("ERC20Permit: expired deadline");
        _testing.permit(owner, spender, 1024, block.timestamp - 1, v, r, s);

        // revert with if the parameters are changed
        (v, r, s) = _getTypedDataSignature(
            privateKey,
            owner,
            spender,
            1024,
            _testing.nonces(owner),
            block.timestamp
        );
        // case 1: spender is changed
        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(owner, address(uint160(spender) + 1), 1024, block.timestamp, v, r, s);

        // case 2: owner is changed
        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(address(uint160(owner) + 1), spender, 1024, block.timestamp, v, r, s);

        // case 3: value is changed
        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(owner, spender, 1024 + 1, block.timestamp, v, r, s);

        // case 4: deadline is changed
        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(owner, spender, 1024, block.timestamp + 1, v, r, s);

        // case 5: nonce is changed
        (v, r, s) = _getTypedDataSignature(
            privateKey,
            owner,
            spender,
            1024,
            _testing.nonces(owner) - 1,
            block.timestamp
        );

        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(owner, spender, 1024, block.timestamp, v, r, s);

        // case 6: not signed by the owner
        (v, r, s) = _getTypedDataSignature(
            privateKey + 1,
            owner,
            spender,
            1024,
            _testing.nonces(owner),
            block.timestamp
        );

        vm.expectRevert("ERC20Permit: invalid signature");
        _testing.permit(owner, spender, 1024, block.timestamp, v, r, s);
    }

    function _getTypedDataSignature(
        uint signerPrivateKey,
        address owner,
        address spender,
        uint value,
        uint nonce,
        uint deadline
    ) private view returns (uint8, bytes32, bytes32){
        bytes32 structHash = keccak256(abi.encode(
            _PERMIT_TYPEHASH,
            owner,
            spender,
            value,
            nonce,
            deadline
        ));

        bytes32 digest = _testing.DOMAIN_SEPARATOR().toTypedDataHash(structHash);
        return vm.sign(signerPrivateKey, digest);
    }
}
