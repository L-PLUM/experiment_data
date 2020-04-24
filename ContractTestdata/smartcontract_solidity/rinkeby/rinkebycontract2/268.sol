/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

pragma solidity ^0.5.0;

/**
 * @title ERC Token Standard #20 Interface
 * @dev https://eips.ethereum.org/EIPS/eip-20
 */
interface ERC20Interface {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath Library
 * @dev Based on OpenZeppelin/SafeMath Library
 * @dev Used to avoid Solidity Overflow Errors
 * @dev Only add and sub functions used in this contract - others removed
 */
library SafeMath {
  // Returns the addition of two unsigned integers & reverts on overflow
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  // Returns the subtraction of two unsigned integers & reverts on overflow
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }

}

/**
 * @title TwitterNodeDapp Token Contract
 * @dev The Token used in this contract is an ERC20 Token
 */
contract TwitterNodeDapp is ERC20Interface {
  // Initial Token Set-up - Change values as required
  string public symbol = "TND";
  string public name = "Twitter Node DApp Token";
  uint8 public decimals = 0;

  using SafeMath for uint256;

  uint256 private initialSupply = 10000;  // Initial token supply
  uint256 private initialTweetValue = 10;  // Initial number of tokens sent per tweet

  uint256 private _totalSupply;
  uint256 private _tweetValue;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) private _admins;

  event TweetValueSet(uint256 tweetValue);
  event AdminAdded(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor() public {
    _admins[msg.sender] = true;
    emit AdminAdded(msg.sender);
    mint(msg.sender, initialSupply);
    setTweetValue(initialTweetValue);
  }

  /**
   * @dev This contract does not accept ETH
   */
  function() external payable {
    revert("Fallback method not allowed");
  }

  /**
   * @dev Standard ERC20 functions
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return _balances[who];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0), "Invalid Transfer to address zero");
    require(value <= _balances[msg.sender], "Sender does not have enough tokens");

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0), "Invalid Approval for address zero");
    _allowances[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _allowances[from][msg.sender], "Insufficient Allowance available");
    require(value <= _balances[from], "From Address does not have enough tokens");

    // Process Transfer
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);

    //Process Allowance reduction
    _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
    emit Approval(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Admin Functions and onlyAdmin Modifier
   */

  // Modifier used to check if the caller has an Admin Assignment
  modifier onlyAdmin() {
    require(isAdmin(msg.sender), "Admin Assignment Required: Caller is not an Admin");
    _;
  }

  // Check if an Account has an Admin Assignment
  function isAdmin(address account) public view returns (bool) {
    return _admins[account];
  }

  // Create Admin Assignment
  function addAdmin(address account) public onlyAdmin returns (bool) {
    require(!isAdmin(account), "Account already assigned as Admin");
    _admins[account] = true;
    emit AdminAdded(account);
    return true;
  }

  // Remove Admin Assignment
  function removeAdmin(address account) public onlyAdmin returns (bool) {
    require(isAdmin(account), "Account does not have Admin Assignment");
    _admins[account] = false;
    emit AdminRemoved(account);
    return true;
  }

  /**
   * @dev Additional standard functions
   */

  // Creation of new tokens
  // NOTE: Can only be called by the current _admins
  function mint(address account, uint256 amount) public onlyAdmin returns (bool) {
    require(account != address(0), "Invalid Mint to address zero");
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
    return true;
  }

  // Burning of existing tokens
  // NOTE: Can only be called by the current _admins
  function burn(address account, uint256 amount) public onlyAdmin returns (bool) {
    require(account != address(0), "Invalid Burn from address zero");
    require(amount <= _balances[account], "Burn Address does not have enough tokens");
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
    return true;
  }

  /**
   * @dev Additional Contract-specific functions
   */

  // Returns the current set amount of tokens issued per tweet
  function tweetValue() public view returns (uint256) {
    return _tweetValue;
  }

  // Sets the amount of tokens issued per tweet
  // NOTE: Can only be called by the current _admins
  function setTweetValue(uint256 newValue) public onlyAdmin returns (bool) {
    _tweetValue = newValue;
    emit TweetValueSet(_tweetValue);
    return true;
  }

  // Moves `_tweetValue` quantity of tokens from the callers account to recipients
  // NOTE: Can only be called by the current _admins

  function tweetToken(address recipient) public onlyAdmin returns (bool) {
    require (balanceOf(msg.sender) > 0, "Need to mint more tokens");
    transfer(recipient, _tweetValue);
    return true;
  }
  
  /**
   * @dev SafeMath Library Test Functions - Un-comment section for testing purposes.
   * @dev These functions are ONLY required to expose the SafeMath internal Library 
   * @dev functions for testing. These can be removed after testing if required
   */
  // function testAdd(uint256 a, uint256 b) public pure returns (uint256) {
  //   return SafeMath.add(a, b);
  // }

  // function testSub(uint256 a, uint256 b) public pure returns (uint256) {
  //   return SafeMath.sub(a, b);
  // }

}
