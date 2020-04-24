/**
 *Submitted for verification at Etherscan.io on 2019-01-23
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



/** @title Crowdtainer
  * @dev Allows participating in a coffee crowdfunding with ERC20 tokens.
  */
contract Crowdtainer {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // The ERC20 token used to participate in the crowdfunding.
    IERC20 private _token;

    // Address where funds are collected
    address private _wallet;

    // Price table for each type of coffee.
    // Maps CoffeType to number of ERC20 tokens per 1g of coffee.
    uint256[] private _pricesPerGram;

    // The total amount in grams of a type of coffee that a contributor will receive
    // if the crowdfunding is sucessful.
    mapping(address => mapping(uint8 => uint256)) private _amountBought;

    // The minimum amount of grams per purchase.
    uint256 private constant BASE_AMOUNT = 500;

    event BoughtCoffee(address beneficiary, uint8 coffeeType, uint256 amountGrams);


    /** @param pricesPerGram The prices of different coffee types in number of ERC2O.
      * @param wallet The that will receive funds if the crowdfunding is sucessful.
      * @param token Address of the ERC20 token used for payment.
      * - The price should be given in the number of smallest unit for precision (e.g 10^18 == 1 DAI).
      */
    constructor(
        uint256[] memory pricesPerGram,
        address wallet,
        IERC20 token
    )
        public
    {
        require(address(token) != address(0), "A token for payments must be specified");
        require(address(wallet) != address(0), "An address for forwarding funds must be specified");

        _pricesPerGram = pricesPerGram;
        _wallet = wallet;
        _token = token;
    }

    /** @dev Returns the total cost for a price.
      * @param amountToBuy The amount of coffee in grams.
      * @param coffeeType The coffee type.
      * @return The total cost to buy an amount of a coffee type.
      */
    function calculateCost (uint256 amountToBuy, uint8 coffeeType)
        public
        view
        returns (uint256 cost)
    {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type");
        return amountToBuy.mul(_pricesPerGram[coffeeType]);
    }

    /** @dev returns the amount of a coffee type an address acquired.
      * @param contributor The address of the user who participated.
      * @param coffeeType The coffee type we want to check for.
      * @return The amount of coffee the contributor acquired.
      */
    function amountBought(address contributor, uint8 coffeeType)
        public
        view
        returns (uint256 amountBought)
    {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type");
        return _amountBought[contributor][coffeeType];
    }

    /** @param coffeeType The coffee type we want to query.
      * @return The price per gram of the coffeeType. 18 decimals precision.
      */
    function pricePerGram (uint8 coffeeType) public view returns (uint256 pricePerGram) {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type");
        return _pricesPerGram[uint8(coffeeType)];
    }

    /** @return the address where funds will be collected if the crowdfunding is successful.
      */
    function wallet() public view returns(address wallet) {
        return _wallet;
    }

    /** @return The token used for payments.
      */
    function token() public view returns(IERC20 token) {
        return _token;
    }

    /** @return the number of coffee types available.
      */
    function numberOfCoffeeTypes() public view returns (uint256 numberOfCoffeeTypes) {
        return _pricesPerGram.length;
    }

    /** @dev Allows tokens to be forwarded if the crowsale was sucessful. TRUSTED.
      */
    function _forwardFunds() internal {
        uint amountRaised = _token.balanceOf(address(this));
        _token.safeTransfer(_wallet, amountRaised);
    }

    /**
      * @dev Executed when a purchase has been validated and is ready to be executed.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param totalERC20Cost Number of ERC20 tokens to be paid. 18 decimal places of precision.
      */
    function _processPurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 totalERC20Cost
    )
        internal
    {
        uint256 newAmountBought = _amountBought[msg.sender][coffeeType].add(amountToBuy);
        _amountBought[msg.sender][coffeeType] = newAmountBought;

        emit BoughtCoffee(msg.sender, coffeeType, amountToBuy);
        _token.safeTransferFrom(msg.sender, address(this), totalERC20Cost);
    }

    /** @dev Validation of an incoming participation request.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param agreedPricePerGram The price per 1g of coffee agreed.
      */
    function _preValidatePurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 agreedPricePerGram
    )
        internal
        view
    {
        require(coffeeType < _pricesPerGram.length, "Must be a valid coffee type");
        require(
            amountToBuy >= BASE_AMOUNT,
            "Amount of coffee being bought must be greater than the base amount."
        );
        require(
            agreedPricePerGram == _pricesPerGram[coffeeType],
            "Offered and requested prices must match."
        );
        require(amountToBuy.mod(BASE_AMOUNT) == 0, "Amount to buy must be a multiple of the base amount.");
    }

}


