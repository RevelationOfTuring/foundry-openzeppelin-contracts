// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Votes.sol";

contract ERC20VotesTest is Test {
    MockERC20Votes private _testing = new MockERC20Votes("test name", "test symbol");
    address private user1 = address(1);
    address private user2 = address(2);
    address private user3 = address(3);
    address private user4 = address(4);

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    function test_Delegate() external {
        // case 1: first delegation without balance
        assertEq(_testing.delegates(address(this)), address(0));
        vm.expectEmit(true, true, true, false, address(_testing));
        emit DelegateChanged(address(this), address(0), user1);

        _testing.delegate(user1);
        assertEq(_testing.delegates(address(this)), user1);
        // no votes in user1
        assertEq(_testing.getVotes(user1), 0);
        // no Checkpoint generated
        assertEq(_testing.numCheckpoints(user1), 0);

        // case 2: first delegate with balance
        _testing.mint(user1, 1024);
        assertEq(_testing.delegates(user1), address(0));

        vm.expectEmit(true, true, true, false, address(_testing));
        emit DelegateChanged(user1, address(0), user2);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user2, 0, 1024);

        vm.prank(user1);
        _testing.delegate(user2);
        assertEq(_testing.delegates(user1), user2);
        // 1024 votes in user2
        assertEq(_testing.getVotes(user2), 1024);
        // 1 Checkpoint generated
        assertEq(_testing.numCheckpoints(user2), 1);
        MockERC20Votes.Checkpoint memory ckpt = _testing.checkpoints(user2, 0);
        assertEq(ckpt.fromBlock, 1);
        assertEq(ckpt.votes, 1024);

        // case 3: delegate with balance not first
        vm.roll(2);
        vm.expectEmit(true, true, true, false, address(_testing));
        emit DelegateChanged(user1, user2, user3);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user2, 1024, 0);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user3, 0, 1024);

        vm.prank(user1);
        _testing.delegate(user3);
        assertEq(_testing.delegates(user1), user3);
        // 1024 votes in user3
        assertEq(_testing.getVotes(user3), 1024);
        // 1 Checkpoint generated
        assertEq(_testing.numCheckpoints(user3), 1);
        ckpt = _testing.checkpoints(user3, 0);
        assertEq(ckpt.fromBlock, 2);
        assertEq(ckpt.votes, 1024);
        // 0 votes in user2
        assertEq(_testing.getVotes(user2), 0);
        // 1 Checkpoint generated
        assertEq(_testing.numCheckpoints(user2), 2);
        ckpt = _testing.checkpoints(user2, 1);
        assertEq(ckpt.fromBlock, 2);
        assertEq(ckpt.votes, 0);
    }

    function test_MintAndBurnAndMaxSupply() external {
        // test for {_maxSupply}
        assertEq(_testing.maxSupply(), type(uint224).max);

        // test for {_mint}
        // case 1: receiver has no delegatee
        assertEq(_testing.totalSupply(), 0);
        _testing.mint(address(this), 1);
        assertEq(_testing.totalSupply(), 1);
        assertEq(_testing.balanceOf(address(this)), 1);

        // revert if total supply exceeds the ceiling
        vm.expectRevert("ERC20Votes: total supply risks overflowing votes");
        _testing.mint(user1, type(uint224).max);

        // case 2: receiver has a delegatee
        vm.prank(user1);
        _testing.delegate(address(this));
        assertEq(_testing.getVotes(address(this)), 0);

        _testing.mint(user1, 2);
        assertEq(_testing.totalSupply(), 1 + 2);
        assertEq(_testing.balanceOf(user1), 0 + 2);
        // delegatee's votes increased
        assertEq(_testing.getVotes(address(this)), 0 + 2);

        // revert if total supply exceeds the ceiling (happens in {_afterTokenTransfer})
        vm.expectRevert("SafeCast: value doesn't fit in 224 bits");
        _testing.mint(user1, type(uint224).max);

        // test for {_burn}
        // case 3: receiver has no delegatee
        _testing.burn(address(this), 1);
        assertEq(_testing.totalSupply(), 3 - 1);

        // case 4: receiver has a delegatee
        _testing.burn(user1, 1);
        assertEq(_testing.totalSupply(), 2 - 1);
        // delegatee's votes decreased
        assertEq(_testing.getVotes(address(this)), 2 - 1);
    }

    function test_AfterTokenTransfer() external {
        _testing.mint(address(this), 100);
        _testing.delegate(user1);

        assertEq(_testing.delegates(address(this)), user1);
        assertEq(_testing.numCheckpoints(user1), 1);

        // test for {transfer}
        // case 1: 'to' has no delegatee
        vm.roll(2);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user1, 100, 100 - 1);

        _testing.transfer(user2, 1);
        assertEq(_testing.getVotes(user1), 100 - 1);

        // case 2: 'to' has a delegatee
        _testing.mint(user3, 100);
        vm.prank(user3);
        _testing.delegate(user4);

        vm.roll(3);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user1, 99, 99 - 1);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user4, 100, 100 + 1);

        _testing.transfer(user3, 1);
        assertEq(_testing.getVotes(user1), 99 - 1);
        assertEq(_testing.getVotes(user4), 100 + 1);

        // test for {transferFrom}
        // case 3: 'to' has no delegatee
        vm.roll(4);
        assertEq(_testing.delegates(user2), address(0));

        _testing.approve(user1, 100);
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user1, 98, 98 - 1);

        _testing.transferFrom(address(this), user2, 1);

        // case 4: 'to' has a delegatee
        vm.roll(5);
        assertEq(_testing.delegates(user3), user4);

        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user1, 97, 97 - 1);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user4, 101, 101 + 1);

        _testing.transferFrom(address(this), user3, 1);
    }

    using ECDSA for bytes32;
    bytes32 private constant _DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    function test_DelegateBySig() external {
        // case 1: the signer has no balance
        uint privateKey = 1;
        address signer = vm.addr(privateKey);
        address delegatee = user1;
        uint nonce = 0;
        uint expiry = 1024;
        (uint8 v, bytes32 r, bytes32 s) = _getTypedDataSignature(privateKey, delegatee, nonce, expiry);

        vm.expectEmit(true, true, true, false, address(_testing));
        emit DelegateChanged(signer, address(0), delegatee);

        _testing.delegateBySig(delegatee, nonce, expiry, v, r, s);
        assertEq(_testing.delegates(signer), delegatee);
        assertEq(_testing.getVotes(delegatee), 0);

        // case 2: the signer has a balance
        _testing.mint(signer, 100);
        delegatee = user2;
        nonce++;
        (v, r, s) = _getTypedDataSignature(privateKey, delegatee, nonce, expiry);

        vm.expectEmit(true, true, true, false, address(_testing));
        emit DelegateChanged(signer, user1, delegatee);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(user1, 100, 0);
        vm.expectEmit(true, false, false, true, address(_testing));
        emit DelegateVotesChanged(delegatee, 0, 100);

        _testing.delegateBySig(delegatee, nonce, expiry, v, r, s);
        assertEq(_testing.delegates(signer), delegatee);

        // revert with invalid nonce
        vm.expectRevert("ERC20Votes: invalid nonce");
        _testing.delegateBySig(delegatee, nonce, expiry, v, r, s);

        // revert with expire signature
        nonce++;
        (v, r, s) = _getTypedDataSignature(privateKey, delegatee, nonce, expiry);

        vm.warp(expiry + 1);
        vm.expectRevert("ERC20Votes: signature expired");
        _testing.delegateBySig(delegatee, nonce, expiry, v, r, s);
    }

    function _getTypedDataSignature(
        uint signerPrivateKey,
        address delegatee,
        uint nonce,
        uint expiry
    ) private view returns (uint8, bytes32, bytes32){
        bytes32 structHash = keccak256(abi.encode(
            _DELEGATION_TYPEHASH,
            delegatee,
            nonce,
            expiry
        ));

        bytes32 digest = _testing.DOMAIN_SEPARATOR().toTypedDataHash(structHash);
        return vm.sign(signerPrivateKey, digest);
    }

    function test_GetPastVotesAndGetPastTotalSupply() external {
        // 6 Checkpoints of user1:
        //       block             votes             index
        //          2                10                0
        //          3                15                1
        //          6                19                2
        //          10               20                3
        //          11               23                4
        //          13               31                5
        //
        // 6 Checkpoints of total supply:
        //       block          total supply         index
        //          2                10                0
        //          3                15                1
        //          6                19                2
        //          10               20                3
        //          11               23                4
        //          13               31                5

        _testing.delegate(user1);
        vm.roll(2);
        _testing.mint(address(this), 10);
        vm.roll(3);
        _testing.mint(address(this), 15 - 10);
        vm.roll(6);
        _testing.mint(address(this), 19 - 15);
        vm.roll(10);
        _testing.mint(address(this), 20 - 19);
        vm.roll(11);
        _testing.mint(address(this), 23 - 20);
        vm.roll(13);
        _testing.mint(address(this), 31 - 23);
        vm.roll(20);

        // check {getPastVotes} && {getPastTotalSupply}
        assertEq(_testing.numCheckpoints(user1), 6);

        assertEq(_testing.getPastVotes(user1, 1), 0);
        assertEq(_testing.getPastTotalSupply(1), 0);

        assertEq(_testing.getPastVotes(user1, 2), 10);
        assertEq(_testing.getPastTotalSupply(2), 10);

        assertEq(_testing.getPastVotes(user1, 4), 15);
        assertEq(_testing.getPastTotalSupply(4), 15);

        assertEq(_testing.getPastVotes(user1, 6), 19);
        assertEq(_testing.getPastTotalSupply(6), 19);

        assertEq(_testing.getPastVotes(user1, 9), 19);
        assertEq(_testing.getPastTotalSupply(9), 19);

        assertEq(_testing.getPastVotes(user1, 10), 20);
        assertEq(_testing.getPastTotalSupply(10), 20);

        assertEq(_testing.getPastVotes(user1, 12), 23);
        assertEq(_testing.getPastTotalSupply(12), 23);

        assertEq(_testing.getPastVotes(user1, 13), 31);
        assertEq(_testing.getPastTotalSupply(13), 31);

        assertEq(_testing.getPastVotes(user1, 19), 31);
        assertEq(_testing.getPastTotalSupply(19), 31);

        // revert if block not mined
        vm.expectRevert("ERC20Votes: block not yet mined");
        _testing.getPastVotes(user1, 9999);
        vm.expectRevert("ERC20Votes: block not yet mined");
        _testing.getPastTotalSupply(9999);
    }
}
