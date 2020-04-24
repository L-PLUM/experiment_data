/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/CertCenter.sol

pragma solidity ^0.5.2;



contract CertCenter is Ownable {
    mapping(address => bool) public renters;

    event RenterAdded(address indexed renter);
    event RenterRemoved(address indexed renter);

    function updateRenters(
        address[] calldata rentersToRemove,
        address[] calldata rentersToAdd
    )
        external
        onlyOwner
    {
        for (uint i = 0; i < rentersToRemove.length; i++) {
            if (renters[rentersToRemove[i]]) {
                delete renters[rentersToRemove[i]];
                emit RenterRemoved(rentersToRemove[i]);
            }
        }

        for (uint i = 0; i < rentersToAdd.length; i++) {
            if (!renters[rentersToAdd[i]]) {
                renters[rentersToAdd[i]] = true;
                emit RenterAdded(rentersToAdd[i]);
            }
        }
    }
}
