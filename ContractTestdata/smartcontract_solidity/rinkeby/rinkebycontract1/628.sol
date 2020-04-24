/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: contracts/Migrations.sol

contract Migrations {
    address public owner;
    uint256 public last_completed_migration; // solhint-disable-line

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function setCompleted(uint256 _completed) public restricted {
        last_completed_migration = _completed;
    }

    function upgrade(address _newAddress) public restricted {
        Migrations upgraded = Migrations(_newAddress);
        upgraded.setCompleted(last_completed_migration);
    }
}
