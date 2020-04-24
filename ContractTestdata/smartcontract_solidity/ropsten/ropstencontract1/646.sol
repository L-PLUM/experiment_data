/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/node_modules/openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol

/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
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

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/IWhitelist.sol

contract IWhitelist {
  function isWhitelisted(address account) public view returns (bool);
}

// File: contracts/ELNWhitelist.sol

contract ELNWhitelist is IWhitelist, WhitelistedRole, AddressVoting {
  string constant ADD_VOTER_KEY = "ADD_VOTER";
  string constant ADD_WHITELISTED_KEY = "ADD_WHITELISTED";


  constructor() public {
    renounceWhitelistAdmin();
  }

  function startVoting(string memory _key, address _value) public onlyVoter returns (uint256 votingId) {
    require(compareStrings(_key, ADD_VOTER_KEY) || compareStrings(_key, ADD_WHITELISTED_KEY));
    super.startVoting(_key, _value);
  }

  function _apply(string memory _key, address value) internal {
    if (keccak256(abi.encodePacked(_key)) == keccak256(abi.encodePacked(ADD_VOTER_KEY))) {
      _addVoter(value);
      return;
    }
    if (keccak256(abi.encodePacked(_key)) == keccak256(abi.encodePacked(ADD_WHITELISTED_KEY))) {
      _addWhitelisted(value);
      return;
    }
  }

  function compareStrings(string memory a, string memory b) private returns(bool) {
     return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }
}
