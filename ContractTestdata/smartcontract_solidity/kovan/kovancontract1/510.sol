/**
 *Submitted for verification at Etherscan.io on 2019-01-21
*/

pragma solidity ^0.4.24;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract IDealsSupport {

// Any user

	/**
	 * @dev Checks whether a deal can be cancelled by merchant
	 * @param _dealIndex deal index
	 * @return whether a deal can be cancelled by merchant
	 */
	function canBeCancelledByMerchant(uint _dealIndex) public view returns(bool);

	/**
	 * @dev Returns affiliate reward info
	 * @param _referenceHash affiliate's reference hash(index)
	 * @param _affiliateRewardIndex affiliate reward index
	 * @return affiliate reward info
	 */
	function getAffiliateRewardInfo(uint _referenceHash, uint _affiliateRewardIndex) public view returns(uint, uint);

	/**
	 * @dev Returns deal index by reference hash
	 * @param _referenceHash affiliate's reference hash(index)
	 * @return deal index
	 */
	function getDealIndex(uint _referenceHash) public view returns(uint);

	/**
	 * @dev Returns dynamic deal info: reference hashes.
	 * @param _dealIndex deal index
	 * @return array of reference hashes in deal
	 */
	function getDynamicDealInfo(uint _dealIndex) public view returns(uint[]);

	/**
	 * @dev Returns reference hash that should be passed in reference links
	 * @param _dealIndex deal index
	 * @param _affiliateAddress affiliate address
	 * @return reference hash
	 */
	function getReferenceHash(uint _dealIndex, address _affiliateAddress) public view returns(uint);

	/**
	 * @dev Checks whether deal is cancelled
	 * @param _dealIndex deal index
	 * @return bool whether deal is cancelled
	 */
	function isDealCancelled(uint _dealIndex) public view returns(bool);

	/**
	 * @dev Checks whether deal is closed
	 * @param _dealIndex deal index
	 * @return bool whether deal is closed
	 */
	function isDealClosed(uint _dealIndex) public view returns(bool);

// Admin

	/**
	 * @dev Blocks/unblocks affiliate. As an admin i would like to block the selected affiliate.
	 * @param _referenceHash affiliate's reference hash(index)
	 * @param _isBlocked whether to block or unblock affiliate
	 */
	function blockAffiliate(uint _referenceHash, bool _isBlocked) public;

	/**
	 * @dev Cancells deal immediately. As an admin I would like to immediately cancel the selected deal in order to prevent fraudulent behaviour.
	 * @notice Will immediately move the selected deal into 'cancelled' state
	 * @param _dealIndex deal index
	 */
	function cancelDealByAdmin(uint _dealIndex) public;
	
	/**
	 * @dev Changes admin address(transfer ownership)
	 * @param _newAdminAddress new admin address
	 */
	function changeAdmin(address _newAdminAddress) public;

// Affiliate

	/**
	 * @dev Withdraws a reward by affiliate. As an affiliate i would like to get my reward for the selected deal in order to get money.
	 * Preconditions:
	 *  1. The Deal index is valid.
	 *  2. Affiliate is not blocked.
	 *  3. The reward amount is non zero for the selected affiliate.
	 *  4. The reward amount is non zero for the selected deal.
	 * @param _dealIndex deal index
	 * Result:
	 *   All reward tokens are transferred from the current MultistageCrowdsale contract to the affiliate.
	 *   The reward amount for the selected affiliate is set to zero.
	 *   The reward amount for the selected deal is decreased.
	 */
	function getMyReward(uint _dealIndex) public;

// Merchant

	/**
	 * @dev Approves affiliate address for deal. As a merchant i would like to manually approve selected affiliate in order to provide incentives.
	 * @notice The same affiliate address can have different reference hashes because the same affiliate address can participate in multiple deals.
	 * @param _dealIndex deal index
	 * @param _affiliateAddress affiliate address
	 */
	function approveAffiliate(uint _dealIndex, address _affiliateAddress) public;

	/**
	 * @dev Cancels all deals by merchant
	 */
	function cancelAllDealsByMerchant() public;

	/**
	 * @dev Marks deal to be cancelled by merchant. As a merchant I would like to request a deal cancelation in order to cancel it after “Cancelation period” is elapsed.
	 * @param _dealIndex deal index
	 */
	function cancelDealByMerchant(uint _dealIndex) public;
	
	/**
	 * @dev Creates a new deal by merchant. As a merchant i would like to create new deal in order to add incentives for affiliates.
	 * @param _rewardTokenAddress ERC20 token address used for affiliates' rewards
	 * @param _rewardRatePpm reward rate ppm, 100% == 1000000
	 * @param _daysOfCancellation when deal is marked as cancelled it is still live for _daysOfCancellation number of days
	 * @param _daysBeforeClose number of days since deal creation when deal is still live, the deal is over and any left over staked tokens can be withdrawn by merchant
	 */
	function createDeal(address _rewardTokenAddress, uint _rewardRatePpm, uint _daysOfCancellation, uint _daysBeforeClose) public;

	/**
	 * @dev Stakes ERC20 tokens as reward for affiliates by merchant. As a merchant i would like to transfer ERC20 tokens to the selected deal in order to stake them.
	 * @notice Merchant should allow _amount of tokens to be withdrawn (use ERC20.approve() method) BEFORE calling this method.
	 * Preconditions:
	 *  1. The Deal was created by Merchant before
	 *  2. isCancelled == false
	 *  3. isClosed == false
	 *  4. Merchant allowed current MultistageCrowdsale to withdraw correct amount of tokens
	 * @param _dealIndex deal index
	 * @param _amount amount in wei
	 */
	function fillStake(uint _dealIndex, uint _amount) public;

	/**
	 * @dev Returns tokens at stake back to merchant if deal is cancelled. As a merchant i would like to get my stake back in order to get my tokens back (if deal is cancelled).
	 * Preconditions:
     *  1. The Deal was created by Merchant before.
     *  2. The Deal isCancelled==true.
     *  3. The Deal still has some stake left.
	 *  4. The Deal has enough tokens to pay to all affiliates.
	 * @param _dealIndex deal index
	 * Result:
     *    All staked reward tokens are transferred from the current MultistageCrowdsale contract back to merchant.
     *    The “Current reward stake amount” of the selected Deal is decreased.
	 */
	function getMyStakeBack(uint _dealIndex) public;

	/**
	 * @dev Updates a deal by merchant
	 * @param _dealIndex deal index
	 * @param _newRewardRatePpm new reward rate ppm, 100% == 1000000
	 */
	function updateDeal(uint _dealIndex, uint _newRewardRatePpm) public;

}

