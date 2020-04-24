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

// File: ./contracts/shared/Delegator.sol

contract Delegator {
    function _delegate(address _implementation) internal {
        require(_implementation != address(0), "ERROR::UNKNOWN_IMPLEMENTATION");

        bytes memory data = msg.data;

        /* solhint-disable no-inline-assembly */
        assembly {
            let result := delegatecall(
                gas,
                _implementation,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
        /* solhint-enable no-inline-assembly */
    }
}

// File: ./contracts/shared/BaseModuleStorage.sol

contract BaseModuleStorage is Delegator {
    address public controller;

    /* solhint-disable payable-fallback */
    function() external {
        _delegate(controller);
    }
    /* solhint-enable payable-fallback */

    function _assignController(address _controller) internal {
        controller = _controller;
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

// File: ./contracts/shared/ModuleStorage.sol

contract ModuleStorage is WithRegistry, BaseModuleStorage {
    /* solhint-disable payable-fallback */
    function() external {
        // todo: restrict to controllers
        _delegate(controller);
    }
    /* solhint-enable payable-fallback */

    function assignController(address _controller) external onlyDAO {
        _assignController(_controller);
    }
}

// File: contracts/modules/License/License.sol

contract License is LicenseStorageModel, ModuleStorage {
    bytes32 public constant NAME = "License";

    constructor(address _registry) public WithRegistry(_registry) {
        // Empty
    }
}
