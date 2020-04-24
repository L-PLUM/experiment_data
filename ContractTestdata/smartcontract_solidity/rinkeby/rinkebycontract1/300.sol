/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.4.23;

contract message {
    int8 public messagevar;
    
    int8 public num = 11;
    
    function message(int8 inMessage) public {
        messagevar = inMessage+num;
    }
    
    function editMessage(int8 _editMessage) public{
        messagevar = _editMessage+num;
    }
}