contract DealsSupport is IDealsSupport {
	
	using SafeMath for uint;

	address public adminAddress;
	address public merchantAddress;

	mapping(uint => Affiliate) public affiliates;
	uint public affiliatesCount;

	mapping(uint => Deal) public deals;
	uint public dealsCount;

	mapping(address => uint[]) public affiliateDealIndexes;
	mapping(address => uint) public affiliateDealIndexesCount;

	mapping(uint => mapping(address => uint)) public dealAffiliateReferenceHash;
	mapping(uint => mapping(address => uint)) public dealAffiliateReferenceHashCount;
	mapping(uint => uint) public referenceHashDealIndex;
	
	event ApproveAffiliate(address indexed _merchantAddress, uint indexed _dealIndex, address indexed _affiliateAddress);
	event CreateDeal(address indexed _merchantAddress, address indexed _rewardTokenAddress, uint _rewardRatePpm, uint _daysOfCancellation, uint _daysBeforeClose);

	struct Affiliate {
		address affiliateAddress;
		bool isBlocked;
		uint rewardAmount;
		uint affiliateRewardsCount;
		mapping(uint => AffiliateReward) affiliateRewards;
	}

	struct AffiliateReward {
		uint amount;
		uint createdAt;
	}

	struct Deal {
		address rewardTokenAddress;
		bool isCancelled;
		bool isCancelRequestedByMerchant;
		uint rewardRatePpm;
		uint daysOfCancellation;
		uint daysBeforeClose;
		uint createdAt;
		uint cancelRequestedAt;
		uint initialStakeAmount;
		uint leftStakeAmount;
		uint affiliatesCount;
		uint lockedTokensAmount;
		uint[] referenceHashes;
	}

	/**
	 * Modifiers
	 */

	/**
	 * Checks that deal is still active, not cancelled or closed
	 */
	modifier activeDeal(uint _dealIndex) {
		require(!isDealCancelled(_dealIndex));
		require(!isDealClosed(_dealIndex));
		_;
	}
	
	/**
	 * Checks that method is called by admin
	 */
	modifier onlyAdmin() {
		require(msg.sender == adminAddress);
		_;
	}

	/**
	 * Checks that method is called by merchant
	 */
	modifier onlyMerchant() {
		require(msg.sender == merchantAddress);
		_;
	}

	/**
	 * Modifier checks that deal exists
	 */
	modifier validDealIndex(uint _dealIndex) {
		require(_dealIndex < dealsCount);
		_;
	}

	/**
	 * Modifier checks that affiliate exists
	 */
	modifier validReferenceHash(uint _referenceHash) {
		// _referenceHash == 0 is reserved for usage in invest() method to distinguish whether user came from affiliate, so _referenceHash == 0 means that user didn't come from any affiliate
		require(_referenceHash != 0);
		require(_referenceHash < affiliatesCount);
		_;
	}

	/**
	 * @dev Contract constructor
	 * @param _adminAddress admin address
	 * @param _merchantAddress merchant address
	 */
	constructor(address _adminAddress, address _merchantAddress) public {
		// validation
		require(_adminAddress != address(0));
		require(_merchantAddress != address(0));
		// set contract properties
		adminAddress = _adminAddress;
		merchantAddress = _merchantAddress;
		// start affiliate reference hashes from 1 because 0 reference hash is used in invest() to detect whether user has come from affiliate or not
		affiliatesCount = 1;
	}

	/**
	 * Public methods
	 */
	
	/**
	 * @dev Checks whether a deal can be cancelled by merchant
	 * @param _dealIndex deal index
	 * @return whether a deal can be cancelled by merchant
	 */
	function canBeCancelledByMerchant(uint _dealIndex) public view validDealIndex(_dealIndex) returns(bool) {
		bool canBeCancelled = true;
		if(deals[_dealIndex].isCancelled || deals[_dealIndex].isCancelRequestedByMerchant) {
			canBeCancelled = false;
		}
		return canBeCancelled;
	}

	/**
	 * @dev Returns affiliate reward info
	 * @param _referenceHash affiliate's reference hash(index)
	 * @param _affiliateRewardIndex affiliate reward index
	 * @return affiliate reward info
	 */
	function getAffiliateRewardInfo(uint _referenceHash, uint _affiliateRewardIndex) public view validReferenceHash(_referenceHash) returns(uint, uint) {
		require(_affiliateRewardIndex < affiliates[_referenceHash].affiliateRewardsCount);
		AffiliateReward memory affiliateReward = affiliates[_referenceHash].affiliateRewards[_affiliateRewardIndex];
		return (
			affiliateReward.amount,
			affiliateReward.createdAt
		);
	}

	/**
	 * @dev Returns deal index by reference hash
	 * @param _referenceHash affiliate's reference hash(index)
	 * @return deal index
	 */
	function getDealIndex(uint _referenceHash) public view validReferenceHash(_referenceHash) returns(uint) {
		return referenceHashDealIndex[_referenceHash];
	}

	/**
	 * @dev Returns array of deal indexes where provided affiliate takes part
	 * @param _affiliateAddress affiliate address
	 * @return array of deal indexes
	 */
	function getDealIndexesByAffiliate(address _affiliateAddress) public view returns(uint[]) {
		require(_affiliateAddress != address(0));
		return affiliateDealIndexes[_affiliateAddress];
	}

	/**
	 * @dev Returns dynamic deal info: reference hashes.
	 * @param _dealIndex deal index
	 * @return array of reference hashes in deal
	 */
	function getDynamicDealInfo(uint _dealIndex) public view validDealIndex(_dealIndex) returns(uint[]) {
		return deals[_dealIndex].referenceHashes;
	}

	/**
	 * @dev Returns reference hash that should be passed in reference links
	 * @param _dealIndex deal index
	 * @param _affiliateAddress affiliate address
	 * @return reference hash
	 */
	function getReferenceHash(uint _dealIndex, address _affiliateAddress) public view validDealIndex(_dealIndex) returns(uint) {
		// validation
		require(_affiliateAddress != address(0));
		require(dealAffiliateReferenceHashCount[_dealIndex][_affiliateAddress] == 1);
		// return reference hash
		return dealAffiliateReferenceHash[_dealIndex][_affiliateAddress];
	}

	/**
	 * @dev Returns reference hash info: affiliate address and deal index
	 * @param _referenceHash affiliate's reference hash(index)
	 * @return affiliate address and deal index
	 */
	function getReferenceHashInfo(uint _referenceHash) public view validReferenceHash(_referenceHash) returns (address, uint) {
		return (
			affiliates[_referenceHash].affiliateAddress,
			referenceHashDealIndex[_referenceHash]
		);
	}

	/**
	 * @dev Checks whether deal is cancelled
	 * @param _dealIndex deal index
	 * @return bool whether deal is cancelled
	 */
	function isDealCancelled(uint _dealIndex) public view validDealIndex(_dealIndex) returns(bool) {
		bool isCancelled = false;
		Deal memory deal = deals[_dealIndex];
		if(deal.isCancelled) {
			isCancelled = true;
		}
		if(deal.isCancelRequestedByMerchant && ((now - deal.cancelRequestedAt) >= (deal.daysOfCancellation * 24 * 60 * 60))) {
			isCancelled = true;
		}
		return isCancelled;
	}

	/**
	 * @dev Checks whether deal is closed
	 * @param _dealIndex deal index
	 * @return bool whether deal is closed
	 */
	function isDealClosed(uint _dealIndex) public view validDealIndex(_dealIndex) returns(bool) {
		bool isClosed = false;
		Deal memory deal = deals[_dealIndex];
		if((now - deal.createdAt) >= (deal.daysBeforeClose * 24 * 60 * 60)) {
			isClosed = true;
		}
		return isClosed;
	}

	/**
	 * Admin methods
	 */

	/**
	 * @dev Blocks/unblocks affiliate. As an admin i would like to block the selected affiliate.
	 * @param _referenceHash affiliate's reference hash(index)
	 * @param _isBlocked whether to block or unblock affiliate
	 */
	function blockAffiliate(uint _referenceHash, bool _isBlocked) public onlyAdmin validReferenceHash(_referenceHash) {
		affiliates[_referenceHash].isBlocked = _isBlocked;
	}

	/**
	 * @dev Cancells deal immediately. As an admin I would like to immediately cancel the selected deal in order to prevent fraudulent behaviour.
	 * @notice Will immediately move the selected deal into 'cancelled' state
	 * @param _dealIndex deal index
	 */
	function cancelDealByAdmin(uint _dealIndex) public onlyAdmin validDealIndex(_dealIndex) {
		deals[_dealIndex].isCancelled = true;
	}
	
	/**
	 * @dev Changes admin address(transfer ownership)
	 * @param _newAdminAddress new admin address
	 */
	function changeAdmin(address _newAdminAddress) public onlyAdmin {
		require(_newAdminAddress != address(0));
		adminAddress = _newAdminAddress;
	}

	/**
	 * Affiliate methods
	 */

	/**
	 * @dev Withdraws a reward by affiliate. As an affiliate i would like to get my reward for the selected deal in order to get money.
	 * Preconditions:
	 *  1. The Deal index is valid.
	 *  2. Affiliate is not blocked.
	 *  3. The reward amount is non zero for the selected affiliate.
	 *  4. The reward amount is non zero for the selected deal.
	 * @param _dealIndex deal index
	 * Result:
     *   All reward tokens are transferred from the current MultistageCrowdsale contract to the affiliate.
	 *   The reward amount for the selected affiliate is set to zero.
	 *   The reward amount for the selected deal is decreased.
	 */
	function getMyReward(uint _dealIndex) public validDealIndex(_dealIndex) {
		// validation
		uint referenceHash = getReferenceHash(_dealIndex, msg.sender);
		require(!affiliates[referenceHash].isBlocked);
		require(affiliates[referenceHash].rewardAmount > 0);
		require(deals[_dealIndex].leftStakeAmount >= affiliates[referenceHash].rewardAmount);
		// update deal properties
		deals[_dealIndex].leftStakeAmount = deals[_dealIndex].leftStakeAmount.sub(affiliates[referenceHash].rewardAmount);
		// transfer reward tokens to affiliate
		uint tokenAmountToTransfer = affiliates[referenceHash].rewardAmount;
		affiliates[referenceHash].rewardAmount = 0;
		ERC20(deals[_dealIndex].rewardTokenAddress).transfer(affiliates[referenceHash].affiliateAddress, tokenAmountToTransfer);
	}

	/**
	 * Merchant methods
	 */

	/**
	 * @dev Approves affiliate address for deal. As a merchant i would like to manually approve selected affiliate in order to provide incentives.
	 * @notice The same affiliate address can have different reference hashes because the same affiliate address can participate in multiple deals.
	 * @param _dealIndex deal index
	 * @param _affiliateAddress affiliate address
	 */
	function approveAffiliate(uint _dealIndex, address _affiliateAddress) public onlyMerchant validDealIndex(_dealIndex) activeDeal(_dealIndex) {
		// validation
		require(_affiliateAddress != address(0));
		// check that affiliate is not yet approved for this deal
		require(dealAffiliateReferenceHashCount[_dealIndex][_affiliateAddress] == 0);
		// create affiliate
		Affiliate memory affiliate;
		affiliate.affiliateAddress = _affiliateAddress;
		// add affiliate to global affiliates property
		affiliates[affiliatesCount] = affiliate;
		// add affliate to deal
		deals[_dealIndex].referenceHashes.push(affiliatesCount);
		deals[_dealIndex].affiliatesCount = deals[_dealIndex].affiliatesCount.add(1);
		// add deal to affiliate
		affiliateDealIndexes[_affiliateAddress].push(_dealIndex);
		affiliateDealIndexesCount[_affiliateAddress] = affiliateDealIndexesCount[_affiliateAddress].add(1);
		// update globals affiliates count
		dealAffiliateReferenceHash[_dealIndex][_affiliateAddress] = affiliatesCount;
		dealAffiliateReferenceHashCount[_dealIndex][_affiliateAddress] = 1;
		referenceHashDealIndex[affiliatesCount] = _dealIndex;
		affiliatesCount = affiliatesCount.add(1);
		// emitting event
		emit ApproveAffiliate(msg.sender, _dealIndex, _affiliateAddress);
	}

	/**
	 * @dev Cancels all deals by merchant
	 */
	function cancelAllDealsByMerchant() public onlyMerchant {
		for(uint i = 0; i < dealsCount; i++) {
			if(canBeCancelledByMerchant(i)) {
				cancelDealByMerchant(i);
			}
		}
	}

	/**
	 * @dev Marks deal to be cancelled by merchant. As a merchant I would like to request a deal cancelation in order to cancel it after “Cancelation period” is elapsed.
	 * @param _dealIndex deal index
	 */
	function cancelDealByMerchant(uint _dealIndex) public onlyMerchant validDealIndex(_dealIndex) {
		// validation
		require(canBeCancelledByMerchant(_dealIndex));
		// mark deal to be cancelled
		deals[_dealIndex].isCancelRequestedByMerchant = true;
		deals[_dealIndex].cancelRequestedAt = now;
	}
	
	/**
	 * @dev Creates a new deal by merchant. As a merchant i would like to create new deal in order to add incentives for affiliates.
	 * @param _rewardTokenAddress ERC20 token address used for affiliates' rewards
	 * @param _rewardRatePpm reward rate ppm, 100% == 1000000
	 * @param _daysOfCancellation when deal is marked as cancelled it is still live for _daysOfCancellation number of days
	 * @param _daysBeforeClose number of days since deal creation when deal is still live, the deal is over and any left over staked tokens can be withdrawn by merchant
	 */
	function createDeal(address _rewardTokenAddress, uint _rewardRatePpm, uint _daysOfCancellation, uint _daysBeforeClose) public onlyMerchant {
		// validation
		require(_rewardTokenAddress != address(0));
		require(_rewardRatePpm > 0);
		require(_daysOfCancellation <= 90);
		require(_daysBeforeClose > 0);
		require(_daysBeforeClose <= 90);
		// create a new deal
		Deal memory deal;
		deal.rewardTokenAddress = _rewardTokenAddress;
		deal.rewardRatePpm = _rewardRatePpm;
		deal.daysOfCancellation = _daysOfCancellation;
		deal.daysBeforeClose = _daysBeforeClose;
		deal.createdAt = now;
		deals[dealsCount] = deal;
		// update contract properties
		dealsCount = dealsCount.add(1);
		// emitting event
		emit CreateDeal(msg.sender, _rewardTokenAddress, _rewardRatePpm, _daysOfCancellation, _daysBeforeClose);
	}

	/**
	 * @dev Stakes ERC20 tokens as reward for affiliates by merchant. As a merchant i would like to transfer ERC20 tokens to the selected deal in order to stake them.
	 * @notice Merchant should allow _amount of tokens to be withdrawn (use ERC20.approve() method) BEFORE calling this method.
	 * Preconditions:
	 *  1. The Deal was created by Merchant before
	 *  2. isCancelled == false
	 *  3. isClosed == false
	 *  4. Merchant allowed current MultistageCrowdsale to withdraw correct amount of tokens
	 * @param _dealIndex deal index
	 * @param _amount amount in wei
	 */
	function fillStake(uint _dealIndex, uint _amount) public onlyMerchant validDealIndex(_dealIndex) activeDeal(_dealIndex) {
		// validation
		require(_amount > 0);
		ERC20 rewardToken = ERC20(deals[_dealIndex].rewardTokenAddress);
		require(rewardToken.allowance(msg.sender, address(this)) >= _amount);
		// stake tokens for affiliates' rewards
		deals[_dealIndex].initialStakeAmount = deals[_dealIndex].initialStakeAmount.add(_amount);
		deals[_dealIndex].leftStakeAmount = deals[_dealIndex].leftStakeAmount.add(_amount);
		rewardToken.transferFrom(msg.sender, address(this), _amount);
	}

	/**
	 * @dev Returns tokens at stake back to merchant if deal is cancelled. As a merchant i would like to get my stake back in order to get my tokens back (if deal is cancelled).
	 * Preconditions:
	 *  1. The Deal was created by Merchant before.
	 *  2. The Deal isCancelled==true.
	 *  3. The Deal still has some stake left.
	 *  4. The Deal has enough tokens to pay to all affiliates.
	 * @param _dealIndex deal index
	 * Result:
	 *    All staked reward tokens are transferred from the current MultistageCrowdsale contract back to merchant.
	 *    The “Current reward stake amount” of the selected Deal is decreased.
	 */
	function getMyStakeBack(uint _dealIndex) public onlyMerchant validDealIndex(_dealIndex) {
		// validation
		require(isDealCancelled(_dealIndex));
		require(deals[_dealIndex].leftStakeAmount > 0);
		require(deals[_dealIndex].lockedTokensAmount < deals[_dealIndex].initialStakeAmount);
		// transfer ERC20 tokens back to merchant
		uint tokenAmountToWithdraw = deals[_dealIndex].leftStakeAmount;
		deals[_dealIndex].leftStakeAmount = 0;
		ERC20(deals[_dealIndex].rewardTokenAddress).transfer(msg.sender, tokenAmountToWithdraw);
	}

	/**
	 * @dev Updates a deal by merchant
	 * @param _dealIndex deal index
	 * @param _newRewardRatePpm new reward rate ppm, 100% == 1000000
	 */
	function updateDeal(uint _dealIndex, uint _newRewardRatePpm) public onlyMerchant validDealIndex(_dealIndex) activeDeal(_dealIndex) {
		require(_newRewardRatePpm > 0);
		deals[_dealIndex].rewardRatePpm = _newRewardRatePpm;
	}

	/**
	 * Internal methods
	 */
	
	/**
	 * @dev Increases affiliate's reward amount
	 * @param _referenceHash affiliate's reference hash(index/referenceHash that is passed to invest() function)
	 */
	function _rewardAffiliate(uint _referenceHash) internal validReferenceHash(_referenceHash) {
		// get deal index by reference hash
		uint dealIndex = getDealIndex(_referenceHash);
		// calculate reward amount for affiliate
		uint rewardAmount = deals[dealIndex].initialStakeAmount.div(1000000).mul(deals[dealIndex].rewardRatePpm);
		// add affiliate reward to affiliate
		AffiliateReward memory affiliateReward;
		affiliateReward.amount = rewardAmount;
		affiliateReward.createdAt = now;
		affiliates[_referenceHash].affiliateRewards[affiliates[_referenceHash].affiliateRewardsCount] = affiliateReward;
		affiliates[_referenceHash].affiliateRewardsCount = affiliates[_referenceHash].affiliateRewardsCount.add(1);
		// update affiliate reward amount
		affiliates[_referenceHash].rewardAmount = affiliates[_referenceHash].rewardAmount.add(rewardAmount);
		// update deal's locked token balance
		deals[dealIndex].lockedTokensAmount = deals[dealIndex].lockedTokensAmount.add(rewardAmount);
	}

}

