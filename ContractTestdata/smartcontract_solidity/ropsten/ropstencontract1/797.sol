/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.24;

// File: D:/STO/Test1462/contracts/IBaseSecurityToken.sol

/**
 * @title BaseSecurityToken interface
 * @dev see https://github.com/ethereum/EIPs/pull/1462
 */
interface IBaseSecurityToken {    
    
    function attachDocument(bytes32 _name, string _uri, bytes32 _contentHash) external;

    function lookupDocument(bytes32 _name) external view returns (string, bytes32);

    /**
     * @return byte status code (ESC): 0x11 for Allowed, for other please refer to ERC-1066.
     */
    function checkTransferAllowed (address from, address to, uint256 value) external view returns (byte);
   
    /**
     * @return byte status code (ESC): 0x11 for Allowed, for other please refer to ERC-1066.
     */
    function checkTransferFromAllowed (address from, address to, uint256 value) external view returns (byte);
   
    /**
     * @return byte status code (ESC): 0x11 for Allowed, for other please refer to ERC-1066.
     */
    function checkMintAllowed (address to, uint256 value) external view returns (byte);
   
    /**
     * @return byte status code (ESC): 0x11 for Allowed, for other please refer to ERC-1066.
     */
    function checkBurnAllowed (address from, uint256 value) external view returns (byte);    
}

// File: d:/STO/Test1462/contracts/lib/IERC20.sol

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

// File: d:/STO/Test1462/contracts/lib/SafeMath.sol

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
        require(c / a == b, "");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, ""); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "");
        return a % b;
    }
}

// File: D:/STO/Test1462/contracts/lib/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
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
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender], "");
        require(to != address(0), "");

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "");

        _allowed[msg.sender][spender] = value;
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
        returns (bool)
    {
        require(value <= _balances[from], "");
        require(value <= _allowed[from][msg.sender], "");
        require(to != address(0), "");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        require(spender != address(0), "");

        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        require(spender != address(0), "");

        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param amount The amount that will be created.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != 0, "");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != 0, "");
        require(amount <= _balances[account], "");

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender], "");

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            amount);
        _burn(account, amount);
    }
}

// File: D:/STO/Test1462/contracts/lib/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

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
        require(msg.sender == owner, "");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

// File: contracts\BaseSecurityToken.sol

/**
 * @title BaseSecurityToken implementation
 * @dev see https://github.com/ethereum/EIPs/pull/1462
 */
contract BioPak1462 is IBaseSecurityToken, ERC20, Ownable {

    string constant name = "Biopak1462";
    string constant symbol = "BP62";
    uint256 constant decimals = 18;
    
    struct Document {
        bytes32 name;
        string uri;
        bytes32 contentHash;
    }

    mapping (bytes32 => Document) private documents;

    function transfer(address to, uint256 value) public returns (bool) {
        require(checkTransferAllowed(msg.sender, to, value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(checkTransferFromAllowed(from, to, value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transferFrom(from, to, value);
    }

    function _mint(address account, uint256 amount) internal {
        require(checkMintAllowed(account, amount) == STATUS_ALLOWED, "mint must be allowed");
        ERC20._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(checkBurnAllowed(account, amount) == STATUS_ALLOWED, "burn must be allowed");
        ERC20._burn(account, amount);
    }

    function attachDocument(bytes32 _name, string _uri, bytes32 _contentHash) external {
        require(_name.length > 0, "name of the document must not be empty");
        require(bytes(_uri).length > 0, "external URI to the document must not be empty");
        require(_contentHash.length > 0, "content hash is required, use SHA-1 when in doubt");
        require(documents[_name].name.length == 0, "document must not be existing under the same name");
        documents[_name] = Document(_name, _uri, _contentHash);
    }
   
    function lookupDocument(bytes32 _name) external view returns (string, bytes32) {
        Document storage doc = documents[_name];
        return (doc.uri, doc.contentHash);
    }

    // Uses status codes from ERC-1066
    byte private constant STATUS_ALLOWED = 0x11;

    function checkTransferAllowed (address, address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkTransferFromAllowed (address, address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkMintAllowed (address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkBurnAllowed (address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Too much tokens to burn");
        _burn(msg.sender, amount);
    }
}
