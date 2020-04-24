/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.17;

contract School {
  enum Nomination {
    PROCURATOR,   // personero
    COMPTROLLER,  // contralor
    OBSERVER,     // veedor
    COUNCILOR,    // cabildante
    HEALTHWATCH   // vigía de la salud
  }

  struct SchoolData {
    bytes schoolName;
    uint startDateBallot;
    uint endDateBallot;
    bytes32[] candidatesId;
    mapping (bytes32 => Candidate) candidates;
    mapping (bytes32 => mapping (uint8 => uint)) voters;
  }

  struct Candidate {
    bytes32 fname;
    bytes32 lname;
    uint8 votes;
    bytes photoUrl;
    Nomination nomination;
    uint8 position;
  }

  mapping (address => SchoolData) public schools;

  event schoolAdded(bytes schoolName);

  function addSchool(address _account, bytes _schoolName, uint _startDateBallot, uint _endDateBallot) public {
    bytes32[] memory ids = new bytes32[](0);
    schools[_account] = SchoolData({ schoolName: _schoolName, startDateBallot: _startDateBallot, endDateBallot: _endDateBallot, candidatesId: ids });
    schoolAdded(_schoolName);
  }

  function getSchool(address _account) public constant returns (bytes, uint, uint) {
    SchoolData memory school = schools[_account];
    return (school.schoolName, school.startDateBallot, school.endDateBallot);
  }

  function isElectionOpen(address _account) public constant returns (bool _result) {
    SchoolData memory school = schools[_account];
    _result = false;
    if (school.startDateBallot <= now && now <= school.endDateBallot)
      _result = true;
  }

  function addCandidate(address _account, bytes32 _id, bytes32 _fname, bytes32 _lname, bytes _photoUrl, bytes32 _nomination, uint8 _position) public {
    schools[_account].candidates[_id] = Candidate({
      fname: _fname,
      lname: _lname,
      votes: 0,
      photoUrl: _photoUrl,
      nomination: setNomination(_nomination),
      position: _position
      });
    schools[_account].candidatesId.push(_id);
  }

  function setNomination(bytes32 _nomination) internal pure returns (Nomination n) {
    if (_nomination == "procurator" ) {
      n = Nomination.PROCURATOR;
    } else if (_nomination == "comptroller" ) {
      n = Nomination.COMPTROLLER;
    } else if (_nomination == "observer" ) {
      n = Nomination.OBSERVER;
    } else if (_nomination == "councilor" ) {
      n = Nomination.COUNCILOR;
    } else if (_nomination == "healthwatch" ) {
      n = Nomination.HEALTHWATCH;
    }
  }

  function getCandidate(address _account, bytes32 _id) public constant returns (bytes32, bytes32, uint8, string, bytes, uint8) {
    Candidate memory c = schools[_account].candidates[_id];
    return (c.fname, c.lname, c.votes, getNomination(c.nomination), c.photoUrl, c.position);
  }

  function getNomination(Nomination _nomination) internal pure returns (string n) {
    if (_nomination == Nomination.PROCURATOR ) {
      n = "procurator";
    } else if (_nomination == Nomination.COMPTROLLER ) {
      n = "comptroller";
    } else if (_nomination ==  Nomination.OBSERVER ) {
      n = "observer";
    } else if (_nomination ==  Nomination.COUNCILOR ) {
      n = "councilor";
    } else if (_nomination == Nomination.HEALTHWATCH ) {
      n = "healthwatch";
    }
  }

  function getNominationCode(Nomination _nomination) internal pure returns (uint8 n) {
    if (_nomination == Nomination.PROCURATOR ) {
      n = 0;
    } else if (_nomination == Nomination.COMPTROLLER ) {
      n = 1;
    } else if (_nomination ==  Nomination.OBSERVER ) {
      n = 2;
    } else if (_nomination ==  Nomination.COUNCILOR ) {
      n = 3;
    } else if (_nomination == Nomination.HEALTHWATCH ) {
      n = 5;
    }
  }

  function getTotalCandidates(address _account) public constant returns (uint256) {
    bytes32[] memory ids = schools[_account].candidatesId;
    return ids.length;
  }

  function getTotalCandidatesByNomination(address _account, bytes32 _nomination) public constant returns (uint256 total) {
    bytes32[] memory ids = schools[_account].candidatesId;
    for(uint8 i = 0; i < ids.length; i++) {
      Candidate memory candidate = schools[_account].candidates[ids[i]];
      if (candidate.nomination == setNomination(_nomination)) {
        ++total;
      }
    }
  }

  function getCandidateByIndex(address _account, uint8 index) public constant returns (bytes32, bytes32, bytes32, uint8, string, bytes, uint8) {
    bytes32[] memory ids = schools[_account].candidatesId;
    Candidate memory c;
    bytes32 id;
    for (uint8 i = 0; i < ids.length; i++) {
      if (i == index) {
        Candidate memory candidate = schools[_account].candidates[ids[i]];
        c = candidate;
        id = ids[i];
      }
    }
    return (id, c.fname, c.lname, c.votes, getNomination(c.nomination), c.photoUrl, c.position);
  }

  function vote(address _account, bytes32 _id, bytes32 _candidate) public {
    Candidate storage c = schools[_account].candidates[_candidate];
    c.votes += 1;
    schools[_account].voters[_id][getNominationCode(c.nomination)] = now;
  }

  function hasVoted(address _account, bytes32 _id, bytes32 _nomination) public constant returns (uint) {
    return schools[_account].voters[_id][getNominationCode(setNomination(_nomination))];
  }

  function getWinner(address _account, bytes32 _nomination) public constant returns(bytes32, bytes32, bytes32, uint8, string, bytes, uint8) {
    bytes32[] memory ids = schools[_account].candidatesId;
    Candidate memory c;
    bytes32 id;
    for (uint8 i = 0; i < ids.length; i++) {
      Candidate memory candidate = schools[_account].candidates[ids[i]];
      if (candidate.nomination == setNomination(_nomination) && candidate.votes > c.votes) {
        c = candidate;
        id = ids[i];
      }
    }
    return (id, c.fname, c.lname, c.votes, getNomination(c.nomination), c.photoUrl, c.position);
  }
}
