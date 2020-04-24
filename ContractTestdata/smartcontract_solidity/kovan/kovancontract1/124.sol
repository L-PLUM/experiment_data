/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.2;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
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
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
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
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
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
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
    * @dev Returns the largest of two numbers.
    */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev Returns the smallest of two numbers.
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
    * @dev Calculates the average of two numbers. Since these are integers,
    * averages of an even and odd number cannot be represented, and will be
    * rounded down.
    */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Authorizable.sol

/// Modified from 0x
/// Access control utility to provide onlyAuthorized and onlyUserApproved modifiers
contract Authorizable is Ownable {

    // Logs when a new address is authorized.
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    // Logs when a currently authorized address is unauthorized.
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    // Logs when an address is user approved or unapproved.
    event UserApprovedAddressChanged(
        address indexed target,
        address indexed caller,
        bool approved
    );

    /// Only authorized senders can invoke functions with this modifier.
    modifier onlyAuthorized() {
        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    /// Only user approved senders can invoke functions with this modifier.
    modifier onlyUserApproved(address user) {
        require(
            userApproved[msg.sender][user],
            "SENDER_NOT_APPROVED"
        );
        _;
    }

    // Mapping of authorized addresses.
    // authorized[address] = isAuthorized
    mapping(address => bool) public authorized;

    // Array of authorized addresses.
    address[] public authorities;

    // Mapping of user approved addresses.
    // userApproved[address][user] = isUserApproved
    mapping(address => mapping(address => bool)) public userApproved;

    /// Authorizes an address. Only contract owner can call this function.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            !authorized[target],
            "TARGET_ALREADY_AUTHORIZED"
        );

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    /// Removes authorization of an address. Only contract owner can call this function.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );

        delete authorized[target];
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    /// Removes authorization of an address. Only contract owner can call this function.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );
        require(
            index < authorities.length,
            "INDEX_OUT_OF_BOUNDS"
        );
        require(
            authorities[index] == target,
            "AUTHORIZED_ADDRESS_MISMATCH"
        );

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.length -= 1;
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    /// Approves an address by user.
    /// @param target Address to approve / unapprove.
    /// @param approved Whether an address is approved.
    function approve(address target, bool approved)
    external
    {
        if (userApproved[target][msg.sender] != approved) {
            userApproved[target][msg.sender] = approved;
            emit UserApprovedAddressChanged(target, msg.sender, approved);
        }
    }

    /// Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses()
    external
    view
    returns (address[] memory)
    {
        return authorities;
    }
}

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

// File: contracts/Bank.sol

/// An abstract Contract of Bank
contract Bank is Authorizable, ReentrancyGuard {

    /// Checks whether the user has enough deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @return Whether the user has enough deposit.
    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool);

    /// Checks token balance available to use (including user deposit amount + user approved allowance amount).
    /// @param token Token address.
    /// @param user User address.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @return Token amount available.
    function getAvailable(address token, address user, bytes calldata data) external view returns (uint256);

    /// Gets balance of user's deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @return Token deposit amount.
    function balanceOf(address token, address user) public view returns (uint256);

    /// Deposits token from user wallet to bank.
    /// @param token Token address.
    /// @param user User address (allows third-party give tokens to any users).
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    function deposit(address token, address user, uint256 amount, bytes calldata data) external payable;

    /// Withdraws token from bank to user wallet.
    /// @param token Token address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    function withdraw(address token, uint256 amount, bytes calldata data) external;

    /// Transfers token from one address to another address.
    /// Only caller who are double-approved by both bank owner and token owner can invoke this function.
    /// @param token Token address.
    /// @param from The current token owner address.
    /// @param to The new token owner address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @param fromDeposit True if use fund from bank deposit. False if use fund from user wallet.
    /// @param toDeposit True if deposit fund to bank deposit. False if send fund to user wallet.
    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bool fromDeposit,
        bool toDeposit
    )
    external;
}

// File: contracts/ERC20Bank.sol

// Simple WETH interface to wrap and unwarp ETH.
interface WETH {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

/// A bank locks ETH and ERC20 tokens. It doesn't contain any exchange logics that helps upgrade the exchange contract.
/// Users have complete control over their assets. Only user trusted contracts are able to access the assets.
/// Address 0x0 is used to represent ETH.
contract ERC20Bank is Bank {

    mapping(address => bool) public wethAddresses;
    mapping(address => mapping(address => uint256)) public deposits;

    event SetWETH(address addr, bool autoWrap);
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);

    function() external payable {}

    /// Sets WETH address to support auto wrap/unwrap ETH feature.
    /// @param addr WETH token address.
    /// @param autoWrap Whether the address supports auto wrap/unwrap.
    function setWETH(address addr, bool autoWrap) external onlyOwner {
        wethAddresses[addr] = autoWrap;
        emit SetWETH(addr, autoWrap);
    }

    /// Checks whether the user has enough deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @param amount Token amount.
    /// @return Whether the user has enough deposit.
    function hasDeposit(address token, address user, uint256 amount, bytes memory) public view returns (bool) {
        if (wethAddresses[token]) {
            return amount <= deposits[address(0)][user];
        }
        return amount <= deposits[token][user];
    }

