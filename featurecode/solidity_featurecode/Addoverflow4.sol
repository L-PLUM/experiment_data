pragma solidity 0.4.24;
contract Addoverflow4{
uint256 public totalSupply;
uint256 public tokenLimit;
uint256 constant AMOUNT = 60 * 181415052000000;
uint256 public constant PRICE = 3000000;

function m(uint256 _value) external {
require(tokenLimit >= totalSupply + _value);
require(totalSupply + _value <= AMOUNT);
require(this.balance >= totalSupply + _value);
require(totalSupply + _value <= this.balance);
}
function b() public payable{
require(msg.value * PRICE /msg.value == PRICE);
uint256 newTokens = msg.value * PRICE;
require(totalSupply + newTokens <= AMOUNT);
require(AMOUNT >= totalSupply + newTokens);
require(totalSupply + newTokens <= this.balance);
require(this.balance >= totalSupply + newTokens);
}
function f(uint256 _value) public {
require(msg.value * PRICE /msg.value == PRICE);
uint256 tokens = msg.value * PRICE;
require(tokenLimit >= totalSupply + tokens);
require(totalSupply + tokens <= AMOUNT);
require(this.balance >= totalSupply + tokens);
require(totalSupply + tokens <= this.balance);
}

}
