/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.3;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/Badium.sol

contract Badium is ERC20Detailed {
    using SafeMath for uint256;

    uint32 private _mappingVersion = 0;

    mapping(bytes32 => uint256) private _balances;

    uint256 private _totalSupply;

    address payable private _owner;

    bool private _approvalRequired;

    mapping(address => bool) private _approvedReceivers;

    uint256 constant public PRICE = 10 finney;

    constructor(uint256 initialBalance)
    public
    ERC20Detailed("Badium", "BAD", 0) {
        _owner = msg.sender;
        _mint(_owner, initialBalance);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier nonOwner() {
        require(msg.sender != _owner);
        _;
    }

    /**
     * @dev Function for investors to buy tokens from the contract owner
     */
    function buy() public nonOwner payable
    {
        uint256 amountToSell = msg.value / PRICE;
        require(amountToSell < balanceOf(_owner));
        _owner.transfer(msg.value);
        _transfer(_owner, msg.sender, amountToSell);
    }

    function burnAll() public onlyOwner {
        _mappingVersion++;
    }

    /**
     * @dev Function for the contract owner to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Stub method - always returns false, as it does nothing
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) { // solhint-disable-line no-unused-vars
        return false;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from == _owner || from == msg.sender);
        _transfer(from, to, value);
        return true;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param holder The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address holder) public view returns (uint256) {
        return _getBalance(holder);
    }

    /**
     * @dev Function to check the amount of tokens that a holder allowed to a spender.
     * @param holder address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address holder, address spender) public view returns (uint256) {
        if (spender == _owner || spender == holder) {
            return _getBalance(holder);
        }
        return 0;
    }

    /**
    * @dev Set approval (restricted) mode for the contract,
    * when only transfers to approved  addresses are allowed
    */
    function setApprovalMode() public onlyOwner {
        _approvalRequired = true;
    }

    /**
    * @dev Set approval free (unrestricted) mode for the contract,
    * when only transfers to approved addresses are allowed
    */
    function setApprovalFreeMode() public onlyOwner {
        _approvalRequired = false;
    }

    /**
    * @dev Approve a single receiver, so
    * he can receive transfers when in approval mode
    * @param receiver the address to approve
    */
    function approveReceiver(address receiver) public onlyOwner {
        _approveReceiver(receiver);
    }

    /**
    * @dev Ban a single receiver, so
    * he can not receive transfers when in approval mode
    * @param receiver the addresses to ban
    */
    function banReceiver(address receiver) public onlyOwner {
        _banReceiver(receiver);
    }

    /**
    * @dev Approve multiple receivers, so
    * they can receive transfers when in approval mode
    * @param receivers array of addresses to approve
    */
    function approveReceivers(address[] memory receivers) public onlyOwner {
        for (uint i = 0; i < receivers.length; i++) {
            _approveReceiver(receivers[i]);
        }
    }

    /**
    * @dev Ban multiple receivers, so
    * they can not receive transfers when in approval mode
    * @param receivers array of addresses to ban
    */
    function banReceivers(address[] memory receivers) public onlyOwner {
        for (uint i = 0; i < receivers.length; i++) {
            _banReceiver(receivers[i]);
        }
    }

    function _getBalance(address holder) internal view returns (uint256) {
        return _balances[_getKey(holder)];
    }

    function _getKey(address holder) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_mappingVersion, holder));
    }

    function _setBalance(address holder, uint256 balance) internal {
        _balances[_getKey(holder)] = balance;
    }

    function _addBalance(address holder, uint256 value) internal {
        uint256 newBalance = _getBalance(holder).add(value);
        _setBalance(holder, newBalance);
    }

    function _subBalance(address holder, uint256 value) internal {
        uint256 newBalance = _getBalance(holder).sub(value);
        _setBalance(holder, newBalance);
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0) && _receiverApproved(to));
        _subBalance(from, value);
        _addBalance(to, value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(value);
        _addBalance(account, value);
        emit Transfer(address(0), account, value);
    }

    /**
    * @dev Internal function to approve a single receiver, so
    * he can receive transfers when in approval mode
    * @param receiver the address to approve
    */
    function _approveReceiver(address receiver) internal {
        _approvedReceivers[receiver] = true;
    }

    /**
    * @dev Internal function to ban a single receiver, so
    * he can not receive transfers when in approval mode
    * @param receiver the addresses to ban
    */
    function _banReceiver(address receiver) internal {
        _approvedReceivers[receiver] = false;
    }

    /**
    * @dev Internal function to check if an address
    * is approved as receiver at the moment,
    * with respect to the current approval mode
    * @param receiver the address to check
    */
    function _receiverApproved(address receiver) internal view returns (bool) {
        return !_approvalRequired || _approvedReceivers[receiver];
    }
}
