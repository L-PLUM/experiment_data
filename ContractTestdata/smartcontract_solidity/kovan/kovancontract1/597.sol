/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.18;

contract IceContract 
{
    uint balance ;
   address  public owner;
    
    constructor() public
    {
        balance = 1000;
        owner = msg.sender; // owner is my  address 
        
    }
    
  
    
    // Query the balance of the contract 
    function getBalance() public view returns (uint)
    {
        return balance;
        
    }
    // address 
    function setOwener(address _owner) public
    {   require(owner == msg.sender); //msg.sengar is my private key 
        owner = _owner;
    }
    //who call this function is owner
    function setBalanceOwner(uint newBalance) public{
        require(owner == msg.sender);
        balance = newBalance;
        
    }
    
   /* function setBalanceOwner2(uint newBalance) public returns (bool)
    {
        if(owner == msg.sender)
       {
            balance = newBalance;
            return true;
            
    
        }
        return false;
    }*/
    
}
