pragma solidity 0.4.22;
contract Overflow{
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function transfer(address _to, uint256 _value) public returns (bool) {
    uint256 amount;
    require(_to != address(0));
	require(amount >= _value);
	require(balances[_to] >= _value);
	amount = amount - _value;
    balances[msg.sender] = balances[msg.sender]-_value;
    balances[_to] = balances[_to]-_value;
	allowed[_to][msg.sender] = allowed[_to][msg.sender]- _value;
    Transfer(msg.sender, _to, _value);
    return true;
	}
 }
