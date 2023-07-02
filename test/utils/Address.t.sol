// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Address.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../src/utils/MockAddress.sol";

contract AddressTest is Test {
    MockAddress testing = new MockAddress();
    SelfDestructorCase sdc;

    function setUp() external {
        // 由于一个合约的销毁会在一笔tx的执行结束时执行，所以将selfdestruct()的调用放在setUp()中
        // 这样在每个test用例中sdc合约已经是被selfdestruct了
        sdc = new SelfDestructorCase();
        // destruct the contract
        sdc.kill();
    }

    function test_IsContract() external {
        // contract address
        assertTrue(testing.isContract(address(this)));
        // eoa address
        assertFalse(testing.isContract(msg.sender));
    }

    function test_IsContract_SpecialCase_Constructor() external {
        // case 1: 处于constructor时期的合约地址，isContract()会返回false
        ConstructorCase cc = new ConstructorCase(testing);
        assertFalse(cc.flag());
    }

    function test_IsContract_SpecialCase_ContractDestroyed() external {
        // case 2: 销毁后的合约地址，无法被识别出来
        assertFalse(testing.isContract(address(sdc)));
    }

    function test_SendValue() external {
        Receiver r = new Receiver();
        address payable recipient = payable(address(r));
        assertEq(recipient.balance, 0);
        vm.deal(address(testing), 1 ether);

        testing.sendValue(recipient, 1 ether);

        assertEq(recipient.balance, 1 ether);
        assertEq(address(testing).balance, 0);

        // revert check
        vm.deal(address(testing), 1 ether);
        // case 1: insufficient balance
        vm.expectRevert("Address: insufficient balance");
        testing.sendValue(recipient, 2 ether);

        // case 2: send eth to the contract with no revert in receive function
        r.setEthReceived(false);
        vm.expectRevert("Address: unable to send value, recipient may have reverted");
        testing.sendValue(payable(address(r)), 1 ether);
    }

    function test_FunctionCall() external {
        Target t = new Target();
        bytes memory returndata = testing.functionCall(
            address(t),
            abi.encodeCall(t.setSlot0, (1024))
        );

        assertEq(t.slot0(), 1024);
        assertEq(abi.decode(returndata, (uint)), 1024 + 1);

        // check revert
        // case 1: revert if target is eoa
        vm.expectRevert("Address: call to non-contract");
        testing.functionCall(msg.sender, "");

        // case 2: revert with the bubbled revert msg
        vm.expectRevert("revert with msg");
        testing.functionCall(
            address(t),
            abi.encodeCall(t.revertWithMsg, ())
        );

        // case 3: revert with specific msg if the target function reverts with no msg
        vm.expectRevert("Address: low-level call failed");
        testing.functionCall(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ())
        );

        vm.expectRevert("specific revert msg");
        testing.functionCall(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ()),
            "specific revert msg"
        );
    }

    function test_FunctionCallWithValue() external {
        Target t = new Target();
        vm.deal(address(testing), 1 ether);
        bytes memory returndata = testing.functionCallWithValue(
            address(t),
            abi.encodeCall(t.payableFunc, ()),
            1 ether
        );

        assertEq(abi.decode(returndata, (uint)), 1 ether);
        assertEq(address(t).balance, 1 ether);

        // check revert
        vm.deal(address(testing), 1 ether);
        // case 1: revert if target is eoa
        vm.expectRevert("Address: call to non-contract");
        testing.functionCallWithValue(msg.sender, "", 1 ether);

        // case 2: revert if insufficient balance
        vm.expectRevert("Address: insufficient balance for call");
        testing.functionCallWithValue(
            address(t),
            abi.encodeCall(t.payableFunc, ()),
            2 ether
        );

        // case 3: revert with the bubbled revert msg
        vm.expectRevert("revert with msg");
        testing.functionCallWithValue(
            address(t),
            abi.encodeCall(t.revertWithMsg, ()),
            1 ether
        );

        // case 4: revert with specific msg if the target function reverts with no msg
        vm.expectRevert("Address: low-level call with value failed");
        testing.functionCallWithValue(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ()),
            1 ether
        );

        vm.expectRevert("specific revert msg");
        testing.functionCallWithValue(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ()),
            1 ether,
            "specific revert msg"
        );
    }

    function test_functionStaticCall() external {
        Target t = new Target();
        bytes memory returndata = testing.functionStaticCall(
            address(t),
            abi.encodeCall(t.slot0, ())
        );

        assertEq(abi.decode(returndata, (uint)), 1);

        // check revert
        // case 1: revert if target is eoa
        vm.expectRevert("Address: call to non-contract");
        testing.functionStaticCall(msg.sender, "");

        // case 2: revert with the bubbled revert msg
        vm.expectRevert("revert with msg");
        testing.functionStaticCall(
            address(t),
            abi.encodeCall(t.revertWithMsg, ())
        );

        // case 3: revert with specific msg if the target function reverts with no msg
        vm.expectRevert("Address: low-level static call failed");
        testing.functionStaticCall(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ())
        );

        // revert if the target function tries to modify the storage
        vm.expectRevert("specific revert msg");
        testing.functionStaticCall(
            address(t),
            abi.encodeCall(t.setSlot0, (1024)),
            "specific revert msg"
        );
    }

    function test_functionDelegateCall() external {
        Target t = new Target();
        bytes memory returndata = testing.functionDelegateCall(
            address(t),
            abi.encodeCall(t.setSlot0AndReturnSlot1, (1024))
        );

        // return the value of slot 1 in contract MockAddress
        assertEq(abi.decode(returndata, (address)), address(0));
        // delegate call set slot 1 value in contract MockAddress
        assertEq(testing.slot0(), 1024);
        // slot 1 value in target contract not set
        assertEq(t.slot0(), 1);

        // check revert
        // case 1: revert if target is eoa
        vm.expectRevert("Address: call to non-contract");
        testing.functionDelegateCall(msg.sender, "");

        // case 2: revert with the bubbled revert msg
        vm.expectRevert("revert with msg");
        testing.functionDelegateCall(
            address(t),
            abi.encodeCall(t.revertWithMsg, ())
        );

        // case 3: revert with specific msg if the target function reverts with no msg
        vm.expectRevert("Address: low-level delegate call failed");
        testing.functionDelegateCall(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ())
        );

        vm.expectRevert("specific revert msg");
        testing.functionDelegateCall(
            address(t),
            abi.encodeCall(t.revertWithNoMsg, ()),
            "specific revert msg"
        );
    }
}

contract Target {
    uint public slot0 = 1;
    address public slot1 = address(1);

    function setSlot0(uint n) external returns (uint){
        slot0 = n;
        return n + 1;
    }

    function revertWithMsg() external payable {
        revert("revert with msg");
    }

    function revertWithNoMsg() external payable {
        revert();
    }

    function payableFunc() external payable returns (uint){
        return msg.value;
    }

    function setSlot0AndReturnSlot1(uint n) external returns (address){
        slot0 = n;
        return slot1;
    }
}

contract Receiver {
    bool _ethReceived = true;

    function setEthReceived(bool ethReceived) external {
        _ethReceived = ethReceived;
    }

    receive() external payable {
        if (!_ethReceived) {
            revert("revert in receive function");
        }
    }
}

contract ConstructorCase {
    bool public flag;
    constructor(MockAddress ma){
        flag = ma.isContract(address(this));
    }
}

contract SelfDestructorCase {
    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}



