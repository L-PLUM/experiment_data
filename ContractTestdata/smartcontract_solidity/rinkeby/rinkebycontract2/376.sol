/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/DShops.sol

pragma solidity 0.5.10;



/// @title DShops - Online Market Place Contract
/// @author Chet S
contract DShops is Pausable {
    using SafeMath for uint256;

    //////////////////////////////////////// State Variables & Mappings

    address private contractOwner;

    mapping(address => AdminStruct) private admins;
    address[] private adminIndexes;

    mapping(address => StoreOwnerApplicantStruct) private storeOwnerApplicants;
    address[] private storeOwnerApplicantIndexes;

    mapping(address => StoreOwnerStruct) private storeOwners;
    address[] private storeOwnerIndexes;

    mapping(bytes32 => storefrontStruct) private storefronts; // bytes32 represents uniqueId
    bytes32[] private storefrontIndexes; // bytes32[] stores a collection of uniqueIds

    mapping(bytes32 => ProductStruct) private products; // bytes32 represents productCode
    bytes32[] private productIndexes; // bytes32[] stores a collection of productCodes

    mapping(uint256 => OrderStruct) private orders;
    uint256[] orderIndexes;

    //////////////////////////////////////// Enums

    enum StoreOwnerApplicantStatus {None, Applied, Approved}

    //////////////////////////////////////// Structs
    struct AdminStruct {
        uint256 index;
    }

    struct StoreOwnerApplicantStruct {
        StoreOwnerApplicantStatus status;
        string name;
        uint256 index;
    }

    struct StoreOwnerStruct {
        bytes32[] storefrontUniqueIds;
        string name;
        uint256 index;
    }

    struct storefrontStruct {
        string storefrontName;
        address payable storeOwner;
        uint256 balance;
        mapping(bytes32 => uint256) productCodeIndexes;
        bytes32[] productCodes;
        uint256 index;
    }

    struct ProductStruct {
        bytes32 storefrontUniqueId;
        string name;
        uint256 price;
        uint256 availQty;
        uint256 index;
        string infoHash;
        string imageHash;
    }

    struct OrderStruct {
        bytes32 storefrontUniqueId;
        bytes32 productCode;
        uint256 qty;
        uint256 amount;
        address buyer;
    }

    //////////////////////////////////////// Contructor

    /// @notice Assign msg.sender as the contractOwner as well as an Admin
    constructor() public {
        contractOwner = msg.sender;
        assignUserAsAdmin(msg.sender);
    }

    //////////////////////////////////////// Modifiers

    modifier onlyAdmin() {
        if (adminIndexes.length > 0) {
            require(isAdmin(msg.sender), "msg.sender must be an admin!");
        } else {
            require(contractOwner == msg.sender, "msg.sender must at least the contract owner!");
        }
        _;
    }

    modifier onlyStoreOwner() {
        require(isStoreOwner(msg.sender), "msg.sender must be a store owner");
        _;
    }

    //////////////////////////////////////// Events

    event LogAssignUserAsAdmin(address indexed adminAddr);
    event LogRequestToBeStoreOwner(address indexed storeOwnerApplicantAddr);
    event LogApproveStoreOwner(address indexed storeOwnerAddr);
    event LogCreateStorefront(bytes32 indexed storefrontUniqueId);
    event LogCreateProduct(bytes32 indexed productCode);
    event LogDeleteProduct(bytes32 indexed productCode);
    event LogUpdateProduct(bytes32 indexed productCode);
    event LogBuyProduct(address indexed buyer, bytes32 indexed productCode);
    event LogWithdrawBalanceFromStorefront(bytes32 indexed storefrontUniqueId);

    //////////////////////////////////////// Functions

    /// @notice Check if a user is an Admin or not
    /// @param userAddr The address of the user
    /// @return userIsAdmin as a boolean true or false
    function isAdmin(address userAddr) public view returns (bool userIsAdmin) {
        if (adminIndexes.length == 0) return false;
        return (adminIndexes[admins[userAddr].index] == userAddr);
    }

    /// @notice Assign a non-admin user as an Admin. Only an Admin can invoke this function
    /// and when the contract is not paused.
    /// @param userAddr The address to be assigned as an Admin
    /// @return index (uint256) of the added admin
    function assignUserAsAdmin(address userAddr)
        public
        whenNotPaused
        onlyAdmin
        returns (uint256 index)
    {
        require(!isAdmin(userAddr), "Operation aborted. User is already an Admin");
        admins[userAddr].index = (adminIndexes.push(userAddr)).sub(1);
        emit LogAssignUserAsAdmin(userAddr);
        return (adminIndexes.length).sub(1);
    }

    /// @notice Get the total number of Admins
    /// @return count The total number of Admins in uint256
    function getAdminsCount() public view returns (uint256 count) {
        return (adminIndexes.length);
    }

    /// @notice Get the address of an Admin by an index
    /// @param index The index of the Admin
    /// @return adminAddr The address of the Admin
    function getAdminByIndex(uint256 index) public view returns (address adminAddr) {
        require(storeOwnerIndexes.length > 0, "Operation aborted. No store owner to retrieve");
        adminAddr = storeOwnerIndexes[index];
        return (adminAddr);
    }

    /// @notice Get the total number of Store Owner Applicants
    /// @return count The total number of Store Owner Applicants in uint256
    function getStoreOwnerApplicantsCount() public view returns (uint256 count) {
        return (storeOwnerApplicantIndexes.length);
    }

    /// @notice Get the Store Owner Applicant by index
    /// @dev The storeOwnerApplicants contains data such as store owner name (name)
    /// and the application status (status). The storeOwnerApplicantIndexes is
    /// an array containing the store owner applicant addresses
    /// @param index The index of the store owner applicant
    /// @return userIsAdmin as a boolean true or false
    function getStoreOwnerApplicantByIndex(uint256 index)
        public
        view
        returns (
            address storeOwnerApplicantAddr,
            string memory storeOwnerApplicantName,
            StoreOwnerApplicantStatus status
        )
    {
        require(
            storeOwnerApplicantIndexes.length > 0,
            "Operation aborted. No store owner applicant to retrieve"
        );
        /// Get the address of the store owner using the index
        /// and then use the address as the key to access the
        /// store owner applicant details such as name and status
        storeOwnerApplicantAddr = storeOwnerApplicantIndexes[index];
        return (
            storeOwnerApplicantAddr,
            storeOwnerApplicants[storeOwnerApplicantAddr].name,
            storeOwnerApplicants[storeOwnerApplicantAddr].status
        );
    }

    /// @notice Check if a user is a store owner applicant
    /// @param userAddr The address of the user
    /// @return userIsStoreOwnerApplicant The boolean result
    function isStoreOwnerApplicant(address userAddr)
        public
        view
        returns (bool userIsStoreOwnerApplicant)
    {
        if (storeOwnerApplicantIndexes.length == 0) return false;
        return (storeOwnerApplicantIndexes[storeOwnerApplicants[userAddr].index] == userAddr);
    }

    /// @notice Make a user become a store owner applicant. Any user can make this request.
    /// @dev Only the first time applicant can be made an applicant. OpenZeppelin SafeMath is used
    /// @param applicantAddr The address of the store owner applicant
    /// @return index of the added store owner applicant in uint256
    function requestToBeStoreOwner(address applicantAddr, string memory applicantName)
        public
        whenNotPaused
        returns (uint256 index)
    {
        require(
            !isStoreOwnerApplicant(applicantAddr),
            "Request ignored. The user is already an Applicant"
        );
        /// Update initialize the status with 'Applied' and assign applicant name
        storeOwnerApplicants[applicantAddr].status = StoreOwnerApplicantStatus.Applied;
        storeOwnerApplicants[applicantAddr].name = applicantName;
        /// storeOnerApplicantIndexes.push would return the updated length of the array,
        /// subtract it by 1 would be the index of this newly added applicant
        /// OpenZeppelin SafeMath is used .sub(1)
        storeOwnerApplicants[applicantAddr].index = (storeOwnerApplicantIndexes.push(applicantAddr))
            .sub(1);
        emit LogRequestToBeStoreOwner(applicantAddr);
        return (storeOwnerApplicantIndexes.length).sub(1);
    }

    /// @notice Add store owner applicant into the list of approved store owners.
    /// Only Admin is allow to invoke this function
    /// @param applicantAddr The address of the store owner applicant
    /// @return index The uint256 index of the approved store owner indexes array
    function approveStoreOwner(address applicantAddr)
        public
        whenNotPaused
        onlyAdmin
        returns (uint256 index)
    {
        require(isStoreOwnerApplicant(applicantAddr), "User must be a store applicant first");
        require(
            storeOwnerApplicants[applicantAddr].status == StoreOwnerApplicantStatus.Applied,
            "User must be in the status of applied"
        );
        /// Update the store owner applicant's application status to 'Approved'
        storeOwnerApplicants[applicantAddr].status = StoreOwnerApplicantStatus.Approved;
        /// Add the new store owner into storeOwners using the applicantAddr as the key
        /// storeOwners maps to a struct which holds the storeOwner's information
        /// storeOwnerIndexes is an array containing the storeOwner addresses
        /// Adding a store owner involves updating both the storeOwners and storeOwnerIndexes
        storeOwners[applicantAddr].name = storeOwnerApplicants[applicantAddr].name;
        storeOwners[applicantAddr].index = (storeOwnerIndexes.push(applicantAddr)).sub(1);
        emit LogApproveStoreOwner(applicantAddr);
        return (storeOwnerIndexes.length).sub(1);
    }

    /// @notice Check if a user is a store owner or not
    /// @param userAddr The address of the user
    /// @return userIsStoreOwner The boolean result
    function isStoreOwner(address userAddr) public view returns (bool userIsStoreOwner) {
        if (storeOwnerIndexes.length == 0) return false;
        return (storeOwnerIndexes[storeOwners[userAddr].index] == userAddr);
    }

    /// @notice Get the total number of store owners
    /// @return count The total number of store owners in uint256
    function getStoreOwnersCount() public view returns (uint256 count) {
        return (storeOwnerIndexes.length);
    }

    /// @notice Get a store owner's data by Index
    /// @param index The index of the store owner
    /// @return storeOwnerAddr The address of the store owner
    /// @return storeOwnerName The store owner name
    /// @return storefrontsCount The total number of storefronts the store owner has
    function getStoreOwnerByIndex(uint256 index)
        public
        view
        returns (address storeOwnerAddr, string memory storeOwnerName, uint256 storefrontsCount)
    {
        require(storeOwnerIndexes.length > 0, "Operation aborted. No store owner to retrieve");
        storeOwnerAddr = storeOwnerIndexes[index];
        return (
            storeOwnerAddr,
            storeOwners[storeOwnerAddr].name,
            storeOwners[storeOwnerAddr].storefrontUniqueIds.length
        );
    }

    /// @notice Get a store owner's data by store owner's address
    /// @param addr The address of the store owner
    /// @return storeOwnerAddr The address of the store owner
    /// @return storeOwnerName The store owner name
    /// @return storefrontsCount The total number of storefronts the store owner has
    function getStoreOwner(address addr)
        public
        view
        returns (uint256 storeOwnerIndex, string memory storeOwnerName, uint256 storefrontsCount)
    {
        storeOwnerIndex = storeOwners[addr].index;
        storeOwnerName = storeOwners[addr].name;
        storefrontsCount = storeOwners[addr].storefrontUniqueIds.length;
        return (storeOwnerIndex, storeOwnerName, storefrontsCount);
    }

    /// @notice Create a storefront. Only a store owner can invoke this function.
    /// @dev A unique storefront identity would be generated based on the storefront name,
    /// a hash of the storefront name would be generated.
    /// Each store owner can own multiple storefronts, represented by an array of
    /// storefront unique IDs (hashes)
    /// @param newStorefrontName The name of the storefront to be created.
    /// @return index The index of the newly added storefront
    function createStorefront(string memory newStorefrontName)
        public
        whenNotPaused
        onlyStoreOwner
        returns (uint256 index)
    {
        /// Generate the hash to be used as the storefront unique ID
        bytes32 uniqueId = keccak256(abi.encodePacked(newStorefrontName));
        require(
            !storefrontExists(uniqueId),
            "storefront name or storefront uniqueId already exists!"
        );
        /// The msg.sender should be the store owner.
        /// Add the newly generated hash or storefront unique Id into
        /// the storefrontUniqueIds array
        storeOwners[msg.sender].storefrontUniqueIds.push(uniqueId);
        /// Populate the store owner's storefront record with the details
        /// Both storefronts (mapping to storefront struct) and
        /// storefrontIndexes (array of hashes) would be updated accordingly
        storefronts[uniqueId].storeOwner = msg.sender;
        storefronts[uniqueId].index = (storefrontIndexes.push(uniqueId)).sub(1);
        storefronts[uniqueId].storefrontName = newStorefrontName;
        storefronts[uniqueId].balance = 0;
        emit LogCreateStorefront(uniqueId);
        return (storefrontIndexes.length).sub(1);
    }

    /// @notice Get the total number of storefronts of all store owners
    /// @return count The total number of storefronts of all store owners in uint256
    function getStorefrontsCount() public view returns (uint256 count) {
        return storefrontIndexes.length;
    }

    /// @notice Get the total number of storefronts of a particular store owner.
    /// Must provide a valid store owner's address
    /// @param storeOwnerAddr The storeowner's address
    /// @return count The total number of storefronts of a store store owner in uint256
    function getStorefrontsCountForStoreOwner(address storeOwnerAddr)
        public
        view
        returns (uint256 count)
    {
        require(isStoreOwner(storeOwnerAddr), "Input address must be a store owner address");
        return storeOwners[storeOwnerAddr].storefrontUniqueIds.length;
    }

    /// @notice Get the data of a storeowner's storefront by the storefront index
    /// @dev Get the data from the storefrontUniqueIds array based on index,
    /// where the storefrontUniqueIds belongs to a store owner identified by
    /// the storeOwnerAddr
    /// @param storeOwnerAddr The address of the store owner
    /// @param index The index (unint256) for fetching the storefront hash in the
    /// storefrontUniqueIds array
    /// @return storefrontName The name of the store owner's storefront indexed by index
    /// @return storefrontUniqueId The storefront unique id or hash
    /// @return productsCount The total number of products that the storefront has
    /// @return balance The balance in uint256 (wei) that the storefront has.
    /// The true balance will only be revealed to the storeowner who invokes this function.
    /// Non store owner to this storefront will only see zero for the balance.
    function getStorefrontForStoreOwnerByIndex(address storeOwnerAddr, uint256 index)
        public
        view
        returns (
            string memory storefrontName,
            bytes32 storefrontUniqueId,
            uint256 productsCount,
            uint256 balance
        )
    {
        /// Only the store owner who owns this storefront will get to see the actual balance,
        /// others would see a zero balance
        if (msg.sender == storeOwnerAddr)
            balance = storefronts[storeOwners[storeOwnerAddr].storefrontUniqueIds[index]].balance;
        else balance = 0;
        return (
            storefronts[storeOwners[storeOwnerAddr].storefrontUniqueIds[index]].storefrontName,
            storeOwners[storeOwnerAddr].storefrontUniqueIds[index],
            storefronts[storeOwners[storeOwnerAddr].storefrontUniqueIds[index]].productCodes.length,
            balance
        );
    }

    /// @notice Get a storefront by index, irrespective of store owner
    /// @dev Get the storefront by using the index to access the storefrontIndexes array
    /// @param index The index of the storefront, represented in storefrontIndexes
    /// @return uniqueId The unique storefront Id or hash
    /// @return storefrontName The storefront name
    /// @return storeOwner The store owner's address that owns this storefront
    /// @return productCodes The array of bytes32 representing the product codes that
    /// this storefront owns
    function getStorefrontByIndex(uint256 index)
        public
        view
        returns (
            bytes32 uniqueId,
            string memory storefrontName,
            address storeOwner,
            uint256 productsCount,
            bytes32[] memory productCodes
        )
    {
        uniqueId = storefrontIndexes[index];
        productCodes = storefronts[uniqueId].productCodes;
        return (
            uniqueId,
            storefronts[uniqueId].storefrontName,
            storefronts[uniqueId].storeOwner,
            storefronts[uniqueId].productCodes.length,
            productCodes
        );
    }

    /// @notice Get as storefront by its storefront unique id or hash
    /// @param storefrontUniqueId The storefront unique id or hash
    /// @return storefrontName The storefront name
    /// @return storeOwner The storeowner's address who owns this storefront
    /// @return productsCount The total number of products that the storefront has
    /// @return balance The balance in uint256 (wei) that the storefront has.
    /// The true balance will only be revealed to the storeowner who invokes this function.
    /// Non store owner to this storefront will only see zero for the balance.
    function getStorefront(bytes32 storefrontUniqueId)
        public
        view
        returns (
            string memory storefrontName,
            address storeOwner,
            uint256 productsCount,
            uint256 index,
            uint256 balance
        )
    {
        require(storefrontExists(storefrontUniqueId), "storefront does not exist!");
        storefrontName = storefronts[storefrontUniqueId].storefrontName;
        storeOwner = storefronts[storefrontUniqueId].storeOwner;
        productsCount = storefronts[storefrontUniqueId].productCodes.length;
        index = storefronts[storefrontUniqueId].index;
        if (msg.sender == storeOwner) balance = storefronts[storefrontUniqueId].balance;
        else balance = 0; // Only store owner can access to the balance
        return (storefrontName, storeOwner, productsCount, index, balance);
    }

    /// @notice Check if a storefront exists, using its storefront unique id or hash
    /// @param uniqueId The storefront unique id or hash
    /// @return doesExist The boolean result of whether the storefront exists
    function storefrontExists(bytes32 uniqueId) public view returns (bool doesExist) {
        if (storefrontIndexes.length == 0) return false;
        return (storefrontIndexes[storefronts[uniqueId].index] == uniqueId);
    }

    /// @notice Check if a product exists by its productCode
    /// @param productCode The productCode
    /// @return doesExist The boolean result of whether the product exists
    function productExists(bytes32 productCode) public view returns (bool doesExist) {
        if (productIndexes.length == 0) return false;
        return (productIndexes[products[productCode].index] == productCode);
    }

    /// @notice Create a product for a storefront. Only store owner of the storefront
    /// can invoke this function
    /// @dev Creating a product involves updating products, productIndexes,
    /// storefronts' productCodes (array of product codes) and storefront's
    /// productCodeIndexes (mapping of productCode to index)
    /// @param storefrontUniqueId The storefront unique id or hash
    /// @param productCode The product code of the product.
    /// This should be a hex generated code based on the product name.
    /// The frontend app should generate this
    /// @param newProductName The name of the product
    /// @param price The unit price of the product
    /// @param availQty The available quantity for the product
    /// @param infoHash The IPFS hash for accessing the product info stored in IPFS
    /// @param imageHash The IPFS hash for accessing the product image stored in IPFS
    /// @return index The index of the created product in uint256
    function createProduct(
        bytes32 storefrontUniqueId,
        bytes32 productCode,
        string memory newProductName,
        uint256 price,
        uint256 availQty,
        string memory infoHash,
        string memory imageHash
    ) public whenNotPaused onlyStoreOwner returns (uint256 index) {
        require(storefrontExists(storefrontUniqueId), "storefront does not exist!");
        require(
            storefronts[storefrontUniqueId].storeOwner == msg.sender,
            "user is not the storefront owner"
        );
        require(!productExists(productCode), "Product Code already exists!");
        /// Add the productCode into storefront's productCodes array
        /// and at the same time update the storefront's productCodeIndexes
        /// with the index of the inserted productCode
        storefronts[storefrontUniqueId]
            .productCodeIndexes[productCode] = storefronts[storefrontUniqueId]
            .productCodes
            .push(productCode)
            .sub(1);
        /// Add the product info into products
        /// at the same time update productIndexes.
        /// The product index is derived from the productIndexes.push subtracted by 1
        products[productCode].storefrontUniqueId = storefrontUniqueId;
        products[productCode].name = newProductName;
        products[productCode].price = price;
        products[productCode].availQty = availQty;
        products[productCode].infoHash = infoHash;
        products[productCode].imageHash = imageHash;
        products[productCode].index = (productIndexes.push(productCode)).sub(1);
        emit LogCreateProduct(productCode);
        return productIndexes.length.sub(1);
    }

    /// @notice Update the price of a product. Only the store owner of the storefront
    /// that owns the product can invoke this function
    /// @param productCode The product code of the product to be updated
    /// @param newPrice The new product price to replace the old product price
    function updateProductPrice(bytes32 productCode, uint256 newPrice)
        public
        whenNotPaused
        onlyStoreOwner
    {
        require(productExists(productCode), "Product does not exist!");
        bytes32 storefrontUniqueId = products[productCode].storefrontUniqueId;
        require(
            msg.sender == storefronts[storefrontUniqueId].storeOwner,
            "Only store owner of product can update the price!"
        );
        products[productCode].price = newPrice;
        emit LogUpdateProduct(productCode);
    }

    /// @notice Delete a product by its productCode. Only the store owner of
    /// the storefront that owns the product can invoke this function
    /// @dev Delete requires updates to the products, productIndexes,
    /// storefront's productCodes and storefront's productIndexes
    /// @param productCode The productCode of the product to be deleted
    function deleteProduct(bytes32 productCode) public whenNotPaused onlyStoreOwner {
        require(productExists(productCode), "Product does not exist!");

        // Get the index (uint256) of the productCode of the products mappping
        // We name this index rowToDelete
        // We will use this index later to swap position of the last item in the productIndexes array
        // with the item we want to delete (productCode) in the array
        uint256 rowToDelete = products[productCode].index;

        // Get the product code of the last item in the productIndexes array
        bytes32 keyToMove = productIndexes[productIndexes.length.sub(1)];

        // Swap the position of the last item in the productIndexes
        // with the position of the productCode we want to delete
        productIndexes[rowToDelete] = keyToMove;
        products[keyToMove].index = rowToDelete;
        // Now we delete the last item in the productIndexes which contains the productCode
        productIndexes.pop();

        // Remove the associated productCode stored in the corresponding storefront
        // First, we get the storefrontUniqueId based on input productCode
        bytes32 storeId = products[productCode].storefrontUniqueId;

        // Get the index (uint256) of the productCode of the array productCodes in the storefront
        // We name this index rowToDelete
        // We will use this index later to swap position of the last item in the array
        // with the item we want to delete (productCode)
        rowToDelete = storefronts[storeId].productCodeIndexes[productCode];

        // Get the index of the last item in the array productCodes of the storefront
        // for the swapping mentioned above
        uint256 lastIndex = storefronts[storeId].productCodes.length.sub(1);

        // Get the content (a product code) of the last item in the array productCodes
        // using the lastIndex we obtained above
        keyToMove = storefronts[storeId].productCodes[lastIndex];

        // Now we swap the content (product code) of the last item with the item we want to delete
        storefronts[storeId].productCodes[rowToDelete] = keyToMove;
        storefronts[storeId].productCodes[lastIndex] = productCode;

        // We also need to update the productCodeIndexes in the storefront
        // to reflect the swapping took place above
        storefronts[storeId].productCodeIndexes[keyToMove] = rowToDelete;
        storefronts[storeId].productCodeIndexes[productCode] = lastIndex;

        // Now we can remove the last item of the productCodes array which contains the productCode
        storefronts[storeId].productCodes.pop();
        // Also remove the mapping of the productCodeIndexes
        // Note that deleted mapping would still be referencable but the result would be zero
        // So the zero result can mean index 0 or no mapping found, keep in mind
        delete storefronts[storeId].productCodeIndexes[productCode];

        // Remove the product from the mapping(bytes32=>ProductStruct) products
        // We do it here at the end so that fetch the storefrontUniqueId, storeId above
        delete products[productCode];
        emit LogDeleteProduct(productCode);
    }

    /// @notice Get the total number of products of all storefronts
    /// @return count The total number of products of all storefronts in uint256
    function getProductsCount() public view returns (uint256 count) {
        return productIndexes.length;
    }

    /// @notice Get product data by its productCode
    /// @param productCode The product code of the product
    /// @return productName The name of the product
    /// @return price The unit price of the product
    /// @return availQty The available quantity for the product
    /// @return index The index for accessing this product via productIndexes
    /// @return infoHash The IPFS hash for accesing the product information
    /// @return imageHash The IPFS hash for accessing the product image
    function getProduct(bytes32 productCode)
        public
        view
        returns (
            string memory productName,
            uint256 price,
            uint256 availQty,
            uint256 index,
            string memory infoHash,
            string memory imageHash
        )
    {
        require(productExists(productCode), "product does not exist!");
        productName = products[productCode].name;
        price = products[productCode].price;
        availQty = products[productCode].availQty;
        index = products[productCode].index;
        infoHash = products[productCode].infoHash;
        imageHash = products[productCode].imageHash;
        return (productName, price, availQty, index, infoHash, imageHash);
    }

    /// @notice Get the product data by its index
    /// @param index The index for accessing the product via productIndexes
    /// @return productCode The product code of the product
    /// @return productName The name of the product
    /// @return price The unit price of the product
    /// @return availQty The available quantity for the product
    /// @return infoHash The IPFS hash for accesing the product information
    /// @return imageHash The IPFS hash for accessing the product image
    function getProductByIndex(uint256 index)
        public
        view
        returns (
            bytes32 productCode,
            string memory productName,
            uint256 price,
            uint256 availQty,
            string memory infoHash,
            string memory imageHash
        )
    {
        productCode = productIndexes[index];
        return (
            productCode,
            products[productCode].name,
            products[productCode].price,
            products[productCode].availQty,
            products[productCode].infoHash,
            products[productCode].imageHash
        );
    }

    /// @notice Get the storefront's product by product Index
    /// @param storefrontUniqueId The storefront unique id or hash
    /// @param index The index for accessing the product data via productCodes
    /// @return productCode The product code of the product
    /// @return productName The name of the product
    /// @return price The unit price of the product
    /// @return availQty The available quantity for the product
    /// @return infoHash The IPFS hash for accesing the product information
    /// @return imageHash The IPFS hash for accessing the product image
    function getProductForStorefrontByIndex(bytes32 storefrontUniqueId, uint256 index)
        public
        view
        returns (
            bytes32 productCode,
            string memory productName,
            uint256 price,
            uint256 availQty,
            string memory infoHash,
            string memory imageHash
        )
    {
        require(storefrontExists(storefrontUniqueId), "storefront does not exist!");
        require(storefronts[storefrontUniqueId].productCodes.length > index, "index out of range!");
        productCode = storefronts[storefrontUniqueId].productCodes[index];
        return (
            productCode,
            products[productCode].name,
            products[productCode].price,
            products[productCode].availQty,
            products[productCode].infoHash,
            products[productCode].imageHash
        );
    }

    /// @notice Let shopper buy and pay for a product. If shopper pays more than the required amount,
    /// the shopper would be refunded. If the shopper tries to pay below the amount required, this
    /// function would reject it. If the buying quantity is more than the available quantity, this
    /// function would reject it too.
    /// @dev OpenZeppelin SafeMath is used here to prevent overflow or underflow
    /// @param productCode The product code of the product that the shopper is buying or paying for
    /// @param buyQty The quantity of the product the shopper wants to buy or pay for
    function buyProduct(bytes32 productCode, uint256 buyQty) public payable whenNotPaused {
        require(productExists(productCode), "Product does not exist!");
        require(buyQty > 0, "Buy quantity must be more than zero!");
        uint256 price = products[productCode].price;
        uint256 availQty = products[productCode].availQty;
        uint256 amountPayable = price.mul(buyQty);
        uint256 refund = 0;
        if (msg.value > amountPayable) {
            refund = msg.value.sub(amountPayable);
        }
        require(buyQty <= availQty, "Buy quantity is more than the available quantity!");
        require(msg.value >= amountPayable, "Insufficient funds to complete transaction!");
        bytes32 uniqueId = products[productCode].storefrontUniqueId;
        storefronts[uniqueId].balance = storefronts[uniqueId].balance.add(amountPayable);
        /// Deduct the available quantity of the product
        products[productCode].availQty = products[productCode].availQty.sub(buyQty);
        emit LogBuyProduct(msg.sender, productCode);
        /// If there's refund to be made, do it now
        if (refund > 0) {
            msg.sender.transfer(refund);
        }
    }

    /// @notice Withdraw the balance from a storefront,
    /// if the balance is more than zero. Only store owner of the storefront
    /// can invoke this function
    /// @param storefrontUniqueId The storefront unique id or hash
    /// @return success The boolean result whether the withdrawal is successful
    function withdrawBalanceFromStorefront(bytes32 storefrontUniqueId)
        public
        whenNotPaused
        returns (bool success)
    {
        require(storefrontExists(storefrontUniqueId), "Storefront does not exist!");
        require(
            msg.sender == storefronts[storefrontUniqueId].storeOwner,
            "Must be the owner to withdraw balance!"
        );
        uint256 balanceToWithdraw = storefronts[storefrontUniqueId].balance;
        require(balanceToWithdraw > 0, "The balance must be more than zero to withdraw!");
        storefronts[storefrontUniqueId].balance = (storefronts[storefrontUniqueId].balance).sub(
            balanceToWithdraw
        );
        emit LogWithdrawBalanceFromStorefront(storefrontUniqueId);
        msg.sender.transfer(balanceToWithdraw); // transfer balance back to store owner
        return true;
    }

    /// Fallback function
    function() external {
        revert("");
    }

}
