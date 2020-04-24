/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/interfaces/IModuleContract.sol

/**
 * @title Interface that any module contract should implement
 */

interface IModuleContract {
    /**
    * @notice Name of the module
    */
    function getName() external view returns(bytes32);

    /**
    * @notice Type of the module
    */
    function getType() external view returns(uint8);
}

// File: contracts/interfaces/ITransferValidator.sol

/**
 * @title Interface to be implemented by all Transfer Validators
 */

interface ITransferValidator {
    /*----------- Methods -----------*/
    function validateTransfer(address _token, address _from, address _to, uint256 _amount) external returns(bool);
}

// File: contracts/inheritables/TransferValidator.sol

/**
 * @title Base for Transfer Validators, sets moduleType and inherits Interface
 */

contract TransferValidator is ITransferValidator {
    uint8 constant moduleType = 1;
}

// File: contracts/modules/SenderWhitelistValidator.sol

/**
 * @title Transfer Validator that checks if receiver/taker is on whitelist
 */

contract SenderWhitelistValidator is TransferValidator, IModuleContract, Pausable { 

    /*----------- Constants -----------*/
    bytes32 public constant moduleName = "SenderWhitelistValidator";

    /*----------- Globals -----------*/
    mapping(address => bool) public whitelist;

    /*----------- Events -----------*/
    event LogAddAddress(address sender, address nowOkay);
    event LogRemoveAddress(address sender, address deleted);

    /*----------- Validator Methods -----------*/
    /**
    * @dev Validate whether an address is added to the whitelist
    * @param _token address Unused for this validation
    * @param _to address The address which you want to transfer to
    * @param _from address unused for this validation
    * @param _amount uint256 unused for this validation
    * @return bool
    */
    function validateTransfer(address _token, address _from, address _to, uint256 _amount)
        external
        returns(bool)
    {
        return isWhitelisted(_to);
    }

    /**
    * @dev Returns the name of the validator
    * @return bytes32
    */
    function getName()
        external
        view
        returns(bytes32)
    {
        return moduleName;
    }

    /**
    * @dev Returns the type of the validator
    * @return uint8
    */
    function getType()
        external
        view
        returns(uint8)
    {
        return moduleType;
    }

    /*----------- Owner Methods -----------*/
    /**
    * @dev Add address to whitelist
    * @param _okay address Unused for this validation
    * @return success bool
    */
    function addAddress(address _okay)
        external
        onlyOwner
        whenNotPaused
        returns (bool success)
    {
        require(_okay != address(0));
        require(!isWhitelisted(_okay));
        whitelist[_okay] = true;
        emit LogAddAddress(msg.sender, _okay);
        return true;
    }

    /**
    * @dev Remove address from whitelist
    * @param _delete address Unused for this validation
    * @return success bool
    */
    function removeAddress(address _delete)
        external
        onlyOwner
        whenNotPaused
        returns(bool success)
    {
        require(isWhitelisted(_delete));
        whitelist[_delete] = false;
        emit LogRemoveAddress(msg.sender, _delete);
        return true;
    }

    /*----------- View Methods -----------*/
    function isWhitelisted(address _check)
        public
        view
        returns(bool isIndeed)
    {
        return whitelist[_check];
    }
}