contract MultistageCrowdsale is DealsSupport {
  using SafeMath for uint256;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param affiliate address, if any
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   * @param orderID to be used with fiat payments
   */
  event TokenPurchase(address indexed purchaser, address indexed affiliate, uint256 value, uint256 amount, bytes4 indexed orderID);

  struct Stage {
    uint32 time;
    uint64 rate;
  }

  Stage[] stages;

  address wallet;
  address token;
  address signer;
  uint32 saleEndTime;

  /**
   * @dev The constructor that takes all parameters
   * @param _timesAndRates An array that defines the stages of the contract. the first entry being the start time of the sale, followed by pairs of rates ond close times of consequitive stages.
   *       Example 1: [10000, 99, 12000]
   *         A single stage sale that starts at unix time 10000 and ends 2000 seconds later.
   *         This sale gives 99 tokens for each Gwei invested.
   *       Example 2: [10000, 99, 12000, 88, 14000]
   *         A 2 stage sale that starts at unix time 10000 and ends 4000 seconds later.
   *         The sale reduces the rate at mid time
   *         This sale gives 99 tokens for each Gwei invested in first stage.
   *         The sale gives 88 tokens for each Gwei invested in second stage.
   * @param _wallet The address of the wallet where invested Ether will be send to
   * @param _token The tokens that the investor will receive
   * @param _signer The address of the key that whitelists investor (operator key)
   */
  constructor(
    uint256[] _timesAndRates,
    address _wallet,
    address _token,
    address _signer
  )
    public
    DealsSupport(msg.sender, msg.sender)
  {
    require(_wallet != address(0));
    require(_token != address(0));

    storeStages(_timesAndRates);

    saleEndTime = uint32(_timesAndRates[_timesAndRates.length - 1]);
    // check sale ends after last stage opening time
    require(saleEndTime > stages[stages.length - 1].time);

    wallet = _wallet;
    token = _token;
    signer = _signer;
  }

  /**
   * @dev called by investors to purchase tokens
   * @param _r part of receipt signature
   * @param _s part of receipt signature
   * @param _a first payload of signed receipt.
   * @param _b second payload of signed receipt.
   *   The receipt commits to the follwing inputs:
   *     56 bits - sale contract address, to prevent replay of receipt
   *     32 bits - orderID for fiat payments
   *     160 bits - beneficiary address - address whitelisted to receive tokens
   *     32 bits - time - when receipt was signed
   *     64 bits - oobpa - out of band payment amount, for fiat investments
   *     32 bits - reference hash
   */

  function invest(bytes32 _r, bytes32 _s, bytes32 _a, bytes32 _b) public payable {
    // parse inputs
    uint32 time = uint32(_b >> 224);
    address beneficiary = address(_a);
    uint256 oobpa = uint64(_b >> 160);
    uint256 referenceHash = uint256(_b << 96 >> 224);

    // verify inputs
    require(uint56(_a >> 192) == uint56(this));
    if (oobpa == 0) {
      oobpa = msg.value;
    } else {
      oobpa = oobpa.mul(1000000000);  // convert oobpa to wei
    }
    bytes4 orderID = bytes4(uint32(_a >> 160));
    /* solium-disable-next-line arg-overflow */
    require(ecrecover(keccak256(abi.encodePacked(uint8(0), uint248(_a), _b)), uint8(_a >> 248), _r, _s) == signer);
    require(beneficiary != address(0));

    // calculate token amount to be created
    uint256 rate = getRateAt(now); // solium-disable-line security/no-block-members
    // at the time of signing the receipt the rate should have been the same as now
    require(rate == getRateAt(time));
    // multiply rate with Gwei of investment
    uint256 tokens = rate.mul(oobpa).div(1000000000);
    // check that msg.value > 0
    require(tokens > 0);

    // pocket Ether
    if (msg.value > 0) {
      wallet.transfer(oobpa);
    }

    // if user came from affiliate then reward affiliate
    address affiliate = address(0);
    if(referenceHash != 0) {
        affiliate = affiliates[referenceHash].affiliateAddress;
        _rewardAffiliate(referenceHash);
    }
	
    // do token transfer
    ERC20(token).transferFrom(wallet, beneficiary, tokens);
    emit TokenPurchase(beneficiary, affiliate, oobpa, tokens, orderID);
  }

  function getParams() view public returns (uint256[] _times, uint256[] _rates, address _wallet, address _token, address _signer) {
    _times = new uint256[](stages.length + 1);
    _rates = new uint256[](stages.length);
    for (uint256 i = 0; i < stages.length; i++) {
      _times[i] = stages[i].time;
      _rates[i] = stages[i].rate;
    }
    _times[stages.length] = saleEndTime;
    _wallet = wallet;
    _token = token;
    _signer = signer;
  }

  function storeStages(uint256[] _timesAndRates) internal {
    // check odd amount of array elements, tuples of rate and time + saleEndTime
    require(_timesAndRates.length % 2 == 1);
    // check that at least 1 stage provided
    require(_timesAndRates.length >= 3);

    for (uint256 i = 0; i < _timesAndRates.length / 2; i++) {
      stages.push(Stage(uint32(_timesAndRates[i * 2]), uint64(_timesAndRates[(i * 2) + 1])));
      if (i > 0) {
        // check that each time higher than previous time
        require(stages[i-1].time < stages[i].time);
        // check that each rate is lower than previous rate
        require(stages[i-1].rate > stages[i].rate);
      }
    }

    // check that opening time in the future
    require(stages[0].time > now); // solium-disable-line security/no-block-members

    // check final rate > 0
    require(stages[stages.length - 1].rate > 0);
  }

  function getRateAt(uint256 _now) view internal returns (uint256 rate) {
    // if before first stage, return 0
    if (_now < stages[0].time) {
      return 0;
    }

    for (uint i = 1; i < stages.length; i++) {
      if (_now < stages[i].time)
        return stages[i - 1].rate;
    }

    // handle last stage
    if (_now < saleEndTime)
      return stages[stages.length - 1].rate;

    // sale already closed
    return 0;
  }

// Deals overrides:
  /*
  function isMerchant(address _a) public view returns(bool){
    // TODO: implement
    // Who is Merchnat in this case? Who deployed current contract or who owns current contract?
    return false;
  }
  */
}

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
