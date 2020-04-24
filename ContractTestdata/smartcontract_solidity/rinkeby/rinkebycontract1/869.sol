/**
 *Submitted for verification at Etherscan.io on 2019-02-05
*/

pragma solidity^0.5.0;
//import "./SafeMath.sol";

library SafeMath{
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public TotalSupply;
    event Transfer(address indexed _from,address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
    function balanceOf(address _owner) public view returns(uint256);
    function allowance(address _owner,address _spender) public view returns(uint256);
    function transfer(address _to, uint256 _amount) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _amount) public;
    function approve(address _spender, uint256 _amount) public;
}

contract ERC20 is ERC20Interface {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping(address => mapping(address=> uint256)) allowed;
    constructor(string memory _name,string memory _symbol,uint8 _decimals, uint256 _supply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        TotalSupply = _supply * 10**uint(_decimals);
        balances[msg.sender] = balances[msg.sender].add(_supply);
        emit Transfer(address(0),msg.sender,TotalSupply);
    }
    
    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }
    function allowance(address _owner,address _spender) public view returns(uint256){
        return allowed[_owner][_spender];
    }
    function transfer(address _to, uint256 _amount) public  returns(bool){
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender,_to,_amount);
        
    }
    function transferFrom(address _from, address _to, uint256 _amount) public{
        require(balances[_from] >= _amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][_to] = allowed[_from][_to].sub(_amount);
        emit Transfer(_from,_to,_amount);
    }
    function approve(address _spender, uint256 _amount) public{
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_amount);
        emit Approval(msg.sender,_spender,_amount);
    }
    
    // don't accept money 
    function() external payable{
        revert();
    }
}
