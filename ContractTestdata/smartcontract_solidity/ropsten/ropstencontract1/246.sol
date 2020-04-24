/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.4;
contract MouseBelt {
    mapping (address => uint256) private _balances;
    string public name;                  
    uint8 public decimals;              
    string public symbol;  
    uint256 private _totalSupply;
    address public _owner;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Purchase(address indexed from, address indexed to, uint256 value);
    
    constructor() public {
            _owner = msg.sender;
            _balances[msg.sender] = 100000000E18;             
            _totalSupply = 100000000E18;                        
            name = "MouseBelt Token";                                  
            decimals = 18;                            
            symbol = "MBT";                              
        }
    
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address who) public view returns (uint256){
        return _balances[who];
    }
    function transfer(address to, uint256 value) public returns (bool){
        _transfer(msg.sender, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
        require(to != address(0));
    
        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(from, to, value);
  }
  
  function () external payable {
      if(msg.value > 0){
        require(msg.value*10000 <= _balances[_owner]);
        _balances[_owner] = _balances[_owner] - msg.value*10000;
        _balances[msg.sender] = _balances[msg.sender] + msg.value*10000;
      }
  }
    
}
