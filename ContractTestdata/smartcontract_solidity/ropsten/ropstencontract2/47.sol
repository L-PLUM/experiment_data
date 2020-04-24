/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity 0.4.25;

contract CwtBank {
    address owner;
    mapping(address => uint) balances;
    
    function allowed() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            msg.sender.transfer(amount);
        }
    }

    function getMyBalance() public view returns(uint) {
        return balances[msg.sender];
    }

    function kill() public {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}
