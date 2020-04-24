/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity >=0.4.22 <0.6.0;
contract Voting {

    uint8 public votes;
    address public owner;
    
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
}
