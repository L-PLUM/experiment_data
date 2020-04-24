/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

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

    event LogPayoutCompleted(
        uint256 productId,
        uint256 policyId,
        uint256 payoutId,
        uint256 amount,
        PayoutState state
    );

    event LogPartialPayout(
        uint256 productId,
        uint256 policyId,
        uint256 payoutId,
        uint256 amount,
        uint256 remainder,
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

// File: contracts/modules/Policy/PolicyController.sol

pragma experimental ABIEncoderV2;




contract PolicyController is PolicyStorageModel, ModuleController {
    using SafeMath for *;

    constructor(address _registry) public WithRegistry(_registry) {}

    /* Metadata */
    function createPolicyFlow(uint256 _productId)
        external
        onlyPolicyFlow("Policy")
        returns (uint256 _metadataId)
    {
        _metadataId = metadata[_productId].length++;

        Metadata storage metadatum = metadata[_productId][_metadataId];
        metadatum.state = PolicyFlowState.Started;
        metadatum.createdAt = block.timestamp;
        metadatum.updatedAt = block.timestamp;

        emit LogNewMetadata(_productId, _metadataId, PolicyFlowState.Started);
    }

    function setPolicyFlowState(
        uint256 _productId,
        uint256 _metadataId,
        PolicyFlowState _state
    ) external onlyPolicyFlow("Policy") {
        Metadata storage metadatum = metadata[_productId][_metadataId];
        metadatum.state = _state;
        metadatum.updatedAt = block.timestamp;

        emit LogMetadataStateChanged(_productId, _metadataId, _state);
    }

    /* Application */
    function createApplication(
        uint256 _productId,
        uint256 _metadataId,
        bytes32 _customerExternalId,
        uint256 _premium,
        bytes32 _currency,
        uint256[] calldata _payoutOptions
    ) external onlyPolicyFlow("Policy") returns (uint256 _applicationId) {
        _applicationId = applications[_productId].length++;

        Application storage application = applications[_productId][_applicationId];
        application.metadataId = _metadataId;
        application.customerExternalId = _customerExternalId;
        application.premium = _premium;
        application.currency = _currency;
        // todo: check payoutOptions values
        application.payoutOptions = _payoutOptions;
        application.state = ApplicationState.Applied;
        application.createdAt = block.timestamp;
        application.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][_metadataId];
        metadatum.applicationId = _applicationId;
        metadatum.hasApplication = true;
        metadatum.updatedAt = block.timestamp;

        emit LogNewApplication(_productId, _metadataId, _applicationId);
    }

    function setApplicationState(
        uint256 _productId,
        uint256 _applicationId,
        ApplicationState _state
    ) external onlyPolicyFlow("Policy") {
        Application storage application = applications[_productId][_applicationId];
        application.state = _state;
        application.updatedAt = block.timestamp;

        emit LogApplicationStateChanged(
            _productId,
            application.metadataId,
            _applicationId,
            _state
        );
    }

    /* Policy */
    function createPolicy(uint256 _productId, uint256 _metadataId)
        external
        onlyPolicyFlow("Policy")
        returns (uint256 _policyId)
    {
        _policyId = policies[_productId].length++;

        Policy storage policy = policies[_productId][_policyId];
        policy.metadataId = _metadataId;
        policy.state = PolicyState.Active;
        policy.createdAt = block.timestamp;
        policy.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][_metadataId];
        metadatum.policyId = _policyId;
        metadatum.hasPolicy = true;
        metadatum.updatedAt = block.timestamp;

        emit LogNewPolicy(
            _productId,
            _metadataId,
            _policyId,
            metadatum.applicationId
        );
    }

    function setPolicyState(
        uint256 _productId,
        uint256 _policyId,
        PolicyState _state
    ) external onlyPolicyFlow("Policy") {
        Policy storage policy = policies[_productId][_policyId];
        policy.state = _state;
        policy.updatedAt = block.timestamp;

        emit LogPolicyStateChanged(
            _productId,
            policy.metadataId,
            _policyId,
            _state
        );
    }

    /* Claim */
    function createClaim(uint256 _productId, uint256 _policyId, bytes32 _data)
        external
        onlyPolicyFlow("Policy")
        returns (uint256 _claimId)
    {
        Policy storage policy = policies[_productId][_policyId];

        _claimId = claims[_productId].length++;

        Claim storage claim = claims[_productId][_claimId];
        claim.metadataId = policy.metadataId;
        claim.state = ClaimState.Applied;
        claim.data = _data;
        claim.createdAt = block.timestamp;
        claim.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][policy.metadataId];
        metadatum.claimIds.push(_claimId);
        metadatum.updatedAt = block.timestamp;

        emit LogClaimStateChanged(
            _productId,
            policy.metadataId,
            _policyId,
            ClaimState.Applied
        );
    }

    function setClaimState(
        uint256 _productId,
        uint256 _claimId,
        ClaimState _state
    ) external onlyPolicyFlow("Policy") {
        Claim storage claim = claims[_productId][_claimId];
        claim.state = _state;
        claim.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][claim.metadataId];

        emit LogClaimStateChanged(
            _productId,
            claim.metadataId,
            metadatum.policyId,
            _state
        );
    }

    /* Payout */
    function createPayout(uint256 _productId, uint256 _claimId, uint256 _amount)
        external
        onlyPolicyFlow("Policy")
        returns (uint256 _payoutId)
    {
        Claim storage claim = claims[_productId][_claimId];

        _payoutId = payouts[_productId].length++;

        Payout storage payout = payouts[_productId][_payoutId];
        payout.metadataId = claim.metadataId;
        payout.claimId = _claimId;
        payout.state = PayoutState.Expected;
        payout.expectedAmount = _amount;
        payout.createdAt = block.timestamp;
        payout.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][claim.metadataId];
        metadatum.payoutIds.push(_payoutId);
        metadatum.updatedAt = block.timestamp;

        emit LogNewPayout(
            _productId,
            _payoutId,
            claim.metadataId,
            metadatum.policyId,
            _claimId,
            _amount,
            PayoutState.Expected
        );
    }

    function payOut(uint256 _productId, uint256 _payoutId, uint256 _amount)
        external
        onlyPolicyFlow("Policy")
        returns (uint256 _remainder)
    {
        Payout storage payout = payouts[_productId][_payoutId];
        Metadata storage metadatum = metadata[_productId][payout.metadataId];

        uint256 actualAmount = payout.actualAmount.add(_amount);

        require(
            payout.state == PayoutState.Expected,
            "ERROR::PAYOUT_COMPLETED"
        );

        // Check if actual payout amount is no more than expected
        require(
            payout.expectedAmount >= actualAmount,
            "ERROR::Amount is more than expected"
        );

        if (payout.expectedAmount == actualAmount) {
            // Full
            payout.expectedAmount = 0;
            payout.actualAmount = actualAmount;
            payout.state = PayoutState.PaidOut;
            payout.updatedAt = block.timestamp;

            _remainder = 0;

            emit LogPayoutCompleted(
                _productId,
                metadatum.policyId,
                _payoutId,
                actualAmount,
                payout.state
            );
        } else {
            // Partial
            payout.actualAmount = actualAmount;
            payout.updatedAt = block.timestamp;

            _remainder = payout.expectedAmount.sub(payout.actualAmount);

            emit LogPartialPayout(
                _productId,
                metadatum.policyId,
                _payoutId,
                actualAmount,
                _remainder,
                payout.state
            );
        }
    }

    function setPayoutState(
        uint256 _productId,
        uint256 _payoutId,
        PayoutState _state
    ) external onlyPolicyFlow("Policy") {
        Payout storage payout = payouts[_productId][_payoutId];
        payout.state = _state;
        payout.updatedAt = block.timestamp;

        Metadata storage metadatum = metadata[_productId][payout.metadataId];

        emit LogPayoutStateChanged(
            _productId,
            payout.metadataId,
            metadatum.policyId,
            payout.claimId,
            _state
        );
    }

    /* Views */
    function getApplicationData(uint256 _productId, uint256 _applicationId)
        external
        view
        returns (
        uint256 _metadataId,
        bytes32 _customerExternalId,
        uint256 _premium,
        bytes32 _currency,
        ApplicationState _state
    )
    {
        _metadataId = applications[_productId][_applicationId].metadataId;
        _customerExternalId = applications[_productId][_applicationId].customerExternalId;
        _premium = applications[_productId][_applicationId].premium;
        _currency = applications[_productId][_applicationId].currency;
        _state = applications[_productId][_applicationId].state;
    }

    function getPayoutOptions(uint256 _productId, uint256 _applicationId)
        external
        view
        returns (uint256[] memory _payoutOptions)
    {
        _payoutOptions = applications[_productId][_applicationId].payoutOptions;
    }

    function getPremium(uint256 _productId, uint256 _applicationId)
        external
        view
        returns (uint256 _premium)
    {
        _premium = applications[_productId][_applicationId].premium;
    }

    function getApplicationState(uint256 _productId, uint256 _applicationId)
        external
        view
        returns (ApplicationState _state)
    {
        _state = applications[_productId][_applicationId].state;
    }

    function getPolicyState(uint256 _productId, uint256 _policyId)
        external
        view
        returns (PolicyState _state)
    {
        _state = policies[_productId][_policyId].state;
    }

    function getClaimState(uint256 _productId, uint256 _claimId)
        external
        view
        returns (ClaimState _state)
    {
        _state = claims[_productId][_claimId].state;
    }

    function getPayoutState(uint256 _productId, uint256 _payoutId)
        external
        view
        returns (PayoutState _state)
    {
        _state = payouts[_productId][_payoutId].state;
    }
}
