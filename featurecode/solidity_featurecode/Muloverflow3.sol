pragma solidity 0.4.24;
contract Muloverflow3{
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
uint256 public amount;
function mintToken(address target, uint256 mintedAmount) public{
amount *= mintedAmount;
balanceOf[target] *= mintedAmount;
balanceOf[msg.sender] *= mintedAmount;
allowance[msg.sender][target] *= mintedAmount;
}
}