/**
 * @title PausableCrowdtainer
 * @dev Allows participating in a coffee crowdfunding only within a time frame.
 */
contract PausableCrowdtainer is Crowdtainer {

    address private _pauser;
    bool private _paused = false;

    event Paused();
    event Unpaused();

    modifier onlyPauser() {
        require(msg.sender == _pauser, "Only pauser is allowed to call this function.");
        _;
    }

    /**
      * @dev Modifier to make a function callable only when the contract is not paused.
      */
    modifier whenNotPaused() {
        require(!_paused, "Only callable when not paused.");
        _;
    }

    /** @dev Constructor for the pausing mechanism.
      */
    constructor() public {
        _pauser = msg.sender;
        _paused = true;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Only callable when paused.");
        _;
    }

    function pauser() public view returns (address pauser) {
        return _pauser;
    }

    /**
    * @return true if the contract is paused, false otherwise.
    */
    function paused() public view returns(bool paused) {
        return _paused;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused();
    }

    /** @dev Extend parent behaviour requiring to only be callable if not paused.
      */
    function _preValidateRefund()
        internal
        view
    {
        require(!_paused, "Only callable if not paused.");
    }

    /** @dev Extend parent behaviour requiring to only be callable if not paused.
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _pricesPerGram The price per 1g of coffee agreed.
      */
    function _preValidatePurchase(
        uint8 _coffeeType,
        uint256 _amountToBuy,
        uint256 _pricesPerGram
    )
        internal
        view
        whenNotPaused
    {
        super._preValidatePurchase(_coffeeType, _amountToBuy, _pricesPerGram);
    }
}


/** @title TimedCrowdtainer
  * @dev Extends parent to allow participating only within a time frame.
  */
