/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.4.13;

// File: contracts/library/Ownable.sol

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);

    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

// File: contracts/library/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require (paused) ;
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

// File: contracts/library/SafeMath.sol

/* taking ideas from FirstBlood token */
contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

// File: contracts/library/ERC20.sol

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);
  function allowance(address owner, address spender) constant public returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

// File: contracts/library/StandardToken.sol

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }


  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) public returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant public returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

// File: contracts/IndorseToken.sol

contract IndorseToken is SafeMath, StandardToken, Pausable {
    // metadata
    string public constant name = "Indorse Token";
    string public constant symbol = "IND";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public indSaleDeposit        = 0x65b3fC64f7D2957d480D1e6a7ABBbA0DbF5b4Ce0;      // deposit address for Indorse Sale contract
    address public indSeedDeposit        = 0x46B8086916fec41eE2E46AAD91036e08eFc76c48;      // deposit address for Indorse Seed Contributors
    address public indPresaleDeposit     = 0x007AB99FBf023Cb41b50AE7D24621729295EdBFA;      // deposit address for Indorse Presale Contributors
    address public indVestingDeposit     = 0x0011349f715cf59F75F0A00185e7B1c36f55C3ab;      // deposit address for Indorse Vesting for team and advisors
    address public indCommunityDeposit   = 0x0097ec8840E682d058b24E6e19E68358d97A6E5C;      // deposit address for Indorse Marketing, etc
    address public indFutureDeposit      = 0x00d1bCbCDE9Ca431f6dd92077dFaE98f94e446e4;      // deposit address for Indorse Future token sale
    address public indInflationDeposit   = 0x00D31206E625F1f30039d1Fa472303E71317870A;      // deposit address for Indorse Inflation pool

    uint256 public constant indSale      = 31603785 * 10**decimals;
    uint256 public constant indSeed      = 3566341  * 10**decimals;
    uint256 public constant indPreSale   = 22995270 * 10**decimals;
    uint256 public constant indVesting   = 28079514 * 10**decimals;
    uint256 public constant indCommunity = 10919811 * 10**decimals;
    uint256 public constant indFuture    = 58832579 * 10**decimals;
    uint256 public constant indInflation = 14624747 * 10**decimals;

    // constructor
    function IndorseToken()
    {
      balances[indSaleDeposit]           = indSale;                                         // Deposit IND share
      balances[indSeedDeposit]           = indSeed;                                         // Deposit IND share
      balances[indPresaleDeposit]        = indPreSale;                                      // Deposit IND future share
      balances[indVestingDeposit]        = indVesting;                                      // Deposit IND future share
      balances[indCommunityDeposit]      = indCommunity;                                    // Deposit IND future share
      balances[indFutureDeposit]         = indFuture;                                       // Deposit IND future share
      balances[indInflationDeposit]      = indInflation;                                    // Deposit for inflation

      totalSupply = indSale + indSeed + indPreSale + indVesting + indCommunity + indFuture + indInflation;

      Transfer(0x0,indSaleDeposit,indSale);
      Transfer(0x0,indSeedDeposit,indSeed);
      Transfer(0x0,indPresaleDeposit,indPreSale);
      Transfer(0x0,indVestingDeposit,indVesting);
      Transfer(0x0,indCommunityDeposit,indCommunity);
      Transfer(0x0,indFutureDeposit,indFuture);
      Transfer(0x0,indInflationDeposit,indInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}
