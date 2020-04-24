/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

/// @title Migrations: A contract to manage contract migrations
/// @author John McCrae

/// @dev This contract requires solidity compiler version 0.5 or higher
pragma solidity ^0.5.0;

/// @dev Marketplace: A contract to manage contract migrations
contract Migrations {

    /// @param owner A public address data type
    address public owner;

    /// @param last_completed_migration A public uint data type
    uint public last_completed_migration;

    /// @dev Declare constructor. Set owner to be the contract creator
    constructor() public {
      owner = msg.sender;
    }

    /// @dev restricted A modifier requiring the message sender address is equal to the owner address
    modifier restricted() {
      if (msg.sender == owner) _;
    }

    /// @dev setCompleted() A function to register the last completed migration as completed
    /// @param completed A uint data type to register the last completed migration as completed
    function setCompleted(uint completed) public restricted {
      last_completed_migration = completed;
    }

    /// @dev upgrade() A function to manage the upgrade of contracts
    /// @param new_address An address data type to manage the upgrade of contracts
    function upgrade(address new_address) public restricted {
      Migrations upgraded = Migrations(new_address);
      upgraded.setCompleted(last_completed_migration);
    }
}
