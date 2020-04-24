pragma solidity 0.4.24;
contract Suboverflow4{
uint256 _totalSupply = 21000000 * 10**8;
uint256 public constant TOTAL = 10000000* 10**8;
address public owner;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
…
function f(address[] addresses) onlyOwner {
for (uint i = 0; i < addresses.length; i++) {
   balances[owner] -= 2000 * 10**8;
	  balances[msg.sender] -= 2000 * 10**8;
	  _totalSupply -= 2000 * 10**8;
	  allowed[owner][msg.sender] -= 2000 * 10**8;
   …
   }
}
function d(address[] addresses) onlyOwner {
for (uint i = 0; i < addresses.length; i++) {
	  balances[owner] -= TOTAL;
	  balances[msg.sender] -= TOTAL;
	 _totalSupply -= TOTAL;
  allowed[owner][msg.sender] -= TOTAL;
   …
   }
 }
…
}
