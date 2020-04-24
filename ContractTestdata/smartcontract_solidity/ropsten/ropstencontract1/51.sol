/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.0;

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/poster/IPosterRegistry.sol

interface IPosterRegistry {

    function tokensContributed() external view returns (uint);
    function token() external view returns (address);
    function treasury() external view returns (address);
    function tokensRegisteredFor(address) external view returns (uint);

    function registerTokens(address, uint) external;
    function releaseTokens(address, uint) external;
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

// File: contracts/external/PosterRegistryProxy.sol

contract PosterRegistryProxy is Authorizable {

    IPosterRegistry registry;

    constructor(address implementation, address auth) Authorizable(auth) public {
        registry = IPosterRegistry(implementation);
    }

    function setImplementation(address implementation) isAuthorized public {
        registry = IPosterRegistry(implementation);
    }

    function tokensContributed() public view returns (uint) {
        return registry.tokensContributed();
    }

    function token() public view returns (address) {
        return registry.token();
    }

    function treasury() public view returns (address) {
        return registry.treasury();
    }

    function tokensRegisteredFor(address a) public view returns (uint) {
        return registry.tokensRegisteredFor(a);
    }

    function registerTokens(uint amount) external {
        registry.registerTokens(msg.sender, amount);
    }

    function releaseTokens(uint amount) external {
        registry.releaseTokens(msg.sender, amount);
    }
}
