/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.25;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 addrbalance) {
    return balances[_owner];
  }

}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value, string reason);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   * @param _reason The reason why tokens are burned.
   */
  function burn(uint256 _value, string _reason) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value, _reason);
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract DACXTokenT3 is StandardToken, BurnableToken, Ownable {
    using SafeMath for uint;

    string constant public symbol = "DACXT3";
    string constant public name = "DACX Token Test3";

    uint8 constant public decimals = 18;
    uint256 INITIAL_SUPPLY = 786786786e18;

    // First date regular transfers are allowed
    uint constant firstTransferTime = 1551441600; // Friday, March 1, 2019 12:00:00 AM UTC
    
    // First date locked team token transfers are allowed
    uint constant unlockTime = 1583064000; // Sunday, March 1, 2020 12:00:00 AM UTC

    // Below listed are the Master Wallets to be used, for complete transparency purposes
    
    // Company Wallet: Will be used to collect fees, all Company Side Burning will commence using this wallet
    address company = 0x536f64882873443573a7F4638f08A8bc3F9202fe;
    // Angel Wallet: Initial distribution to Angel Investors will be made through this wallet 
    address angel = 0xD086AD2279B81f84CB56801891C231058a650e71;
    // Team Wallet: Initial distribution to Team Members will be made through this wallet 
    address team = 0x13dD90A3C51f85b87A77858765C281746157adAE;
    // Locked Wallet: All remaining team funds will be locked for at least 1 year
    // After first year, a fraction of locked funds will be distributed to Team Members each year
    address locked = 0x433e08EDf0DD86975A8a7a7a155a4eA58C8426Cc;

    // Crowdsale Wallet: All token sales (Private/Pre/Public) will be made through this wallet
    address crowdsale = 0x56390F548cc97FDf187AA2C0bD14c87364C58faD;
    // Bounty Wallet: Holds the tokens reserved for our initial and future bounty campaigns
    address bounty = 0xF4Ab971ff1ba5CB68006181560f93a586e37Db5c;


    uint constant lockedTokens     = 1966966964e17; // 196,696,696.40
    uint constant angelTokens      =  393393393e17; //  39,339,339.30
    uint constant teamTokens       = 1180180180e17; // 118,018,018.00
    uint constant crowdsaleTokens  = 3933933930e17; // 393,393,393.00 
    uint constant bountyTokens     =  393393393e17; //  39,339,339.30


    constructor () public {

        totalSupply_ = INITIAL_SUPPLY;

        // InitialDistribution
        preSale(locked, lockedTokens);
        preSale(angel, angelTokens);
        preSale(team, teamTokens);
        preSale(crowdsale, crowdsaleTokens);
        preSale(bounty, bountyTokens);

    }

    function preSale(address _address, uint _amount) internal {
        balances[_address] = _amount;
        emit Transfer(address(0x0), _address, _amount);
    }

    function checkPermissions(address _from) internal constant returns (bool) {

        if (_from == locked && now < unlockTime) {
            return false;
        }

        if (_from == bounty || _from == crowdsale || _from == angel || _from == team) {
            return true;
        }

        if (now < firstTransferTime) {
            return false;
        } else {
            return true;
        }

    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(msg.sender));
        bool ret = super.transfer(_to, _value);
        return ret;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(_from));
        bool ret = super.transferFrom(_from, _to, _value);
        return ret;
    }

    function () public payable {
        require(msg.value >= 1e16);
        owner.transfer(msg.value);
    }

}
