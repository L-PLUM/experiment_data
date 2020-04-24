/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
        internal
    {
        require(token.transfer(to, value), "Transfer must be successful.");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
        internal
    {
        require(token.transferFrom(from, to, value), "Transfer must be successful.");
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
        internal
    {
        require(token.approve(spender, value), "Approve must be successful.");
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
      * @dev Multiplies two numbers, reverts on overflow.
      */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Multiplication failed.");

        return c;
    }

    /**
      * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
      */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Division failed."); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
      * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
      */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction failed.");
        uint256 c = a - b;

        return c;
    }

    /**
      * @dev Adds two numbers, reverts on overflow.
      */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition failed.");

        return c;
    }

    /**
      * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
      * reverts when dividing by zero.
      */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Modulus operation failed.");
        return a % b;
    }
}


/** @title ReferalCrowdtainer
  * @dev Allows parties to participate in a crowdsale of coffee with ERC20 tokens. Includes a referal program for discounts ands rewards in purchases.
  */
contract ReferalCrowdtainer {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    // The ERC20 token used to participate in the crowdfunding.
    IERC20 public token;

    // Address where funds are collected
    address public wallet;

    // Price table for each type of coffee.
    // Maps CoffeType to number of ERC20 tokens per 1g of coffee.
    uint[] public pricePerGram;

    // The total amount in grams of a type of coffee that a contributor will receive
    // if the crowdfunding is sucessful.
    mapping(address => mapping(uint => uint)) public amountBought;

    // The kyc manager address
    address public kycManager;

    // Is the event finalized.
    bool public finalized = false;

    // Minimum amount of grams to be raised
    uint public goalGrams;

    // The amount of coffee sold in grams.
    uint public amountSold = 0;

    // Are refunds enabled.
    bool public refundsEnabled = false;

    // True if crowdfunding was successful and finalize was called.
    bool public rewardsEnabled = false;

    // Number of ERC20 tokens rewarded to accounts through the referal program. 18 decimal places
    // of precision. This value will be left behind to be claimed by the awarded accounts if
    // the crowdfunding is successful.
    uint public amountRewarded;

    // Percentage of discount a user gets for refering to a previous buyer.
    // See `calculateDiscount` for more information. 10 == 10%
    uint public discount;

    // Percentage of reward a user gets being referd to by a new buyer. 10 == 10%
    // See `calculateReward` for more information.
    uint public reward;
    uint public openingTime;
    uint public closingTime;
    uint public constant BASE_AMOUNT = 500;
	bool public paused;
    address public pauser;

    // Number of ERC20 tokens sent by an address.
    mapping(address => uint) public amountPaid;

    // Maps nicknames to accounts for ease of refering.
    mapping(string => address) nicknameToOwner;

	struct Participant {
        string nickname; // The participant nickname.
        uint rewardBalance; // Rewards accquired from being refered to in number of ERC20.
        bool optedInReferal; // Weather this user has opted into the referal program.
    }

    // Maps addresses to participant data.
    mapping(address => Participant) public participants;

	/*   Events   */

    event BoughtCoffee(address indexed _beneficiary, uint indexed _coffeeType, uint _amountGrams);
    event DiscountedPurchase(address indexed _beneficiary, uint _discount);
    event RefundClaimed(address indexed _beneficiary, uint _amount);
    event AccountRewarded(address indexed _beneficiary, uint _reward);
    event RewardClaimed(address indexed _beneficiary, uint _reward);
    event Finalized();
    event FundsForwarded(address _wallet);
    event Paused();
    event Unpaused();

	/*   Modifiers   */

    modifier whileNotPaused() {
        require(!paused, "Only callable when not paused.");
        _;
    }

    modifier whileOpen {
        require(isOpen(), "Only callable if in crowdfunding time range");
        _;
    }

    modifier whilePaused() {
        require(paused, "Only callable when paused.");
        _;
    }

	modifier onlyPauser() {
        require(msg.sender == pauser, "Only pauser is allowed to call this function.");
        _;
    }

    modifier onlyKycManager() {
        require(msg.sender == kycManager, "Only KYC manager may call this function.");
        _;
    }

    modifier onlyAuthorizedByKyc(bytes memory _signature) {
        require(isCallerAuthorizedByKyc(_signature), "KYC signature check failed.");
        _;
    }

    /** @param _openingTime crowdfunding opening time
      * @param _closingTime crowdfunding closing time
      * @param _goalGrams The amount of grams to be raised for the crowdfunding to be considered to be successful.
      * @param _pricePerGram The prices of different coffee types in number of ERC2O. The price should be given in the number of smallest unit for precision (e.g 10^18 == 1 DAI).
      * @param _discount The discount percentage to be received for using the referal system.
      * @param _reward The reward percentage to be given for being refered to by a buyer.
      * @param _kycManager The address of the authority authorizing buyers.
      * @param _wallet The that will receive funds if the crowdfunding is sucessful.
      * @param _token Address of the ERC20 token used for payment.
      */
    constructor (
        uint _openingTime,
        uint _closingTime,
        uint _goalGrams,
        uint[] memory _pricePerGram,
        uint _discount,
        uint _reward,
        address _kycManager,
        address _wallet,
        IERC20 _token
    )
      public
    {
        require(address(_token) != address(0), "A token for payments must be specified.");
        require(address(_wallet) != address(0), "An address for forwarding funds must be specified.");
        require(_closingTime >= _openingTime, "Closing time should be after opening time.");
        require(_kycManager != address(0), "A KYC manager address must be specified.");
        require(_goalGrams > 0, "Goal should be above zero.");

        goalGrams = _goalGrams;
        kycManager = _kycManager;
        openingTime = _openingTime;
        closingTime = _closingTime;
        pricePerGram = _pricePerGram;
        wallet = _wallet;
        token = _token;
        pauser = msg.sender;
        paused = true;
        discount = _discount;
        reward = _reward;
    }

	/** @dev Allows an authorized user to participate in the coffee crowdsale with ERC20. TRUSTED.
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _agreedPricePerGram The price per 1g of coffee agreed.
      * @param _signature KYC's signature.
      */
    function buyCoffee(
        uint _coffeeType,
        uint _amountToBuy,
        uint _agreedPricePerGram,
        bytes memory _signature
    )
        public
		whileOpen
      	whileNotPaused
      	onlyAuthorizedByKyc(_signature)
    {
        require(_coffeeType < pricePerGram.length, "Must be a valid coffee type.");
        require(
            _amountToBuy >= BASE_AMOUNT,
            "Amount of coffee being bought must be greater than the base amount."
        );
        require(
            _agreedPricePerGram == pricePerGram[_coffeeType],
            "Offered and requested prices must match."
        );
        require(_amountToBuy.mod(BASE_AMOUNT) == 0, "Amount to buy must be a multiple of the base amount.");

        uint totalERC20Cost = calculateCost(_amountToBuy, _coffeeType);

        amountSold = amountSold.add(_amountToBuy);
        amountPaid[msg.sender] = amountPaid[msg.sender].add(totalERC20Cost);
        amountBought[msg.sender][_coffeeType] = amountBought[msg.sender][_coffeeType].add(_amountToBuy);
        token.safeTransferFrom(msg.sender, address(this), totalERC20Cost);

        emit BoughtCoffee(msg.sender, _coffeeType, _amountToBuy);
    }

	/** @dev Allows an authorized account to participate and opt into the referal program. TRUSTED.
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _pricePerGram The price per 1g of coffee agreed.
      * @param _newNickname The caller's chosen nickname.
      * @param _signature KYC's signature.
      */
    function buyCoffeeSetNickname(
        uint _coffeeType,
        uint _amountToBuy,
        uint _pricePerGram,
        string calldata _newNickname,
        bytes calldata _signature
    )
        external
    {
		require(bytes(_newNickname).length >= 4, "Nickname must not be too small.");
        require(bytes(_newNickname).length <= 32, "Nickname must not be too big.");
        require(nicknameToOwner[_newNickname] == address(0x0), "Nickname must not be taken.");

		// Make any previously owned nickname available.
        string memory previousNickname = participants[msg.sender].nickname;
        nicknameToOwner[previousNickname] = address(0x0);

        // Save caller as the nickname owner.
        nicknameToOwner[_newNickname] = msg.sender;

        // Update participant data.
        participants[msg.sender].nickname = _newNickname;

        // Mark participant as having opted into the referal program.
        participants[msg.sender].optedInReferal = true;

        buyCoffee(_coffeeType, _amountToBuy, _pricePerGram, _signature);
    }

	/** @dev Allows an authorized user to participate in discounted coffee crowdsale. TRUSTED.
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _agreedPricePerGram The price per 1g of coffee agreed.
      * @param _previousBuyerNickname A previous buyer nickname. Used to get a discount through the referal program.
      * @param _signature KYC's signature.
      */
    function buyDiscountedCoffee(
        uint _coffeeType,
        uint _amountToBuy,
        uint _agreedPricePerGram,
        string memory _previousBuyerNickname,
        bytes memory _signature
    )
        public
		whileOpen
		whileNotPaused
		onlyAuthorizedByKyc(_signature)
    {
        address previousBuyer = nicknameToOwner[_previousBuyerNickname];
        require(previousBuyer != address(0x0), "Refered account must be valid.");
        require(participants[previousBuyer].optedInReferal, "Previous buyer must have participated.");
        require(_coffeeType < pricePerGram.length, "Must be a valid coffee type.");
        require(
            _amountToBuy >= BASE_AMOUNT,
            "Amount of coffee being bought must be greater than the base amount."
        );
        require(
            _agreedPricePerGram == pricePerGram[_coffeeType],
            "Offered and requested prices must match."
        );
        require(
			_amountToBuy.mod(BASE_AMOUNT) == 0,
			"Amount to buy must be a multiple of the base amount."
		);

        uint totalERC20Cost = calculateCost(_amountToBuy, _coffeeType);
        uint totalDiscount = calculateDiscount(totalERC20Cost);
        uint totalReward = calculateReward(totalERC20Cost);
        uint discountedCost = totalERC20Cost.sub(totalDiscount);

        participants[previousBuyer].rewardBalance = participants[previousBuyer].rewardBalance.add(totalReward);
        amountRewarded = amountRewarded.add(totalReward);
        amountSold = amountSold.add(_amountToBuy);
        amountPaid[msg.sender] = amountPaid[msg.sender].add(discountedCost);
        amountBought[msg.sender][_coffeeType] = amountBought[msg.sender][_coffeeType].add(_amountToBuy);
        token.safeTransferFrom(msg.sender, address(this), discountedCost);

        emit BoughtCoffee(msg.sender, _coffeeType, _amountToBuy);
		emit AccountRewarded(previousBuyer, totalReward);
        emit DiscountedPurchase(msg.sender, totalDiscount);
    }

    /** @dev Allows an authorized user to participate in the discounted coffee crowdsale and opt into the referal program. TRUSTED.
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _pricePerGram The price per 1g of coffee agreed.
      * @param _previousBuyerNickname A previous buyer nickname. Used to get a discount.
      * @param _newNickname This callers chosen nickname.
      * @param _signature KYC's signature.
      */
    function buyDiscountedCoffeeSetNickname(
        uint _coffeeType,
        uint _amountToBuy,
        uint _pricePerGram,
        string calldata _previousBuyerNickname,
        string calldata _newNickname,
        bytes calldata _signature
    )
        external
    {
		require(bytes(_newNickname).length >= 4, "Nickname must not be too small.");
        require(bytes(_newNickname).length <= 32, "Nickname must not be too big.");
        require(nicknameToOwner[_newNickname] == address(0x0), "Nickname must not be taken");

		// Make any previously used nickname available.
        string memory previousNickname = participants[msg.sender].nickname;
        nicknameToOwner[previousNickname] = address(0x0);

        // Save this user as the nickname owner.
        nicknameToOwner[_newNickname] = msg.sender;

        // Update participant data.
        participants[msg.sender].nickname = _newNickname;

        // Mark participant as opted into the referal program.
        participants[msg.sender].optedInReferal = true;

        buyDiscountedCoffee(_coffeeType, _amountToBuy, _pricePerGram, _previousBuyerNickname, _signature);
    }

	/** @dev Must be called after crowdfunding ends, to do some extra finalization work.
      */
    function finalize() external {
        require(!finalized, "Crowdfunding must not be finalized.");
        require(hasClosed(), "Crowdfunding must have closed.");

		if (wasGoalReached()) {
            rewardsEnabled = true;
			uint amountRaised = token.balanceOf(address(this)).sub(amountRewarded);
        	token.safeTransfer(wallet, amountRaised);
        } else {
            refundsEnabled = true;
        }

        finalized = true;

        emit Finalized();
    }

    /** @dev Allows an authorized user to receive rewards if the crowdfunding is succesful. TRUSTED.
      * @param _beneficiary The receiver of rewards.
      */
    function claimReward(address _beneficiary) external {
        require(participants[_beneficiary].rewardBalance > 0, "Beneficiary must have a positive balance");
		require(finalized, "Crowdtainer should be finalized.");
        require(hasClosed(), "Crowdsale must have closed.");
        require(wasGoalReached(), "Goal must have been reached.");
        require(rewardsEnabled, "Rewards should be enabled.");

        uint amountDue = participants[_beneficiary].rewardBalance;
        participants[_beneficiary].rewardBalance = 0;
        token.safeTransfer(_beneficiary, amountDue);

        emit RewardClaimed(_beneficiary, amountDue);
    }

	/** @dev Allows withdrawing refunds if the crowdsale is unsuccessful.
      * @param _beneficiary Whose refund will be claimed.
      */
    function claimRefund(address _beneficiary)	external {
        require(hasClosed(), "Crowdsale must have closed.");
        require(!wasGoalReached(), "Goal must have not been reached.");
        require(finalized, "Crowdtainer should be finalized.");
        require(refundsEnabled, "Refunds should be enabled.");
        require(!paused, "Only callable if not paused.");

        uint amountDue = amountPaid[_beneficiary];
        amountPaid[_beneficiary] = 0;
        token.safeTransfer(_beneficiary, amountDue);

        emit RefundClaimed(_beneficiary, amountDue);
    }

    /** @dev Prevents future buyers from refering to this account. Any rewards will still
      * be available to be claimed if the crowdfunding is successful.
      */
    function optOutOfReferral() external {
        participants[msg.sender].optedInReferal = false;
    }

	/**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() external onlyPauser whileNotPaused {
        paused = true;
        emit Paused();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() external onlyPauser whilePaused {
        paused = false;
        emit Unpaused();
    }

    /** @dev Returns the total cost for a price.
      * @param _amountToBuy The amount of coffee in grams.
      * @param _coffeeType The coffee type.
      * @return The total cost to buy an amount of a coffee type.
      */
    function calculateCost (uint _amountToBuy, uint _coffeeType) public view returns (uint cost) {
        require(_coffeeType < pricePerGram.length, "Must be a valid coffee type");
        return _amountToBuy.mul(pricePerGram[_coffeeType]);
    }

    /** @dev returns the amount of a coffee type an address acquired.
      * @param _contributor The address of the user who participated.
      * @param _coffeeType The coffee type we want to check for.
      * @return The amount of coffee the contributor acquired.
      */
    function getAmountBought(address _contributor, uint _coffeeType)
        external
        view
        returns (uint amount)
    {
        return amountBought[_contributor][_coffeeType];
    }

    /** @param _nickname The nickname we want to query for.
      * @return The owner of the nickname.
      */
    function nicknameOwner(string calldata _nickname) external view returns (address owner) {
        return nicknameToOwner[_nickname];
    }

    /** @return the number of coffee types available.
      */
    function getNumberOfCoffeeTypes() external view returns (uint numberOfCoffeeTypes) {
        return pricePerGram.length;
    }

    /** @return True if the crowdfunding is open, false otherwise.
      */
    function isOpen() public view returns (bool open) {
        return block.timestamp >= openingTime && block.timestamp <= closingTime;
    }

    /** @dev Checks whether the period in which the crowdfunding is open has already passed.
      * @return Whether crowdfunding period has passed.
      */
    function hasClosed() public view returns (bool closed) {
        return block.timestamp > closingTime;
    }

    /** @return Whether funding goal was reached
      */
    function wasGoalReached() public view returns (bool goalReached) {
        return amountSold >= goalGrams;
    }

    /** @dev Calculates the discount received by a buyer for refering to a new buyer.
      * @param _totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be discounted. 18 decimal places of precision.
      */
    function calculateDiscount(uint _totalERC20Cost) public view returns (uint amount) {
        return _totalERC20Cost.mul(discount).div(100);
    }

    /** @dev Calculates the reward received by a previous buyer for being refered to by a new buyer.
      * @param _totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be rewarded. 18 decimal places of precision.
      */
    function calculateReward(uint _totalERC20Cost) public view returns (uint amount) {
        return _totalERC20Cost.mul(reward).div(100);
    }

    /** @param _account The account we want to query.
      * @return True if the account has participated in the contribution previously.
      */
    function isParticipatingInReferal(address _account)
        external
        view
        returns (bool isParticipatingInReferral)
    {
        return participants[_account].optedInReferal;
    }

    /** @param _account The account we want to query
      * @return An array with participant information: [nickname, rewardBalance, optedInReferal]
      */
    function getParticipantInfo(address _account)
        external
        view
        returns (string memory nickname, uint rewardBalance, bool optedInReferal)
    {
        Participant memory participant = participants[_account];
        return (participant.nickname, participant.rewardBalance, participant.optedInReferal);
    }

    /** @dev Checks that a signature by the `kycManager` authorizes `msg.sender`.
      * @param _signature The signature.
      * @return True if the hash was signed by the kycManager.
      */
    function isCallerAuthorizedByKyc(bytes memory _signature)
        public
        view
        returns (bool authorizedByKyc)
    {
        string memory strAddr = _addrToString(msg.sender);
        bytes32 hashedAddress = keccak256(abi.encodePacked("0x",strAddr));

        bytes memory prefixedMsg = abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedAddress);
        bytes32 prefixedMsgHash = keccak256(prefixedMsg);
        return recoverSigner(prefixedMsgHash, _signature) == kycManager;
    }

    function recoverSigner(bytes32 _message, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(_signature);

        return ecrecover(_message, v, r, s);
    }

    function splitSignature (bytes memory _sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(_sig.length == 65, "Signature length should be 65.");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(_sig, 32))
            // second 32 bytes
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(_sig, 96)))
        }

        return (v, r, s);
    }

    /** @dev Converts an ethereum address to ascii string.
      * @param _addr The address to be converted.
      * @return Ascii version of the provided an address.
      */
    function _addrToString(address _addr) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            byte b = byte(uint8(uint256(_addr) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = _byteToChar(hi);
            s[2*i+1] = _byteToChar(lo);
        }
        return string(s);
    }

    /** @dev Converts a byte to its asciichar.
      * @param _b The input byte.
      * @return Ascii char of the byte.
      */
    function _byteToChar(byte _b) private pure returns (byte) {
        if (uint8(_b) < 10) {
            return byte(uint8(_b) + 0x30);
        }

        return byte(uint8(_b) + 0x57);
    }
}
