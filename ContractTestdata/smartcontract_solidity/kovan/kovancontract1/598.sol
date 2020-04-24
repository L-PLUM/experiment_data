/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.24;

contract SimpleContractLim{
    uint balance;
    address owner = 0x1eb0FaA33b84751F186D2A271276b025D4F6516C;
    
    constructor() public{
        balance = 1000;
        owner = msg.sender;
    }
    
    // function getOwner() public view returns (address){
    //     return owner;
    // }
    
    // function setBalance(uint newBalance) public{
    //     balance = newBalance;
    // }
    
    function getBalance() public view returns (uint){
        return balance;
    }
    function setOwner(address _owner) public{
        require(owner == msg.sender);
        owner = _owner;
    }
    function setBalanceOwner1(uint newBalance) public{
        require(owner == msg.sender);
        balance = newBalance;
    }
    // function setBalanceOwner2(uint newBalance) public returns(bool){
    //     if(owner == msg.sender){
    //         balance = newBalance;
    //         return true;
    //     }
    // }
}
