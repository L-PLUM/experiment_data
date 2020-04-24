/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.4.18;

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}


contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}


/// @title StandardBounties
/// @dev Used to pay out individuals or groups for task fulfillment through
/// stepwise work submission, acceptance, and payment
/// @author Mark Beylin <[email protected]>, Gonçalo Sá <[email protected]>
contract StandardBounties {

  /*
   * Events
   */
  event BountyIssued(uint bountyId);
  event BountyActivated(uint bountyId, address issuer);
  event BountyFulfilled(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);
  event FulfillmentUpdated(uint _bountyId, uint _fulfillmentId);
  event FulfillmentAccepted(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);
  event FulfillmentAcceptedPartial(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId, uint _percentage);
  event BountyKilled(uint bountyId, address indexed issuer);
  event ContributionAdded(uint bountyId, address indexed contributor, uint256 value);
  event DeadlineExtended(uint bountyId, uint newDeadline);
  event BountyChanged(uint bountyId);
  event IssuerTransferred(uint _bountyId, address indexed _newIssuer);
  event PayoutIncreased(uint _bountyId, uint _newFulfillmentAmount);
  
  // Royalty Events
  event RoyaltyFunded(uint indexed bountyId, uint indexed value);
  event RoyaltyExhausted(uint indexed bountyId);
  event PayoutGenerated(uint indexed bountyId, address indexed payee, uint indexed amount);
  event OwnerAdded(uint indexed bountyId, address indexed owner, uint indexed weight);
  event ForwarderSet(uint indexed bountyId, address indexed owner, address indexed beneficiary);

  /*
   * Storage
   */

  address public owner;

  Bounty[] public bounties;

  mapping(uint=>Fulfillment[]) fulfillments;
  mapping(uint=>uint) numAccepted;
  mapping(uint=>HumanStandardToken) tokenContracts;
  
  mapping(address=>UserStats) userStats;

  /*
   * Enums
   */

  enum BountyStages {
      Draft,
      Active,
      Dead
  }

  /*
   * Structs
   */

  struct Bounty {
      address issuer;
      uint deadline;
      string data;
      uint fulfillmentAmount;
      uint fulfillmentDistributed;
      address arbiter;
      bool paysTokens;
      BountyStages bountyStage;
      uint balance;
  }

  struct Fulfillment {
      bool accepted;
      address fulfiller;
      string data;
  }
  
  struct UserStats {
      uint bountiesWon;
      uint royaltiesWon;
  }
  
 /*
  * RoyaltyStructs
  */

    struct Royalty {
		uint bountyId;
		uint initialFunding;
		uint balance;
		uint distributionPercent;
		mapping (address => uint) ownerIndicies;
		address[] owners;
		mapping (address => uint) ownerWeights;
		mapping (address => address) forwarderAddresses;
		uint foundingTime;
		uint totalWeight;
    }
    
    uint distributionPercent;
    ERC20Interface distributionToken;

	// map bountyId -> royalty.
    mapping (uint => Royalty) royalties;
    
    // Beneficiaries can choose to donate their proceeds to another organization.
    mapping (address => address) forwarderAddresses;

  /*
   * Modifiers
   */

  modifier validateNotTooManyBounties(){
    require((bounties.length + 1) > bounties.length);
    _;
  }

  modifier validateNotTooManyFulfillments(uint _bountyId){
    require((fulfillments[_bountyId].length + 1) > fulfillments[_bountyId].length);
    _;
  }
  
  modifier validateBountyArrayIndex(uint _bountyId){
    require(_bountyId < bounties.length);
    _;
  }

  modifier onlyIssuer(uint _bountyId) {
      require(msg.sender == bounties[_bountyId].issuer);
      _;
  }

  modifier onlyFulfiller(uint _bountyId, uint _fulfillmentId) {
      require(msg.sender == fulfillments[_bountyId][_fulfillmentId].fulfiller);
      _;
  }
  
  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }

  modifier amountIsNotZero(uint _amount) {
      require(_amount != 0);
      _;
  }

  modifier transferredAmountEqualsValue(uint _bountyId, uint _amount) {
      if (bounties[_bountyId].paysTokens){
        require(msg.value == 0);
        uint oldBalance = tokenContracts[_bountyId].balanceOf(this);
        if (_amount != 0){
          require(tokenContracts[_bountyId].transferFrom(msg.sender, this, _amount));
        }
        require((tokenContracts[_bountyId].balanceOf(this) - oldBalance) == _amount);

      } else {
        require((_amount * 1 wei) == msg.value);
      }
      _;
  }

  modifier isBeforeDeadline(uint _bountyId) {
      require(now < bounties[_bountyId].deadline);
      _;
  }

  modifier validateDeadline(uint _newDeadline) {
      require(_newDeadline > now);
      _;
  }

  modifier isAtStage(uint _bountyId, BountyStages _desiredStage) {
      require(bounties[_bountyId].bountyStage == _desiredStage);
      _;
  }

  modifier validateFulfillmentArrayIndex(uint _bountyId, uint _index) {
      require(_index < fulfillments[_bountyId].length);
      _;
  }

  modifier notYetAccepted(uint _bountyId, uint _fulfillmentId){
      require(fulfillments[_bountyId][_fulfillmentId].accepted == false);
      _;
  }

  /*
   * Public functions
   */


  /// @dev StandardBounties(): instantiates
  /// the issuer of the standardbounties contract, who has the
  /// ability to remove bounties
  function StandardBounties(address _owner, address _tokenAddress)
      public
  {
      owner = _owner;
      distributionToken = ERC20Interface(_tokenAddress);
  }

  /// @dev issueBounty(): instantiates a new draft bounty
  /// @param _issuer the address of the intended issuer of the bounty
  /// @param _deadline the unix timestamp after which fulfillments will no longer be accepted
  /// @param _data the requirements of the bounty
  /// @param _fulfillmentAmount the amount of wei to be paid out for each successful fulfillment
  /// @param _arbiter the address of the arbiter who can mediate claims
  /// @param _paysTokens whether the bounty pays in tokens or in ETH
  /// @param _tokenContract the address of the contract if _paysTokens is true
  function issueBounty(
      address _issuer,
      uint _deadline,
      string _data,
      uint256 _fulfillmentAmount,
      address _arbiter,
      bool _paysTokens,
      address _tokenContract
  )
      public
      validateDeadline(_deadline)
      amountIsNotZero(_fulfillmentAmount)
      validateNotTooManyBounties
      returns (uint)
  {
      bounties.push(Bounty(_issuer, _deadline, _data, _fulfillmentAmount, 0, _arbiter, _paysTokens, BountyStages.Draft, 0));
      if (_paysTokens){
        tokenContracts[bounties.length - 1] = HumanStandardToken(_tokenContract);
      }
      BountyIssued(bounties.length - 1);
      return (bounties.length - 1);
  }

  modifier isNotDead(uint _bountyId) {
      require(bounties[_bountyId].bountyStage != BountyStages.Dead);
      _;
  }

  /// @dev contribute(): a function allowing anyone to contribute tokens to a
  /// bounty, as long as it is still before its deadline. Shouldn't keep
  /// them by accident (hence 'value').
  /// @param _bountyId the index of the bounty
  /// @param _value the amount being contributed in ether to prevent accidental deposits
  /// @notice Please note you funds will be at the mercy of the issuer
  ///  and can be drained at any moment. Be careful!
  function contribute (uint _bountyId, uint _value)
      payable
      public
      validateBountyArrayIndex(_bountyId)
      isBeforeDeadline(_bountyId)
      isNotDead(_bountyId)
      amountIsNotZero(_value)
      transferredAmountEqualsValue(_bountyId, _value)
  {
      bounties[_bountyId].balance += _value;

      ContributionAdded(_bountyId, msg.sender, _value);
  }

  /// @notice Send funds to activate the bug bounty
  /// @dev activateBounty(): activate a bounty so it may pay out
  /// @param _bountyId the index of the bounty
  /// @param _value the amount being contributed in ether to prevent
  /// accidental deposits
  function activateBounty(uint _bountyId, uint _value)
      payable
      public
      validateBountyArrayIndex(_bountyId)
      isBeforeDeadline(_bountyId)
      onlyIssuer(_bountyId)
  {
      require(_value == bounties[_bountyId].fulfillmentAmount * 2, "Not exact value");
      bounties[_bountyId].balance += _value;
      fundRoyalty(_bountyId, _value);
      
      require (bounties[_bountyId].balance >= bounties[_bountyId].fulfillmentAmount, "Not enough funds to activate");
      transitionToState(_bountyId, BountyStages.Active);

      ContributionAdded(_bountyId, msg.sender, _value);
      BountyActivated(_bountyId, msg.sender);
  }

  modifier notIssuerOrArbiter(uint _bountyId) {
      require(msg.sender != bounties[_bountyId].issuer && msg.sender != bounties[_bountyId].arbiter);
      _;
  }

  /// @dev fulfillBounty(): submit a fulfillment for the given bounty
  /// @param _bountyId the index of the bounty
  /// @param _data the data artifacts representing the fulfillment of the bounty
  function fulfillBounty(uint _bountyId, string _data)
      public
      isAtStage(_bountyId, BountyStages.Active)
      isBeforeDeadline(_bountyId)
      returns (uint)
  {
      fulfillments[_bountyId].push(Fulfillment(false, msg.sender, _data));

      BountyFulfilled(_bountyId, msg.sender, (fulfillments[_bountyId].length - 1));
      
      return fulfillments[_bountyId].length - 1;
  }

  /// @dev updateFulfillment(): Submit updated data for a given fulfillment
  /// @param _bountyId the index of the bounty
  /// @param _fulfillmentId the index of the fulfillment
  /// @param _data the new data being submitted
  function updateFulfillment(uint _bountyId, uint _fulfillmentId, string _data)
      public
      validateBountyArrayIndex(_bountyId)
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
      onlyFulfiller(_bountyId, _fulfillmentId)
      notYetAccepted(_bountyId, _fulfillmentId)
  {
      fulfillments[_bountyId][_fulfillmentId].data = _data;
      FulfillmentUpdated(_bountyId, _fulfillmentId);
  }

  modifier onlyIssuerOrArbiter(uint _bountyId) {
      require(msg.sender == bounties[_bountyId].issuer ||
         (msg.sender == bounties[_bountyId].arbiter && bounties[_bountyId].arbiter != address(0)));
      _;
  }

  modifier fulfillmentNotYetAccepted(uint _bountyId, uint _fulfillmentId) {
      require(fulfillments[_bountyId][_fulfillmentId].accepted == false);
      _;
  }

  modifier enoughFundsToPay(uint _bountyId) {
      require(bounties[_bountyId].balance >= bounties[_bountyId].fulfillmentAmount);
      _;
  }
  
  /// @dev acceptFulfillmentPartial(): accept a given fulfillment, but only distribute part of reward
  /// @param _bountyId the index of the bounty
  /// @param _fulfillmentId the index of the fulfillment being accepted
  function acceptFulfillmentPartial(uint _bountyId, uint _fulfillmentId, uint _percentage) public
      validateBountyArrayIndex(_bountyId)
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
      onlyIssuerOrArbiter(_bountyId)
      isAtStage(_bountyId, BountyStages.Active)
      enoughFundsToPay(_bountyId)
  {
      //TODO: Add math safety
      require(bounties[_bountyId].fulfillmentDistributed + _percentage <= 100, "Not enough distrbution remaining");

      fulfillments[_bountyId][_fulfillmentId].accepted = true;
      bounties[_bountyId].fulfillmentDistributed += _percentage;
      numAccepted[_bountyId]++;
      
      uint fulfillmentAmount = (bounties[_bountyId].fulfillmentAmount / 100 * _percentage);
      increaseBountiesWon(fulfillments[_bountyId][_fulfillmentId].fulfiller, fulfillmentAmount);
      bounties[_bountyId].balance -= fulfillmentAmount;
      addRoyaltyBeneficiary(_bountyId, fulfillments[_bountyId][_fulfillmentId].fulfiller, _percentage);
      
      if (bounties[_bountyId].paysTokens){
        require(tokenContracts[_bountyId].transfer(fulfillments[_bountyId][_fulfillmentId].fulfiller, fulfillmentAmount));
      } else {
        fulfillments[_bountyId][_fulfillmentId].fulfiller.transfer(fulfillmentAmount);
      }
      
      FulfillmentAcceptedPartial(_bountyId, msg.sender, _fulfillmentId, _percentage);
  }

  modifier newDeadlineIsValid(uint _bountyId, uint _newDeadline) {
      require(_newDeadline > bounties[_bountyId].deadline);
      _;
  }

  modifier newFulfillmentAmountIsIncrease(uint _bountyId, uint _newFulfillmentAmount) {
      require(bounties[_bountyId].fulfillmentAmount < _newFulfillmentAmount);
      _;
  }

  /// @dev getFulfillment(): Returns the fulfillment at a given index
  /// @param _bountyId the index of the bounty
  /// @param _fulfillmentId the index of the fulfillment to return
  /// @return Returns a tuple for the fulfillment
  function getFulfillment(uint _bountyId, uint _fulfillmentId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)
      returns (bool, address, string)
  {
      return (fulfillments[_bountyId][_fulfillmentId].accepted,
              fulfillments[_bountyId][_fulfillmentId].fulfiller,
              fulfillments[_bountyId][_fulfillmentId].data);
  }

  /// @dev getBounty(): Returns the details of the bounty
  /// @param _bountyId the index of the bounty
  /// @return Returns a tuple for the bounty
  function getBounty(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (address, uint, uint, bool, uint, uint)
  {
      return (bounties[_bountyId].issuer,
              bounties[_bountyId].deadline,
              bounties[_bountyId].fulfillmentAmount,
              bounties[_bountyId].paysTokens,
              uint(bounties[_bountyId].bountyStage),
              bounties[_bountyId].balance);
  }

  /// @dev getBountyArbiter(): Returns the arbiter of the bounty
  /// @param _bountyId the index of the bounty
  /// @return Returns an address for the arbiter of the bounty
  function getBountyArbiter(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (address)
  {
      return (bounties[_bountyId].arbiter);
  }

  /// @dev getBountyData(): Returns the data of the bounty
  /// @param _bountyId the index of the bounty
  /// @return Returns a string for the bounty data
  function getBountyData(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (string)
  {
      return (bounties[_bountyId].data);
  }

  /// @dev getBountyToken(): Returns the token contract of the bounty
  /// @param _bountyId the index of the bounty
  /// @return Returns an address for the token that the bounty uses
  function getBountyToken(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (address)
  {
      return (tokenContracts[_bountyId]);
  }

  /// @dev getNumBounties() returns the number of bounties in the registry
  /// @return Returns the number of bounties
  function getNumBounties()
      public
      constant
      returns (uint)
  {
      return bounties.length;
  }

  /// @dev getNumFulfillments() returns the number of fulfillments for a given milestone
  /// @param _bountyId the index of the bounty
  /// @return Returns the number of fulfillments
  function getNumFulfillments(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (uint)
  {
      return fulfillments[_bountyId].length;
  }
  
  // Royalties 
  
  /// @dev addRoyaltyBeneficiary() adds a beneficiary to an existing royalty
  /// @param _bountyId the index of the corresponding bounty
  /// @return Returns the number of fulfillments
  function addRoyaltyBeneficiary(uint _bountyId, address _newOwner, uint _weight) public {
      if (royalties[_bountyId].ownerIndicies[_newOwner] == 0) {
        royalties[_bountyId].owners.push(_newOwner);
		royalties[_bountyId].ownerIndicies[_newOwner] = royalties[_bountyId].owners.length - 1;  
      }
		
		royalties[_bountyId].ownerWeights[_newOwner] += _weight;
		royalties[_bountyId].totalWeight += _weight;
		
		emit OwnerAdded(_bountyId, _newOwner, _weight);
	}

	// Transfer your weight of a given bounty to another party.
	function setRoyaltiesForwardingAddress(uint _bountyId, address _forwardingAddress) public {
		require (royalties[_bountyId].ownerIndicies[msg.sender] != 0, "Sender is not an owner of royalty");
		royalties[_bountyId].forwarderAddresses[msg.sender] = _forwardingAddress;
	}

	function fundRoyalty(uint _bountyId, uint _value) public payable returns (bool) {
	    royalties[_bountyId].initialFunding = msg.value;
		royalties[_bountyId].balance = msg.value;
		royalties[_bountyId].distributionPercent = 1;
		emit RoyaltyFunded(_bountyId, _value);
		return true;
	}

	function distributeRoyaltyFundsSimple(uint _bountyId) {
	    uint _dist = 100;
	    
	    for (uint i = 0; i < royalties[_bountyId].owners.length; i++) {
	        address _owner = royalties[_bountyId].owners[i];

	        require(distributionToken.transfer(royalties[_bountyId].owners[i], _dist));
	        increaseRoyaltiesWon(_owner, _dist);
			emit PayoutGenerated(_bountyId ,_owner, _dist);
	    }
	}
	
	function getRoyaltyOwnerCount(uint _bountyId, uint _index) public view returns (uint) {
	    return royalties[_bountyId].owners.length;
	}
	
    /// @dev getRoyaltyBeneficiary() get royalty beneficiary by index
    /// @param _bountyId the index of the corresponding bounty
    /// @return Returns the beneficiarys' key information
	function getRoyaltyBeneficiary(uint _bountyId, uint _index) public view returns (address, uint) {
	    address _owner = royalties[_bountyId].owners[_index];
	    return (_owner, royalties[_bountyId].ownerWeights[_owner]);
	}
	
  /// @dev getRoyaltyFinances() shows transparent financial information about a royalty
  /// @param _bountyId the index of the corresponding bounty
  /// @return Returns the initial funding, current balance, and distribution data
  function getRoyaltyFinances(uint _bountyId)
      public
      constant
      validateBountyArrayIndex(_bountyId)
      returns (uint, uint, uint)
  {
      return (royalties[_bountyId].initialFunding, royalties[_bountyId].balance, royalties[_bountyId].distributionPercent);
  }
  
  // User Stats
  
  function increaseRoyaltiesWon(address _user, uint _value) internal {
       require(userStats[_user].royaltiesWon + _value > userStats[_user].royaltiesWon);
       userStats[_user].royaltiesWon += _value;
   }
   
   function increaseBountiesWon(address _user, uint _value) internal {
       require(userStats[_user].bountiesWon + _value > userStats[_user].bountiesWon);
       userStats[_user].bountiesWon += _value;
   }
   
   function getUserStats(address _user) public view returns (uint, uint) {
       return (userStats[_user].bountiesWon, userStats[_user].royaltiesWon);
   }
  
  /*
   * Internal functions
   */
   
  /// @dev transitionToState(): transitions the contract to the
  /// state passed in the parameter `_newStage` given the
  /// conditions stated in the body of the function
  /// @param _bountyId the index of the bounty
  /// @param _newStage the new stage to transition to
  function transitionToState(uint _bountyId, BountyStages _newStage)
      internal
  {
      bounties[_bountyId].bountyStage = _newStage;
  }
}
