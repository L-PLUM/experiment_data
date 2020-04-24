/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.5.10;

contract Shared_Table {

  address public created_by;
  address public updated_by;
  string public currentHash;

  struct proposal {
    address proposer;
    bool exists;
    string previousHash;
  }
  mapping(string => proposal) internal proposals;
  string[] public proposalIds;

  event hashUpdated(
    string hash
  );

  event newProposal(
    string hash
  );

  event proposalAccepted(
    string hash
  );

  constructor () public {
    created_by = msg.sender;
  }

  //// To accept a proposal
  function acceptProposal(string memory _hash) public returns (bool) {
    require(proposals[_hash].exists, "This proposal doesn't exist");
    //require(proposals[_hash].proposer != msg.sender, "You can't accept your own proposal");
    require(keccak256(abi.encodePacked(proposals[_hash].previousHash)) == keccak256(abi.encodePacked(currentHash)), "You can't accept an out of date proposal !");

    emit proposalAccepted(_hash);

    bool updated = updateHash(proposals[_hash].previousHash, _hash);
    if (updated) {
        delete proposalIds;
    }

    return true;
  }

  //// To add a new proposal
  function addProposal(string memory _newHash) public returns (bool) {
    require(!(proposals[_newHash].exists && keccak256(abi.encodePacked(proposals[_newHash].previousHash)) == keccak256(abi.encodePacked(currentHash))), "This proposal already exist");

    proposals[_newHash] = proposal({proposer: msg.sender, exists: true, previousHash: currentHash});
    proposalIds.push(_newHash);

    emit newProposal(_newHash);

    return true;
  }

  function numberOfProposals() public view returns (uint) {
      uint arrayLength = proposalIds.length;

      return arrayLength;
  }

  //// To update a the current hash without the proposal part
  function updateHash(string memory _currentHash, string memory _newHash) public returns (bool) {
    require(keccak256(abi.encodePacked(_currentHash)) == keccak256(abi.encodePacked(currentHash)), "Your current version is not up-to-date, concurrency problem ?");

    currentHash = _newHash;
    updated_by = msg.sender;
    emit hashUpdated(currentHash);

    return true;
  }
}
