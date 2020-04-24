/**
 *Submitted for verification at Etherscan.io on 2019-02-05
*/

pragma solidity ^0.5.1;

contract ERC20Token {


    

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);




    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
     uint256 public totalSupply;


    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
   

    function balanceOf(address _owner) public view returns (uint256 balance) {
      return balances[_owner];
  }
  
    string public name;
    uint8 public decimals;
    string public symbol;
    string public somedata;

    function btn(
        ) public{
        balances[msg.sender] = 10000000000000;    // creator gets all initial tokens
        totalSupply = 10000000000000;             // total supply of token
        name = "bitnote/0.0.1";               // name of token
        decimals = 0;                  // amount of decimals
        symbol = "btn";                // symbol of token
        somedata=" ";
    }

}
