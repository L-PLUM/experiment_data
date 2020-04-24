/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity >=0.4.22 <0.6.0;

contract Inbox {
    string public message;

    constructor(string memory initialMessage) public {
        message = initialMessage;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}
