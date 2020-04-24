/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.0;

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/validator/IValidatorRegistry.sol

interface IValidatorRegistry {

    enum Status {
        NULL,
        PENDING,
        ACCEPTED,
        CHALLENGED,
        REJECTED
    }

    struct Listing {
        Status status;
        uint stakedBalance;
        uint applicationBlock;
        bytes32 tendermintPublicKey;
        address owner;
        address challenger;
        uint challengeBalance;
        uint pollId;
        uint challengeEnd;
    }

    function applicationPeriod() external view returns (uint);
    function commitPeriod() external view returns (uint);
    function challengePeriod() external view returns (uint);
    function minimumBalance() external view returns (uint);
    function treasury() external view returns (address);
    function voting() external view returns (address);
    function token() external view returns (address);
    function validators() external view returns (bytes32[] memory);
    function getListing(bytes32) external view returns (Status, uint, bytes32, address, address, uint);

    function registerListing(address, bytes32) external;
    function challenge(address, bytes32) external;
    function resolveChallenge(bytes32) external;
    function confirmListing(address, bytes32) external;
    function removeListing(address, bytes32) external;
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/access_control/AuthorizedAddresses.sol

contract AuthorizedAddresses is Ownable {

    mapping(address => bool) authorizedAddresses;

    constructor() Ownable() public {
        authorizedAddresses[owner()] = true;
    }

    function authorizeAddress(address a) public {
        require(authorizedAddresses[msg.sender]);
        authorizedAddresses[a] = true;
    }

    function unauthorizeAddress(address a) public {
        require(authorizedAddresses[msg.sender]);
        authorizedAddresses[a] = false;
    }

    function isAddressAuthorized(address a) public view returns (bool) {
        return authorizedAddresses[a];
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/base/Authorizable.sol

contract Authorizable {

    AuthorizedAddresses authorizedAddress;

    constructor(address authorizedAddressesAddress) public {
        authorizedAddress = AuthorizedAddresses(authorizedAddressesAddress);
    }

    modifier isAuthorized() {
        require(authorizedAddress.isAddressAuthorized(msg.sender));
        _;
    }
}

// File: contracts/external/ValidatorRegistryProxy.sol

contract ValidatorRegistryProxy is Authorizable {

    IValidatorRegistry registry;

    constructor(address _registry, address auth) Authorizable(auth) public {
        registry = IValidatorRegistry(_registry);
    }

    function setImplementation(address implementation) isAuthorized public {
        registry = IValidatorRegistry(implementation);
    }


    function applicationPeriod() public view returns (uint) {
        return registry.applicationPeriod();
    }

    function commitPeriod() public view returns (uint) {
        return registry.commitPeriod();
    }

    function challengePeriod() public view returns (uint) {
        return registry.challengePeriod();
    }

    function minimumBalance() public view returns (uint) {
        return registry.minimumBalance();
    }

    function treasury() external view returns (address) {
        return registry.treasury();
    }

    function voting() external view returns (address) {
        return registry.voting();
    }

    function token() external view returns (address) {
        return registry.token();
    }

    function validators() external view returns (bytes32[] memory) {
        return registry.validators();
    }

    function getListing(bytes32 _pubKey) external view returns
        (IValidatorRegistry.Status status, uint applicationBlock, bytes32 tendermintPublicKey, address owner, address challenger, uint challengeEnd)
    {
        return registry.getListing(_pubKey);
    }

    function registerListing(bytes32 _pubKey) external {
        registry.registerListing(msg.sender, _pubKey);
    }

    function challenge(bytes32 _pubKey) external {
        registry.challenge(msg.sender, _pubKey);
    }

    function resolveChallenge(bytes32 pubKey) public {
        registry.resolveChallenge(pubKey);
    }

    function confirmListing(bytes32 _pubKey) external {
        registry.confirmListing(msg.sender, _pubKey);
    }

    function removeListing(bytes32 _pubKey) external {
        registry.removeListing(msg.sender, _pubKey);
    }
}
