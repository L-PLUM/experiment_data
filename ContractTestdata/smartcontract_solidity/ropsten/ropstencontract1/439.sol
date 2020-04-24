/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

// File: contracts/token/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 *
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    /** Event emitted whenever tokens are transferred from one account to another. */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /** Event emitted whenever an account approves another account to spent from its balance. */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/math/SafeMath.sol

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 *
 * @dev Unsigned math operations with safety checks that revert on error.
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

// File: contracts/utils/Address.sol

pragma solidity ^0.4.24;

/**
 * @title Address
 *
 * @dev Utility library of inline functions on addresses.
 */
library Address {
    /**
     * @dev Returns whether the target address is a contract.
     * This function will return false if invoked during the constructor of a contract, as the code is not actually
     * created until after the constructor finishes.
     *
     * @param account The address of the account to check
     * @return True if the target address is a contract, otherwise false
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: contracts/token/ERC20.sol

pragma solidity ^0.4.24;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 *
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    /** Total supply of tokens in existence. */
    uint256 private _totalSupply;

    /** Mapping of each address to their token balance. */
    mapping (address => uint256) private _balances;

    /** Mapping of each address to, a mapping of, the amount of tokens they've allowed each other address to spend. */
    mapping (address => mapping (address => uint256)) private _allowed;

    /**
     * @return Total number of tokens in existence.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     *
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     *
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token for a specified address
     *
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * @notice Only use this function to set the spender allowance to zero.
     * To increment allowed value use the increaseAllowance function.
     * To decrement allowed value use the decreaseAllowance function.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering.
     *
     * One possible solution to mitigate this race condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     *
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     *
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     *
     * @notice The approve function should be called when setting the spender allowance to zero.
     * To increment allowed value it is better to use this function to avoid 2 calls.
     *
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     *
     * @notice The approve function should be called when setting the spender allowance to zero.
     * To decrement allowed value it is better to use this function to avoid 2 calls.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Internal function that transfers tokens for a specified addresses.
     * This encapsulates the modification of balances such that the proper events are emitted.
     * Emits a Transfer event.
     *
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
     * @dev Internal function that approves an address to spend another addresses' tokens.
     * We do not assert if the owner is the zero address as when being called by a public approve function the sender
     * would need to control the zero address, and when being called by the transferFrom the zero address would have to
     * have a balance greater than zero despite it not being able to receive tokens.
     *
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to an account.
     * This encapsulates the modification of balances such that the proper events are emitted.
     * Emits a Transfer event.
     *
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
     * @dev Internal function that burns an amount of the token of a given account.
     * This encapsulates the modification of balances such that the proper events are emitted.
     * We do not assert if the account is the zero address as the zero address cannot ever receive tokens.
     * Emits a Transfer event.
     *
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}

// File: contracts/access/Roles.sol

pragma solidity ^0.4.24;

/**
 * @title Roles
 *
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    /** Role struct that contains a mapping of account addresses that have access to the role. */
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     *
     * @return True if the given `account` has access to this role, otherwise false
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/access/roles/OwnerRole.sol

pragma solidity ^0.4.24;


/**
 * @title OwnerRole
 *
 * @dev Role for providing access control to high risk functions, such as upgrades and administering master roles.
 * All other role contracts should inherit from this contract, as it provides top-level access control.
 */
contract OwnerRole {
    using Roles for Roles.Role;

    //** Event emitted whenever an account is given access to the owner role. */
    event OwnerAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the owner role. */
    event OwnerRemoved(address indexed account);

    /** Mapping of account addresses with access to the owner role. */
    Roles.Role private _owners;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the owner role.
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the owner role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the owner role, otherwise false
     */
    function isOwner(address account) public view returns (bool) {
        return _owners.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the owner role.
     * Callable by another account with access to the owner role.
     *
     * @param account The account address being given access to the owner role
     */
    function addOwner(address account) external onlyOwner {
        _addOwner(account);
    }

    /**
     * @dev Remove access to the owner role for the given `account`.
     * Callable by another account with access to the owner role.
     *
     * @param account The account address having access removed for the owner role
     */
    function removeOwner(address account) external onlyOwner {
        _removeOwner(account);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_owners`.
     * Emits an OwnerAdded event.
     *
     * @param account The account account being given access to the owner role
     */
    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_owners`.
     * Emits an OwnerRemoved event.
     *
     * @param account The account account having access removed for the owner role
     */
    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account);
    }
}

// File: contracts/access/roles/MinterAdminRole.sol

pragma solidity ^0.4.24;



/**
 * @title MinterAdminRole
 *
 * @dev Role for providing access control to functions that administer individual minter roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The MinterRole contract should inherit from this contract.
 */
contract MinterAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the minterAdmin role. */
    event MinterAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the minterAdmin role. */
    event MinterAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the minterAdmin role. */
    Roles.Role private _minterAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the minterAdmin role.
     */
    modifier onlyMinterAdmin() {
        require(isMinterAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the minterAdmin role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the minterAdmin role, otherwise false
     */
    function isMinterAdmin(address account) public view returns (bool) {
        return _minterAdmins.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the minterAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the minterAdmin role
     */
    function addMinterAdmin(address account) external onlyOwner {
        _addMinterAdmin(account);
    }

    /**
     * @dev Remove access to the minterAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the minterAdmin role
     */
    function removeMinterAdmin(address account) external onlyOwner {
        _removeMinterAdmin(account);
    }

    /**
     * @dev Renounce access to the minterAdmin role.
     * Callable by an account with the minterAdmin role.
     */
    function renounceMinterAdmin() external onlyMinterAdmin {
        _removeMinterAdmin(msg.sender);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_minterAdmins`.
     * Emits a MinterAdminAdded event.
     *
     * @param account The account account being given access to the minterAdmin role
     */
    function _addMinterAdmin(address account) internal {
        _minterAdmins.add(account);
        emit MinterAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_minterAdmins`.
     * Emits a MinterAdminRemoved event.
     *
     * @param account The account account having access removed from the minterAdmin role
     */
    function _removeMinterAdmin(address account) internal {
        _minterAdmins.remove(account);
        emit MinterAdminRemoved(account);
    }
}

// File: contracts/access/roles/MinterRole.sol

pragma solidity ^0.4.24;



/**
 * @title MinterRole
 *
 * @dev Role for providing access control to functions that mint tokens.
 * This contract inherits from MinterAdminRole so that minter admins can administer this role.
 */
contract MinterRole is MinterAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the minter role. */
    event MinterAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the minter role. */
    event MinterRemoved(address indexed account);

    /** Mapping of account addresses with access to the minter role. */
    Roles.Role private _minters;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the minter role.
     */
    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the minter role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the minter role, otherwise false
     */
    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the minter role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the minter role
     */
    function addMinter(address account) external onlyMinterAdmin {
        _addMinter(account);
    }

    /**
     * @dev Remove access to the minter role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the minter role
     */
    function removeMinter(address account) external onlyMinterAdmin {
        _removeMinter(account);
    }

    /**
     * @dev Renounce access to the minter role.
     * Callable by an account with the minter role.
     */
    function renounceMinter() external onlyMinter {
        _removeMinter(msg.sender);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_minters`.
     * Emits a MinterAdded event.
     *
     * @param account The account account being given access to the minter role
     */
    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_minters`.
     * Emits a MinterRemoved event.
     *
     * @param account The account account having access removed from the minter role
     */
    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: contracts/lifecycle/Mintable.sol

pragma solidity ^0.4.24;



/**
 * @title Mintable
 *
 * @dev Base contract which allows children to implement limit-based minting of tokens.
 * This contract inherits the MinterRole contract to use RBAC for administering accounts that can mint tokens.
 */
contract Mintable is MinterRole {
    using SafeMath for uint256;

    /** The amount of tokens each minter is allowed to mint. */
    mapping(address => uint256) private _minterLimits;

    /** Event emitted whenever a minter limit is updated. */
    event MinterLimitUpdated(address indexed minter, uint256 limit);

    /** Event emitted whenever tokens are minted. */
    event Mint(address indexed minter, address indexed to, uint256 value);

    /**
     * @dev Gets the amount of tokens the given `minter` is limited to minting.
     *
     * @param minter The minter account whose limit is being queried
     * @return The amount of tokens allowed to be minted
     */
    function limitOf(address minter) external view returns (uint256) {
        return _minterLimits[minter];
    }

    /**
     * @dev Extension of the MinterRole removeMinter function to additionally set minter limit to zero.
     * Callable by an account with the minterAdmin role.
     *
     * @param account The account address having access removed from the minter role
     */
    function removeMinter(address account) external onlyMinterAdmin {
        _setLimit(account, 0);
        super._removeMinter(account);
    }

    /**
     * @dev Set the amount of tokens the given `minter` is allowed to mint.
     * Callable by an account with the minterAdmin role.
     *
     * @notice This function should only be called when setting the minter's limit to zero.
     *
     * @param minter The minter account whose limit is being set
     * @param value The amount to set the minter's limit to
     */
    function setLimit(address minter, uint256 value) external onlyMinterAdmin {
        require(super.isMinter(minter));
        _setLimit(minter, value);
    }

    /**
     * @dev Increase the amount of tokens the given `minter` is allowed to mint.
     * Callable by an account with the minterAdmin role.
     *
     * @param minter The minter account whose limit is being increased
     * @param value The amount to increase the minter's limit by
     */
    function increaseLimit(address minter, uint256 value) external onlyMinterAdmin {
        require(super.isMinter(minter));
        _setLimit(minter, _minterLimits[minter].add(value));
    }

    /**
     * @dev Decrease the amount of tokens the given `_minter` is allowed to mint.
     * Callable by an account with the minterAdmin role.
     *
     * @param minter The minter account whose limit is being decreased
     * @param value The amount to decrease the minter's limit by
     */
    function decreaseLimit(address minter, uint256 value) external onlyMinterAdmin {
        require(super.isMinter(minter));
        _setLimit(minter, _minterLimits[minter].sub(value));
    }

    /**
     * @dev Add the given `minter` account address as a minter and set their limit to the given `_value`.
     * Callable by an account with the minterAdmin role.
     *
     * @notice This is a batch utility function so two separate transactions don't need to be sent.
     *
     * @param minter The account address to assign to the minter role
     * @param value The amount to set the minter's limit to
     */
    function addMinterAndSetLimit(address minter, uint256 value) external onlyMinterAdmin {
        super._addMinter(minter);
        _setLimit(minter, value);
    }

    /**
     * @dev Internal function that sets the limit of a minter in the private mapping of `_minterLimits`.
     * Emits a MinterLimitUpdated event.
     *
     * @param minter The minter account whose limit is being updated
     * @param limit The amount of tokens to set the minter's limit to
     */
    function _setLimit(address minter, uint256 limit) internal {
        _minterLimits[minter] = limit;
        emit MinterLimitUpdated(minter, limit);
    }

    /**
     * @dev Internal function that should be called whenever new tokens are being minted as it encapsulates limit logic.
     * Emits a Mint event.
     *
     * @param minter The account that is minting the tokens
     * @param to The account the tokens are being minted to
     * @param value The amount of tokens being minted
     */
    function _mint(address minter, address to, uint256 value) internal {
        require(to != address(0));
        require(value > 0);
        _minterLimits[minter] = _minterLimits[minter].sub(value);
        emit Mint(minter, to, value);
    }
}

// File: contracts/lifecycle/Burnable.sol

pragma solidity ^0.4.24;



/**
 * @title Burnable
 *
 * @dev Base contract which allows children to implement burning of tokens by transferring to a `_burnAddress`.
 * This contract inherits the OwnerRole contract to use RBAC for updating the `_burnAddress`.
 */
contract Burnable is OwnerRole {
    using SafeMath for uint256;

    /** Transfers made to this address are treated as burns, causing both balance and token supply to decrease. */
    address private _burnAddress;

    /** Event emitted whenever the burn address is updated. */
    event BurnAddressUpdated(address indexed previousBurnAddress, address indexed newBurnAddress);

    /** Event emitted whenever tokens are burned. */
    event Burn(address indexed burner, uint256 value);

    /**
     * @return The `_burnAddress`, for which transfers to are treated as burns
     */
    function burnAddress() external view returns (address) {
        return _burnAddress;
    }

    /**
     * @dev Assert if the given `account` is the burn address.
     *
     * @param account The address to query for
     * @return True if the given `account` is the burn address, otherwise false
     */
    function isBurnAddress(address account) external view returns (bool) {
        return _burnAddress == account;
    }

    /**
     * @dev Update the `_burnAddress` to a new address.
     * Transfers to the `newBurnAddress` will be treated as burns.
     * Callable by an account with the owner role.
     *
     * @param newBurnAddress The new address to set as the burn address
     */
    function updateBurnAddress(address newBurnAddress) external onlyOwner {
        _updateBurnAddress(newBurnAddress);
    }

    /**
     * @dev Internal function that asserts if the given `account` is the burn address.
     *
     * @param account The address to query for
     * @return True if the given `account` is the burn address, otherwise false
     */
    function _isBurnAddress(address account) internal view returns (bool) {
        return _burnAddress == account;
    }

    /**
     * @dev Internal function that updates the `_burnAddress` to a new address.
     * Emits a BurnAddressUpdated event.
     *
     * @param newBurnAddress The new address to set as the burn address
     */
    function _updateBurnAddress(address newBurnAddress) internal {
        require(newBurnAddress != address(0));
        emit BurnAddressUpdated(_burnAddress, newBurnAddress);
        _burnAddress = newBurnAddress;
    }

    /**
     * @dev Internal function that should be called whenever tokens are being burned.
     * Emits a Burn event.
     *
     * @param burner The address of the account burning tokens
     * @param value The amount of tokens being burnt
     */
    function _burn(address burner, uint256 value) internal {
        require(value > 0);
        emit Burn(burner, value);
    }
}

// File: contracts/access/roles/PauserAdminRole.sol

pragma solidity ^0.4.24;



/**
 * @title PauserAdminRole
 *
 * @dev Role for providing access control to functions that administer individual pauser roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The PauserRole contract should inherit from this contract.
 */
contract PauserAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the pauserAdmin role. */
    event PauserAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the pauserAdmin role. */
    event PauserAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the pauserAdmin role. */
    Roles.Role private _pauserAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the pauserAdmin role.
     */
    modifier onlyPauserAdmin() {
        require(isPauserAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the pauserAdmin role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the pauserAdmin role, otherwise false
     */
    function isPauserAdmin(address account) public view returns (bool) {
        return _pauserAdmins.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the pauserAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the pauserAdmin role
     */
    function addPauserAdmin(address account) external onlyOwner {
        _addPauserAdmin(account);
    }

    /**
     * @dev Remove access to the pauserAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the pauserAdmin role
     */
    function removePauserAdmin(address account) external onlyOwner {
        _removePauserAdmin(account);
    }

    /**
     * @dev Renounce access to the pauserAdmin role.
     * Callable by an account with the pauserAdmin role.
     */
    function renouncePauserAdmin() external onlyPauserAdmin {
        _removePauserAdmin(msg.sender);
    }

    /**
     * @dev Interanl function that adds the given `account` to the private mapping of `_pauserAdmins`.
     * Emits a PauserAdminAdded event.
     *
     * @param account The account account being given access to the pauserAdmin role
     */
    function _addPauserAdmin(address account) internal {
        _pauserAdmins.add(account);
        emit PauserAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_pauserAdmins`.
     * Emits a PauserAdminRemoved event.
     *
     * @param account The account account having access removed from the pauserAdmin role
     */
    function _removePauserAdmin(address account) internal {
        _pauserAdmins.remove(account);
        emit PauserAdminRemoved(account);
    }
}

// File: contracts/access/roles/PauserRole.sol

pragma solidity ^0.4.24;



/**
 * @title PauserRole
 *
 * @dev Role for providing access control to functions that pause/unpause contract functionality.
 * This contract inherits from PauserAdminRole so that pauser admins can administer this role.
 */
contract PauserRole is PauserAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the pauser role. */
    event PauserAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the pauser role. */
    event PauserRemoved(address indexed account);

    /** Mapping of account addresses with access to the pauser role. */
    Roles.Role private _pausers;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the pauser role.
     */
    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the pauser role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the pauser role, otherwise false
     */
    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the pauser role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the pauser role
     */
    function addPauser(address account) external onlyPauserAdmin {
        _addPauser(account);
    }

    /**
     * @dev Remove access to the pauser role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the pauser role
     */
    function removePauser(address account) external onlyPauserAdmin {
        _removePauser(account);
    }

    /**
     * @dev Renounce access to the pauser role.
     * Callable by an account with the pauser role.
     */
    function renouncePauser() external onlyPauser {
        _removePauser(msg.sender);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_pausers`.
     * Emits a PauserAdded event.
     *
     * @param account The account account being given access to the pauser role
     */
    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_pausers`.
     * Emits a PauserRemoved event.
     *
     * @param account The account account having access removed from the pauser role
     */
    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: contracts/lifecycle/Pausable.sol

pragma solidity ^0.4.24;


/**
 * @title Pausable
 *
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * This contract inherits the PauserRole contract to use RBAC for administering accounts that can pause/unpause.
 */
contract Pausable is PauserRole {
    /** Whether or not contract functionality is paused. */
    bool private _paused;

    /** Event emitted whenever the contract is set to the paused state. */
    event Paused(address indexed pauser);

    /** Event emitted whenever the contract is unset from the paused state. */
    event Unpaused(address indexed pauser);

    /**
     * @dev Constructor.
     * Initializes the contract state to unpaused.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev Query whether the contract is paused or not.
     *
     * @return True if the contract is paused, otherwise false
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Pauses by setting `_paused` to true, to trigger stopped state.
     * Callable by an account with the pauser role.
     */
    function pause() external onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Unpauses by setting `_paused` to false, to return to normal state.
     * Callable by an account with the pauser role.
     */
    function unpause() external onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/access/roles/ListerAdminRole.sol

pragma solidity ^0.4.24;



/**
 * @title ListerAdminRole
 *
 * @dev Role for providing access control to functions that administer individual lister roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The ListerRole contract should inherit from this contract.
 */
contract ListerAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the listerAdmin role. */
    event ListerAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the listerAdmin role. */
    event ListerAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the listerAdmin role. */
    Roles.Role private _listerAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the listerAdmin role.
     */
    modifier onlyListerAdmin() {
        require(isListerAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the listerAdmin role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the listerAdmin role, otherwise false
     */
    function isListerAdmin(address account) public view returns (bool) {
        return _listerAdmins.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the listerAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the listerAdmin role
     */
    function addListerAdmin(address account) external onlyOwner {
        _addListerAdmin(account);
    }

    /**
     * @dev Remove access to the listerAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the listerAdmin role
     */
    function removeListerAdmin(address account) external onlyOwner {
        _removeListerAdmin(account);
    }

    /**
     * @dev Renounce access to the listerAdmin role.
     * Callable by an account with the listerAdmin role.
     */
    function renounceListerAdmin() external onlyListerAdmin {
        _removeListerAdmin(msg.sender);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_listerAdmins`.
     * Emits a ListerAdminAdded event.
     *
     * @param account The account account being given access to the listerAdmin role
     */
    function _addListerAdmin(address account) internal {
        _listerAdmins.add(account);
        emit ListerAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_listerAdmins`.
     * Emits a ListAdminRemoved event.
     *
     * @param account The account account having access removed from the listerAdmin role
     */
    function _removeListerAdmin(address account) internal {
        _listerAdmins.remove(account);
        emit ListerAdminRemoved(account);
    }
}

// File: contracts/access/roles/ListerRole.sol

pragma solidity ^0.4.24;



/**
 * @title ListerRole
 *
 * @dev Role for providing access control to functions that add/remove accounts to/from a blacklist.
 * This contract inherits from ListerAdminRole so that lister admins can administer this role.
 */
contract ListerRole is ListerAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the lister role. */
    event ListerAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the lister role. */
    event ListerRemoved(address indexed account);

    /** Mapping of account addresses with access to the lister role. */
    Roles.Role private _listers;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the lister role.
     */
    modifier onlyLister() {
        require(isLister(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the lister role.
     *
     * @param account The address to query for
     * @return True if the given `account` has access to the lister role, otherwise false
     */
    function isLister(address account) public view returns (bool) {
        return _listers.has(account);
    }

    /**
     * @dev Provide the given `account` with access to the lister role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the lister role
     */
    function addLister(address account) external onlyListerAdmin {
        _addLister(account);
    }

    /**
     * @dev Remove access to the lister role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the lister role
     */
    function removeLister(address account) external onlyListerAdmin {
        _removeLister(account);
    }

    /**
     * @dev Renounce access to the lister role.
     * Callable by an account with the lister role.
     */
    function renounceLister() external onlyLister {
        _removeLister(msg.sender);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_listers`.
     * Emits a ListerAdded event.
     *
     * @param account The account account being given access to the listerAdmin role
     */
    function _addLister(address account) internal {
        _listers.add(account);
        emit ListerAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_listers`.
     * Emits a ListerRemoved event.
     *
     * @param account The account account having access removed from the lister role
     */
    function _removeLister(address account) internal {
        _listers.remove(account);
        emit ListerRemoved(account);
    }
}

// File: contracts/storage/AddressList.sol

pragma solidity ^0.4.24;


/**
 * @title AddressList
 *
 * @dev This contract inherits the Lister contract to use RBAC for administering accounts that can update the list.
 */
contract AddressList is ListerRole {
    /** Whether or not this contract has been initialized. */
    bool private _initialized;

    /** Name of this AddressList, used as a display attribute only. */
    string private _name;

    /** Mapping of each address to whether or not they're on the list. */
    mapping (address => bool) private _onList;

    /** Event emitted whenever an address is added to the list. */
    event AddressAdded(address indexed account);

    /** Event emitted whenever an address is removed from the list. */
    event AddressRemoved(address indexed account);

    /**
     * @dev Initialize function used in place of a constructor.
     * This is required over a normal due to the constructor caveat when using proxy contracts.
     *
     * @param name The name of the address list
     */
    function initialize(string name) external {
        // Assert that the contract hasn't already been initialized
        require(!_initialized);

        // Provide the account initializing the contract with access to the owner role
        super._addOwner(msg.sender);

        // Set the name of the list
        _name = name;

        // Set the initialized state to true so the contract cannot be initialized again
        _initialized = true;
    }

    /**
     * @return True if the contract has been initialized, otherwise false
     */
    function initialized() external view returns (bool) {
        return _initialized;
    }

    /**
     * @return The name of the AddressList
     */
    function name() external view returns (string) {
        return _name;
    }

    /**
     * @dev Query whether the the given `account` is on this list or not.
     *
     * @param account The account address being queried
     * @return True if the account is on the list, otherwise false
     */
    function onList(address account) external view returns (bool) {
        return _onList[account];
    }

    /**
     * @dev Update the name of the list.
     * Callable by an account with the listerAdmin role.
     *
     * @param newName The new display name of the list
     */
    function updateName(string newName) external onlyListerAdmin {
        _name = newName;
    }

    /**
     * @dev Add the given `account` to the list.
     * Callable by an account with the lister role.
     *
     * @param account Account to add to the list
     */
    function addAddress(address account) external onlyLister {
        // Throw if the account is already on the list
        require(!_onList[account]);

        _onList[account] = true;
        emit AddressAdded(account);
    }

    /**
     * @dev Remove the given `account` from the list.
     * Callable by an account with the lister role.
     *
     * @param account Account to remove from the list
     */
    function removeAddress(address account) external onlyLister {
        // Throw if the account is not on the list
        require(_onList[account]);

        _onList[account] = false;
        emit AddressRemoved(account);
    }
}

// File: contracts/lifecycle/Blacklistable.sol

pragma solidity ^0.4.24;




/**
 * @title Blacklistable
 *
 * @dev Base contract which allows children to restrict functions based on whether an account is on a blacklist.
 * This contract inherits the OwnerRole contract to use RBAC for updating the blacklist reference.
 * This contract references an external AddressList contract that stores the mapping of blacklisted accounts.
 */
contract Blacklistable is OwnerRole {
    /** External AddressList contract storing account addresses that are blacklisted. */
    AddressList private _blacklist;

    /** Event emitted whenever the address of the AddressList contract is updated. */
    event BlacklistUpdated(address indexed previousBlacklist, address indexed newBlacklist);

    /**
     * @dev Modifier to make a function callable only when the given `account` is NOT blacklisted.
     *
     * @param account The account address to check
     */
    modifier notBlacklisted(address account) {
        require(!_blacklist.onList(account));
        _;
    }

    /**
     * @return The address of the `_blacklist` contract
     */
    function blacklist() external view returns (address) {
        return address(_blacklist);
    }

    /**
     * @dev Assert if the given `account` is the address of the current blacklist contract.
     *
     * @param account The address to query for
     * @return True if the given `account` is the address of the current blacklist contract, otherwise false
     */
    function isBlacklist(address account) external view returns (bool) {
        return address(_blacklist) == account;
    }

    /**
     * @dev Asserts if the given `account` is blacklisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is blacklisted, otherwise false
     */
    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist.onList(account);
    }

    /**
     * @dev Update the `_blacklist` to a new contract address.
     * Callable by an account with the owner role.
     *
     * @param newBlacklist The address of the new blacklist contract
     */
    function updateBlacklist(address newBlacklist) external onlyOwner {
        _updateBlacklist(newBlacklist);
    }

    /**
     * @dev Internal function that updates the `_blacklist` to a new contract address.
     * Emits a BlacklistUpdated event.
     *
     * @param newBlacklist The address of the new blacklist contract
     */
    function _updateBlacklist(address newBlacklist) internal {
        require(newBlacklist != address(0));
        require(Address.isContract(newBlacklist));
        emit BlacklistUpdated(address(_blacklist), newBlacklist);
        _blacklist = AddressList(newBlacklist);
    }
}

// File: contracts/lifecycle/Whitelistable.sol

pragma solidity ^0.4.24;




/**
 * @title Whitelistable
 *
 * @dev Base contract which allows children to restrict functions based on whether an account is on a whitelist.
 * This contract inherits the OwnerRole contract to use RBAC for updating the whitelist reference.
 * This contract references an external AddressList contract that stores the mapping of whitelisted accounts.
 */
contract Whitelistable is OwnerRole {
    /** External AddressList contract storing account addresses that are whitelisted. */
    AddressList private _whitelist;

    /** Event emitted whenever the address of the AddressList contract is updated. */
    event WhitelistUpdated(address indexed previousWhitelist, address indexed newWhitelist);

    /**
     * @return The address of the `_whitelist` contract
     */
    function whitelist() external view returns (address) {
        return address(_whitelist);
    }

    /**
     * @dev Assert if the given `account` is the address of the current whitelist contract.
     *
     * @param account The address to query for
     * @return True if the given `account` is the address of the current whitelist contract, otherwise false
     */
    function isWhitelist(address account) external view returns (bool) {
        return address(_whitelist) == account;
    }

    /**
     * @dev Assert if the given `account` is whitelisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is whitelisted, otherwise false
     */
    function isWhitelisted(address account) external view returns (bool) {
        return _whitelist.onList(account);
    }

    /**
     * @dev Update the `_whitelist` to a new contract address.
     * Callable by an account with the owner role.
     *
     * @param newWhitelist The address of the new whitelist contract
     */
    function updateWhitelist(address newWhitelist) external onlyOwner {
        _updateWhitelist(newWhitelist);
    }

    /**
     * @dev Internal function that asserts if the given `account` is whitelisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is whitelisted, otherwise false
     */
    function _isWhitelisted(address account) internal view returns (bool) {
        return _whitelist.onList(account);
    }

    /**
     * @dev Internal function that updates the `_whitelist` to a new contract address.
     * Emits a WhitelistUpdated event.
     *
     * @param newWhitelist The address of the new whitelist contract
     */
    function _updateWhitelist(address newWhitelist) internal {
        require(newWhitelist != address(0));
        require(Address.isContract(newWhitelist));
        emit WhitelistUpdated(address(_whitelist), newWhitelist);
        _whitelist = AddressList(newWhitelist);
    }
}

// File: contracts/TokenImpl.sol

pragma solidity ^0.4.24;








/**
 * @title TokenImpl
 *
 * @dev This contract is the token implementation contract encapsulating all logic for the token.
 *
 * It inherits the ERC20 contract to provide ERC20 token functionality.
 * It inherits the Mintable contract to provide mint functionality.
 * It inherits the Burnable contract to provide burn functionality.
 * It inherits the Pausable contract to provide pause normal token functionality.
 * It inherits the Blacklistable contract to restrict blacklisted accounts from sending/receiving tokens.
 * It inherits the Whitelistable contract to allow whitelisted accounts to burn their own tokens.
 */
contract TokenImpl is ERC20, Mintable, Burnable, Pausable, Blacklistable, Whitelistable {
    using SafeMath for uint256;

    /** Whether or not this contract has been initialized. */
    bool private _initialized;

    /** Descriptive attributes, for display purposes. */
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Initialize function used in place of a constructor.
     * This is required over a normal due to the constructor caveat when using proxy contracts.
     *
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param decimals The number decimals of the token
     * @param burnAddress The address for which transfers to are treated as burns
     * @param blacklist The address of the AddressList contract being used as a blacklist
     * @param whitelist The address of the AddressList contract being used as a whitelist
     */
    function initialize(
        string name,
        string symbol,
        uint8 decimals,
        address burnAddress,
        address blacklist,
        address whitelist
    ) external {
        // Assert that the contract hasn't already been initialized
        require(!_initialized);

        // Provide the account initializing the contract with access to the owner role
        super._addOwner(msg.sender);

        // Set descriptive attributes
        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        // Set burn address
        super._updateBurnAddress(burnAddress);

        // Set blacklist and whitelist contract addresses
        super._updateBlacklist(blacklist);
        super._updateWhitelist(whitelist);

        // Set the initialized state to true so the contract cannot be initialized again
        _initialized = true;
    }

    /**
     * @return True if the contract has been initialized, otherwise false
     */
    function initialized() external view returns (bool) {
        return _initialized;
    }

    /**
     * @return The name of the token
     */
    function name() external view returns (string) {
        return _name;
    }

    /**
     * @return The symbol of the token
     */
    function symbol() external view returns (string) {
        return _symbol;
    }

    /**
     * @return The number of decimals of the token
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Extension of the ERC20 transfer function to enforce lifecycle behaviours and support burns.
     * If `to` is the `_burnAddress` the call will be treated as a burn and the caller must be whitelisted.
     * If burning this function calls `Burnable._burn()` for additional burn logic, and emitting the Burn event.
     * If burning this function calls `ERC20._burn()` for balance/total supply logic, and emitting the Transfer event.
     *
     * @notice Transfer to the `_burnAddress` if you wish to redeem tokens.
     *
     * @param to The address to transfer to, or the `_burnAddress` if caller wishes to burn their tokens
     * @param value The amount of tokens to transfer, or to burn
     */
    function transfer(address to, uint256 value)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        // If the recipient is the burn address then treat the transaction as a burn instead of a transfer
        if (super._isBurnAddress(to)) {
            // Ensure the account burning the tokens has been whitelisted
            require(super._isWhitelisted(msg.sender));

            // Handle additional burn logic and emit Burn event
            Burnable._burn(msg.sender, value);

            // Decrease token balance/total supply and emit Transfer event
            ERC20._burn(msg.sender, value);

            return true;
        } else {
            // Normal ERC20 transfer
            return super.transfer(to, value);
        }
    }

    /**
     * @dev Extension of the ERC20 approve function to enforce lifecycle behaviours.
     *
     * @notice Only use this function to set the spender allowance to zero.
     * To increment allowed value use the increaseAllowance function.
     * To decrement allowed value use the decreaseAllowance function.
     */
    function approve(address spender, uint256 value)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        return super.approve(spender, value);
    }

    /**
     * @dev Extension of the ERC20 approve function to enforce lifecycle behaviours.
     */
    function transferFrom(address from, address to, uint256 value)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        // Do not allow transferFrom when the recipient is the burn address
        require(!super._isBurnAddress(to));

        return super.transferFrom(from, to, value);
    }

    /**
     * @dev Extension of the ERC20 increaseApproval function to enforce lifecycle behaviours.
     */
    function increaseAllowance(address spender, uint addedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev Extension of the ERC20 decreaseApproval function to enforce lifecycle behaviours.
     */
    function decreaseAllowance(address spender, uint subtractedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }


    /**
     * @dev Mints new tokens to the given `_to` account.
     * This function calls `Mintable._mint()` for minter limit logic, and emitting the Mint event.
     * This function calls `ERC20._mint()` for balance/total supply logic, and emitting the Transfer event.
     * Callable by an account with the minter role.
     *
     * @param to The account the tokens are being minted to
     * @param value The amount of tokens being minted
     */
    function mint(address to, uint256 value)
        external
        whenNotPaused
        onlyMinter
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        // Decrease minter limit logic and emit Mint event
        Mintable._mint(msg.sender, to, value);

        // Increase token balance/total supply and emit Transfer event
        ERC20._mint(to, value);

        return true;
    }
}
