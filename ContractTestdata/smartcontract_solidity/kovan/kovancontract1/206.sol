/**
 *Submitted for verification at Etherscan.io on 2019-02-14
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
    IERC20 private _token;

    // Address where funds are collected
    address private _wallet;

    // Price table for each type of coffee.
    // Maps CoffeType to number of ERC20 tokens per 1g of coffee.
    uint[] private _pricesPerGram;

    // The total amount in grams of a type of coffee that a contributor will receive
    // if the crowdfunding is sucessful.
    mapping(address => mapping(uint => uint)) private _amountBought;

    // The kyc manager address
    address private _kycManager;

    // Is the event finalized.
    bool private _finalized = false;

    // Minimum amount of grams to be raised
    uint private _goalGrams;

    // The amount of coffee sold in grams.
    uint private _amountSold = 0;

    // Are refunds enabled.
    bool private _refundsEnabled = false;

    // True if crowdfunding was successful and finalize was called.
    bool private _rewardsEnabled = false;

    // Number of ERC20 tokens rewarded to accounts through the referal program. 18 decimal places
    // of precision. This value will be left behind to be claimed by the awarded accounts if
    // the crowdfunding is successful.
    uint private _amountRewarded;

    // Percentage of discount a user gets for refering to a previous buyer.
    // See `calculateDiscount` for more information. 10 == 10%
    uint private _discount;

    // Percentage of reward a user gets being referd to by a new buyer. 10 == 10%
    // See `calculateReward` for more information.
    uint private _reward;

	bool private _paused;
    address private _pauser;
    uint private _openingTime;
    uint private _closingTime;
    uint private constant BASE_AMOUNT = 500;

    // Number of ERC20 tokens sent by an address.
    mapping(address => uint) internal _amountPaid;

    // Maps nicknames to accounts for ease of refering.
    mapping(string => address) private _nicknameToOwner;

	struct Participant {
        string nickname; // The participant nickname.
        uint rewardBalance; // Rewards accquired from being refered to in number of ERC20.
        bool optedInReferal; // Weather this user has opted into the referal program.
    }

    // Maps addresses to participant data.
    mapping(address => Participant) private _participants;

	/*   Events   */

    event BoughtCoffee(address indexed beneficiary, uint indexed coffeeType, uint amountGrams);
    event DiscountedPurchase(address indexed beneficiary, uint discount);
    event RefundClaimed(address indexed beneficiary, uint _amount);
    event AccountRewarded(address indexed beneficiary, uint reward);
    event RewardClaimed(address indexed beneficiary, uint reward);
    event Finalized();
    event FundsForwarded(address _wallet);
    event Paused();
    event Unpaused();

	/*   Modifiers   */

    modifier whileNotPaused() {
        require(!_paused, "Only callable when not paused.");
        _;
    }

    modifier whileOpen {
        require(isOpen(), "Only callable if in crowdfunding time range");
        _;
    }

    modifier whilePaused() {
        require(_paused, "Only callable when paused.");
        _;
    }

	modifier onlyPauser() {
        require(msg.sender == _pauser, "Only pauser is allowed to call this function.");
        _;
    }

    modifier onlyKycManager() {
        require(msg.sender == _kycManager, "Only KYC manager may call this function.");
        _;
    }

    modifier onlyAuthorizedByKyc(bytes memory signature) {
        require(isSenderAuthorizedByKyc(signature), "KYC signature check failed.");
        _;
    }

    /** @param openingTime crowdfunding opening time
      * @param closingTime crowdfunding closing time
      * @param goalGrams The amount of grams to be raised for the crowdfunding to be considered to be successful.
      * @param pricesPerGram The prices of different coffee types in number of ERC2O. The price should be given in the number of smallest unit for precision (e.g 10^18 == 1 DAI).
      * @param discount The discount percentage to be received for using the referal system.
      * @param reward The reward percentage to be given for being refered to by a buyer.
      * @param kycManager The address of the authority authorizing buyers.
      * @param wallet The that will receive funds if the crowdfunding is sucessful.
      * @param token Address of the ERC20 token used for payment.
      */
    constructor (
        uint openingTime,
        uint closingTime,
        uint goalGrams,
        uint[] memory pricesPerGram,
        uint discount,
        uint reward,
        address kycManager,
        address wallet,
        IERC20 token
    )
      public
    {
        require(address(token) != address(0), "A token for payments must be specified.");
        require(address(wallet) != address(0), "An address for forwarding funds must be specified.");
        require(openingTime >= block.timestamp, "Opening time should be in the future.");
        require(closingTime >= openingTime, "Closing time should be after opening time.");
        require(kycManager != address(0), "A KYC manager address must be specified.");
        require(goalGrams > 0, "Goal should be above zero.");

        _goalGrams = goalGrams;
        _kycManager = kycManager;
        _openingTime = openingTime;
        _closingTime = closingTime;
        _pricesPerGram = pricesPerGram;
        _wallet = wallet;
        _token = token;
        _pauser = msg.sender;
        _paused = true;
        _discount = discount;
        _reward = reward;
    }

	/** @dev Allows an authorized user to participate in the coffee crowdsale with ERC20. TRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param agreedPricePerGram The price per 1g of coffee agreed.
      * @param signature KYC's signature.
      */
    function buyCoffee(
        uint coffeeType,
        uint amountToBuy,
        uint agreedPricePerGram,
        bytes memory signature
    )
        public
		whileOpen
      	whileNotPaused
      	onlyAuthorizedByKyc(signature)
    {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type.");
        require(
            amountToBuy >= BASE_AMOUNT,
            "Amount of coffee being bought must be greater than the base amount."
        );
        require(
            agreedPricePerGram == _pricesPerGram[coffeeType],
            "Offered and requested prices must match."
        );
        require(amountToBuy.mod(BASE_AMOUNT) == 0, "Amount to buy must be a multiple of the base amount.");

        uint totalERC20Cost = calculateCost(amountToBuy, coffeeType);

        _amountSold = _amountSold.add(amountToBuy);
        _amountPaid[msg.sender] = _amountPaid[msg.sender].add(totalERC20Cost);
        _amountBought[msg.sender][coffeeType] = _amountBought[msg.sender][coffeeType].add(amountToBuy);
        _token.safeTransferFrom(msg.sender, address(this), totalERC20Cost);

        emit BoughtCoffee(msg.sender, coffeeType, amountToBuy);
    }

	/** @dev Allows an authorized account to participate and opt into the referal program. TRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param newNickname The caller's chosen nickname.
      * @param signature KYC's signature.
      */
    function buyCoffeeSetNickname(
        uint coffeeType,
        uint amountToBuy,
        uint pricePerGram,
        string calldata newNickname,
        bytes calldata signature
    )
        external
    {
		require(bytes(newNickname).length >= 4, "Nickname must not be too small.");
        require(bytes(newNickname).length <= 32, "Nickname must not be too big.");
        require(_nicknameToOwner[newNickname] == address(0x0), "Nickname must not be taken.");

		// Make any previously owned nickname available.
        string memory previousNickname = _participants[msg.sender].nickname;
        _nicknameToOwner[previousNickname] = address(0x0);

        // Save caller as the nickname owner.
        _nicknameToOwner[newNickname] = msg.sender;

        // Update participant data.
        _participants[msg.sender].nickname = newNickname;

        // Mark participant as having opted into the referal program.
        _participants[msg.sender].optedInReferal = true;

        buyCoffee(coffeeType, amountToBuy, pricePerGram, signature);
    }

	/** @dev Allows an authorized user to participate in discounted coffee crowdsale. TRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param agreedPricePerGram The price per 1g of coffee agreed.
      * @param previousBuyerNickname A previous buyer nickname. Used to get a discount through the referal program.
      * @param signature KYC's signature.
      */
    function buyDiscountedCoffee(
        uint coffeeType,
        uint amountToBuy,
        uint agreedPricePerGram,
        string memory previousBuyerNickname,
        bytes memory signature
    )
        public
		whileOpen
		whileNotPaused
		onlyAuthorizedByKyc(signature)
    {
        address previousBuyer = _nicknameToOwner[previousBuyerNickname];
        require(previousBuyer != address(0x0), "Refered account must be valid.");
        require(_participants[previousBuyer].optedInReferal, "Previous buyer must have participated.");
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type.");
        require(
            amountToBuy >= BASE_AMOUNT,
            "Amount of coffee being bought must be greater than the base amount."
        );
        require(
            agreedPricePerGram == _pricesPerGram[coffeeType],
            "Offered and requested prices must match."
        );
        require(
			amountToBuy.mod(BASE_AMOUNT) == 0,
			"Amount to buy must be a multiple of the base amount."
		);

        uint totalERC20Cost = calculateCost(amountToBuy, coffeeType);
        uint discount = calculateDiscount(totalERC20Cost);
        uint reward = calculateReward(totalERC20Cost);
        uint discountedCost = totalERC20Cost.sub(discount);

        _participants[previousBuyer].rewardBalance = _participants[previousBuyer].rewardBalance.add(reward);
        _amountRewarded = _amountRewarded.add(reward);
        _amountSold = _amountSold.add(amountToBuy);
        _amountPaid[msg.sender] = _amountPaid[msg.sender].add(discountedCost);
        _amountBought[msg.sender][coffeeType] = _amountBought[msg.sender][coffeeType].add(amountToBuy);
        _token.safeTransferFrom(msg.sender, address(this), discountedCost);

        emit BoughtCoffee(msg.sender, coffeeType, amountToBuy);
		emit AccountRewarded(previousBuyer, reward);
        emit DiscountedPurchase(msg.sender, discount);
    }

    /** @dev Allows an authorized user to participate in the discounted coffee crowdsale and opt into the referal program. TRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param previousBuyerNickname A previous buyer nickname. Used to get a discount.
      * @param newNickname This callers chosen nickname.
      * @param signature KYC's signature.
      */
    function buyDiscountedCoffeeSetNickname(
        uint coffeeType,
        uint amountToBuy,
        uint pricePerGram,
        string calldata previousBuyerNickname,
        string calldata newNickname,
        bytes calldata signature
    )
        external
    {
		require(bytes(newNickname).length >= 4, "Nickname must not be too small.");
        require(bytes(newNickname).length <= 32, "Nickname must not be too big.");
        require(_nicknameToOwner[newNickname] == address(0x0), "Nickname must not be taken");

		// Make any previously used nickname available.
        string memory previousNickname = _participants[msg.sender].nickname;
        _nicknameToOwner[previousNickname] = address(0x0);

        // Save this user as the nickname owner.
        _nicknameToOwner[newNickname] = msg.sender;

        // Update participant data.
        _participants[msg.sender].nickname = newNickname;

        // Mark participant as opted into the referal program.
        _participants[msg.sender].optedInReferal = true;

        buyDiscountedCoffee(coffeeType, amountToBuy, pricePerGram, previousBuyerNickname, signature);
    }

	/** @dev Must be called after crowdfunding ends, to do some extra finalization work.
      */
    function finalize() external {
        require(!_finalized, "Crowdfunding must not be finalized.");
        require(hasClosed(), "Crowdfunding must have closed.");

		if (goalReached()) {
            _rewardsEnabled = true;
			uint amountRaised = _token.balanceOf(address(this)).sub(_amountRewarded);
        	_token.safeTransfer(_wallet, amountRaised);
        } else {
            _refundsEnabled = true;
        }

        _finalized = true;

        emit Finalized();
    }

    /** @dev Allows an authorized user to receive rewards if the crowdfunding is succesful. TRUSTED.
      * @param beneficiary The receiver of rewards.
      */
    function claimReward(address beneficiary) external {
        require(_participants[beneficiary].rewardBalance > 0, "Beneficiary must have a positive balance");
		require(_finalized, "Crowdtainer should be finalized.");
        require(hasClosed(), "Crowdsale must have closed.");
        require(goalReached(), "Goal must have been reached.");
        require(rewardsEnabled(), "Rewards should be enabled.");

        uint amountDue = _participants[beneficiary].rewardBalance;
        _participants[beneficiary].rewardBalance = 0;
        _token.safeTransfer(beneficiary, amountDue);

        emit RewardClaimed(beneficiary, amountDue);
    }

	/** @dev Allows withdrawing refunds if the crowdsale is unsuccessful.
      * @param beneficiary Whose refund will be claimed.
      */
    function claimRefund(address beneficiary)	external {
        require(hasClosed(), "Crowdsale must have closed.");
        require(!goalReached(), "Goal must have not been reached.");
        require(_finalized, "Crowdtainer should be finalized.");
        require(_refundsEnabled, "Refunds should be enabled.");
        require(!_paused, "Only callable if not paused.");

        uint amountDue = _amountPaid[beneficiary];
        _amountPaid[beneficiary] = 0;
        _token.safeTransfer(beneficiary, amountDue);

        emit RefundClaimed(beneficiary, amountDue);
    }

    /** @dev Prevents future buyers from refering to this account. Any rewards will still
      * be available to be claimed if the crowdfunding is successful.
      */
    function optOutOfReferral() external {
        _participants[msg.sender].optedInReferal = false;
    }

	/**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() external onlyPauser whileNotPaused {
        _paused = true;
        emit Paused();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() external onlyPauser whilePaused {
        _paused = false;
        emit Unpaused();
    }

    /** @dev Returns the total cost for a price.
      * @param amountToBuy The amount of coffee in grams.
      * @param coffeeType The coffee type.
      * @return The total cost to buy an amount of a coffee type.
      */
    function calculateCost (uint amountToBuy, uint coffeeType) public view returns (uint cost) {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type");
        return amountToBuy.mul(_pricesPerGram[coffeeType]);
    }

    /** @dev returns the amount of a coffee type an address acquired.
      * @param contributor The address of the user who participated.
      * @param coffeeType The coffee type we want to check for.
      * @return The amount of coffee the contributor acquired.
      */
    function amountBought(address contributor, uint coffeeType)
        external
        view
        returns (uint amountBought)
    {
        return _amountBought[contributor][coffeeType];
    }

    /** @param coffeeType The coffee type we want to query.
      * @return The price per gram of the coffeeType. 18 decimals precision.
      */
    function pricePerGram (uint coffeeType) external view returns (uint pricePerGram) {
        return _pricesPerGram[uint(coffeeType)];
    }

    /** @return the address where funds will be collected if the crowdfunding is successful.
      */
    function wallet() external view returns(address wallet) {
        return _wallet;
    }

    /** @return The token used for payments.
      */
    function token() external view returns(IERC20 token) {
        return _token;
    }

    /** @return the number of coffee types available.
      */
    function numberOfCoffeeTypes() external view returns (uint numberOfCoffeeTypes) {
        return _pricesPerGram.length;
    }

    /**
    * @return The address authorized to pause contributions.
    */
    function pauser() external view returns (address pauser) {
        return _pauser;
    }

    /**
    * @return true if the contract is paused, false otherwise.
    */
    function paused() external view returns(bool paused) {
        return _paused;
    }

    /** @return The approximate opening time.
      */
    function openingTime() external view returns(uint openingTime) {
        return _openingTime;
    }

    /** @return The approximate closing time.
      */
    function closingTime() external view returns(uint closingTime) {
        return _closingTime;
    }

    /** @return True if the crowdfunding is open, false otherwise.
      */
    function isOpen() public view returns (bool isOpen) {
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /** @dev Checks whether the period in which the crowdfunding is open has already passed.
      * @return Whether crowdfunding period has passed.
      */
    function hasClosed() public view returns (bool hasClosed) {
        return block.timestamp > _closingTime;
    }


    /** @return Return the address of the KYC Authority.
      */
    function kycManager() external view returns (address kycManager) {
        return _kycManager;
    }

	/** @return Minimum amount of grams to be sold for a successful crowdfunding.
      */
    function goalGrams() public view returns(uint goalGrams) {
        return _goalGrams;
    }

    /** @return Whether funding goal was reached
      */
    function goalReached() public view returns (bool goalReached) {
        return amountSold() >= _goalGrams;
    }

    /** @param _contributor The contributor that we want to query.
      * @return the number of ERC20 paid.
      */
    function amountPaid(address _contributor) external view returns (uint amountPaid) {
        return _amountPaid[_contributor];
    }

    /** @return The total amount of grams of coffee sold.
      */
    function amountSold() public view returns (uint amountSold) {
        return _amountSold;
    }

    /** @return True if the crowdfunding is finalized, false otherwise.
      */
    function finalized() external view returns (bool finalized) {
        return _finalized;
    }

    /** @return True if the refunds are enabled, false otherwise.
      */
    function refundsEnabled() external view returns (bool refundsEnabled) {
        return _refundsEnabled;
    }

    /** @dev Calculates the discount received by a buyer for refering to a new buyer.
      * @param totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be discounted. 18 decimal places of precision.
      */
    function calculateDiscount(uint totalERC20Cost) public view returns (uint discount) {
        return totalERC20Cost.mul(_discount).div(100);
    }

    /** @dev Calculates the reward received by a previous buyer for being refered to by a new buyer.
      * @param totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be rewarded. 18 decimal places of precision.
      */
    function calculateReward(uint totalERC20Cost) public view returns (uint reward) {
        return totalERC20Cost.mul(_reward).div(100);
    }

    /** @param account The account we want to query.
      * @return True if the account has participated in the contribution previously.
      */
    function isParticipatingInReferal(address account)
        external
        view
        returns (bool isParticipatingInReferral)
    {
        return _participants[account].optedInReferal;
    }

    /** @return True if rewards are enabled.
      */
    function rewardsEnabled() public view returns (bool rewardsEnabled) {
        return _rewardsEnabled;
    }

    /** @param nickname The nickname we want to query for.
      * @return The owner of the nickname.
      */
    function nicknameOwner(string calldata nickname) external view returns (address nicknameOwner) {
        return _nicknameToOwner[nickname];
    }

    /** @param account The account we want to query
      * @return An array with participant information: [nickname, rewardBalance, optedInReferal]
      */
    function participants(address account)
        external
        view
        returns (string memory nickname, uint rewardBalance, bool optedInReferal)
    {
        Participant memory participant = _participants[account];
        return (participant.nickname, participant.rewardBalance, participant.optedInReferal);
    }

    /** @dev Checks that a signature by the `kycManager` authorizes `msg.sender`.
      * @param signature The signature.
      * @return True if the hash was signed by the kycManager.
      */
    function isSenderAuthorizedByKyc(bytes memory signature)
        public
        view
        returns (bool isSenderAuthorizedByKyc)
    {
        string memory strAddr = _addrToString(msg.sender);
        bytes32 hashedAddress = keccak256(abi.encodePacked("0x",strAddr));

        bytes memory prefixedMsg = abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedAddress);
        bytes32 prefixedMsgHash = keccak256(prefixedMsg);
        return recoverSigner(prefixedMsgHash, signature) == _kycManager;
    }

    function recoverSigner(bytes32 message, bytes memory signature)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(signature);

        return ecrecover(message, v, r, s);
    }

    function splitSignature (bytes memory sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65, "Signature length should be 65.");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    /** @dev Converts an ethereum address to ascii string.
      * @param addr The address to be converted.
      * @return Ascii version of the provided an address.
      */
    function _addrToString(address addr) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            byte b = byte(uint8(uint256(addr) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = _byteToChar(hi);
            s[2*i+1] = _byteToChar(lo);
        }
        return string(s);
    }

    /** @dev Converts a byte to its asciichar.
      * @param b The input byte.
      * @return Ascii char of the byte.
      */
    function _byteToChar(byte b) private pure returns (byte) {
        if (uint8(b) < 10) {
            return byte(uint8(b) + 0x30);
        }

        return byte(uint8(b) + 0x57);
    }
}
