/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^ 0.5.0;

contract FICO_test {
    
    
    
    
    uint public balance; 
    address owner;
    
    constructor()public{
     owner = msg.sender;  
     balance=owner.balance;
    }
    
    
}
