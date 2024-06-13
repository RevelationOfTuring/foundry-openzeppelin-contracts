// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/security/PullPayment.sol";

contract MockPullPayment is PullPayment {
    event DoWithAsyncTransfer(address payee, uint amount);

    function doWithAsyncTransfer(address payee, uint amount) external payable {
        _asyncTransfer(payee, amount);
        emit DoWithAsyncTransfer(payee, amount);
    }
}
