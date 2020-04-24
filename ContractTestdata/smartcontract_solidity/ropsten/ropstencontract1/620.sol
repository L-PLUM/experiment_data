/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.23;

contract messageBoard {
    string public message;
    int public num = 129;
    function messageBoard(string initMessage) public {
        message = initMessage;
    }
    function editMessage(string _editMessage) public{
        message = _editMessage;
    }
}
