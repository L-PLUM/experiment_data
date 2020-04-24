/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity ^0.4.23;
contract messageboard{
    string public message;
    function messageBoard(string initMessage) public {
        message = initMessage;
    }
    function editMessage(string editMessage) public {
        message = editMessage;
    }
    function viewMessage() public  returns(string) {
        return message;
    }
}
