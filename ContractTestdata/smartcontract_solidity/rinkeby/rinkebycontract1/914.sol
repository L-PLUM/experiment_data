/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity 0.5.0;

// File: contracts/AdminInterface.sol

/**
 * @title AdminInterface
 */
interface AdminInterface {

  /**
   * @dev Return whether the given address is an admin at the moment.
   */
  function isAdmin(address account) external view returns (bool);
}

// File: contracts/AdminSimple.sol

/**
 * @title AdminSimple
 */
contract AdminSimple is AdminInterface {

  mapping (address => bool) admins;

  constructor() public {
    admins[msg.sender] = true;
  }

  function addAdmin(address account) public returns (bool) {
    require(isAdmin(msg.sender));
    require(!isAdmin(account));

    admins[account] = true;
    return true;
  }

  function removeAdmin(address account) public returns (bool) {
    require(isAdmin(msg.sender));
    require(isAdmin(account));

    admins[account] = false;
    return true;
  }

  /**
   * @dev Return whether the given address is an admin at the moment.
   */
  function isAdmin(address account) public view returns (bool) {
    return admins[account];
  }
}
