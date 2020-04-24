/**
 *Submitted for verification at Etherscan.io on 2019-07-21
*/

pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract GameToken {
    using SafeMath for uint256;
    
    // creator of this contract
    address private _owner;
    
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => bool) public _authorizdedMachines;
    
    string public name;
    uint8 public decimals;
    string public symbol;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Reward(address indexed machine, address indexed player, uint256 value);
    event Consume(address indexed machine, address indexed player, uint256 value);
    
    constructor (
        uint256 totalSupply,
        string tokenName,
        string tokenSymbol,
        uint8 decimalUnits
    ) public {
        _owner = msg.sender;
        _totalSupply = totalSupply;
        _balances[msg.sender] = totalSupply;
        
        name = tokenName;
        decimals = decimalUnits;
        symbol = tokenSymbol;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }
    
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[msg.sender]);
        require(to != address(0));
        
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        
        _transfer(from, to, value);
        emit Transfer(from, to, value);
        return true;
    }
    
    modifier onlyOwner()  {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyAuthorizedMachine()  {
        require(_authorizdedMachines[msg.sender]);
        _;
    }
    
    function addGameMachine(address machine) public onlyOwner() {
        _authorizdedMachines[machine] = true;
    }
    
    function removeGameMachine(address machine) public onlyOwner() {
        _authorizdedMachines[machine] = false;
    }
    
    function reward(address to, uint256 value) public onlyAuthorizedMachine() returns (bool) {
        _transfer(msg.sender, to, value);
        emit Reward(msg.sender, to, value);
        return true;
    }
    
    function consume(address by, uint256 value) public onlyAuthorizedMachine() returns (bool){
        _transfer(by, msg.sender, value);
        emit Consume(msg.sender, by, value);
        return true;
    }
}
