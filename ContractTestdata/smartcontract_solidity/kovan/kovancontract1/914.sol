/**
 *Submitted for verification at Etherscan.io on 2018-12-17
*/

pragma solidity ^0.4.0;

contract SaveToBlockchain {
    
    address private owner;
    string private ownerName;
    
    mapping (address => string[]) public texts;
    
    event newText(address _sender, string _id, string _text);
    
    
    constructor() public {
        
        owner = msg.sender;
        ownerName = "Clounix";
        
    }
    
    function addText(string id, string text) public payable returns(bool) {
        
        texts[msg.sender].push(id);
        texts[msg.sender].push(text);

        emit newText(msg.sender, id, text);
        
        return true;
        
    }
    
}
