/**
 *Submitted for verification at Etherscan.io on 2019-01-10
*/

pragma solidity 0.5.2;

contract Fauset {
    
    mapping(address => bool) public payee;
    
    address payable public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    // fallback function
    function () external payable {
        
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getEther(uint256 _amount) public {
        require(_amount <= 0.1 ether);
        require(!payee[msg.sender]);
        
        payee[msg.sender] = true;
        msg.sender.transfer(_amount);
    }
    
    function withdraw(uint256 _amount) public onlyOwner {
        owner.transfer(_amount);
    }
    
}
