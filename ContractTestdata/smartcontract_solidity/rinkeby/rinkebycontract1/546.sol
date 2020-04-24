/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
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

// File: src/contracts/StorageFeeCollector.sol

/**
 * @title StorageFeeCollector
 *
 * @notice StorageFeeCollector is a contract managing the fees
 */
contract StorageFeeCollector is Ownable {
  using SafeMath for uint256;

  /**
   * Fee computation for storage are based on four parameters:
   * minimumFee (wei) fee that will be applied for any size of storage
   * threshold (byte) minimum size from where the variable fee will be applied
   * rateFeesNumerator (wei) and rateFeesDenominator (byte) define the variable fee,
   * for each <rateFeesDenominator> bytes above threshold, <rateFeesNumerator> wei will be charged
   *
   * Example:
   * If the size to store is 50 bytes, the threshold is 100 bytes and the minimum fee is 300 wei,
   * then 300 will be charged
   *
   * If rateFeesNumerator is 2 and rateFeesDenominator is 1 then 2 wei will be charged for every bytes above threshold,
   * if the size to store is 150 bytes then the fee will be 300 + (150-100)*2 = 400 wei
   */
  uint256 public minimumFee;
  uint256 public rateFeesNumerator;
  uint256 public rateFeesDenominator;
  uint256 public threshold;

  // address of the contract that will burn req token
  address payable public requestBurnerContract;

  event UpdatedFeeParameters(uint256 minimumFee, uint256 rateFeesNumerator, uint256 rateFeesDenominator);
  event UpdatedMinimumFeeThreshold(uint256 threshold);
  event UpdatedBurnerContract(address burnerAddress);

  /**
   * @param _requestBurnerContract Address of the contract where to send the ether.
   * This burner contract will have a function that can be called by anyone and will exchange ether to req via Kyber and burn the REQ
   */  
  constructor(address payable _requestBurnerContract) 
    public
  {
    requestBurnerContract = _requestBurnerContract;
  }

  /**
    * @notice Sets the fees rate and minimum fee.
    * @dev if the _rateFeesDenominator is 0, it will be treated as 1. (in other words, the computation of the fees will not use it)
    * @param _minimumFee minimum fixed fee
    * @param _rateFeesNumerator numerator rate
    * @param _rateFeesDenominator denominator rate
    */  
  function setFeeParameters(uint256 _minimumFee, uint256 _rateFeesNumerator, uint256 _rateFeesDenominator)
    external
    onlyOwner
  {
    minimumFee = _minimumFee;
    rateFeesNumerator = _rateFeesNumerator;
    rateFeesDenominator = _rateFeesDenominator;
    emit UpdatedFeeParameters(minimumFee, rateFeesNumerator, rateFeesDenominator);
  }


  /**
    * @notice Sets the threshold from where the variable fee (rateFeesNumerator/rateFeesDenominator) will be applied
    * @param _threshold threshold
    */  
  function setMinimumFeeThreshold(uint256 _threshold)
    external
    onlyOwner
  {
    threshold = _threshold;
    emit UpdatedMinimumFeeThreshold(threshold);
  }


  /**
    * @notice Set the request burner address.
    * @param _requestBurnerContract address of the contract that will burn req token (probably through Kyber)
    */  
  function setRequestBurnerContract(address payable _requestBurnerContract) 
    external
    onlyOwner
  {
    requestBurnerContract = _requestBurnerContract;
    emit UpdatedBurnerContract(requestBurnerContract);
  }

  /**
    * @notice Computes the fees.
    * @param _dataSize Size of the data which hash is stored on storage
    * @return the expected amount of fees in wei
    */  
  function getFeesAmount(uint256 _dataSize)
    public
    view
    returns(uint256)
  {

    if (_dataSize <= threshold) {
      return minimumFee;
    } else {
      // Variable fees are applied to remaining size
      uint256 remainingSize = _dataSize.sub(threshold);
      uint256 computedCollect = remainingSize.mul(rateFeesNumerator);

      if (rateFeesDenominator != 0) {
        computedCollect = computedCollect.div(rateFeesDenominator);
      }

      return computedCollect.add(minimumFee);
    }
  }

  /**
    * @notice Sends fees to the request burning address.
    * @param _amount amount to send to the burning address
    */  
  function collectForREQBurning(uint256 _amount)
    internal
  {
    // .transfer throws on failure
    requestBurnerContract.transfer(_amount);
  }
}

// File: src/contracts/RequestHashStorage.sol

/**
 * @title RequestHashStorage
 * @notice Contract that stores ipfs hashes with event logs
 */
contract RequestHashStorage is StorageFeeCollector {

  /**
   * @param _addressBurner Burner address address
   */
  constructor(address payable _addressBurner) 
    StorageFeeCollector(_addressBurner)
    public
  {
  }

  // Event for submitted hashes
  event NewHash(string hash, uint size);

  /**
   * @notice Submit a new hash to the blockchain.
   *
   * @param _hash Hash of the request to be stored
   * @param _size Size of the request to be stored
   */
  function submitHash(string calldata _hash, uint256 _size)
    external
    payable
  {
    // Check fees are paid
    require(getFeesAmount(_size) == msg.value);

    // Send fees to burner, throws on failure
    collectForREQBurning(msg.value);

    // Emit event for log
    emit NewHash(_hash, _size);
  }

  // Fallback function returns funds to the sender
  function() 
    external
    payable 
  { 
    revert();
  }
}
