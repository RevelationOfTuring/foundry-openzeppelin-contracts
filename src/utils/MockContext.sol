// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Context.sol";

contract MockContext is Context {
    address _worker;
    constructor(){
        _worker = msg.sender;
    }

    event MsgContext(address msgSender, bytes msgData, uint input);

    function _msgSender() internal view override returns (address){
        if (msg.sender == _worker) {
            address sender;
            assembly{
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return sender;
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view override returns (bytes calldata){
        if (msg.sender == _worker) {
            return msg.data[: msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    function targetFunction(uint number) external {
        // emit the msg context in the function
        emit MsgContext(_msgSender(), _msgData(), number);
    }
}