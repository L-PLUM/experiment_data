/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/IRegistry.sol

contract IRegistry {
  string public constant REGISTRY_KEY = "REGISTRY";

  function getAddress(string memory _key) public view returns (address);
}

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/AddressVoting.sol

contract AddressVoting {
  address[] public voters;
  mapping (address => bool) votersMap;

  uint256 votingsLength;
  mapping (uint256 => Voting) votings;

  modifier onlyVoter() {
    require(votersMap[msg.sender]);
    _;
  }

  modifier votingExists(uint256 _voteId) {
    require(_voteId < votingsLength, "Voting must exist");
    _;
  }

  struct Voting {
    uint256 votingId;
    uint256 votesCount;
    string key;
    address value;
    bool applyed;
    mapping (address => bool) voted;
  }

  event VoterAdded(address voter);
  event VotingStarted(uint256 votingId, string key, address value);
  event Voted(uint256 votingId, address voter, uint256 votingCount);
  event VotingApplyed(uint256 votingId);

  constructor() internal {
    _addVoter(msg.sender);
  }

  function _addVoter(address _voter) internal {
    voters.push(_voter);
    votersMap[_voter] = true;

    emit VoterAdded(_voter);
  }

  function startVoting(string memory _key, address _value) public onlyVoter returns (uint256 votingId) {
    votingId = votingsLength++;

    votings[votingId] = Voting(votingId, 1, _key, _value, false);
    votings[votingId].voted[msg.sender] = true;

    emit VotingStarted(votingId, _key, _value);
  }

  function vote(uint256 _votingId) public onlyVoter votingExists(_votingId) {
    Voting storage voting = votings[_votingId];

    require(!voting.applyed, "Voting already applyed");
    require(!voting.voted[msg.sender], "Already voted");

    voting.votesCount = voting.votesCount + 1;
    voting.voted[msg.sender] = true;

    emit Voted(_votingId, msg.sender, voting.votesCount);
  }

  function applyVoting(uint256 _votingId) public votingExists(_votingId) {
    Voting storage voting = votings[_votingId];

    require(isVotingSuccessful(voting.votesCount), "Voting must be successful");

    _apply(voting.key, voting.value);

    emit VotingApplyed(_votingId);
  }

  function isVotingSuccessful(uint256 _votesCount) internal view returns (bool) {
    return _votesCount * 3 >= voters.length * 2;
  }

  function _apply(string memory _key, address value) internal;
}

// File: contracts/Registry.sol

contract Registry is IRegistry, AddressVoting {
  string constant ADD_VOTER_KEY = "ADD_VOTER";

  mapping (string => address) registry;

  constructor () public {
    _apply(IRegistry.REGISTRY_KEY, address(this));
  }

  function _apply(string memory _key, address value) internal {
    if (keccak256(abi.encodePacked(_key)) == keccak256(abi.encodePacked(ADD_VOTER_KEY))) {
      _addVoter(value);
      return;
    }
    registry[_key] = value;
  }

  function getAddress(string memory _key) public view returns (address) {
    return registry[_key];
  }
}
