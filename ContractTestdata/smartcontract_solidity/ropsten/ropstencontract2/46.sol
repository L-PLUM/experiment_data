/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

/* file: openzeppelin-solidity/contracts/ownership/Ownable.sol */
pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

/* eof (openzeppelin-solidity/contracts/ownership/Ownable.sol) */
/* file: openzeppelin-solidity/contracts/math/SafeMath.sol */
pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/* eof (openzeppelin-solidity/contracts/math/SafeMath.sol) */
/* file: ./contracts/whitelist/Whitelist.sol */
/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;



contract Whitelist is Ownable {
    using SafeMath for uint256;

    address public multisigProxy;

    mapping(address => bool) public isWhitelisted;

    // allow managers add/update whitelist registrants
    // managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;

    // enable whitelist restrictions by default
    bool public isWhitelisting = true;

    /** EVENTS **/
    event ChangedManager(address indexed manager, bool active);
    event ChangedWhitelisting(address indexed registrant, bool whitelisted);
    event WhitelistDisabled();

    /** MODIFIERS **/
    modifier onlyManager() {
        require(isManager[msg.sender], "is not manager");
        _;
    }

    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    modifier onlyMultisig() {
        require(msg.sender == multisigProxy);
        _;
    }

    /**
    * @dev constructor 
    */
    constructor(address _multisigProxy) public onlyValidAddress(_multisigProxy) {
        multisigProxy = _multisigProxy;
        setManager(msg.sender, true);
    }

    /**
     * @dev Set / alter manager / whitelister "account". This can be done from owner only
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }

    /**
    * @dev getter to determine if address is in whitelist
    * @param _address address to check against whitelist mapping
    * @return bool is whitelisted
    */
    function whitelist(address _address) public view returns (bool) {
        return isWhitelisted[_address];
    }

    /**
    * @dev add an address to the whitelist
    * @param _address address
    */
    function addAddressToWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    /**
    * @dev add addresses to the whitelist
    * @param _addresses addresses array
    */
    function addAddressesToWhitelist(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param _address address
    */
    function removeAddressFromWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }

    /**
    * @dev remove addresses from the whitelist
    * @param _addresses addresses
    */
    function removeAddressesFromWhitelist(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** 
    * @dev disable the whitelist, once done cannot be reversed
    */
    function disableWhitelist() public onlyMultisig {
        isWhitelisting = false;
        emit WhitelistDisabled();
    }
}

/* eof (./contracts/whitelist/Whitelist.sol) */
