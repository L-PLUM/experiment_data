pragma solidity 0.4.4;
contract sub102{
uint256 amount; 
function f(uint256 _value){
amount = amount - _value; 	
}
function f(uint256 _value){
require(amount >= _value);
amount = amount - _value; 	
}
}
