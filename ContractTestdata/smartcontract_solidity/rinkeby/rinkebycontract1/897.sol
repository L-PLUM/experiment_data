/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.5.1;

contract Token {
    mapping (address => uint) balances;
    uint totalSupply;
    
    constructor (uint initialTotalSupply) public {
        totalSupply = initialTotalSupply;
        balances[msg.sender]=totalSupply;
    }
    
    function transfer(address to, uint value) public {
        require(value <= balances[msg.sender]);
        balances[to] += value;
        balances[msg.sender] -= value;
    }
    
    function getBalance(address holder) public view returns (uint) {
        return balances[holder];
    }
    
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }
}
