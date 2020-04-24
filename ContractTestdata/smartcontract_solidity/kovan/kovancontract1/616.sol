/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.18;

contract MonzContract{
    uint balance;
    address owner;
    
    constructor() public{
            balance = 100;
            owner = msg.sender;
    }
    
    function setBalance(uint newBalance) public{
            balance = newBalance;
    }
    function getBalance() public view returns (uint){
            return balance;
    }
    function setOwner(address _owner) public{
            owner = _owner;
    }        
    function setBalanceOwner1(uint newBalance) public{
            require(owner == msg.sender);
            balance = newBalance;
    }
    function setBalanceOwner2(uint newBalance) public returns(bool){
            if(owner == msg.sender)  {
             balance = newBalance;
             return true;
            }
                return false;
    }
}
