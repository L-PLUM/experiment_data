/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: ./contracts/modules/license/ILicenseController.sol

interface ILicenseController {
    function register(bytes32 _name, address _addr, bytes32 _policyFlow)
        external
        returns (uint256 _registrationId);

    function declineRegistration(uint256 _registrationId) external;

    function approveRegistration(uint256 _registrationId)
        external
        returns (uint256 _productId);

    function disapproveProduct(uint256 _productId) external;

    function reapproveProduct(uint256 _productId) external;

    function pauseProduct(uint256 _productId) external;

    function unpauseProduct(uint256 _productId) external;

    function isApprovedProduct(address _addr)
        external
        view
        returns (bool _approved);

    function isPausedProduct(address _addr)
        external
        view
        returns (bool _paused);

    function isValidCall(address _addr) external view returns (bool _valid);

    function authorize(address _sender)
        external
        view
        returns (bool _authorized, address _policyFlow);

    function getProductId(address _addr)
        external
        view
        returns (uint256 _productId);
}

// File: ./contracts/modules/access/IAccessController.sol

interface IAccessController {
    function createRole(bytes32 _role) external;

    function addRoleToAccount(address _address, bytes32 _role) external;

    function cleanRolesForAccount(address _address) external;

    function hasRole(address _address, bytes32 _role)
        external
        view
        returns (bool _hasRole);
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

// File: ./contracts/modules/query/IQuery.sol

interface IQuery {
    enum OracleTypeState {Inactive, Active}

    enum OracleState {Inactive, Active}

    struct OracleType {
        string inputFormat; // e.g. '(uint256 longitude,uint256 latitude)'
        string callbackFormat; // e.g. '(uint256 longitude,uint256 latitude)'
        string description;
        OracleTypeState state;
        bool initialized;
    }

    struct Oracle {
        address oracleOwner;
        address oracleContract;
        string description;
        OracleState state;
    }

    struct OracleRequest {
        bytes data;
        string callbackMethodName;
        address callbackContractAddress;
        bytes32 oracleTypeName;
        uint256 responsibleOracleId;
        uint256 createdAt;
    }

    struct OracleResponse {
        uint256 requestId;
        address responder;
        uint256 createdAt;
        bool status;
    }

    /* Logs */
    event LogOracleTypeProposed(
        bytes32 oracleTypeName,
        string inputFormat,
        string callbackFormat,
        string description
    );

    event LogOracleTypeActivated(bytes32 oracleTypeName);

    event LogOracleTypeDeactivated(bytes32 oracleTypeName);

    event LogOracleTypeRemoved(bytes32 oracleTypeName);

    event LogOracleProposed(address oracleContract, string description);

    event LogOracleContractUpdated(
        uint256 oracleId,
        address prevContract,
        address nextContract
    );

    event LogOracleActivated(uint256 oracleId);

    event LogOracleDeactivated(uint256 oracleId);

    event LogOracleRemoved(uint256 oracleId);

    event LogOracleProposedToType(
        bytes32 oracleTypeName,
        uint256 oracleId,
        uint256 proposalId
    );

    event LogOraclePriceUpdatedInType(
        uint256 oracleId,
        uint256 oracleTypeId,
        uint256 price
    );

    event LogOracleToTypeProposalRevoked(
        bytes32 oracleTypeName,
        uint256 oracleId,
        uint256 proposalId
    );

    event LogOracleAssignedToOracleType(
        bytes32 oracleTypeName,
        uint256 oracleId
    );

    event LogOracleRemovedFromOracleType(
        bytes32 oracleTypeName,
        uint256 oracleId
    );

    event LogOracleRequested(uint256 requestId, uint256 responsibleOracleId);

    event LogOracleResponded(
        uint256 requestId,
        uint256 responseId,
        address responder,
        bool status
    );
}

// File: ./contracts/modules/query/IQueryController.sol

interface IQueryController {
    function proposeOracleType(
        bytes32 _oracleTypeName,
        string calldata _inputFormat,
        string calldata _callbackFormat,
        string calldata _description
    ) external;

    function activateOracleType(bytes32 _oracleTypeName) external;

    function deactivateOracleType(bytes32 _oracleTypeName) external;

