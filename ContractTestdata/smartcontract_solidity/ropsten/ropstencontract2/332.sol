/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * mul 
     * @dev Safe math multiply function
     */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  /**
   * add
   * @dev Safe math addition function
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
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

}

/**
 * @title Ownable
 * @dev Ownable has an owner address to simplify "user permissions".
 */
contract Ownable {
  address payable owner;

  /**
   * Ownable
   * @dev Ownable constructor sets the `owner` of the contract to sender
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * ownerOnly
   * @dev Throws an error if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * transferOwnership
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
}

/**
 * @title LavevelICO
 * @dev LavevelICO contract is Ownable
 **/
contract AUDICO is Ownable {
  using SafeMath for uint256;
  Token token;

  uint256 public tokenRate = 10000; // Number of tokens per Ether
  uint256 private totalTokensSold = 0;    // total tokens sold in ICO
  uint256 public constant Hard_cap = 20000; // Cap in Ether
  uint256 public constant Soft_cap = 1000; // Cap in Ether
  uint256 public constant icoStart = 1519862400; // Mar 26, 2018 @ 12:00 EST
  uint256 public icoEnd = 1552754559;
  uint256 public constant initialTokens = 1600000000 * 10**18; // Initial number of tokens available
  uint256 public raisedAmount = 0;
  mapping (address => uint) public contributedAmountInEther;
  
  /**
   * BoughtTokens
   * @dev Log tokens bought onto the blockchain
   */
  event BoughtTokens(address indexed to, uint256 value);
  event LogTokenRateUpdated(uint new_rate);
  event LogIcoEndDateUpdated(uint _oldEndDate, uint _newEndDate);
  event LogBurnedUnsoldTokens(address indexed from, uint indexed amount);
  /**
   * whenSaleIsActive
   * @dev ensures that the contract is still active
   **/
  modifier isSaleActive() {
    // Check if sale is active
    require(now > icoStart);
    require(now<icoEnd);
    require(!goalReached());
    require(tokensAvailable()>0);
    _;
  }
  
  /**
   * LavevelICO
   * @dev LavevelICO constructor
   **/
  constructor(address _tokenAddr) public {
      require(address(_tokenAddr) != address(0));
      token = Token(_tokenAddr);
  }

  /**
   * goalReached
   * @dev Function to determin is goal has been reached
   **/
  function goalReached() public view returns (bool) {
    return (raisedAmount >= Hard_cap * 1 ether);
  }

  /**
   * @dev Fallback function if ether is sent to address insted of buyTokens function
   **/
  function () external payable {
    buyTokens();
  }

  /**
   * buyTokens
   * @dev function that sells available tokens
   **/
  function buyTokens() public payable isSaleActive{
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount.mul(tokenRate);
    uint256 bonus = calculateBonus();
    if(bonus>0){
      tokens = tokens + tokens.mul(bonus.div(100));
    }
    raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
    token.transfer(msg.sender, tokens); // Send tokens to buyer
    totalTokensSold.add(tokens);
    owner.transfer(msg.value);// Send money to owner
    contributedAmountInEther[msg.sender] = contributedAmountInEther[msg.sender].add(msg.value);
    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
  }

  /**
   * tokensAvailable
   * @dev returns the number of tokens allocated to this contract
   **/
  function tokensAvailable() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  function getTotalTokensSold() public view returns (uint _tokensSold){
        return totalTokensSold;
      }

  function calculateBonus() internal view returns(uint) {
        // this function will calculate no of tokens will be allocated to user as per current bonus scheme
       if(totalTokensSold < 400000000){
        return 30;
      } else if(totalTokensSold < 800000000){
        return 20;
      } else if(totalTokensSold < 1200000000){
        return 10;
      } else {
        return 0;
      }

}
  /**
   * destroy
   * @notice Terminate contract and refund to owner
   **/
  function destroy() onlyOwner public {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    // There should be no ether in the contract but just in case
    selfdestruct(owner);
  }

  function updateRate (uint256 new_rate) public onlyOwner returns (bool _res){
          tokenRate = new_rate;
          emit LogTokenRateUpdated(new_rate);
          return true;
    }

  function updateIcoEndDate(uint _newDate) public onlyOwner returns (bool _res){
          uint oldEndDate = icoEnd;
          icoEnd = _newDate;
          emit LogIcoEndDateUpdated (oldEndDate, _newDate);
          return true;
        }

   function gettokenRate() public view returns (uint256 _rate){
        return tokenRate;
      }
    function withdrawEther() public payable returns(bool res){
      return (raisedAmount < Soft_cap * 1 ether);
      require(now > icoEnd);
      require(contributedAmountInEther[msg.sender]> 0);
      uint256 contributedAmount = contributedAmountInEther[msg.sender];
      msg.sender.transfer(contributedAmount);
    }

    /**
   * isActive
   * @dev Determins if the contract is still active
   **/
  function isICOActive() public view returns (bool) {
    return (
        now >= icoStart && // Must be after the icoStart date
        now <= icoEnd && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }
}
