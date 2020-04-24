/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity 0.5.2;


contract RandomToken {
    string private constant NAME = "Random Token";
    string private constant SYMBOL = "RNDM";
    uint8 private constant DECIMALS = 18;
    uint256 private constant TOTAL_SUPPLY = 1e27;
    mapping (address => uint256) private privateBalances;
    mapping (address => mapping (address => uint256)) private privateAllowed;
    mapping (address => mapping (address => uint8)) private privateNonce;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _initialTokenHolder)
        public
    {
        require(_initialTokenHolder != address(0), "1001");
        privateBalances[_initialTokenHolder] = TOTAL_SUPPLY;
    }

    modifier validAddress(address targetAddress) {
        require(targetAddress != address(0), "1001");
        _;
    }

    modifier notThisAddress(address targetAddress) {
        require(targetAddress != address(this), "1002");
        _;
    }

    modifier hasSufficientTokens(address targetAddress, uint256 value) {
        require(value <= privateBalances[targetAddress], "1005");
        _;
    }

    modifier validAmountAndNonce(address fromAddress, address toAddress, uint256 expectedAmount, uint8 expectNonce) {
        require(expectedAmount == privateAllowed[fromAddress][toAddress], "1007");
        require(expectNonce == privateNonce[fromAddress][toAddress], "1008");
        _;
    }

    modifier validTransferFromAmount(address fromAddress, address toAddress, uint256 tokens) {
        require(tokens <= privateAllowed[fromAddress][toAddress], "1009");
        _;
    }

    function totalSupply()
        public
        pure
        returns (uint256 tokenSupply)
    {
        return TOTAL_SUPPLY;
    }

    /**
    * @dev Name of the token
    */
    function name() public pure returns (string memory tokenName) {
        return NAME;
    }

    /**
    * @dev Symbol of the token
    */
    function symbol() public pure returns (string memory tokenSymbol) {
        return SYMBOL;
    }

    /**
    * @dev Number of decimals the token uses
    */
    function decimals() public pure returns (uint8 tokenDecimals) {
        return DECIMALS;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(
        address owner
    )
        public
        view
        returns (uint256 balance)
    {
        return privateBalances[owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256 remaining)
    {
        return privateAllowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(
        address to,
        uint256 value
    )
        public
        returns (bool success)
    {
        privateTransfer(msg.sender, to, value);
        return true;
    }

    function approve(
        address spender,
        uint256 value
    )
        public
        validAddress(spender)
        returns (bool success)
    {
        return privateApprove(spender, value);
    }

    function privateApprove(
        address spender,
        uint256 value
    )
        internal
        returns (bool success)
    {
        // intentional allowance for an overflow
        privateNonce[msg.sender][spender]++;
        privateAllowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        validTransferFromAmount(from, msg.sender, value)
        returns (bool success)
    {
        privateAllowed[from][msg.sender] = sub(privateAllowed[from][msg.sender], value);
        privateTransfer(from, to, value);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    * This function reverts on tokens being sent to this contract
    * as an added safe guard for accidental transfers.
    */
    function privateTransfer(
        address from,
        address to,
        uint256 value
    )
        internal
        validAddress(to)
        notThisAddress(to)
        hasSufficientTokens(from, value)
    {
        privateBalances[from] = sub(privateBalances[from], value);
        privateBalances[to] = add(privateBalances[to], value);
        emit Transfer(from, to, value);
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    * This function is taken directly from the SafeMath.sol library
    * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0/contracts/math/SafeMath.sol
    * revert codes: 1004
    */
    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256 result)
    {
        // `b` must be less than `a` to avoid an underflow condition
        require(b <= a, "1004");

        uint256 c = a - b;
        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    * This function is taken directly from the SafeMath.sol library
    * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.0.0/contracts/math/SafeMath.sol
    * revert codes: 1003
    */
    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256 result)
    {
        uint256 c = a + b;

        // if `c` is not greater than `a` then an overflow condition occurred
        require(c >= a, "1003");

        return c;
    }
}
