/**
 *Submitted for verification at Etherscan.io on 2019-02-07
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
    event Transfer(address indexed from,address indexed to, uint256 tokens);
    event Approval(address indexed _owner, address indexed _spender, uint256 tokens);
    function balanceOf(address _owner) public view returns(uint256);
    function allowance(address _owner,address _spender) public view returns(uint256);
    function transfer(address _to, uint256 tokens) public returns(bool);
    function transferFrom(address _from, address _to, uint256 tokens) public;
    function approve(address _spender, uint256 tokens) public;
}

contract Owned{
    address owner;
    address newOwner;
    event OwnershipTransferred(address indexed from,address indexed to);
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    constructor() public{
        owner = msg.sender;
    }
    function transferOwner(address _newOwner) public onlyOwner{
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner,newOwner);
    }
}

contract ERC20 is ERC20Interface, Owned{
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping(address => mapping(address=> uint256)) allowed;
    constructor(string memory _name,string memory _symbol,uint8 _decimals, uint256 _supply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        TotalSupply = _supply * 10**uint(_decimals);
        balances[owner] = balances[msg.sender].add(TotalSupply);
        emit Transfer(address(0),owner,TotalSupply);
    }
    function totalSupply() public view returns(uint256){
        return TotalSupply;
    }
    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }
    function allowance(address _owner,address _spender) public view returns(uint256){
        return allowed[_owner][_spender];
    }
    function transfer(address _to, uint256 tokens) public  returns(bool){
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[_to] = balances[_to].add(tokens);
        emit Transfer(msg.sender,_to,tokens);
        
    }
    function transferFrom(address _from, address _to, uint256 tokens) public{
        require(balances[_from] >= tokens);
        balances[_from] = balances[_from].sub(tokens);
        balances[_to] = balances[_to].add(tokens);
        allowed[_from][_to] = allowed[_from][_to].sub(tokens);
        emit Transfer(_from,_to,tokens);
    }
    function approve(address _spender, uint256 tokens) public{
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(tokens);
        emit Approval(msg.sender,_spender,tokens);
    }
    
    // don't accept money 
    function() external payable{
        revert();
    }
}
