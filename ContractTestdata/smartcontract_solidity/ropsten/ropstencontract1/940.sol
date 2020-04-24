/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.4.0;
contract TestContract {

    struct Proposal {
        uint voteCount;
        string description;
    }

    address public owner;
    Proposal[] public proposals;

    function TestContractFunction() public{
        owner = msg.sender;
    }

    function createProposal(string memory description) public{
        Proposal memory p;
        p.description = description;
        proposals.push(p);
    }

    function vote(uint proposal) public{
        proposals[proposal].voteCount += 1;
    }
}
