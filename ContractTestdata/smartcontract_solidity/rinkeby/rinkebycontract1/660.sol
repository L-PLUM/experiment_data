/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity 0.5.2;

// File: ./contracts/modules/registry/IRegistryController.v1.sol

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

// File: contracts/services/ProductService.sol

contract ProductService is WithRegistry, Delegator {
    bytes32 public constant NAME = "ProductService";

    constructor(address _registry) public WithRegistry(_registry) {}

    function() external {
        (bool authorized, address policyFlow) = license().authorize(msg.sender);

        require(authorized == true, "ERROR::NOT_AUTHORIZED");
        require(policyFlow != address(0), "ERROR::POLICY_FLOW_NOT_RESOLVED");

        _delegate(policyFlow);
    }

    function register(bytes32 _name, bytes32 _policyFlow)
        external
        returns (uint256 _registrationId)
    {
        _registrationId = license().register(_name, msg.sender, _policyFlow);
    }

    function license() internal view returns (ILicenseController) {
        return ILicenseController(registry.getContract("License"));
    }
}
