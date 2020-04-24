pragma solidity 0.4.22;
contract Suboverflow10{
uint256 _totalSupply = 21000000 * 10**8;
uint256 public constant TOTAL = 10000000* 10**8;
address public owner;
mapping(address => uint256) balances; 
mapping(address => mapping (address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);

function distributeBTR(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
            require(balances[owner] >= 2000 * 10**8);
			balances[owner] -= 2000 * 10**8;
			balances[msg.sender] -= 2000 * 10**8;
		    _totalSupply -= 2000 * 10**8;
			 require(allowed[owner][msg.sender] >= 2000 * 10**8);
			allowed[owner][msg.sender] -= 2000 * 10**8;
             balances[addresses[i]] += 2000 * 10**8;
             Transfer(owner, addresses[i], 2000 * 10**8);
         }
     }
function distributeBTR1(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
            balances[owner] -= 2000 * 10**8;
			require(balances[msg.sender] >= 2000 * 10**8);
			balances[msg.sender] -= 2000 * 10**8;
			require(_totalSupply >= 2000 * 10**8);
		    _totalSupply -= 2000 * 10**8;
			allowed[owner][msg.sender] -= 2000 * 10**8;
             balances[addresses[i]] += 2000 * 10**8;
             Transfer(owner, addresses[i], 2000 * 10**8);
         }
     }	 
function distributeBTR2(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
			 require(balances[owner] >= TOTAL);
			 balances[owner] -= TOTAL;
			 balances[msg.sender] -= TOTAL;
			 require(_totalSupply >= TOTAL);
			 _totalSupply -= TOTAL;
			 allowed[owner][msg.sender] -= TOTAL;
             balances[addresses[i]] += TOTAL;
             Transfer(owner, addresses[i], TOTAL);
         }
     }
function distributeBTR3(address[] addresses) onlyOwner {
         for (uint i = 0; i < addresses.length; i++) {
			 balances[owner] -= TOTAL;
			 require(balances[msg.sender] >= TOTAL);
			 balances[msg.sender] -= TOTAL;
			 _totalSupply -= TOTAL;
			 require(allowed[owner][msg.sender] >= TOTAL);
			 allowed[owner][msg.sender] -= TOTAL;
             balances[addresses[i]] += TOTAL;
             Transfer(owner, addresses[i], TOTAL);
         }
     }
}