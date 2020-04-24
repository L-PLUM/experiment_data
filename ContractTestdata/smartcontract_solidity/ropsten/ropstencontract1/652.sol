/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


contract erctoken {

    using SafeMath for uint256;
    uint256 public constant decimals = 18;
    string public constant name = "ABCRajToken";
    string public constant symbol = "ABCRAJ";
    address public owner;
    bool isEnabled=true;
    uint256 public totalSupply;
    //uint public totalSupply = 10**27; // 1 billion tokens, 18 decimal places


    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    ///////////////////////////////////////////// Ownership

    constructor() public {
        owner = msg.sender;
        totalSupply=1000000000000000000000000000000000000000000000000000000;
        balances[owner] = totalSupply;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function enableToken() onlyOwner public {
        isEnabled = true;
    }

    function disableToken() onlyOwner public {
        isEnabled = false;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    function burn(uint256 _value) public onlyOwner {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);


    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        require (isEnabled);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require (isEnabled);
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}
