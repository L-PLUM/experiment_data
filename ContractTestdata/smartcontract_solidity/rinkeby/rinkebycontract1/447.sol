/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.18;

contract HelloWorld {
    
    string public name;
    
    function setValue(string _name) public returns (string){
        name = _name;
        return name;
    }
    
    function getValue() public constant returns (string){
        return name;
    }
    
}
