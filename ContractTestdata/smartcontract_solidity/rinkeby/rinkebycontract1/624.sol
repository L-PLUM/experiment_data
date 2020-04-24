/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: ./contracts/modules/License/LicenseStorageModel.sol

contract LicenseStorageModel {
    event LogNewRegistration(
        uint256 registrationId,
        bytes32 name,
        address addr
    );

    event LogRegistrationDeclined(uint256 registrationId);

    event LogNewProductApproved(bytes32 name, address addr, uint256 id);

    event LogProductDisapproved(bytes32 name, address addr, uint256 id);

    event LogProductReapproved(bytes32 name, address addr, uint256 id);

    event LogProductPaused(bytes32 name, address addr, uint256 id);

    event LogProductUnpaused(bytes32 name, address addr, uint256 id);

    struct Registration {
        bytes32 name;
        address addr;
        bytes32 policyFlow;
        uint256 release;
        bool declined;
    }

    struct Product {
        bytes32 name;
        address addr;
        bytes32 policyFlow;
        uint256 release; // core
        // uint256 applicationRelease
        address policyToken;
        bool approved;
        bool paused;
    }

    /**
     * @dev Registration array
     */
    Registration[] public registrations;

    /**
     * @dev Products
     */
    Product[] public products;

    /**
     * @dev Get product id by contract's address
     */
    mapping(address => uint256) public productIdByAddress;
}

// File: ./contracts/shared/BaseModuleController.sol

contract BaseModuleController {
    address public delegator;

    function _assignStorage(address _storage) internal {
        delegator = _storage;
    }
}

// File: ./contracts/modules/registry/IRegistryController.sol

interface IRegistryController {
    function registerInRelease(
        uint256 _release,
        bytes32 _contractName,
        address _contractAddress
    ) external;

    function register(bytes32 _contractName, address _contractAddress) external;

    function registerService(bytes32 _name, address _addr) external;

    function deregisterInRelease(uint256 _release, bytes32 _contractName)
        external;

    function deregister(bytes32 _contractName) external;

    function prepareRelease() external returns (uint256 _release);

    function getContractInRelease(uint256 _release, bytes32 _contractName)
        external
        view
        returns (address _contractAddress);

    function getContract(bytes32 _contractName)
        external
        view
        returns (address _contractAddress);

    function getService(bytes32 _contractName)
        external
        view
        returns (address _contractAddress);

    function getRelease() external view returns (uint256 _release);
}

// File: ./contracts/shared/AccessModifiers.sol

contract AccessModifiers {
    modifier onlyDAO() {
        require(msg.sender == getService("DAO"), "ERROR::NOT_DAO_SERVICE");
        _;
    }

    modifier onlyPolicyFlow(bytes32 _module) {
        // Allow only from delegator
        require(address(this) == getContract(_module), "ERROR::NOT_ON_STORAGE");

        // Allow only ProductService (it delegates to PolicyFlow)
        require(
            msg.sender == getContract("ProductService"),
            "ERROR::NOT_PRODUCT_SERVICE"
        );
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == getService("OracleService"), "ERROR::NOT_ORACLE");
        _;
    }

    modifier onlyOracleOwner() {
        require(
            msg.sender == getService("OracleOwnerService"),
            "ERROR::NOT_ORACLE_OWNER"
        );
        _;
    }

    modifier onlyProductOwner() {
        require(
            msg.sender == getService("ProductOwnerService"),
            "ERROR::NOT_PRODUCT_OWNER"
        );
        _;
    }

    function getContract(bytes32 _contractName)
        public
        view
        returns (address _addr);

    function getService(bytes32 _contractName)
        public
        view
        returns (address _addr);
}

// File: ./contracts/shared/WithRegistry.sol

contract WithRegistry is AccessModifiers {
    IRegistryController public registry;

    constructor(address _registry) internal {
        registry = IRegistryController(_registry);
    }

    function assignRegistry(address _registry) external onlyDAO {
        registry = IRegistryController(_registry);
    }

    function getService(bytes32 _contractName)
        public
        view
        returns (address _addr)
    {
        _addr = registry.getService(_contractName);
    }

    function getContract(bytes32 _contractName)
        public
        view
        returns (address _addr)
    {
        _addr = registry.getContract(_contractName);
    }

    function getContractInRelease(uint256 _release, bytes32 _contractName)
        internal
        view
        returns (address _addr)
    {
        _addr = registry.getContractInRelease(_release, _contractName);
    }

    function getRelease() internal view returns (uint256 _release) {
        _release = registry.getRelease();
    }
}

// File: ./contracts/shared/ModuleController.sol

