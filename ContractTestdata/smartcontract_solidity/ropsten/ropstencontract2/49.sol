/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity 0.4.25;

contract CWTBank {
address owner;
mapping(address => uint) balances;
mapping (address => mapping (address => uint256)) public allowed;
uint256 public totalSupply;
uint256 public summa;


function Bank() private {
    owner = msg.sender;
}



function deposit() public payable {
   
       
       
       balances[msg.sender] += msg.value;
       totalSupply += msg.value ;
       
}
    



function MyDepositInfo(address investorAddr) public view returns(uint investment) {
(investment) = balances[investorAddr] / 10**18;

}

function withdraw(uint amount) public {
  summa = amount * 10**18;
if (balances[msg.sender] >= summa) {
balances[msg.sender] -= summa;
msg.sender.transfer(summa);
}
}

function getMyBalance() private view returns(uint) {
return balances[msg.sender];
}

function kill() private {
if (msg.sender == owner)
selfdestruct(owner);
}
}
