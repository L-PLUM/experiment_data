/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity 0.5.0;

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

// File: contracts/KBDChestSale.sol

// https://github.com/ethereum/EIPs/issues/20

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Detailed {
  function name() external view returns (string memory _name);
  
  function symbol() external view returns (string memory _symbol);
  
  function decimals() external view returns (uint8 _decimals);
}

/// @title Kyber Network interface
interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns (uint);
    
    function getUserCapInWei(address user) external view returns(uint);
    
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    
    function enabled() external view returns(bool);
    
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);
}

library AddressUtils {
  function toPayable(address _address) internal pure returns (address payable _payable) {
    return address(uint160(_address));
  }

  function isContract(address _address) internal view returns (bool _correct) {
    uint256 _size;
    // solium-disable-next-line security/no-inline-assembly
    assembly { _size := extcodesize(_address) }
    return _size > 0;
  }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    require(c >= a);
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b <= a);
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    require(c / a == b);
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Since Solidity automatically asserts when dividing by 0,
    // but we only need it to revert.
    require(b > 0);
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Same reason as `div`.
    require(b > 0);
    return a % b;
  }

  function ceilingDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return add(div(a, b), mod(a, b) > 0 ? 1 : 0);
  }

  function subU64(uint64 a, uint64 b) internal pure returns (uint64 c) {
    require(b <= a);
    return a - b;
  }

  function addU8(uint8 a, uint8 b) internal pure returns (uint8 c) {
    c = a + b;
    require(c >= a);
  }
}

/**
 * @dev KingdomsBeyond Founder Sale Smart contract
 * Facilitates the distribution of chests purchased 
 * Chests can be purchased with ETH natively or 
 * alternatively purchased with ERC20 Tokens via KyberSwap
 * or Fiat via NiftyGateway.
 */
