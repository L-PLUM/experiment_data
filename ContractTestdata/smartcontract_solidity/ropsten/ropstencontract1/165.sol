/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.5.4;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded
 to a wallet
 * as they arrive.
 */
interface token { function transfer(address receiver, uint amount) external ; }

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Crowdsale is Ownable {
  using SafeMath for uint256;


  // address where funds are collected
  address payable public wallet;
  // token address
  address public addressOfToken;
  uint256 public price = 1000;

  // the bonus percents are required to be only as whole numbers
  // decimal bonus percents are not needed.

  uint256 public _0to10EthLimit = 10 ether;
  uint256 public _0to10EthBonusPercent = 50;

  uint256 public _10to20EthLimit = 20 ether;
  uint256 public _10to20EthBonusPercent = 100;

  uint256 public _20PlusEthBonusPercent = 200;

  uint256 public maxPurchase = 1000 ether;
  uint256 public minPurchase = 10 finney;

  token tokenInstance;

  // amount of raised money in wei
  //uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  constructor () public {

    wallet = 0x3474eFc54afb1fb8c8877B0F2495cb2eca8c0fcd;
    addressOfToken =  0xee5a43702e26d572c96C29678cAa24AB5b093A40;
    tokenInstance = token(addressOfToken);
  }

  bool public started = true;

  function startSale() external onlyOwner {
    started = true;
  }

  function stopSale() external onlyOwner {
    started = false;
  }

  function setPrice(uint256 _price) external onlyOwner {
    price = _price;
  }

  function changeWallet(address payable _wallet) external onlyOwner {
  	wallet = _wallet;
  }

  function changeMaxPurchase(uint _newMax) external onlyOwner {
    maxPurchase = _newMax;
  }

  function changeMinPurchase(uint _newMin) external onlyOwner {
    minPurchase = _newMin;
  }

  function set0to10EthBonusPercent(uint _bonusPercent) external onlyOwner {
    require(_bonusPercent > _0to10EthBonusPercent);
    _0to10EthBonusPercent = _bonusPercent;
  }

  function set10to20EthBonusPercent(uint _bonusPercent) external onlyOwner {
    require(_bonusPercent > _10to20EthBonusPercent);
    _10to20EthBonusPercent = _bonusPercent;
  }

  function set20plusEthBonusPercent(uint _bonusPercent) external onlyOwner {
    require(_bonusPercent > _20PlusEthBonusPercent);
    _20PlusEthBonusPercent = _bonusPercent;
  }

  // fallback function can be used to buy tokens
  function () payable external {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable public {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // require min or max investment
    require(weiAmount >= minPurchase && weiAmount <= maxPurchase);

    // calculate token amount to be sent
    uint256 tokens = weiAmount.mul(price);

    if (weiAmount < _0to10EthLimit) {
      tokens = tokens.add(tokens.mul(_0to10EthBonusPercent).div(100));
    } else if (weiAmount < _10to20EthLimit) {
      tokens = tokens.add(tokens.mul(_10to20EthBonusPercent).div(100));
    } else {
      tokens = tokens.add(tokens.mul(_20PlusEthBonusPercent).div(100));
    }

    tokenInstance.transfer(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    //forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function withdrawOnDemand(uint256 _amount) external onlyOwner {
     wallet.transfer(_amount);
  }

  function updateTokenInstance(address _newToken) external onlyOwner {
    addressOfToken =  _newToken;
    tokenInstance = token(addressOfToken);
  }

  function withdrawOnDemandAll() external onlyOwner {
     wallet.transfer(address(this).balance);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens(uint256 _amount) public {
    require (msg.sender == wallet);
    tokenInstance.transfer(wallet,_amount);
  }
}
