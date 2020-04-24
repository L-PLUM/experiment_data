/**
 *Submitted for verification at Etherscan.io on 2018-12-13
*/

pragma solidity ^0.4.20;

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);  
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

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
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
    using SafeERC20 for ERC20Basic;

    // ERC20 basic token contract being held
    ERC20Basic public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint64 public releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
        require(_releaseTime > uint64(block.timestamp));
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        require(uint64(block.timestamp) >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.safeTransfer(beneficiary, amount);
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
    Transfer(_from, _to, _value);
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
    Approval(msg.sender, _spender, _value);
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract LockerToken is PausableToken {
    string  public  constant name = "LockerToken";
    string  public  constant symbol = "LUT";
    uint256   public  constant decimals = 10;

    modifier validDestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

	uint256 public constant UNIT = 10 ** decimals;
	
	address public teamWallet;
	address public bonusWallet;
	address public admin;
	
	uint256 public tokenPrice = 0.00025 ether;
	uint256 public maxSupply = 50000000000 * UNIT;
	uint256 public totalSupply = 0;
	uint256 public totalWeiReceived = 0;
	
	uint256 startDate  = 1544371201; //	12:01 GMT February 1 2018
	uint256 endDate    = 1544457601; //	12:00 GMT March 15 2018
	
	uint256 bonus50end = 1544446800; //	12:01 GMT February 4 2018
	uint256 bonus40end = 1544448600; //	12:01 GMT February 7 2018
	uint256 bonus35end = 1544450400; //	12:01 GMT February 10 2018
	uint256 bonus30end = 1544452200; //	12:01 GMT February 13 2018
	uint256 bonus25end = 1544454000; //	12:01 GMT February 17 2018
	uint256 bonus20end = 1544455800; //	12:01 GMT February 20 2018
	
    /// team tokens are locked until this date (01.01.2021) 00:00:00
    uint64 private constant dateTeamTokensLockedTill = 1609459200;
    /// contract to be called to release the Dorado team tokens
    address public timelockContractAddress;
	
    /**
     * issue the tokens for the team and the foodout group.
     * tokens are locked for 3 years.
     * @param lockedTokens the amount of tokens to the issued and locked
     * */
    function issueLockedTokens(uint lockedTokens) internal{
        /// team tokens are locked until this date (01.01.2021)
        TokenTimelock lockedTeamTokens = new TokenTimelock(this, owner, dateTeamTokensLockedTill);
        timelockContractAddress = address(lockedTeamTokens);
        balances[timelockContractAddress] = balances[timelockContractAddress].add(lockedTokens);
        /// fire event when tokens issued
        Transfer(address(0), timelockContractAddress, lockedTokens);        
    }
	
	/**
	 * event for token purchase logging
	 * @param purchaser - who paid for the tokens
	 * @param beneficiary - who got the tokens
	 * @param value - weis paid for purchase
	 * @param amount - amount of tokens purchased
	 */
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	
	event NewSale();
	
	modifier onlyAdmin() {
		require(msg.sender == admin);
		_;
	}
	
	function LockerToken(address _teamWallet, address _bonusWallet, address _admin) public {
		teamWallet = _teamWallet;
		bonusWallet = _bonusWallet;
		admin = _admin;
		balances[teamWallet] = 10000000000 * UNIT;
		balances[bonusWallet] = 15000000000 * UNIT;
		totalSupply = totalSupply.add(25000000000 * UNIT);
		Transfer(address(0x0), _teamWallet, 10000000000 * UNIT);
		Transfer(address(0x0), _bonusWallet, 15000000000 * UNIT);
	}

	function setAdmin(address _admin) public onlyOwner {
		admin = _admin;
	}
	
	function calcBonus(uint256 _amount) internal view returns (uint256) {
					  uint256 bonusPercentage = 50;
		if (now > bonus50end) bonusPercentage = 40;
		if (now > bonus40end) bonusPercentage = 35;
		if (now > bonus35end) bonusPercentage = 30;
		if (now > bonus30end) bonusPercentage = 25;
		if (now > bonus25end) bonusPercentage = 20;
		if (now > bonus20end) bonusPercentage = 0;
		return _amount * bonusPercentage / 100;
	}
	
	function buyTokens() public payable {
		require(now < endDate);
		require(now >= startDate);
		require(msg.value > 0);
	
		uint256 amount = msg.value * UNIT / tokenPrice;
		uint256 bonus = calcBonus(msg.value) * UNIT / tokenPrice;
		
		totalSupply = totalSupply.add(amount);
		
		require(totalSupply <= maxSupply);
	
		totalWeiReceived = totalWeiReceived.add(msg.value);
	
		balances[msg.sender] = balances[msg.sender].add(amount);
		
		TokenPurchase(msg.sender, msg.sender, msg.value, amount);
		
		Transfer(address(0x0), msg.sender, amount);
	
		if (bonus > 0) {
		Transfer(bonusWallet, msg.sender, bonus);
		balances[bonusWallet] -= bonus;
		balances[msg.sender] = balances[msg.sender].add(bonus);
		}
	
		bonusWallet.transfer(msg.value);
	}
	
	function() public payable {
		buyTokens();
	}
	
		/***
		* This function is used to transfer tokens that have been bought through other means (credit card, bitcoin, etc), and to burn tokens after the sale.
		*/
	function sendTokens(address receiver, uint256 tokens) public onlyAdmin {
		require(now < endDate);
		require(now >= startDate);
		require(totalSupply + tokens * UNIT <= maxSupply);
	
		uint256 amount = tokens * UNIT;
		balances[receiver] += amount;
		totalSupply += amount;
		Transfer(address(0x0), receiver, amount);
	}

	/**
	* @dev burn tokens
	* @param _value The amount to be burned.
	* @return always true (necessary in case of override)
	*/	 
    event Burn(address indexed _burner, uint256 _value);

    function burn(uint _value) public returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }
	
    // save some gas by making only one contract call
    function burnFrom(address _from, uint256 _value) public returns (bool) 
    {
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        Transfer(_from, address(0x0), _value);
        return true;
	}

    /**
     * @dev transfer to owner any tokens send by mistake on this contracts
     * @param token The address of the token to transfer.
     * @param amount The amount to be transfered.
     */
    function emergencyERC20Drain(ERC20 token, uint amount) public onlyOwner 
	{
        token.transfer(owner, amount);
    }
	
	function getTokenDetail() public view returns (string memory, string memory, uint256) {
	    return (name, symbol, totalSupply);
    }
	
}
