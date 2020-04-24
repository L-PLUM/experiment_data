/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.3;

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

contract Approvable is Ownable {
    mapping(address => bool) private _approvedAddress;


    modifier onlyApproved() {
        require(isApproved());
        _;
    }

    function isApproved() public view returns(bool) {
        return _approvedAddress[msg.sender] || isOwner();
    }

    function approveAddress(address _address) public onlyOwner {
        _approvedAddress[_address] = true;
    }

    function revokeApproval(address _address) public onlyOwner {
        _approvedAddress[_address] = false;
    }
}

contract StoringCreationMeta {
    uint public creationBlock;
    uint public creationTime;

    constructor() internal {
        creationBlock = block.number;
        creationTime = block.timestamp;
    }
}

contract ContractRegistry is StoringCreationMeta, Approvable {
    address public eventRegistry;
    address public nodeRegistry;
    address public userRoles;

    enum Contracts {
        EventRegistry,
        NodeRegistry,
        UserRoles
    }

    event ContractChange(uint _contractType, address _newAddress);

    function setEventRegistry(address _eventRegistry) public onlyApproved {
        eventRegistry = _eventRegistry;
        emit ContractChange(uint(Contracts.EventRegistry), _eventRegistry);
    }

    function setNodeRegistry(address _nodeRegistry) public onlyApproved {
        nodeRegistry = _nodeRegistry;
        emit ContractChange(uint(Contracts.NodeRegistry), _nodeRegistry);
    }

    function setUserRoles(address _userRoles) public onlyApproved {
        userRoles = _userRoles;
        emit ContractChange(uint(Contracts.UserRoles), _userRoles);
    }

    // Enables setting all contracts in one call - [EventRegistry, NodeRegistry, UserRoles]
    function setContracts(address[3] memory _contracts) public onlyApproved {
        setEventRegistry(_contracts[uint(Contracts.EventRegistry)]);
        setNodeRegistry(_contracts[uint(Contracts.NodeRegistry)]);
        setUserRoles(_contracts[uint(Contracts.UserRoles)]);
    }

    function getContracts() public view returns(address[3] memory) {
        return [
            eventRegistry,
            nodeRegistry,
            userRoles
        ];
    }
}