contract KBDChestSale is
  Ownable
{
  using SafeMath for uint256;
  using AddressUtils for address;
  
  /**
   * @dev Event is broadcast whenever a chest is purchased. 
   */ 
  event ChestPurchased(
    uint16 _chestType,
    uint16 _chestAmount,
    address indexed _buyer,
    address indexed _referrer
  );

  event Swap(address indexed sender, ERC20 srcToken, ERC20 destToken);
  
  // Updated every day 
  uint256 ethPrice;
  
  mapping (uint256 => uint256) chestTypePricing;
  
  /** Kyber Swap Util
   */
  address public ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address internal walletId = 0xB391AE8Fc7483770930d1dEAb5a898206E9cDb3F;

  uint constant internal MAX_QTY = (10**28); // 10B tokens

  // Rinkeby Interface
  KyberNetworkProxyInterface public kyberNetworkProxyContract = KyberNetworkProxyInterface(0xF77eC7Ed5f5B9a5aee4cfa6FFCaC6A4C315BaC76);
  
  constructor() public {
    chestTypePricing[0] = 5; 
    chestTypePricing[1] = 20;
    chestTypePricing[2] = 80;
    ethPrice = 217;
  }
  
  // Sets the price of 1 Eth in volatile situations
  function setPriceOfEth(uint256 _price) external onlyOwner {
      ethPrice = _price;
  }
  
  function getPriceOfEth() external view returns (uint256) {
      return ethPrice;
  }
  
  function setChestTypePricing(uint256 _chestType, uint256 _chestPrice) external onlyOwner {
      chestTypePricing[_chestType] = _chestPrice;
  }
  
  function purchaseFor(address payable _user, uint16 _chestType, uint16 _chestAmount, address payable _referrer) external payable {
        _purchaseChest(_user, _referrer, _chestType, _chestAmount, msg.value);
  } 
  
  function purchaseChest(uint16 _chestType, uint16 _chestAmount, address payable _referrer) external payable {
        _purchaseChest(msg.sender, _referrer, _chestType, _chestAmount, msg.value);
  } 
  
  // The cost of the chest in Wei
  function _getChestPrice(uint256 _chestType) public view returns (uint256) {
      uint256 chestPrice = chestTypePricing[_chestType];
      require(chestPrice != 0, "Invalid chest");
      
      return (chestPrice).mul(1000000000000000000).div(ethPrice);
  }
  
  // The cost of one premium chest in Ether is pegged to 
  function getChestPrice(uint8 _chestType, uint8 _chestAmount) public view returns (uint256) {
      require(_chestAmount < 256, "Invalid Amount");
      
      return _getChestPrice(_chestType) * _chestAmount;
  }
  
  function _getTokenDecimals(address _token) internal view returns (uint8 _decimals) {
    return _token != ethAddress ? IERC20Detailed(_token).decimals() : 18;
  }

  function _fixTokenDecimals(
    address _src,
    address _dest,
    uint256 _unfixedDestAmount,
    bool _ceiling
  )
    internal
    view
    returns (uint256 _destTokenAmount)
  {
    uint256 _unfixedDecimals = _getTokenDecimals(_src) + 18; // Kyber by default returns rates with 18 decimals.
    uint256 _decimals = _getTokenDecimals(_dest);

    if (_unfixedDecimals > _decimals) {
      // Divide token amount by 10^(_unfixedDecimals - _decimals) to reduce decimals.
      if (_ceiling) {
        return _unfixedDestAmount.ceilingDiv(10 ** (_unfixedDecimals - _decimals));
      } else {
        return _unfixedDestAmount.div(10 ** (_unfixedDecimals - _decimals));
      }
    } else {
      // Multiply token amount with 10^(_decimals - _unfixedDecimals) to increase decimals.
      return _unfixedDestAmount.mul(10 ** (_decimals - _unfixedDecimals));
    }
  }
  
  function getPrice(
    uint256 _chestType,
    uint256 _chestAmount,
    address _tokenAddress
  )
    external
    view
    returns (
      uint256 _tokenAmount,
      uint256 _minConversionRate
    )
  {
    uint256 _totalPrice = getChestPrice(uint8(_chestType), uint8(_chestAmount));

    if (_tokenAddress != ethAddress) {
      uint256 _expectedRate;
      (_expectedRate, ) = kyberNetworkProxyContract.getExpectedRate(ERC20(ethAddress), ERC20(_tokenAddress), _totalPrice);
      _tokenAmount = _fixTokenDecimals(ethAddress, _tokenAddress, _totalPrice.mul(_expectedRate), false);
      (, _minConversionRate) = kyberNetworkProxyContract.getExpectedRate(ERC20(_tokenAddress), ERC20(ethAddress), _tokenAmount);
      _tokenAmount = _totalPrice.mul(10**36).ceilingDiv(_minConversionRate);
      _tokenAmount = _fixTokenDecimals(ethAddress, _tokenAddress, _tokenAmount, true);
    } else {
      _tokenAmount = _totalPrice;
    }
  }
  
  function getApproveData(
      address payable _referrer, 
      uint256 _chestType,
      uint256 _chestAmount,
      uint256 _minConversionRate
  ) public pure returns (bytes memory) {
      return abi.encode(_referrer, _chestType, _chestAmount, _minConversionRate);
  }
  
  /** Called from ERC20 smart contracts after approving a certain amount of tokens to use
   */
  function receiveApproval(
    address _from,
    uint256 _value,
    address _tokenAddress,
    bytes calldata _data
  )
    external
  {
    require(msg.sender == _tokenAddress);

    address payable _referrer;
    uint256 _chestType;
    uint256 _chestAmount;
    uint256 _minConversionRate;

    (_referrer, _chestType, _chestAmount, _minConversionRate) = abi.decode(_data, (address, uint256, uint256, uint256));

    bytes memory hint;
    uint256 _ethAmount = kyberNetworkProxyContract.tradeWithHint(
        ERC20(_tokenAddress),
        _value,
        ERC20(ethAddress),
        _from,
        MAX_QTY,
        _minConversionRate,
        walletId,
        hint
    );
    
    _purchaseChest(
        _from.toPayable(),
        _referrer,
        _chestType,
        _chestAmount,
        _ethAmount
    );
  }
  
  function _getReferralPercentage(address _referrer, address _owner) internal pure returns (uint256 _percentage) {
    return _referrer != _owner && _referrer != address(0) ? 1000 : 0;
  }
  
  function _purchaseChest(
      address payable _buyer, 
      address payable _referrer, 
      uint256 _chestType,
      uint256 _chestAmount,
      uint256 _ethAmount
  ) internal {
    uint256 _totalPrice = getChestPrice(uint8(_chestType), uint8(_chestAmount));

    // Check if we received enough payment.
    require(_ethAmount >= _totalPrice, "Not enough ether");

    // Send back the ETH change, if there is any.
    if (_ethAmount > _totalPrice) {
      _buyer.transfer(_ethAmount - _totalPrice);
    }

    emit ChestPurchased(uint16(_chestType), uint16(_chestAmount), _buyer, _referrer);

    uint256 _referralReward = _totalPrice
      .mul(_getReferralPercentage(_referrer, _buyer))
      .div(10000);

    /// @dev If the referral reward cannot be sent because of a referrer's fault, set it to 0.
    if (_referralReward > 0 && !_referrer.send(_referralReward)) {
      _referralReward = 0;
    }
  }
  
  /// @dev Withdraw function to withdraw the earnings 
  function withdrawBalance()
  external onlyOwner {
    msg.sender.transfer(address(this).balance);
  }
}