    /// Checks token balance available to use (including user deposit amount + user approved allowance amount).
    /// @param token Token address.
    /// @param user User address.
    /// @return Token amount available.
    function getAvailable(address token, address user, bytes calldata) external view returns (uint256) {
        if (token == address(0)) {
            return deposits[address(0)][user];
        }
        uint256 allowance = Math.min(
            ERC20(token).allowance(user, address(this)),
            ERC20(token).balanceOf(user)
        );
        return SafeMath.add(allowance, balanceOf(token, user));
    }

    /// Gets balance of user's deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @return Token deposit amount.
    function balanceOf(address token, address user) public view returns (uint256) {
        if (wethAddresses[token]) {
            return deposits[address(0)][user];
        }
        return deposits[token][user];
    }

    /// Deposits token from user wallet to bank.
    /// @param token Token address.
    /// @param user User address (allows third-party give tokens to any users).
    /// @param amount Token amount.
    function deposit(address token, address user, uint256 amount, bytes calldata) external nonReentrant payable {
        if (token == address(0)) {
            require(amount == msg.value, "UNMATCHED_DEPOSIT_AMOUNT");
            deposits[address(0)][user] = SafeMath.add(deposits[address(0)][user], msg.value);
            emit Deposit(address(0), user, msg.value, deposits[address(0)][user]);
        } else {
            // Token should be approved in order to transfer
            require(ERC20(token).transferFrom(msg.sender, address(this), amount), "FAILED_DEPOSIT_TOKEN");
            if (wethAddresses[token]) {
                // Auto unwrap to ETH
                // Make sure ETH was received from external contract
                uint256 before = address(this).balance;
                WETH(token).withdraw(amount);
                require(address(this).balance - before == amount, "FAILED_UNWRAP");
                deposits[address(0)][user] = SafeMath.add(deposits[address(0)][user], amount);
            } else {
                deposits[token][user] = SafeMath.add(deposits[token][user], amount);
            }
            emit Deposit(token, user, amount, deposits[token][user]);
        }
    }

    /// Withdraws token from bank to user wallet.
    /// @param token Token address.
    /// @param amount Token amount.
    function withdraw(address token, uint256 amount, bytes calldata) external nonReentrant {
        require(hasDeposit(token, msg.sender, amount, ""), "FAILED_WITHDRAW_INSUFFICIENT_DEPOSIT");
        if (token == address(0)) {
            deposits[address(0)][msg.sender] = SafeMath.sub(deposits[address(0)][msg.sender], amount);
            require(msg.sender.send(amount), "FAILED_WITHDRAW_SENDING_ETH");
            emit Withdraw(address(0), msg.sender, amount, deposits[address(0)][msg.sender]);
        } else {
            if (wethAddresses[token]) {
                // Auto wrap to WETH
                WETH(token).deposit.value(amount)();
                deposits[address(0)][msg.sender] = SafeMath.sub(deposits[address(0)][msg.sender], amount);
            } else {
                deposits[token][msg.sender] = SafeMath.sub(deposits[token][msg.sender], amount);
            }
            require(ERC20(token).transfer(msg.sender, amount), "FAILED_WITHDRAW_SENDING_TOKEN");
            emit Withdraw(token, msg.sender, amount, deposits[token][msg.sender]);
        }
    }

    /// Transfers token from one address to another address.
    /// Only caller who are double-approved by both bank owner and token owner can invoke this function.
    /// @param token Token address.
    /// @param from The current token owner address.
    /// @param to The new token owner address.
    /// @param amount Token amount.
    /// @param fromDeposit True if use fund from bank deposit. False if use fund from user wallet.
    /// @param toDeposit True if deposit fund to bank deposit. False if send fund to user wallet.
    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bool fromDeposit,
        bool toDeposit
    )
    external
    onlyAuthorized
    onlyUserApproved(from)
    nonReentrant
    {
        if (amount == 0 || from == to) {
            return;
        }
        if (fromDeposit) {
            require(hasDeposit(token, from, amount, ""));
            address actualToken = token;
            if (toDeposit) {
                // Deposit to deposit
                if (wethAddresses[token]) {
                    actualToken = address(0);
                }
                deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                deposits[actualToken][to] = SafeMath.add(deposits[actualToken][to], amount);
            } else {
                // Deposit to wallet
                if (token == address(0)) {
                    deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                    require(address(uint160(to)).send(amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                } else {
                    if (wethAddresses[token]) {
                        // Auto wrap to WETH
                        WETH(token).deposit.value(amount)();
                        actualToken = address(0);
                    }
                    deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                    require(ERC20(token).transfer(to, amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                }
            }
        } else {
            if (toDeposit) {
                // Wallet to deposit
                require(ERC20(token).transferFrom(from, address(this), amount), "FAILED_TRANSFER_FROM_WALLET_TO_DEPOSIT");
                deposits[token][to] = SafeMath.add(deposits[token][to], amount);
            } else {
                // Wallet to wallet
                require(ERC20(token).transferFrom(from, to, amount), "FAILED_TRANSFER_FROM_WALLET_TO_WALLET");
            }
        }
    }
}
