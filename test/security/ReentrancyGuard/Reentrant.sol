// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Reentrant {
    address private target;

    constructor(address targetAddress){
        target = targetAddress;
    }

    function callback(bytes calldata calldata_) external {
        (bool ok, bytes memory returnData) = target.call(calldata_);
        if (!ok) {
            // pull the revert msg out of the return data of the call
            uint len = returnData.length;
            if (len > 4 && bytes4(returnData) == bytes4(keccak256(bytes("Error(string)")))) {
                // get returnData[4:] in memory bytes
                bytes memory encodedRevertMsg = new bytes(len - 4);
                for (uint i = 4; i < len; ++i) {
                    encodedRevertMsg[i - 4] = returnData[i];
                }
                revert(abi.decode(encodedRevertMsg, (string)));
            } else {
                revert();
            }
        }
    }
}