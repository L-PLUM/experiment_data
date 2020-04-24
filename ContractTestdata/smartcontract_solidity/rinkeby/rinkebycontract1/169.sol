/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.25;

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/SIROToken.sol

contract ERC677Receiver {
  function onTokenTransfer(address _sender, uint _amount) public;
  function onTokenTransferWithUint(address _sender, uint _amount, uint _enum_ordinal) public;
  function onTokenTransferWithByte(address _sender, uint _amount, bytes _data) public;
}

contract SIROToken is StandardToken, Ownable, Pausable {

    using SafeMath for uint;

    event Released(address indexed receiver, uint amount);
    event Transfer(address indexed sender, address indexed _to, uint _amount, bytes _data);
    event Transfer(address indexed sender, address indexed _to, uint _amount, uint _enum_ordinal);
    event Buy(address indexed _contributor, uint _SIRO_sold);
    event Refund(address indexed _patron_wallet, uint _SIRO_remaining_token);

    uint    public decimals = 18;
    string  public name = "SiroSmile";
    string  public symbol = "SIRO";
    uint    public totalSupply = 500 * MILLION_SIRO_UNIT;                                        // 500,000,000 SIRO

    uint    public constant DECIMALS_UNIT = 18;
    uint    public constant SIRO_UNIT = 10 ** DECIMALS_UNIT;
    uint    public constant MILLION_SIRO_UNIT = 10 ** 6 * SIRO_UNIT;

    uint    public constant SIROCommunityReserveAllocation = 125 * MILLION_SIRO_UNIT;            // 125,000,000 SIRO
    uint    public constant SIROCrowdFundAllocation = 75 * MILLION_SIRO_UNIT;                    // 75,000,000 SIRO - private sale & other currency
    uint    public constant SIROEcoAllocation = 75 * MILLION_SIRO_UNIT;                          // 75,000,000 SIRO
    uint    public constant SIROCompanyAllocation = 85 * MILLION_SIRO_UNIT;                      // 85,000,000 SIRO
    uint    public constant SIROTeamAllocation = 50 * MILLION_SIRO_UNIT;                         // 50,000,000 SIRO

    uint    public constant SIROCrowdFundTomoAllocation = 90 * MILLION_SIRO_UNIT;                // 90,000,000 SIRO

    address public SIROCommunityReserveWallet;
    address public SIROCrowdFundAllocationWallet;
    address public SIROEcoWallet;
    address public SIROCompanyWallet;
    address public teamWallet;
    address public founderWallet;
    address public SIROCrowdFundTomoAllocationWallet;

    uint    public startTime = 1550854800;                                                      // February 23, 2019 0:00:00 GMT+07:00
    uint    public endTime = 1554051599;                                                        // March 31, 2019 23:59:59 GMT+07:00

    // SIRO team allocation & holding variables
    uint    public constant teamAllocation = 45 * MILLION_SIRO_UNIT;                            // allocate for team : 9% = 45,000,000 SIRO
    
    uint    public totalTeamAllocated = 0;
    uint    public teamTranchesReleased = 0;
    uint    public maxTeamTranches = 12;                                                        // release team tokens 12 tranches every 30 days period
    
    // SIRO founder allocation & holding variables
    uint    public constant founderAllocation = 5 * MILLION_SIRO_UNIT;                          // allocate for founder : 1% = 5,000,000 SIRO
    
    
    uint    public totalFounderAllocated = 0;
    uint    public founderTranchesReleased = 0;
    uint    public maxFounderTranches = 24;                                                     // release founder tokens 24 tranches every 30 days period
    
    uint    public constant RELEASE_PERIOD = 30 days;

    uint    public constant conversionRate = 40;                                            // 1 TOMO = 40 SIRO
    uint    public constant minimumContribute = 10;                                         // contribute amount has to be equal or greater than 10 TOMO

    function setEndTimeForTesting(uint _endTime) public onlyOwner returns (bool) {
      endTime = _endTime;
      return true;
    }

    constructor(address _SIROCommunityReserveWallet, 
                address _SIROCrowdFundAllocationWallet, 
                address _SIROEcoWallet, 
                address _SIROCompanyWallet,
                address _teamWallet,
                address _founderWallet,
                address _SIROCrowdFundTomoAllocationWallet) public {
                    
        SIROCommunityReserveWallet = _SIROCommunityReserveWallet;
        SIROCrowdFundAllocationWallet = _SIROCrowdFundAllocationWallet;
        SIROEcoWallet = _SIROEcoWallet;
        SIROCompanyWallet = _SIROCompanyWallet;
        teamWallet = _teamWallet;
        founderWallet = _founderWallet;
        SIROCrowdFundTomoAllocationWallet = _SIROCrowdFundTomoAllocationWallet;

        balances[SIROCommunityReserveWallet] = balances[SIROCommunityReserveWallet].add(SIROCommunityReserveAllocation);
        balances[SIROCrowdFundAllocationWallet] = balances[SIROCrowdFundAllocationWallet].add(SIROCrowdFundAllocation);
        balances[SIROEcoWallet] = balances[SIROEcoWallet].add(SIROEcoAllocation);
        balances[SIROCompanyWallet] = balances[SIROCompanyWallet].add(SIROCompanyAllocation);
        balances[SIROCrowdFundTomoAllocationWallet] = balances[SIROCrowdFundTomoAllocationWallet].add(SIROCrowdFundTomoAllocation);

        pause();
    }

    /**
    * @dev ensure function call after endTime ICO
    */
    modifier afterEndIco() {
        require(now >= endTime, "Should be after End ICO");
        _;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _amount The amount to be transferred.
    */
    function transfer(address _to, uint _amount) public whenNotPaused returns (bool) {
        super.transfer(_to, _amount);
        return true;
    }

    /**
    * @dev transfer token to a contract address with additional data if the recipient is a contact.
    * @param _to The address to transfer to.
    * @param _amount The amount to be transferred.
    */
    function transferAndCall(address _to, uint _amount) public whenNotPaused returns (bool success)    {
        transfer(_to, _amount);
        
        if (isContract(_to)) {
            
            ERC677Receiver receiver = ERC677Receiver(_to);
            
            receiver.onTokenTransfer(msg.sender, _amount);
        }
        
        return true;
    }

    /**
    * @dev transfer token to a contract address with additional data if the recipient is a contact.
    * @param _to The address to transfer to.
    * @param _amount The amount to be transferred.
    * @param _data The extra data to be passed to the receiving contract.
    */
    function transferAndCallWithData(address _to, uint _amount, bytes _data) public whenNotPaused returns (bool success)    {
        transfer(_to, _amount);
        
        emit Transfer(msg.sender, _to, _amount, _data);
        
        if (isContract(_to)) {
            
            ERC677Receiver receiver = ERC677Receiver(_to);
            
            receiver.onTokenTransferWithByte(msg.sender, _amount, _data);
        }
        
        return true;
    }

    /**
    * @dev transfer token to a contract address with additional data if the recipient is a contact.
    * @param _to The address to transfer to.
    * @param _amount The amount to be transferred.
    * @param _enum_ordinal The enum ordinal function on receiving contract.
    */
    function transferAndCallWithUint(address _to, uint _amount, uint _enum_ordinal) public whenNotPaused returns (bool success)    {
        
        transfer(_to, _amount);

        emit Transfer(msg.sender, _to, _amount, _enum_ordinal);
        
        if (isContract(_to)) {
            
            ERC677Receiver receiver = ERC677Receiver(_to);
            
            receiver.onTokenTransferWithUint(msg.sender, _amount, _enum_ordinal);
        }
        
        return true;
    }

    function isContract(address _addr) private view returns (bool hasCode)  {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
    
    /*
        @dev start public ICO function
    */
    function startPublicIco() onlyOwner public {
        require(now >= startTime, "Start public ICO time should be after startTime");
        
        unpause();
    }
    
    /**
        @dev Release SIRO Token to Team based on 12 tranches release every 30 days
        @return true if successful
    */
    function releaseTeamTokens() public onlyOwner afterEndIco returns (bool) {

        require(teamWallet != 0x0);
        require(totalTeamAllocated < teamAllocation);
        require(teamTranchesReleased < maxTeamTranches);

        uint currentTranche = now.sub(endTime).div(RELEASE_PERIOD);

        if (teamTranchesReleased < maxTeamTranches && currentTranche > teamTranchesReleased) {

            uint amount = teamAllocation.div(maxTeamTranches);

            balances[teamWallet] = balances[teamWallet].add(amount);

            totalTeamAllocated = totalTeamAllocated.add(amount);

            teamTranchesReleased++;

            emit Transfer(0x0, teamWallet, amount);
            emit Released(teamWallet, amount);
        }
        return true;
    }

    /**
        @dev Release SIRO Token to Founder based on 24 tranches release every 30 days
        @return true if successful
    */
    function releaseFounderTokens() public onlyOwner afterEndIco returns (bool) {

        require(founderWallet != 0x0);
        require(totalFounderAllocated < founderAllocation);
        require(founderTranchesReleased < maxFounderTranches);

        uint currentTranche = now.sub(endTime).div(RELEASE_PERIOD);

        if (founderTranchesReleased < maxFounderTranches && currentTranche > founderTranchesReleased) {

            uint amount = founderAllocation.div(maxFounderTranches);

            balances[founderWallet] = balances[founderWallet].add(amount);

            totalFounderAllocated = totalFounderAllocated.add(amount);

            founderTranchesReleased++;

            emit Transfer(0x0, founderWallet, amount);
            emit Released(founderWallet, amount);
        }
        return true;
    }

    // ------------------------------------------------------------------------
    // Accept TOMO
    // ------------------------------------------------------------------------
    function () public payable  {

        processBuy();

    }

    function processBuy() public payable whenNotPaused {

        address _contributor = msg.sender;
        uint _amount = msg.value;

        require(_contributor != address(0x0), "Must have contributor wallet address");
        
        require(_amount >= (minimumContribute * 1 ether), "We only accept minimum purchase of 10 TOMO");
        
        require(!isContract(_contributor), "We do not allow buyer from contract");

        uint remainingToken = publicIcoRemainingToken();
        
        require(remainingToken > 0, "We have not enough Token for this purchase");
        
        
        uint tokenAmount = _amount.mul(conversionRate);

        if( tokenAmount > remainingToken ) {

            // partial sale
            tokenAmount = remainingToken;
            
            uint refundAmount = _amount.sub(remainingToken.div(conversionRate));

            _amount = _amount - refundAmount;
            
            // refund remaining Tomo to contributor
            _contributor.transfer(refundAmount);
        }

        // subtract SIRO from SIROCrowdFundTomoAllocationWallet
        balances[SIROCrowdFundTomoAllocationWallet] = balances[SIROCrowdFundTomoAllocationWallet].sub(tokenAmount);
        // send SIRO to contributor address
        balances[_contributor] = balances[_contributor].add(tokenAmount);

        // send TOMO to Siro crowd funding wallet
        SIROCrowdFundAllocationWallet.transfer(_amount);

        emit Transfer(SIROCrowdFundTomoAllocationWallet, _contributor, tokenAmount);
        emit Buy(_contributor, tokenAmount);
    }

    function publicIcoRemainingToken() public view returns (uint) {
        return balanceOf(SIROCrowdFundTomoAllocationWallet);
    }

    function refundRemainingTokenToPatron() public afterEndIco returns (bool) {
        
        uint remainingToken = publicIcoRemainingToken();

        balances[SIROCrowdFundTomoAllocationWallet] = balances[SIROCrowdFundTomoAllocationWallet].sub(remainingToken);

        balances[SIROCommunityReserveWallet] = balances[SIROCommunityReserveWallet].add(remainingToken);

        emit Transfer(SIROCrowdFundTomoAllocationWallet, SIROCommunityReserveWallet, remainingToken);

        emit Refund(SIROCommunityReserveWallet, remainingToken);

        return true;
    }
}