    function removeOracleType(bytes32 _oracleTypeName) external;

    function proposeOracle(
        address _sender,
        address _oracleContract,
        string calldata _description
    ) external returns (uint256 _oracleId);

    function updateOracleContract(
        address _sender,
        address _newOracleContract,
        uint256 _oracleId
    ) external;

    function activateOracle(uint256 _oracleId) external;

    function deactivateOracle(uint256 _oracleId) external;

    function removeOracle(uint256 _oracleId) external;

    function proposeOracleToType(
        address _sender,
        bytes32 _oracleTypeName,
        uint256 _oracleId
    ) external returns (uint256 _proposalId);

    function revokeOracleToTypeProposal(
        address _sender,
        bytes32 _oracleTypeName,
        uint256 _proposalId
    ) external;

    function assignOracleToOracleType(
        bytes32 _oracleTypeName,
        uint256 _proposalId
    ) external;

    function removeOracleFromOracleType(
        bytes32 _oracleTypeName,
        uint256 _oracleId
    ) external;

    function request(
        bytes calldata _input,
        string calldata _callbackMethodName,
        address _callabackContractAddress,
        bytes32 _oracleTypeName,
        uint256 _responsibleOracleId
    ) external returns (uint256 _requestId);

    function respond(
        uint256 _requestId,
        address _responder,
        bytes calldata _data
    ) external returns (uint256 _responseId);
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

// File: contracts/services/DAOService.sol

contract DAOService is WithRegistry {
    bytes32 public constant NAME = "DAO";

    constructor(address _registry) public WithRegistry(_registry) {}

    /* License */
    function approveRegistration(uint256 _registrationId)
        external
        returns (uint256 _productId)
    {
        _productId = license().approveRegistration(_registrationId);
    }

    function declineRegistration(uint256 _registrationId) external {
        license().declineRegistration(_registrationId);
    }

    function disapproveProduct(uint256 _productId) external {
        license().disapproveProduct(_productId);
    }

    function reapproveProduct(uint256 _productId) external {
        license().reapproveProduct(_productId);
    }

    function pauseProduct(uint256 _productId) external {
        license().pauseProduct(_productId);
    }

    function unpauseProduct(uint256 _productId) external {
        license().unpauseProduct(_productId);
    }

    /* Access */
    function createRole(bytes32 _role) external {
        access().createRole(_role);
    }

    function addRoleToAccount(address _address, bytes32 _role) external {
        access().addRoleToAccount(_address, _role);
    }

    function cleanRolesForAccount(address _address) external {
        access().cleanRolesForAccount(_address);
    }

    /* Registry */
    function registerInRelease(
        uint256 _release,
        bytes32 _contractName,
        address _contractAddress
    ) external {
        registryStorage().registerInRelease(
            _release,
            _contractName,
            _contractAddress
        );
    }

    function register(bytes32 _contractName, address _contractAddress)
        external
    {
        registryStorage().register(_contractName, _contractAddress);
    }

    function deregisterInRelease(uint256 _release, bytes32 _contractName)
        external
    {
        registryStorage().deregisterInRelease(_release, _contractName);
    }

    function deregister(bytes32 _contractName) external {
        registryStorage().deregister(_contractName);
    }

    function prepareRelease() external returns (uint256 _release) {
        _release = registryStorage().prepareRelease();
    }

    /* Query */
    function activateOracleType(bytes32 _oracleTypeName) external {
        query().activateOracleType(_oracleTypeName);
    }

    function activateOracle(uint256 _oracleId) external {
        query().activateOracle(_oracleId);
    }

    function assignOracleToOracleType(
        bytes32 _oracleTypeName,
        uint256 _oracleId
    ) external {
        query().assignOracleToOracleType(_oracleTypeName, _oracleId);
    }

    /* Lookup */
    function license() internal view returns (ILicenseController) {
        return ILicenseController(registry.getContract("License"));
    }

    function access() internal view returns (IAccessController) {
        return IAccessController(registry.getContract("Access"));
    }

    function registryStorage() internal view returns (IRegistryController) {
        return IRegistryController(registry.getContract("Registry"));
    }

    function query() internal view returns (IQueryController) {
        return IQueryController(registry.getContract("Query"));
    }
}
