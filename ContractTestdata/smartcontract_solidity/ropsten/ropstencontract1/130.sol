/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.0;

contract ERC20 {
   
   function totalSupply() public view returns(uint256);
   function balanceOf(address to_who) public view returns(uint256);
  
   function transfer(address to_a,uint256 _value) public returns(bool);
}


pragma solidity ^0.4.0;


contract payto  is ERC20{
    
    mapping(address =>uint256) public amount;
    uint256 totalAmount;
    uint256 decimal;
    string tokenName;
    address owner=0x636c7e2324b6d485abc2203D0928e5e3D99e3E55;
    
   
   constructor() public{
    totalAmount = 10000 * 10**18;
    amount[owner]=totalAmount;
    decimal=18;
    tokenName="suresh";
   }

        
    function totalSupply() public view returns(uint256){
    
        
        if(owner!=msg.sender) return;
        
        return totalAmount;
    }
    function balanceOf(address to_who) public view returns(uint256){
        return amount[to_who];
    }
    
     function transfer(address to_a,uint256 _value) public returns(bool){
          uint256 x = amount[msg.sender];
    if (x<_value) return;
    amount[msg.sender]=amount[msg.sender]-_value;
    amount[to_a]=amount[to_a]+_value;
    return true;
    
         
     }
}
