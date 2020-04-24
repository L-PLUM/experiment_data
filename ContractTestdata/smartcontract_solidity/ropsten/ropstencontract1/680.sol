/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.5.4;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Token {
    
    function transfer(address _to,uint256 _value) public returns (bool success) {}
    function buy() public {}
    mapping(address=> uint256) public  balances;
    uint256 public totalSupply;
    
}

contract SimpleToken is owned,Token  {
    
      uint8 public decimals = 18;
      string public name;
      string public symbol;
      
    
    
    constructor(
        string memory tokenName,
        string memory tokenSymbol)
        SimpleToken(tokenName,tokenSymbol)
        public {
            balances[msg.sender] = 750000000000000000000000;
            totalSupply =750000000000000000000000;
            name = tokenName;
            symbol = tokenSymbol;
        
 
    }
    
    function Transfer(address _to,uint256 _value) public returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }
    
    
}
