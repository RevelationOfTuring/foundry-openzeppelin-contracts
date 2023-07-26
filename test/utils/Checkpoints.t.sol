// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockCheckpoints.sol";

contract CheckpointsTest is Test {
    MockCheckpointsHistory mch = new MockCheckpointsHistory();
    MockCheckpointsTrace224 mct224 = new MockCheckpointsTrace224();
    MockCheckpointsTrace160 mct160 = new MockCheckpointsTrace160();

    function test_CheckpointsHistory() external {
        assertEq(mch.length(), 0);
        (bool exists,uint32 blockNumber,uint224 value) = mch.latestCheckpoint();
        assertFalse(exists);
        assertEq(blockNumber, 0);
        assertEq(value, 0);
        assertEq(mch.latest(), 0);

        // push on block number 1
        vm.roll(1);
        (uint latestValue,uint newValue) = mch.push(11);
        assertEq(latestValue, 0);
        assertEq(newValue, 11);
        assertEq(mch.length(), 1);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 1);
        assertEq(value, 11);
        assertEq(mch.latest(), newValue);

        // push on block number 2
        vm.roll(2);
        (latestValue, newValue) = mch.push(22);
        assertEq(latestValue, 11);
        assertEq(newValue, 22);
        assertEq(mch.length(), 2);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 2);
        assertEq(value, 22);
        assertEq(mch.latest(), newValue);

        // update value when push on block number 2 again
        (latestValue, newValue) = mch.push(33);
        // value before update
        assertEq(latestValue, 22);
        // value after update
        assertEq(newValue, 33);
        // total length no change
        assertEq(mch.length(), 2);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 2);
        assertEq(value, 33);
        assertEq(mch.latest(), newValue);

        // push on block number 3
        vm.roll(3);
        (latestValue, newValue) = mch.push(44);
        assertEq(latestValue, 33);
        assertEq(newValue, 44);
        assertEq(mch.length(), 3);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 3);
        assertEq(value, 44);
        assertEq(mch.latest(), newValue);

        // push with customized op function on a new block number
        vm.roll(4);
        (latestValue, newValue) = mch.pushWithOp(55);
        assertEq(latestValue, 44);
        // 44(latest)+55(delta)
        assertEq(newValue, 99);
        assertEq(mch.length(), 4);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 4);
        assertEq(value, 99);
        assertEq(mch.latest(), newValue);

        // push with customized op function on an existed block number
        (latestValue, newValue) = mch.pushWithOp(11);
        assertEq(latestValue, 99);
        // 99(latest)+11(delta)
        assertEq(newValue, 110);
        assertEq(mch.length(), 4);
        (exists, blockNumber, value) = mch.latestCheckpoint();
        assertTrue(exists);
        assertEq(blockNumber, 4);
        assertEq(value, 110);
        assertEq(mch.latest(), newValue);

        // push more
        vm.roll(10);
        mch.push(100);
        vm.roll(20);
        mch.push(101);
        vm.roll(25);
        mch.push(102);
        assertEq(mch.length(), 7);

        // history now:
        // 11(1)、33(2)、44(3)、110(4)、100(10)、101(20)、102(25)
        uint[7] memory values = [uint(11), 33, 44, 110, 100, 101, 102];
        uint[7] memory blockNumbers = [uint(1), 2, 3, 4, 10, 20, 25];

        // test getAtBlock
        // revert if the target block number not < the current block number of chain
        vm.expectRevert("Checkpoints: block not yet mined");
        mch.getAtBlock(25);

        vm.roll(25 + 1);
        for (uint i = 0; i < 7; ++i) {
            assertEq(mch.getAtBlock(blockNumbers[i]), values[i]);
        }

        // test getAtProbablyRecentBlock
        // revert if the target block number not < the current block number of chain
        vm.expectRevert("Checkpoints: block not yet mined");
        mch.getAtProbablyRecentBlock(26);
        for (uint i = 0; i < 7; ++i) {
            assertEq(mch.getAtProbablyRecentBlock(blockNumbers[i]), values[i]);
        }
    }

    function test_CheckpointsTrace224() external {
        assertEq(mct224.length(), 0);
        (bool exists,uint32 key,uint224 value) = mct224.latestCheckpoint();
        assertFalse(exists);
        assertEq(key, 0);
        assertEq(value, 0);
        assertEq(mct224.latest(), 0);

        // push on key 1
        (uint224 latestValue,uint224 newValue) = mct224.push(1, 10);
        assertEq(latestValue, 0);
        assertEq(newValue, 10);
        assertEq(mct224.length(), 1);
        (exists, key, value) = mct224.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 1);
        assertEq(value, 10);
        assertEq(mct224.latest(), newValue);

        // push on key 2
        (latestValue, newValue) = mct224.push(2, 20);
        assertEq(latestValue, 10);
        assertEq(newValue, 20);
        assertEq(mct224.length(), 2);
        (exists, key, value) = mct224.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 2);
        assertEq(value, 20);
        assertEq(mct224.latest(), newValue);

        // update value on key 2
        (latestValue, newValue) = mct224.push(2, 30);
        // value before update
        assertEq(latestValue, 20);
        // value after update
        assertEq(newValue, 30);
        // total length no change
        assertEq(mct224.length(), 2);
        (exists, key, value) = mct224.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 2);
        assertEq(value, 30);
        assertEq(mct224.latest(), newValue);

        // revert if the key to push is < latest key
        vm.expectRevert("Checkpoint: invalid key");
        mct224.push(2 - 1, 1);
        // push more
        mct224.push(3, 40);
        mct224.push(4, 50);
        mct224.push(5, 60);
        mct224.push(6, 70);
        assertEq(mct224.length(), 6);

        // Trace224 now:
        // 10(1)、30(2)、40(3)、50(4)、60(5)、70(6)
        // lowerLookup():
        // return the value in the oldest checkpoint with key greater or equal than the search key
        assertEq(mct224.lowerLookup(0), 10);
        assertEq(mct224.lowerLookup(1), 10);
        assertEq(mct224.lowerLookup(2), 30);
        assertEq(mct224.lowerLookup(3), 40);
        assertEq(mct224.lowerLookup(4), 50);
        assertEq(mct224.lowerLookup(5), 60);
        assertEq(mct224.lowerLookup(6), 70);
        assertEq(mct224.lowerLookup(7), 0);

        // upperLookup():
        // return the value in the most recent checkpoint with key lower or equal than the search key
        assertEq(mct224.upperLookup(0), 0);
        assertEq(mct224.upperLookup(1), 10);
        assertEq(mct224.upperLookup(2), 30);
        assertEq(mct224.upperLookup(3), 40);
        assertEq(mct224.upperLookup(4), 50);
        assertEq(mct224.upperLookup(5), 60);
        assertEq(mct224.upperLookup(6), 70);
        assertEq(mct224.upperLookup(7), 70);
    }

    function test_CheckpointsTrace160() external {
        assertEq(mct160.length(), 0);
        (bool exists,uint96 key,uint160 value) = mct160.latestCheckpoint();
        assertFalse(exists);
        assertEq(key, 0);
        assertEq(value, 0);
        assertEq(mct160.latest(), 0);

        // push on key 1
        (uint160 latestValue,uint160 newValue) = mct160.push(1, 10);
        assertEq(latestValue, 0);
        assertEq(newValue, 10);
        assertEq(mct160.length(), 1);
        (exists, key, value) = mct160.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 1);
        assertEq(value, 10);
        assertEq(mct160.latest(), newValue);

        // push on key 2
        (latestValue, newValue) = mct160.push(2, 20);
        assertEq(latestValue, 10);
        assertEq(newValue, 20);
        assertEq(mct160.length(), 2);
        (exists, key, value) = mct160.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 2);
        assertEq(value, 20);
        assertEq(mct160.latest(), newValue);

        // update value on key 2
        (latestValue, newValue) = mct160.push(2, 30);
        // value before update
        assertEq(latestValue, 20);
        // value after update
        assertEq(newValue, 30);
        // total length no change
        assertEq(mct160.length(), 2);
        (exists, key, value) = mct160.latestCheckpoint();
        assertTrue(exists);
        assertEq(key, 2);
        assertEq(value, 30);
        assertEq(mct160.latest(), newValue);

        // revert if the key to push is < latest key
        vm.expectRevert("Checkpoint: invalid key");
        mct160.push(2 - 1, 1);
        // push more
        mct160.push(3, 40);
        mct160.push(4, 50);
        mct160.push(5, 60);
        mct160.push(6, 70);
        assertEq(mct160.length(), 6);

        // Trace160 now:
        // 10(1)、30(2)、40(3)、50(4)、60(5)、70(6)
        // lowerLookup():
        // return the value in the oldest checkpoint with key greater or equal than the search key
        assertEq(mct160.lowerLookup(0), 10);
        assertEq(mct160.lowerLookup(1), 10);
        assertEq(mct160.lowerLookup(2), 30);
        assertEq(mct160.lowerLookup(3), 40);
        assertEq(mct160.lowerLookup(4), 50);
        assertEq(mct160.lowerLookup(5), 60);
        assertEq(mct160.lowerLookup(6), 70);
        assertEq(mct160.lowerLookup(7), 0);

        // upperLookup():
        // return the value in the most recent checkpoint with key lower or equal than the search key
        assertEq(mct160.upperLookup(0), 0);
        assertEq(mct160.upperLookup(1), 10);
        assertEq(mct160.upperLookup(2), 30);
        assertEq(mct160.upperLookup(3), 40);
        assertEq(mct160.upperLookup(4), 50);
        assertEq(mct160.upperLookup(5), 60);
        assertEq(mct160.upperLookup(6), 70);
        assertEq(mct160.upperLookup(7), 70);
    }
}
