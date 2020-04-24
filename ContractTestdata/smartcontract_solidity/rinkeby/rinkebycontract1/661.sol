/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity 0.5.2;

// File: ./contracts/modules/Policy/IPolicy.sol

interface IPolicy {
    // Events
    event LogNewMetadata(
        uint256 productId,
        uint256 metadataId,
        PolicyFlowState state
    );

    event LogMetadataStateChanged(
        uint256 productId,
        uint256 metadataId,
        PolicyFlowState state
    );

    event LogNewApplication(
        uint256 productId,
        uint256 metadataId,
        uint256 applicationId
    );

    event LogApplicationStateChanged(
        uint256 productId,
        uint256 metadataId,
        uint256 applicationId,
        ApplicationState state
    );

    event LogNewPolicy(
        uint256 productId,
        uint256 metadataId,
        uint256 policyId,
        uint256 applicationId
    );

    event LogPolicyStateChanged(
        uint256 productId,
        uint256 metadataId,
        uint256 policyId,
        PolicyState state
    );

    event LogNewClaim(
        uint256 productId,
        uint256 metadataId,
        uint256 policyId,
        ClaimState state
    );

    event LogClaimStateChanged(
        uint256 productId,
        uint256 metadataId,
        uint256 policyId,
        ClaimState state
    );

    event LogNewPayout(
        uint256 productId,
        uint256 payoutId,
        uint256 metadataId,
        uint256 policyId,
        uint256 claimId,
        uint256 amount,
        PayoutState state
    );

    event LogPayoutStateChanged(
        uint256 productId,
        uint256 metadataId,
        uint256 policyId,
        uint256 claimId,
        PayoutState state
    );

    // Statuses
    enum PolicyFlowState {Started, Paused, Finished}

    enum ApplicationState {Applied, Revoked, Underwritten, Declined}

    enum PolicyState {Active, Expired}

    enum ClaimState {Applied, Confirmed, Declined}

    enum PayoutState {Expected, PaidOut}

    // Objects
    struct Metadata {
        // Lookup
        uint256 applicationId;
        uint256 policyId;
        uint256[] claimIds;
        uint256[] payoutIds;
        bool hasPolicy;
        bool hasApplication;
        // ERC721 token
        address tokenContract;
        uint256 tokenId;
        // Core
        uint256 registryContract;
        uint256 release;
        // State
        PolicyFlowState state;
        bytes32 stateMessage;
        // Datetime
        uint256 createdAt;
        uint256 updatedAt;

        // BPMN
        // PolicyState[] next;
    }

    struct Application {
        uint256 metadataId;
        // Customer
        bytes32 customerExternalId;
        // Premium
        uint256 premium;
        bytes32 currency;
        // Proof

        // Payout
        uint256[] payoutOptions;
        // State
        ApplicationState state;
        bytes32 stateMessage;
        // Datetime
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Policy {
        uint256 metadataId;
        // State
        PolicyState state;
        bytes32 stateMessage;
        // Datetime
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Claim {
        uint256 metadataId;
        // Data
        bytes32 data;
        // State
        ClaimState state;
        bytes32 stateMessage;
        // Proof

        // Datetime
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Payout {
        uint256 metadataId;
        uint256 claimId;
        // Amounts
        uint256 expectedAmount;
        uint256 actualAmount;
        // State
        PayoutState state;
        bytes32 stateMessage;
        // Proof

        // Datetime
        uint256 createdAt;
        uint256 updatedAt;
    }
}

// File: ./contracts/modules/Policy/PolicyStorageModel.sol

contract PolicyStorageModel is IPolicy {
    mapping(uint256 => Metadata[]) public metadata;

    mapping(uint256 => Application[]) public applications;

    mapping(uint256 => Policy[]) public policies;

    mapping(uint256 => Claim[]) public claims;

    mapping(uint256 => Payout[]) public payouts;
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

// File: contracts/modules/Policy/Policy.sol

contract Policy is PolicyStorageModel, ModuleStorage {
    bytes32 public constant NAME = "Policy";

    constructor(address _registry) public WithRegistry(_registry) {}
}
