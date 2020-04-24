pragma solidity 0.4.22;
contract Addoverflow3{
uint256 amount;
function t(uint256 _value) public returns (bool) {
	amount = amount + _value;
    msg.sender.transfer(amount);
    return true;
	}
	function t1(uint256 mint) public returns (bool) {
    uint256 _amount;
	require(_amount + mint >= _amount );
	_amount = _amount + mint;
    msg.sender.transfer(_amount);
    return true;
	}
 }

contract Addoverflow4{
mapping(address => uint256) balances;
function f(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
	require(_value + balances[_to]>= balances[_to]);
    balances[_to] = balances[_to]+_value;
	msg.sender.transfer(balances[_to]);
    return true;
	}
	function f1(address _from, uint256 msgValue) public returns (bool) {
	require(_from != address(0));
    balances[_from] = balances[_from] + msgValue;
	msg.sender.transfer(balances[_from]);
    return true;
	}
 }
 
contract Addoverflow5{
mapping(address => uint256) balances;
function s(uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender]+_value;
    msg.sender.transfer(_value);
    return true;
	}
function s1(uint256 tr) public returns (bool) {
	require(balances[msg.sender]+tr >= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender]+tr;
    msg.sender.transfer(tr);
    return true;
	}	
 }
 
contract Addoverflow6{
mapping (address => mapping (address => uint256)) allowed;
function ff(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
	require(allowed[_to][msg.sender]+_value >= _value);
	allowed[_to][msg.sender] = allowed[_to][msg.sender]+ _value;
    msg.sender.transfer(_value);
    return true;
	}
function ff1(address _spend, uint256 _value) public returns (bool) {
    require(_spend != address(0));
	allowed[_spend][msg.sender] = allowed[_spend][msg.sender]+ _value;
    msg.sender.transfer(_value);
    return true;
	}
 }