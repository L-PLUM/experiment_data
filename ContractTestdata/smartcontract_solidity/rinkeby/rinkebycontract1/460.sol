/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity >=0.4.21 <0.6.0;

contract Message {
    string  myMessage;

    function setMessage(string memory x) public {
        myMessage = x;
    }

    function getMessage() public view returns (string memory) {
        return myMessage;
        
    }
}
