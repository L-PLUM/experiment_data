pragma solidity 0.4.24;
contract Muloverflow2{
uint256 public sellPrice;
uint256 public buyPrice;
function sell(uint256 amount) {
require(this.balance >= amount * sellPrice);
require(tokenLimit >= amount * sellPrice);
}
function buy(uint256 total) {
require( total * buyPrice <= this.balance);
require( total * buyPrice <= tokenLimit);
}
}
