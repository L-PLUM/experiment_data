/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.5.0;

// File: contracts/UsingOracleI.sol

interface UsingOracleI {
    function __callback(bytes32 _id, string calldata _value, uint _errorCode) external;
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

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: contracts/auth/Authorizable.sol

contract Authorizable is Ownable {

    using Roles for Roles.Role;
    Roles.Role private _authorized;


    function grantAccessToAddress(address _authorizedAddress) public onlyOwner {
        _authorized.add(_authorizedAddress);
    }

    function revokeAccessFromAddress(address _addressToRevoke) public onlyOwner {
        _authorized.remove(_addressToRevoke);
    }

    function isAuthorized(address _checkingAddress) public view returns(bool) {
        return _authorized.has(_checkingAddress);
    }

    modifier onlyAuthorized() {
        require(_authorized.has(msg.sender));
        _;
    }
}

// File: contracts/Oracle.sol

contract Oracle is Authorizable {

    struct Request {
        address requestAddress;
        uint validFrom;
    }

    address public trustedServer;

    /**
     * @dev A unix timestamp (epoch seconds) differentiating delayed requests.
     *      Delay values greater than LIMIT_DATE are considered timestamps.
     *      Delay values smaller or equal than LIMIT_DATE are considered delays given in seconds.
     *      No delay can be bigger than 2 years.
     *      LIMIT_DATE value is 2018/01/01 00:00:00 GMT.
     */
    uint constant LIMIT_DATE = 1514764800;
    uint constant YEAR = 365 days;

    mapping(bytes32 => Request) pendingRequests;

    event DataRequested(bytes32 indexed id, string url);
    event DelayedDataRequested(bytes32 indexed id, string url, uint validFrom);
    event RequestFulfilled(bytes32 indexed id, string value, uint errorCode);

    constructor(address _trustedServer) public {
        trustedServer = _trustedServer;
    }

    function request(string memory _url) public onlyAuthorized() returns(bytes32 id) {
        id = keccak256(abi.encodePacked(_url, msg.sender, now));
        pendingRequests[id].requestAddress = msg.sender;
        pendingRequests[id].validFrom = now;
        emit DataRequested(id, _url);
    }

    function delayedRequest(string memory _url, uint _delay) public returns(bytes32 id) {
        if (_delay > LIMIT_DATE) {
            require(_delay - now <= 2 * YEAR, "Invalid request timestamp delay");
            id = keccak256(abi.encodePacked(_url, msg.sender, _delay));
            pendingRequests[id].requestAddress = msg.sender;
            pendingRequests[id].validFrom = _delay;
            emit DelayedDataRequested(id, _url, pendingRequests[id].validFrom);
        } else {
            require(_delay <= 2 * YEAR, "Invalid request delay");
            id = keccak256(abi.encodePacked(_url, msg.sender, now, _delay));
            pendingRequests[id].requestAddress = msg.sender;
            pendingRequests[id].validFrom = now + _delay;
            emit DelayedDataRequested(id, _url, pendingRequests[id].validFrom);
        }
    }

    function fillRequest(bytes32 _id, string calldata _value, uint _errorCode) external
    onlyFromTrustedServer onlyIfValidRequestId(_id) onlyIfValidTimestamp(_id) {
        address callbackContract = pendingRequests[_id].requestAddress;
        delete pendingRequests[_id];

        UsingOracleI(callbackContract).__callback(_id, _value, _errorCode);

        emit RequestFulfilled(_id, _value, _errorCode);
    }

    modifier onlyFromTrustedServer() {
        require(msg.sender == trustedServer, "Sender address doesn't equal trusted server");
        _;
    }

    modifier onlyIfValidRequestId(bytes32 _id) {
        require(pendingRequests[_id].requestAddress != address(0), "Invalid request id");
        _;
    }

    modifier onlyIfValidTimestamp(bytes32 _id) {
        require(pendingRequests[_id].validFrom <= now, "Invalid request delay as timestamp");
        _;
    }
}