contract ModuleController is WithRegistry, BaseModuleController {
    /* solhint-disable payable-fallback */
    function() external {
        revert("ERROR::FALLBACK_FUNCTION_NOW_ALLOWED");
    }
    /* solhint-enable payable-fallback */

    function assignStorage(address _storage) external onlyDAO {
        _assignStorage(_storage);
    }
}

// File: contracts/modules/License/LicenseController.sol

contract LicenseController is LicenseStorageModel, ModuleController {
    bytes32 public constant NAME = "LicenseController";

    constructor(address _registry) public WithRegistry(_registry) {}

    /**
     * @dev Register new product
     */
    function register(bytes32 _name, address _addr, bytes32 _policyFlow)
        external
        returns (uint256 _registrationId)
    {
        _registrationId = registrations.length++;

        Registration storage newRegistration = registrations[_registrationId];
        newRegistration.name = _name;
        newRegistration.addr = _addr;
        newRegistration.policyFlow = _policyFlow;
        newRegistration.release = getRelease();
        newRegistration.declined = true;

        emit LogNewRegistration(_registrationId, _name, _addr);
    }

    /**
     * @dev Decline new product registration
     */
    function declineRegistration(uint256 _registrationId) external onlyDAO {
        require(
            registrations.length > _registrationId,
            "ERROR_INVALID_REGISTRATION_ID"
        ); // todo: check overflow

        Registration storage registration = registrations[_registrationId];
        registration.declined = true;

        emit LogRegistrationDeclined(_registrationId);
    }

    /**
     * @dev Approve registration and create new product
     */
    function approveRegistration(uint256 _registrationId)
        external
        onlyDAO
        returns (uint256 _productId)
    {
        require(
            registrations.length > _registrationId,
            "ERROR_INVALID_REGISTRATION_ID"
        ); // todo: check overflow

        _productId = products.length++;

        Product storage newProduct = products[_productId];
        newProduct.name = registrations[_registrationId].name;
        newProduct.addr = registrations[_registrationId].addr;
        newProduct.policyFlow = registrations[_registrationId].policyFlow;
        newProduct.release = registrations[_registrationId].release;
        newProduct.approved = true;

        productIdByAddress[newProduct.addr] = _productId;

        // create new erc721 token

        emit LogNewProductApproved(
            newProduct.name,
            newProduct.addr,
            _productId
        );
    }

    /**
     * @dev Disapprove product once it was approved
     */
    function disapproveProduct(uint256 _productId) external onlyDAO {
        Product storage product = products[_productId];

        require(product.approved == true, "ERROR_INVALID_APPROVE_STATUS");

        product.approved = false;

        emit LogProductDisapproved(product.name, product.addr, _productId);
    }

    /**
     * @dev Reapprove product once it was disapproved
     */
    function reapproveProduct(uint256 _productId) external onlyDAO {
        Product storage product = products[_productId];

        require(product.approved == false, "ERROR_INVALID_APPROVE_STATUS");

        product.approved = true;

        emit LogProductReapproved(product.name, product.addr, _productId);
    }

    /**
     * @dev Pause product
     */
    function pauseProduct(uint256 _productId) external onlyDAO {
        Product storage product = products[_productId];

        require(product.paused == false, "ERROR_INVALID_PAUSED_STATUS");

        product.paused = true;

        emit LogProductPaused(product.name, product.addr, _productId);
    }

    /**
     * @dev Unpause product
     */
    function unpauseProduct(uint256 _productId) external onlyDAO {
        Product storage product = products[_productId];

        require(product.paused == true, "ERROR_INVALID_PAUSED_STATUS");

        product.paused = false;

        emit LogProductUnpaused(product.name, product.addr, _productId);
    }

    /**
     * @dev Check if contract is approved product
     */
    function isApprovedProduct(address _addr)
        public
        view
        returns (bool _approved)
    {
        _approved = products[productIdByAddress[_addr]].approved == true;
    }

    /**
     * @dev Check if contract is paused product
     */
    function isPausedProduct(address _addr) public view returns (bool _paused) {
        _paused = products[productIdByAddress[_addr]].paused == true;
    }

    function isValidCall(address _addr) public view returns (bool _valid) {
        _valid = isApprovedProduct(_addr) && !isPausedProduct(_addr);
    }

    function authorize(address _sender)
        public
        view
        returns (bool _authorized, address _policyFlow)
    {
        _authorized = isValidCall(_sender);
        _policyFlow = getContractInRelease(
            products[productIdByAddress[_sender]].release,
            products[productIdByAddress[_sender]].policyFlow
        );
    }

    function getProductId(address _addr)
        public
        view
        returns (uint256 _productId)
    {
        _productId = productIdByAddress[_addr];
    }
}
