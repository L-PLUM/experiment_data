/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity >=0.4.22 <0.6.0;

contract Test {
    
    address public owner;
    uint256 private number;
    uint256 public balance;
    
    constructor (uint256 x) public payable
    {
        number = x;
        owner = msg.sender;
        balance += msg.value;
    }
    
    function guessNumber (uint256 x) public payable returns (bool)
    {
        require(msg.sender != owner);
        require(msg.value >= 10);
        
        balance += msg.value;
        
        if (x == number)
        {
            (msg.sender).transfer(balance);
            balance = 0;
            return true;
        }
        else if (x < number)
        {
            return false;
        }
        else if (x > number)
        {
            return true;
        }
        
        
    }
    
    
    
    
    
}