contract TimedCrowdtainer is PausableCrowdtainer {

    uint256 private _openingTime;
    uint256 private _closingTime;

    modifier onlyWhileOpen {
        require(isOpen(), "Only callable if in crowdfunding time range");
        _;
    }

    /** @dev Constructor, takes crowdfunding opening and closing times.
      * @param openingTime crowdfunding opening time
      * @param closingTime crowdfunding closing time
      */
    constructor(uint256 openingTime, uint256 closingTime) public {
        require(openingTime >= block.timestamp, "Opening time should be in the future.");
        require(closingTime >= openingTime, "Closing time should be after opening time.");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    /** @return The approximate opening time.
      */
    function openingTime() public view returns(uint256 openingTime) {
        return _openingTime;
    }

    /** @return The approximate closing time.
      */
    function closingTime() public view returns(uint256 closingTime) {
        return _closingTime;
    }

    /** @return True if the crowdfunding is open, false otherwise.
      */
    function isOpen() public view returns (bool isOpen) {
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /** @dev Checks whether the period in which the crowdfunding is open has already elapsed.
      * @return Whether crowdfunding period has elapsed.
      */
    function hasClosed() public view returns (bool hasClosed) {
        return block.timestamp > _closingTime;
    }

    /** @dev Extend parent behavior requiring to be within contributing period
      * @param _coffeeType The coffee type to be bought.
      * @param _amountToBuy The number of grams of coffee to be bought.
      * @param _pricesPerGram The price per 1g of coffee agreed.
      */
    function _preValidatePurchase(
        uint8 _coffeeType,
        uint256 _amountToBuy,
        uint256 _pricesPerGram
    )
        internal
        view
        onlyWhileOpen
    {
        super._preValidatePurchase(_coffeeType, _amountToBuy, _pricesPerGram);
    }

    /** @dev Extend parent behaviour requiring to only be callable if after closing period.
      */
    function _preValidateRefund()
        internal
        view
    {
        require(hasClosed(), "Crowdsale must have closed.");
        super._preValidateRefund();
    }
}


/**
 * @title KycCrowdtainer
 * @dev Extension of TimedCrowdtainer kyc management functions.
 */
contract KycCrowdtainer is TimedCrowdtainer {

    // The kyc manager address
    address private _kycManager;

    modifier onlyKycManager() {
        require(msg.sender == _kycManager, "Only KYC manager may call this function.");
        _;
    }

    modifier onlyAuthorizedByKyc(bytes memory signature) {
        require(isSenderAuthorizedByKyc(signature), "KYC signature check failed.");
        _;
    }

    /** @param kycManager The address of the authority authorizing buyers.
      */
    constructor(address kycManager) public {
        require(kycManager != address(0), "A KYC manager address must be specified");
        _kycManager = kycManager;
    }

    /** @dev Checks that a signature by the `kycManager` authorizes `msg.sender`.
      * @param signature The signature.
      * @return True if the hash was signed by the kycManager.
      */
    function isSenderAuthorizedByKyc(
        bytes memory signature
    )
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

    /** @dev Extend parent behaviour requiring to be authorized by `kycManager`.
      */
    function _preValidateRefund(bytes memory signature)
        internal
        view
        onlyAuthorizedByKyc(signature)
    {
        super._preValidateRefund();
    }

    /** @dev Extend parent behavior requiring to be authorized by `kycManager`.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
            * @param signature KYC's signature.
      */
    function _preValidatePurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        bytes memory signature
    )
        internal
        view
        onlyAuthorizedByKyc(signature)
    {
        super._preValidatePurchase(coffeeType, amountToBuy, pricePerGram);
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


/** @title RefundableCrowdtainer
  * @dev Extension of KycCrowdtainer contract that adds a funding goal, and
  * the possibility of users getting a refund if goal is not met.
  */
contract RefundableCrowdtainer is KycCrowdtainer {
    using SafeMath for uint256;

    // Is the event finalized.
    bool private _finalized = false;

    // Minimum amount of grams to be raised
    uint256 private _goalGrams;

    // The amount of coffee sold in grams.
    uint256 private _amountSold = 0;

    // Are refunds enabled.
    bool private _refundsEnabled = false;

    // Number of ERC20 tokens sent by an address.
    mapping(address => uint256) internal _amountPaid;

    event CrowdtainerFinalized();
    event RefundClaimed(address beneficiary);

    /** @param goalGrams The amount of grams to be raised for the crowdfunding to
      * be considered to be successful.
      */
    constructor (uint256 goalGrams) public {
        require(goalGrams > 0, "Goal should be above zero");
        _goalGrams = goalGrams;
    }

    /** @dev Contributors can claim refunds here if crowdfunding is unsuccessful.
      * @param beneficiary Whose refund will be claimed.
      * @param signature KYC's signature.
      */
    function claimRefund(address beneficiary, bytes calldata signature) external {
        _preValidateRefund(beneficiary, signature);
        _processRefund(beneficiary);
    }

    /** @dev Must be called after crowdfunding ends, to do some extra finalization
      * work. Calls the contract's finalization function.
      */
    function finalize() external {
        require(!_finalized, "Crowdfunding must not be finalized.");
        require(hasClosed(), "Crowdfunding must have closed.");
        _finalization();
    }

    /** @dev Allows an authorized user to participate in the coffee crowdfunding with ERC20. UNTRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param signature KYC's signature.
      */
    function buyCoffee(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        bytes memory signature
    )
        public
    {
        _preValidatePurchase(coffeeType, amountToBuy, pricePerGram, signature);

        uint256 totalERC20Cost = calculateCost(amountToBuy, coffeeType);

        _processPurchase(coffeeType, amountToBuy, totalERC20Cost);
    }

    /** @return Minimum amount of grams to be sold for a successful crowdfunding.
      */
    function goalGrams() public view returns(uint256 goalGrams) {
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
    function amountPaid(address _contributor) public view returns (uint256 amountPaid) {
        return _amountPaid[_contributor];
    }

    /** @return The total amount of grams of coffee sold.
      */
    function amountSold() public view returns (uint256 amountSold) {
        return _amountSold;
    }

    /** @return True if the crowdfunding is finalized, false otherwise.
      */
    function finalized() public view returns (bool finalized) {
        return _finalized;
    }

    /** @return True if the refunds are enabled, false otherwise.
      */
    function refundsEnabled() public view returns (bool refundsEnabled) {
        return _refundsEnabled;
    }

    /** @dev Extend the parent behavior, storing the amount paid.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param totalERC20Cost Number of ERC20 tokens to be paid. 18 decimal places of precision.
      */
    function _processPurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 totalERC20Cost
    )
        internal
    {
        _amountSold = _amountSold.add(amountToBuy);
        _amountPaid[msg.sender] = _amountPaid[msg.sender].add(totalERC20Cost);
        super._processPurchase(coffeeType, amountToBuy, totalERC20Cost);
    }

    /** @dev Finalization task, called when finalize() is called.
      */
    function _finalization() internal {
        if (goalReached()) {
            _forwardFunds();
        } else {
            _refundsEnabled = true;
        }
        _finalized = true;
        emit CrowdtainerFinalized();
    }

    /** @dev Extend parent behaviour requiring to be a failed crowdfunding.
      */
    function _preValidateRefund(address beneficiary, bytes memory signature) internal view {
        require(!goalReached(), "Goal must have not been reached.");
        require(_amountPaid[beneficiary] > 0, "Amount paid by beneficiary should be above 0.");
        require(_finalized, "Crowdtainer should be finalized.");
        require(_refundsEnabled, "Refunds should be enabled.");
        require(hasClosed(), "Crowdtainer should have closed.");
        super._preValidateRefund(signature);
    }

    /** @dev Extend parent behaviour to update amount due.
      * @param beneficiary Contributor receiving the refund.
      */
    function _processRefund(address beneficiary) internal {
        uint256 amountDue = _amountPaid[beneficiary];
        _amountPaid[beneficiary] = 0;
        emit RefundClaimed(beneficiary);
        token().safeTransfer(beneficiary, amountDue);
    }
}


/** @title ReferalCrowdtainer
  * @dev Extension of RefundableCrowdtainer contract that adds a refereal mechanism:
  * - Users may include a previous contributor to get a discount when calling buyCoffee().
  * - The contributor refered to also gets a reward.
  */
contract ReferalCrowdtainer is RefundableCrowdtainer {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // True if crowdfunding was successful and finalize() was called.
    bool private _rewardsEnabled = false;

    // Number of ERC20 tokens rewarded to accounts through the referal program. 18 decimal places
    // of precision. This value will be left behind to be claimed by the awarded accounts if
    // the crowdfunding is successful.
    uint256 private _amountRewarded;

    // Percentage of discount a user gets for refering to a previous buyer.
    // See `calculateDiscount` for more information. 10 == 10%
    uint8 private _discount;

    // Percentage of reward a user gets being referd to by a new buyer. 10 == 10%
    // See `calculateReward` for more information.
    uint8 private _reward;

    struct Participant {
        string nickname; // The participant nickname.
        uint256 rewardBalance; // Rewards accquired from being refered to in number of ERC20.
        bool optedInReferal; // Weather this user has opted into the referal program.
    }

    // Maps nicknames to accounts for ease of refering.
    mapping(string => address) private _nicknames;

    // Maps addresses to participant data.
    mapping(address => Participant) private _participants;

    event AccountRewarded(address beneficiary, uint256 reward);
    event DiscountedPurchase(address beneficiary, uint256 discount);
    event RewardClaimed(address beneficiary, uint256 reward);

    /** @param openingTime crowdfunding opening time
      * @param closingTime crowdfunding closing time
      * @param goalGrams The amount of grams to be raised for the crowdfunding to
      * - be considered to be successful.
      * @param pricesPerGram The prices of different coffee types in number of ERC2O.
      * - The price should be given in the number of smallest unit for precision (e.g 10^18 == 1 DAI).
      * @param discount The discount percentage to be received for using the referal system.
      * @param reward The reward percentage to be given for being refered to by a buyer.
      * @param kycManager The address of the authority authorizing buyers.
      * @param wallet The that will receive funds if the crowdfunding is sucessful.
      * @param token Address of the ERC20 token used for payment.
      */
    constructor (
        uint256 openingTime,
        uint256 closingTime,
        uint256 goalGrams,
        uint256[] memory pricesPerGram,
        uint8 discount,
        uint8 reward,
        address kycManager,
        address wallet,
        IERC20 token
    )
        public
        KycCrowdtainer(kycManager)
        TimedCrowdtainer(openingTime, closingTime)
        Crowdtainer(pricesPerGram, wallet, token)
        RefundableCrowdtainer(goalGrams)
    {
        _discount = discount;
        _reward = reward;
    }

    /** @dev Allows an authorized user to participate and opt into the referall program. UNTRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param newNickname This caller's chosen nickname.
      * @param signature KYC's signature.
      */
    function buyCoffeeSetNickname(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        string calldata newNickname,
        bytes calldata signature
    )
        external
    {
        _preValidateSetNickname(newNickname);
        _processSetNickname(newNickname);
        buyCoffee(coffeeType, amountToBuy, pricePerGram, signature);
    }

    /** @dev Allows an authorized user to participate in discounted coffee crowdfunding and
      * opt into the referal program. UNTRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param previousBuyerNickname A previous buyer nickname. Used to get a discount.
      * @param newNickname This callers chosen nickname.
      * @param signature KYC's signature.
      */
    function buyDiscountedCoffeeSetNickname(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        string calldata previousBuyerNickname,
        string calldata newNickname,
        bytes calldata signature
    )
        external
    {
        _preValidateSetNickname(newNickname);
        _processSetNickname(newNickname);
        buyDiscountedCoffee(coffeeType, amountToBuy, pricePerGram, previousBuyerNickname, signature);
    }

    /** @dev Allows an authorized user to receive rewards if the crowdfunding is succesful. UNTRUSTED.
      * @param beneficiary The receiver of rewards.
      */
    function claimReward(address beneficiary) external {
        require(_participants[beneficiary].optedInReferal, "Beneficiary must have participated");
        require(_participants[beneficiary].rewardBalance > 0, "Beneficiary must have a positive balance");
        require(hasClosed(), "Crowdsale must have closed.");
        require(goalReached(), "Goal must have been reached.");
        require(rewardsEnabled(), "Rewards should be enabled.");

        uint256 amountDue = _participants[beneficiary].rewardBalance;
        _participants[beneficiary].rewardBalance = 0;
        emit RewardClaimed(beneficiary, amountDue);
        token().safeTransfer(beneficiary, amountDue);
    }

    /** @dev Prevents future buyers from refering to this account. Any rewards will still
      * be available to be claimed if the crowdfunding is successful.
      */
    function optOutOfReferral() external {
        _participants[msg.sender].optedInReferal = false;
    }

    /** @dev Allows an authorized user to participate in discounted coffee crowdfunding. UNTRUSTED.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param previousBuyerNickname A previous buyer nickname. Used to get a discount.
      * @param signature KYC's signature.
      */
    function buyDiscountedCoffee(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        string memory previousBuyerNickname,
        bytes memory signature
    )
        public
    {
        _preValidateDiscountedPurchase(
            coffeeType,
            amountToBuy,
            pricePerGram,
            previousBuyerNickname,
            signature
        );

        _processDiscountedPurchase(coffeeType, amountToBuy, previousBuyerNickname);
    }

    /** @dev Calculates the discount received by a buyer for refering to a new buyer.
      * @param totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be discounted. 18 decimal places of precision.
      */
    function calculateDiscount(uint256 totalERC20Cost) public view returns (uint256 discount) {
        return totalERC20Cost.mul(_discount).div(100);
    }

    /** @dev Calculates the reward received by a previous buyer for being refered to by a new buyer.
      * @param totalERC20Cost The total cost of a purchase, without discount.
      * @return The number of ERC20 tokens to be rewarded. 18 decimal places of precision.
      */
    function calculateReward(uint256 totalERC20Cost) public view returns (uint256 reward) {
        return totalERC20Cost.mul(_reward).div(100);
    }

    /** @param account The account we want to query.
      * @return True if the account has participated in the contribution previously.
      */
    function isParticipatingInReferal(
        address account
    )
        public
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
    function nicknameOwner(string memory nickname) public view returns (address nicknameOwner) {
        return _nicknames[nickname];
    }

    /** @param account The account we want to query
      * @return An array with participant information: [nickname, rewardBalance, optedInReferal]
      */
    function participants(address account)
        public
        view
        returns (string memory nickname, uint256 rewardBalance, bool optedInReferal)
    {
        Participant memory participant = _participants[account];
        return (participant.nickname, participant.rewardBalance, participant.optedInReferal);
    }

    /** @dev Extends to allow rewards to be collected. Called when finalize() is called
      */
    function _finalization() internal {
        if (goalReached()) {
            _rewardsEnabled = true;
        }
        super._finalization();
    }

    /** @dev Prevalidates nickname updates.
      * @param newNickname The nickname we want to validate.
      */
    function _preValidateSetNickname(string memory newNickname) internal view {
        require(bytes(newNickname).length >= 4, "Nickname must not be too small.");
        require(bytes(newNickname).length <= 32, "Nickname must not be too big.");
        require(_nicknames[newNickname] == address(0x0), "Nickname must not be taken");
    }

    /** @dev Sets an nickname for the caller that wants to opt into the referall program.
      * @param newNickname The nickname we want to set for the caller.
      */
    function _processSetNickname(string memory newNickname) internal {
        // Make any previously used nickname available.
        string memory previousNickname = _participants[msg.sender].nickname;
        _nicknames[previousNickname] == address(0x0);

        // Save this user as the nickname owner.
        _nicknames[newNickname] = msg.sender;

        // Update participant data.
        _participants[msg.sender].nickname = newNickname;

        // Mark participant as opted into the referal program.
        _participants[msg.sender].optedInReferal = true;
    }

    /** @dev Extends parent behavior to require a previous buyer.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param pricePerGram The price per 1g of coffee agreed.
      * @param previousBuyerNickname The previous buyer the caller refers to.
      * @param signature KYC's signature.
      */
    function _preValidateDiscountedPurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        uint256 pricePerGram,
        string memory previousBuyerNickname,
        bytes memory signature
    )
        internal
        view
    {
        address previousBuyer = _nicknames[previousBuyerNickname];
        require(_participants[previousBuyer].optedInReferal, "Previous buyer must have participated");
        require(previousBuyer != address(0x0), "Previous buyer must be not be 0x0");

        super._preValidatePurchase(coffeeType, amountToBuy, pricePerGram, signature);
    }

    /** @dev Extend `_processPurchase` to include a discount.
      * @param coffeeType The coffee type to be bought.
      * @param amountToBuy The number of grams of coffee to be bought.
      * @param previousBuyerNickname The account rewarded for being refered to.
      */
    function _processDiscountedPurchase(
        uint8 coffeeType,
        uint256 amountToBuy,
        string memory previousBuyerNickname
    )
        internal
    {
        uint256 totalERC20Cost = calculateCost(amountToBuy, coffeeType);
        uint256 discount = calculateDiscount(totalERC20Cost);
        uint256 reward = calculateReward(totalERC20Cost);

        uint256 discountedCost = totalERC20Cost.sub(discount);

        address previousBuyer = _nicknames[previousBuyerNickname];
        uint256 newRewardBalance = _participants[previousBuyer].rewardBalance.add(reward);

        _participants[previousBuyer].rewardBalance = newRewardBalance;
        _amountRewarded = reward;

        emit AccountRewarded(previousBuyer, reward);
        emit DiscountedPurchase(msg.sender, discount);

        super._processPurchase(coffeeType, amountToBuy, discountedCost);
    }

    /** @dev Overrides parent to only forward part of the tokens, leaving funds to be claimed by
      * participants rewarded by the referal program.
      */
    function _forwardFunds() internal {
        uint amountRaised = token().balanceOf(address(this)).sub(_amountRewarded);
        token().safeTransfer(wallet(), amountRaised);
    }
}
