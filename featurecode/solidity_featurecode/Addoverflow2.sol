pragma solidity 0.4.24;
contract Addoverflow2{
uint256 amount; 
uint256 public constant PRICE = 3000000;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;

function t(address _to, uint256 _value) public returns (bool) {
amount = amount + _value;
balances[_to] = balances[_to]+_value;
balances[msg.sender] = balances[msg.sender]+_value;
allowed[_to][msg.sender] = allowed[_to][msg.sender]+ _value;
}
function buyTokensPresale(address _to) public payable{
require(msg.value * PRICE /msg.value == PRICE);
uint256 newTokens = msg.value * PRICE;
amount = amount + newTokens;
balances[_to] = balances[_to]+ newTokens;
balances[msg.sender] =balances[msg.sender]+ newTokens;
allowed[_to][msg.sender] = allowed[_to][msg.sender]+ newTokens;

}
function issue_noVesting(address _to, uint _value)  public{
require(_value * PRICE /_value == PRICE);
uint256 tokens = _value * PRICE;
amount = amount + tokens;
balances[_to] = balances[_to]+tokens;
balances[msg.sender] =balances[msg.sender]+ tokens;
allowed[_to][msg.sender] = allowed[_to][msg.sender]+ tokens;

}

}
