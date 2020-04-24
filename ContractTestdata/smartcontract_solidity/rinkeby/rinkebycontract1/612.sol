/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.4.24;
contract class32{
    address owner;
    constructor() public payable{
        owner = msg.sender;
    }    
    function querybalance() public view returns(uint){
        return owner.balance;
    }
    
    function querybalance1() public view returns(uint){
        return address(this).balance;
    }
    
    function send(uint money) public returns(bool){
        bool reuslt = owner.send(money);
        return reuslt;
    }
    
    function transfer(uint money) public {
        owner.transfer(money);
    }
}
