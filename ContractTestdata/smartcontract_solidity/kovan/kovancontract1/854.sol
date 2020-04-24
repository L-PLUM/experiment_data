/**
 *Submitted for verification at Etherscan.io on 2018-12-24
*/

pragma solidity >=0.4.0 <0.6.0;

contract NetMonitor {
    
    address public owner;
    uint256 public last_seen;
    event LastSeen(uint256 timestamp);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner is allowed to do this");
        _;
    }

    function update() onlyOwner public {
        last_seen = now;
        emit LastSeen(last_seen);
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
}
