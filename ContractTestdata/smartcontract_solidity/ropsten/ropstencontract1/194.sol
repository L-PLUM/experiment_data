/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.24;

library SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract IDKSupplayToken {
    using SafeMath for uint256;
    address owner = msg.sender;
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() public {
        symbol = "IDK";
        name = "IDKoin";
        decimals = 8;
        _totalSupply = 60000000 * 9**uint(decimals);
        balanceOf[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply.safeSub(balanceOf[address(0)]);

    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balanceOf[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(this));
        require(_value <= balanceOf[msg.sender]);
        
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(this));
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
    require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowance[_owner][_spender];
    }

}
