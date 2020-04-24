/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity >=0.4.22 <0.6.0;
/// @title Voting with delegation.
contract Hello {
    function giveRightToVote() public view returns(address) {
        return msg.sender;
    }
}
