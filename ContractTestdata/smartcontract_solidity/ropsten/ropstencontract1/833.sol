/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.25;

contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        assert(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        assert(b > 0);
        c = a / b;
    }
}

contract ERC20token is ERC20Interface, SafeMath {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_;
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
   
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner    = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns(address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BurnableToken is Ownable, ERC20token {

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function _burn(address account, uint256 value) internal onlyOwner {
        require(account != 0);
        require(value <= balances[account]);
        
        totalSupply_ = safeSub(totalSupply_, value);
        balances[account] = safeSub(balances[account], value);

        emit Transfer(account, address(0), value);
    }

}

contract SunblockToken is BurnableToken {
    string tokenName;
    string tokenSymbol;
    uint256 tokenDecimals;

    constructor(string name, string symbol, uint256 decimals, uint256 totalSupply, address founder) public {
        tokenName = name;
        tokenSymbol = symbol;
        tokenDecimals = decimals;
        totalSupply_ = totalSupply * (10 ** decimals);
        balances[founder] = totalSupply_;
        emit Transfer(address(0), founder, totalSupply_);
    }

    function name() public view returns (string) {
        return tokenName;
    }
    
    function symbol() public view returns (string) {
        return tokenSymbol;
    }
    
    function decimals() public view returns (uint256) {
        return tokenDecimals;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
}
