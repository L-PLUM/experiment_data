/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

/**
 * Issued by Morpheus Labs ICO as a Service Wizard
 */
pragma solidity ^0.4.24;

contract PricingStrategy {

  address public tier;

  /** Interface declaration. */
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }

  /** Self check if all references are correctly set.
   * Checks that pricing strategy matches crowdsale parameters.
   */
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }

  /**
   * @dev Pricing tells if this is a presale purchase or not.
   * @param purchaser Address of the purchaser
   * @return False by default, true if a presale purchaser
   */
  function isPresalePurchase(address purchaser) public constant returns (bool) {
    return false;
  }

  /* How many weis one token costs */
  function updateRate(uint newOneTokenInWei) public {}

  /**
   * When somebody tries to buy tokens for X eth, calculate how many tokens they get.
   * @param value - What is the value of the transaction send in as wei
   * @param tokensSold - how much tokens have been sold this far
   * @param weiRaised - how much money has been raised this far in the main token sale - this number excludes presale
   * @param msgSender - who is the investor of this transaction
   * @param decimals - how many decimal units the token has
   * @return Amount of tokens the investor receives
   */
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount) {}
}
contract FinalizeAgent {

  bool public reservedTokensAreDistributed = false;

  function isFinalizeAgent() public constant returns (bool) {
    return true;
  }

  /** Return true if we can run finalizeCrowdsale() properly.
   *
   * This is a safety check function that doesn't allow crowdsale to begin
   * unless the finalizer has been set up properly.
   */
  function isSane() public constant returns (bool) {
    return true;
  }

  function distributeReservedTokens(uint reservedTokensDistributionBatch) public {

  }

  /** Called once by crowdsale finalize() if the sale was success. */
  function finalizeCrowdsale() public {

  }

}
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a && c >= b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}
contract Ownable {
  address public owner;

  bool public isParamSet = false;

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier paramNotSet() {
    require(isParamSet == false);
    _;
  }

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
   * @return the address of the owner.
   */
  function owner() public view returns (address) {
    return owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner(), "Not owner");
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns (bool) {
    return msg.sender == owner;
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
    require(newOwner != address(0), "New owner address is 0");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
contract ERC20Basic {
  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier stopNonOwnersInEmergency {
    if (halted && msg.sender != owner) revert();
    _;
  }

  modifier onlyInEmergency {
    if (!halted) revert();
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Recoverable is Ownable {

  /// @dev This will be invoked by the owner, when owner wants to rescue tokens
  /// @param token Token which will we rescue to the owner from the contract
  function recoverTokens(ERC20Basic token) onlyOwner public {
    token.transfer(owner, tokensToBeReturned(token));
  }

  /// @dev Interface function, can be overwritten by the superclass
  /// @param token Token which balance we will check and return
  /// @return The amount of tokens (in smallest denominator) the contract owns
  function tokensToBeReturned(ERC20Basic token) public returns (uint) {
    return token.balanceOf(this);
  }
}
contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address receiver, uint amount);

  /* Actual balances of token holders */
  mapping(address => uint) balances;

  /* approve() allowances */
  mapping(address => mapping(address => uint)) allowed;

  /* Interface declaration */
  function isToken() public constant returns (bool weAre) {
    return true;
  }

  function transfer(address _to, uint _value) public returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}
contract FractionalERC20Ext is ERC20 {

  uint public decimals;
  uint public minCap;

}
contract StandardTokenExt is StandardToken, Recoverable {

  /* Interface declaration */
  function isToken() public view returns (bool weAre) {
    return true;
  }
}
contract MintableTokenExt is StandardTokenExt {

  bool public mintingFinished = false;

  /** List of agents that are allowed to create new tokens */
  mapping(address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state);

  /** inPercentageUnit is percents of tokens multiplied to 10 up to percents decimals.
  * For example, for reserved tokens in percents 2.54%
  * inPercentageUnit = 254
  * inPercentageDecimals = 2
  */
  struct ReservedTokensData {
    uint inTokens;
    uint inPercentageUnit;
    uint inPercentageDecimals;
    bool isReserved;
    bool isDistributed;
  }

  mapping(address => ReservedTokensData) public reservedTokensList;
  address[] public reservedTokensDestinations;
  uint public reservedTokensDestinationsLen = 0;
  bool reservedTokensDestinationsAreSet = false;

  modifier onlyMintAgent() {
    // Only crowdsale contracts are allowed to mint new tokens
    require (mintAgents[msg.sender]);
    _;
  }

  /** Make sure we are not done yet. */
  modifier canMint() {
    require (!mintingFinished);
    _;
  }

  function finalizeReservedAddress(address addr) public onlyMintAgent canMint {
    ReservedTokensData storage reservedTokensData = reservedTokensList[addr];
    reservedTokensData.isDistributed = true;
  }

  function isAddressReserved(address addr) public constant returns (bool isReserved) {
    return reservedTokensList[addr].isReserved;
  }

  function areTokensDistributedForAddress(address addr) public constant returns (bool isDistributed) {
    return reservedTokensList[addr].isDistributed;
  }

  function getReservedTokens(address addr) public constant returns (uint inTokens) {
    return reservedTokensList[addr].inTokens;
  }

  function getReservedPercentageUnit(address addr) public constant returns (uint inPercentageUnit) {
    return reservedTokensList[addr].inPercentageUnit;
  }

  function getReservedPercentageDecimals(address addr) public constant returns (uint inPercentageDecimals) {
    return reservedTokensList[addr].inPercentageDecimals;
  }

  function setReservedTokensListMultiple(
    address[] addrs,
    uint[] inTokens,
    uint[] inPercentageUnit,
    uint[] inPercentageDecimals
  ) public canMint onlyOwner {
    assert(!reservedTokensDestinationsAreSet);
    assert(addrs.length == inTokens.length);
    assert(inTokens.length == inPercentageUnit.length);
    assert(inPercentageUnit.length == inPercentageDecimals.length);
    for (uint iterator = 0; iterator < addrs.length; iterator++) {
      if (addrs[iterator] != address(0)) {
        setReservedTokensList(addrs[iterator], inTokens[iterator], inPercentageUnit[iterator], inPercentageDecimals[iterator]);
      }
    }
    reservedTokensDestinationsAreSet = true;
  }

  /**
   * Create new tokens and allocate them to an address.
   * Only callably by a crowdsale contract (mint agent).
   */
  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply = safeAdd(totalSupply, amount);
    balances[receiver] = safeAdd(balances[receiver], amount);

    // This will make the mint transaction apper in EtherScan.io
    // We can remove this after there is a standardized minting event
    Transfer(0, receiver, amount);
  }

  /**
   * Owner can allow a crowdsale contract to mint new tokens.
   */
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }

  /**
   * Owner can allow a crowdsale contract to mint new tokens.
   */
  function setMintAgentMany(address[] addrList) onlyOwner canMint public {
    for (uint i = 0; i < addrList.length; i++) {
      setMintAgent(addrList[i], true);
    }
  }

  function setReservedTokensList(address addr, uint inTokens, uint inPercentageUnit, uint inPercentageDecimals) private canMint onlyOwner {
    assert(addr != address(0));
    if (!isAddressReserved(addr)) {
      reservedTokensDestinations.push(addr);
      reservedTokensDestinationsLen++;
    }

    reservedTokensList[addr] = ReservedTokensData({
      inTokens : inTokens,
      inPercentageUnit : inPercentageUnit,
      inPercentageDecimals : inPercentageDecimals,
      isReserved : true,
      isDistributed : false
      });
  }
}
contract CrowdsaleExt is Haltable, SafeMath {

    /* Max investment count when we are still allowed to change the multisig address */
    uint public MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE = 5;

    /* The token we are selling */
    FractionalERC20Ext public token;

    /* How we are going to price our offering */
    PricingStrategy public pricingStrategy;

    /* Post-success callback */
    FinalizeAgent public finalizeAgent;

    /* name of the crowdsale tier */
    string public name;

    /* tokens will be transfered from this address */
    address public multisigWallet;

    /* if the funding goal is not reached, investors may withdraw their funds */
    uint public minimumFundingGoal;

    /* the UNIX timestamp start date of the crowdsale */
    uint public startsAt;

    /* the UNIX timestamp end date of the crowdsale */
    uint public endsAt;

    /* the number of tokens already sold through this contract*/
    uint public tokensSold = 0;

    /* How many wei of funding we have raised */
    uint public weiRaised = 0;

    /* How many distinct addresses have invested */
    uint public investorCount = 0;

    /* Has this crowdsale been finalized */
    bool public finalized;

    bool public isWhiteListed;

    address[] public joinedCrowdsales;
    uint8 public joinedCrowdsalesLen = 0;
    uint8 public joinedCrowdsalesLenMax = 50;

    struct JoinedCrowdsaleStatus {
        bool isJoined;
        uint8 position;
    }

    mapping(address => JoinedCrowdsaleStatus) joinedCrowdsaleState;

    /** How much ETH each address has invested to this crowdsale */
    mapping(address => uint256) public investedAmountOf;

    /** How much tokens this crowdsale has credited for each investor address */
    mapping(address => uint256) public tokenAmountOf;

    struct WhiteListData {
        bool status;
        uint minCap;
        uint maxCap;
    }

    /** Addresses that are allowed to invest even before ICO offical opens. For testing, for ICO partners, etc. */
    mapping(address => WhiteListData) public earlyParticipantWhitelist;

    /** List of whitelisted addresses */
    address[] public whitelistedParticipants;

    /** This is for manuel testing for the interaction from owner wallet. You can set it to any value and inspect this in blockchain explorer to see that crowdsale interaction works. */
    uint public ownerTestValue;

    /** State machine
     * - Preparing: All contract initialization calls and variables have not been set yet
     * - Prefunding: We have not passed start time yet
     * - Funding: Active crowdsale
     * - Success: Minimum funding goal reached
     * - Failure: Minimum funding goal not reached before ending time
     * - Finalized: The finalized has been called and succesfully executed
     */
    enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized}

    /** Modified allowing execution only if the crowdsale is currently running.  */
    modifier inState(State state) {
      if (getState() != state) revert();
      _;
    }

    // A new investment was made
    event Invested(address investor, uint weiAmount, uint tokenAmount, uint128 customerId);

    // Address early participation whitelist status changed
    event Whitelisted(address addr, bool status, uint minCap, uint maxCap);
    event WhitelistItemChanged(address addr, bool status, uint minCap, uint maxCap);

    // Crowdsale start time has been changed
    event StartsAtChanged(uint newStartsAt);

    // Crowdsale end time has been changed
    event EndsAtChanged(uint newEndsAt);

    constructor() {
        
    }

    function setParamInternal(string _name, address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, bool _isWhiteListed) internal onlyOwner paramNotSet {
        require (_multisigWallet != address(0));
        require (_token != address(0));
        require (_pricingStrategy != address(0));
        require (_start != 0);
        require (_end != 0);
        require (_start < _end);

        name = _name;
        token = FractionalERC20Ext(_token);
        setPricingStrategy(_pricingStrategy);
        multisigWallet = _multisigWallet;
        startsAt = _start;
        endsAt = _end;
        // Minimum funding goal can be zero
        minimumFundingGoal = _minimumFundingGoal;
        isWhiteListed = _isWhiteListed;

        isParamSet = true;
    }

    /**
     * Don't expect to just send in money and get tokens.
     */
    function() public payable {
        revert();
    }

    /**
     * Make an investment.
     * Crowdsale must be running for one to invest.
     * We must have not pressed the emergency brake.
     * @param receiver The Ethereum address who receives the tokens
     * @param customerId (optional) UUID v4 to track the successful payments on the server side
     */
    function investInternal(address receiver, uint128 customerId) stopInEmergency private {
        // Determine if it's a good time to accept investment from this participant
        require (getState() == State.Funding);

        // Retail participants can only come in when the crowdsale is running
        // pass
        if (isWhiteListed) {
            if (!earlyParticipantWhitelist[receiver].status) {
                revert();
            }
        }

        uint weiAmount = msg.value;

        // Account presale sales separately, so that they do not count against pricing tranches
        uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised, tokensSold, msg.sender, token.decimals());

        require (tokenAmount != 0);

        if (isWhiteListed) {
            require (tokenAmount >= earlyParticipantWhitelist[receiver].minCap && tokenAmountOf[receiver] != 0);

            // Check that we did not bust the investor's cap
            require (!isBreakingInvestorCap(receiver, tokenAmount));

            updateInheritedEarlyParticipantWhitelist(receiver, tokenAmount);
        } else {
            require (tokenAmount >= token.minCap() && tokenAmountOf[receiver] != 0);
        }

        if (investedAmountOf[receiver] == 0) {
            // A new investor
            investorCount++;
        }

        // Update investor
        investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);
        tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver], tokenAmount);

        // Update totals
        weiRaised = safeAdd(weiRaised, weiAmount);
        tokensSold = safeAdd(tokensSold, tokenAmount);

        // Check that we did not bust the cap
        require (!isBreakingCap(weiAmount, tokenAmount, weiRaised, tokensSold));

        assignTokens(receiver, tokenAmount);

        // Pocket the money
        require (multisigWallet.send(weiAmount));

        // Tell us invest was success
        Invested(receiver, weiAmount, tokenAmount, customerId);
    }

    /**
     * Allow anonymous contributions to this crowdsale.
     */
    function invest(address addr) public payable {
        investInternal(addr, 0);
    }

    /**
     * The basic entry point to participate the crowdsale process.
     * Pay for funding, get invested tokens back in the sender address.
     */
    function buy() public payable {
        invest(msg.sender);
    }

    function distributeReservedTokens(uint reservedTokensDistributionBatch) public inState(State.Success) onlyOwner stopInEmergency {
        // Already finalized
        require (!finalized);

        // Finalizing is optional. We only call it if we are given a finalizing agent.
        if (address(finalizeAgent) != address(0)) {
            finalizeAgent.distributeReservedTokens(reservedTokensDistributionBatch);
        }
    }

    function areReservedTokensDistributed() public constant returns (bool) {
        return finalizeAgent.reservedTokensAreDistributed();
    }

    function canDistributeReservedTokens() public constant returns (bool) {
        CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
        if ((lastTierCntrct.getState() == State.Success) && !lastTierCntrct.halted() && !lastTierCntrct.finalized() && !lastTierCntrct.areReservedTokensDistributed()) return true;
        return false;
    }

    /**
     * Finalize a succcesful crowdsale.
     * The owner can triggre a call the contract that provides post-crowdsale actions, like releasing the tokens.
     */
    function finalize() public inState(State.Success) onlyOwner stopInEmergency {
        // Already finalized
        require (!finalized);

        // Finalizing is optional. We only call it if we are given a finalizing agent.
        if (address(finalizeAgent) != address(0)) {
            finalizeAgent.finalizeCrowdsale();
        }
        finalized = true;
    }

    /**
     * Allow to (re)set finalize agent.
     * Design choice: no state restrictions on setting this, so that we can fix fat finger mistakes.
     */
    function setFinalizeAgent(FinalizeAgent addr) public onlyOwner {
        assert(address(addr) != address(0));
        assert(address(finalizeAgent) == address(0));
        finalizeAgent = addr;

        // Don't allow setting bad agent
        require (finalizeAgent.isFinalizeAgent());
    }

    /**
     * Allow addresses to do early participation.
     */
    function setEarlyParticipantWhitelist(address addr, bool status, uint minCap, uint maxCap) public onlyOwner {
        require (isWhiteListed);
        assert(addr != address(0));
        assert(maxCap > 0);
        assert(minCap <= maxCap);
        assert(now <= endsAt);

        if (!isAddressWhitelisted(addr)) {
            whitelistedParticipants.push(addr);
            Whitelisted(addr, status, minCap, maxCap);
        } else {
            WhitelistItemChanged(addr, status, minCap, maxCap);
        }

        earlyParticipantWhitelist[addr] = WhiteListData({status : status, minCap : minCap, maxCap : maxCap});
    }

    function setEarlyParticipantWhitelistMultiple(address[] addrs, bool[] statuses, uint[] minCaps, uint[] maxCaps) public onlyOwner {
        require (isWhiteListed);
        assert(now <= endsAt);
        assert(addrs.length == statuses.length);
        assert(statuses.length == minCaps.length);
        assert(minCaps.length == maxCaps.length);

        for (uint iterator = 0; iterator < addrs.length; iterator++) {
            setEarlyParticipantWhitelist(addrs[iterator], statuses[iterator], minCaps[iterator], maxCaps[iterator]);
        }
    }

    function updateInheritedEarlyParticipantWhitelist(address reciever, uint tokensBought) private {
        require (isWhiteListed);
        require (tokensBought >= earlyParticipantWhitelist[reciever].minCap && tokenAmountOf[reciever] != 0);

        uint8 tierPosition = getTierPosition(this);

        for (uint8 j = tierPosition + 1; j < joinedCrowdsalesLen; j++) {
            CrowdsaleExt crowdsale = CrowdsaleExt(joinedCrowdsales[j]);
            crowdsale.updateEarlyParticipantWhitelist(reciever, tokensBought);
        }
    }

    function updateEarlyParticipantWhitelist(address addr, uint tokensBought) public {
        require (isWhiteListed);
        assert(addr != address(0));
        assert(now <= endsAt);
        assert(isTierJoined(msg.sender));

        require (tokensBought >= earlyParticipantWhitelist[addr].minCap && tokenAmountOf[addr] != 0);
        //if (addr != msg.sender && contractAddr != msg.sender) throw;
        uint newMaxCap = earlyParticipantWhitelist[addr].maxCap;
        newMaxCap = safeSub(newMaxCap, tokensBought);
        earlyParticipantWhitelist[addr] = WhiteListData({status : earlyParticipantWhitelist[addr].status, minCap : 0, maxCap : newMaxCap});
    }

    function isAddressWhitelisted(address addr) public constant returns (bool) {
        for (uint i = 0; i < whitelistedParticipants.length; i++) {
            if (whitelistedParticipants[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function whitelistedParticipantsLength() public constant returns (uint) {
        return whitelistedParticipants.length;
    }

    function isTierJoined(address addr) public constant returns (bool) {
        return joinedCrowdsaleState[addr].isJoined;
    }

    function getTierPosition(address addr) public constant returns (uint8) {
        return joinedCrowdsaleState[addr].position;
    }

    function getLastTier() public constant returns (address) {
        if (joinedCrowdsalesLen > 0)
            return joinedCrowdsales[joinedCrowdsalesLen - 1];
        else
            return address(0);
    }

    function setJoinedCrowdsales(address addr) private onlyOwner {
        assert(addr != address(0));
        assert(joinedCrowdsalesLen <= joinedCrowdsalesLenMax);
        assert(!isTierJoined(addr));
        joinedCrowdsales.push(addr);
        joinedCrowdsaleState[addr] = JoinedCrowdsaleStatus({
            isJoined : true,
            position : joinedCrowdsalesLen
            });
        joinedCrowdsalesLen++;
    }

    function updateJoinedCrowdsalesMultiple(address[] addrs) public onlyOwner {
        assert(addrs.length > 0);
        assert(joinedCrowdsalesLen == 0);
        assert(addrs.length <= joinedCrowdsalesLenMax);
        for (uint8 iter = 0; iter < addrs.length; iter++) {
            setJoinedCrowdsales(addrs[iter]);
        }
    }

    function setStartsAt(uint time) public onlyOwner {
        assert(!finalized);
        assert(now <= time);
        // Don't change past
        assert(time <= endsAt);
        assert(now <= startsAt);

        CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
        require (!lastTierCntrct.finalized());

        uint8 tierPosition = getTierPosition(this);

        //start time should be greater then end time of previous tiers
        for (uint8 j = 0; j < tierPosition; j++) {
            CrowdsaleExt crowdsale = CrowdsaleExt(joinedCrowdsales[j]);
            assert(time >= crowdsale.endsAt());
        }

        startsAt = time;
        StartsAtChanged(startsAt);
    }

    /**
     * Allow crowdsale owner to close early or extend the crowdsale.
     * This is useful e.g. for a manual soft cap implementation:
     * - after X amount is reached determine manual closing
     * This may put the crowdsale to an invalid state,
     * but we trust owners know what they are doing.
     */
    function setEndsAt(uint time) public onlyOwner {
        assert(!finalized);
        assert(now <= time);
        // Don't change past
        assert(startsAt <= time);
        assert(now <= endsAt);

        CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
        require (!lastTierCntrct.finalized());


        uint8 tierPosition = getTierPosition(this);

        for (uint8 j = tierPosition + 1; j < joinedCrowdsalesLen; j++) {
            CrowdsaleExt crowdsale = CrowdsaleExt(joinedCrowdsales[j]);
            assert(time <= crowdsale.startsAt());
        }

        endsAt = time;
        EndsAtChanged(endsAt);
    }

    /**
     * Allow to (re)set pricing strategy.
     *
     * Design choice: no state restrictions on the set, so that we can fix fat finger mistakes.
     */
    function setPricingStrategy(PricingStrategy _pricingStrategy) public onlyOwner {
        assert(address(_pricingStrategy) != address(0));
        assert(address(pricingStrategy) == address(0));
        pricingStrategy = _pricingStrategy;

        // Don't allow setting bad agent
        require (pricingStrategy.isPricingStrategy());
    }

    /**
     * Allow to change the team multisig address in the case of emergency.
     * This allows to save a deployed crowdsale wallet in the case the crowdsale has not yet begun
     * (we have done only few test transactions). After the crowdsale is going
     * then multisig address stays locked for the safety reasons.
     */
    function setMultisig(address addr) public onlyOwner {
        // Change
        require (investorCount <= MAX_INVESTMENTS_BEFORE_MULTISIG_CHANGE);
        multisigWallet = addr;
    }

    /**
     * @return true if the crowdsale has raised enough money to be a successful.
     */
    function isMinimumGoalReached() public constant returns (bool reached) {
        return weiRaised >= minimumFundingGoal;
    }

    /**
     * Check if the contract relationship looks good.
     */
    function isFinalizerSane() public constant returns (bool sane) {
        return finalizeAgent.isSane();
    }

    /**
     * Check if the contract relationship looks good.
     */
    function isPricingSane() public constant returns (bool sane) {
        return pricingStrategy.isSane(address(this));
    }

    /**
     * Crowdfund state machine management.
     * We make it a function and do not assign the result to a variable, so there is no chance of the variable being stale.
     */
    function getState() public constant returns (State) {
        if (finalized) return State.Finalized;
        else if (address(finalizeAgent) == 0) return State.Preparing;
        else if (!finalizeAgent.isSane()) return State.Preparing;
        else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
        else if (block.timestamp < startsAt) return State.PreFunding;
        else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
        else if (isMinimumGoalReached()) return State.Success;
        else return State.Failure;
    }

    /** Interface marker. */
    function isCrowdsale() public constant returns (bool) {
        return true;
    }

    //
    // Abstract functions
    //

    /**
     * Check if the current invested breaks our cap rules.
     * The child contract must define their own cap setting rules.
     * We allow a lot of flexibility through different capping strategies (ETH, token count)
     * Called from invest().
     * @param weiAmount The amount of wei the investor tries to invest in the current transaction
     * @param tokenAmount The amount of tokens we try to give to the investor in the current transaction
     * @param weiRaisedTotal What would be our total raised balance after this transaction
     * @param tokensSoldTotal What would be our total sold tokens count after this transaction
     * @return true if taking this investment would break our cap rules
     */
    function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) public constant returns (bool limitBroken) {}

    function isBreakingInvestorCap(address receiver, uint tokenAmount) public constant returns (bool limitBroken) {}

    /**
     * Check if the current crowdsale is full and we can no longer sell any tokens.
     */
    function isCrowdsaleFull() public constant returns (bool) {}

    /**
     * Create new tokens or transfer issued tokens to the investor depending on the cap model.
     */
    function assignTokens(address receiver, uint tokenAmount) private {}
}

contract MintedTokenCappedCrowdsaleExt is CrowdsaleExt {

    /* Maximum amount of tokens this crowdsale can sell. */
    uint public maximumSellableTokens;

    constructor() payable {

    }

    function setParam(string _name, address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, bool _isWhiteListed, uint _maximumSellableTokens) public onlyOwner paramNotSet {

        setParamInternal(_name, _token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal, _isWhiteListed);

        maximumSellableTokens = _maximumSellableTokens;
    }

    // Crowdsale maximumSellableTokens has been changed
    event MaximumSellableTokensChanged(uint newMaximumSellableTokens);

    /**
     * Called from invest() to confirm if the curret investment does not break our cap rule.
     */
    function isBreakingCap(uint tokensSoldTotal) public constant returns (bool limitBroken) {
        return tokensSoldTotal > maximumSellableTokens;
    }

    function isBreakingInvestorCap(address addr, uint tokenAmount) public constant returns (bool limitBroken) {
        assert(isWhiteListed);
        uint maxCap = earlyParticipantWhitelist[addr].maxCap;
        return (safeAdd(tokenAmountOf[addr], tokenAmount)) > maxCap;
    }

    function isCrowdsaleFull() public constant returns (bool) {
        return tokensSold >= maximumSellableTokens;
    }

    function setMaximumSellableTokens(uint tokens) public onlyOwner {
        assert(!finalized);
        assert(now <= startsAt);

        CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
        assert(!lastTierCntrct.finalized());

        maximumSellableTokens = tokens;
        MaximumSellableTokensChanged(maximumSellableTokens);
    }

    function updateRate(uint newOneTokenInWei) public onlyOwner {
        assert(!finalized);
        assert(now <= startsAt);

        CrowdsaleExt lastTierCntrct = CrowdsaleExt(getLastTier());
        assert(!lastTierCntrct.finalized());

        pricingStrategy.updateRate(newOneTokenInWei);
    }

    /**
     * Dynamically create tokens and assign them to the investor.
     */
    function assignTokens(address receiver, uint tokenAmount) private {
        MintableTokenExt mintableToken = MintableTokenExt(token);
        mintableToken.mint(receiver, tokenAmount);
    }

    function finalizeCrowdsale() public {

    }
}
