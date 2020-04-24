/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.24;

contract SimpleContract{
    uint balance_owner;
    address owner;
    address public subOwner;
    uint balance_subOwner;
    
    constructor() public{
        balance_owner = 1000;
        owner = 0xBbc2789cF3348Ae8617992b876331B62269172fB;
        subOwner = msg.sender;
        balance_subOwner = 500;
    }
    
    function getOwner() public view returns (address){
        return owner;
    }
    
    // function setBalance(uint newBalance) public{
    //     balance = newBalance;
    // }
    
    function getBalanceOwner() public view returns (uint){
        return balance_owner;
    }
    
    function getSubOwner() public view returns (address){
        return subOwner;
    }
    
    function getBalanceSubOwner() public view returns (uint){
        return balance_subOwner;
    }
    
    function setSubOwner(address _subOwner) public{
        require(owner == msg.sender);
        subOwner = _subOwner;
    }
    
    function setBalanceSubOwner(uint newBalance) public{
        require(owner == msg.sender || subOwner == msg.sender);
        balance_subOwner = newBalance;
    }
    
    function setOwner(address _owner) public{
        require(owner == msg.sender);
        owner = _owner;
    }
    function setBalanceOwner(uint newBalance) public{
        require(owner == msg.sender);
        balance_owner = newBalance;
    }
    // function setBalanceOwner2(uint newBalance) public returns(bool){
    //     if(owner == msg.sender){
    //         balance = newBalance;
    //         return true;
    //     }
    //     return false;
    // }
}
