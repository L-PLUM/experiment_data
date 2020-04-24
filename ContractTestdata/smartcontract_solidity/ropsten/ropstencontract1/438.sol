/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

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
