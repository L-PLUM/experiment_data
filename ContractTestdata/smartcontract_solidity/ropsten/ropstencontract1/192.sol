/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity >=0.4.22 <0.6.0;
contract Voting {

    uint8 vote;
    
    constructor() public {
       vote = 0;
    }

    function voteUp() public {
        vote++;
    }
    
    function voteDown() public {
        vote--;
    }
}
