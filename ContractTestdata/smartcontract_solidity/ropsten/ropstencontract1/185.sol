/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity >=0.4.22 <0.6.0;
contract Voting {

    uint8 public votes;
    address public owner;
    address public richestAddr;
    uint256 public richestMoney;
    uint256 public money;
    
    constructor() public {
        owner = msg.sender;
        votes = 0;
    }

    function voteUp() public {
        votes++;
    }
    
    function voteDown() public {
        votes--;
    }
    
    function voteReset() public {
        require (owner == msg.sender);
        votes = 0;
        
    }
    
    function () external payable {
        money += msg.value;
        if (msg.value > richestMoney) {
            richestMoney = msg.value;
            richestAddr = msg.sender;
        }
        
    }
    
    function assignOwner(address newaddr) public {
        require (owner == msg.sender);
        owner = newaddr;
        
    }
}
