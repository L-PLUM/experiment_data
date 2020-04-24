/**
 *Submitted for verification at Etherscan.io on 2019-01-31
*/

pragma solidity >=0.5.0;

contract Voting {

    struct Voter {
        bool ifVote;
        uint256 voterId;
        bytes pubK;
        bytes priK;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 voteHash;
        bytes messageString;
    }

    address public admin;
    address public thirdParty;
    uint256 public votersCount = 1;
    bytes public thirdPartyPubKey;
    bytes public thirdPartyPriKey;


    mapping(address => Voter) public voters;
    
    mapping(uint256 => address) public listStore;

    constructor(address _thirdParty, bytes memory pubK) public {
        admin = msg.sender;
        thirdParty = _thirdParty;
        thirdPartyPubKey = pubK;
    }

    function addVoter(address _voter, bytes memory pubK) public {
        require(msg.sender == admin || msg.sender == thirdParty);

        voters[_voter].voterId = votersCount;
        voters[_voter].pubK = pubK;
        listStore[votersCount] = _voter;
        votersCount++;
    }

    function voterVote(bytes memory messageString, uint8 v, bytes32 r, bytes32 s) public {
        require(!voters[msg.sender].ifVote);
       
        require(msg.sender == ecrecover(keccak256(messageString), v, r, s));

        voters[msg.sender].ifVote = true;
        voters[msg.sender].v = v;
        voters[msg.sender].r = r;
        voters[msg.sender].s = s;
        voters[msg.sender].voteHash = keccak256(messageString);
        voters[msg.sender].messageString = messageString;
    }

    function disclosePk(bytes memory priK) public {
        require(msg.sender == admin || msg.sender == thirdParty);
        thirdPartyPriKey = priK;
    }

    function voterDisclose(bytes memory priK) public {
        require(voters[msg.sender].voterId != 0);
        voters[msg.sender].priK = priK;
    }
}
