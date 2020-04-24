/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^0.5.0;

/// @dev Provides a source of truth, to be used by external contract, to verify if an address is authorized to perform certain kind of operations.
/// @title Identity Manager Contract
/// @author Aristide Piazza
contract IdManager {

  mapping (address => bool) private _whitelist;

  address public owner;
  bool public active; // used to block all members in case of emergency

  /// @dev constructor
  constructor () public {
    owner = msg.sender;
    active = true;
  }

  /// @dev requires that owner == msg.sender
  modifier checkSender () {
    require (msg.sender == owner, "Address not authorized");
    _;
  }

  /// @dev emitted when a new member is added to the whitelist
  event MemberAdded(address member);

  /// @dev emitted when a member is removed from the whitelist
  event MemberRemoved(address member);

  /// @dev emitted when the contract status (variable "active") changes
  event ActiveChanged(bool status);

  /// @dev used to block all members in case of emergency
  function setActive(bool status) public checkSender() {
    active = status;
    emit ActiveChanged(status);
  }

  /// @dev add a member to the whitelist. It can be called only by the contract owner
  function addMember(address addr) public checkSender() {
    _whitelist[addr] = true;
    emit MemberAdded(addr);
  }

  /// @dev remove a member from the whitelist. It can be called only by the contract owner
  function removeMember(address addr) public checkSender() {
    _whitelist[addr] = false;
    emit MemberRemoved(addr);
  }

  /// @dev check if a member is in the whitelist & the the contract is active (not stopped for emergency), and thus authorized to perform token transactions.
  /// @return bool
  function verifyAddress(address addr) public view returns (bool) {
    return (_whitelist[addr] && active);
  }

}
