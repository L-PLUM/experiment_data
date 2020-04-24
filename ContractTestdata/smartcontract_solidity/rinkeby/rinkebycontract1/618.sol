/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: ./contracts/shared/RBAC.sol

contract RBAC {
    mapping(bytes32 => uint256) public roles;
    bytes32[] public rolesKeys;

    mapping(address => uint256) public permissions;

    modifier onlyWithRole(bytes32 _role) {
        require(hasRole(msg.sender, _role));
        _;
    }

    function createRole(bytes32 _role) public {
        require(roles[_role] == 0);
        // todo: check overflow
        roles[_role] = 1 << rolesKeys.length;
        rolesKeys.push(_role);
    }

    function addRoleToAccount(address _address, bytes32 _role) public {
        require(roles[_role] != 0);

        permissions[_address] = permissions[_address] | roles[_role];
    }

    function cleanRolesForAccount(address _address) public {
        delete permissions[_address];
    }

    function hasRole(address _address, bytes32 _role)
        public
        view
        returns (bool _hasRole)
    {
        _hasRole = (permissions[_address] & roles[_role]) > 0;
    }
}

// File: ./contracts/services/IProductService.sol

interface IProductService {
    function register(bytes32 _productName, bytes32 _policyFlow)
        external
        returns (uint256 _registrationId);

    function newApplication(
        bytes32 _customerExternalId,
        uint256 _premium,
        bytes32 _currency,
        uint256[] calldata _payoutOptions
    ) external returns (uint256 _applicationId);

    function underwrite(uint256 applicationId)
        external
        returns (uint256 _policyId);

    function decline(uint256 _applicationId) external;

    function newClaim(uint256 _policyId) external returns (uint256 _claimId);

    function confirmClaim(uint256 _claimId, uint256 _sum)
        external
        returns (uint256 _payoutId);

    function declineClaim(uint256 _claimId) external;

    function expire(uint256 _policyId) external;

    function payout(uint256 _payoutId, uint256 _sum)
        external
        returns (uint256 _remainder);

    function getPayoutOptions(uint256 _applicationId)
        external
        returns (uint256[] memory _payoutOptions);

    function getPremium(uint256 _applicationId)
        external
        returns (uint256 _premium);

    function request(
        bytes calldata _input,
        string calldata _callbackMethodName,
        address _callabackContractAddress,
        bytes32 _oracleTypeName,
        uint256 _responsibleOracleId
    ) external returns (uint256 _requestId);
}

// File: ./contracts/Product.sol

contract Product is RBAC {
    bool public developmentMode = false;
    bool public maintenanceMode = false;

    IProductService public productService;

    constructor(address _productService, bytes32 _name, bytes32 _policyFlow)
        internal
    {
        productService = IProductService(_productService);
        register(_name, _policyFlow);
    }

    function toggleDevelopmentMode() internal {
        developmentMode = !developmentMode;
    }

    function toggleMaintenanceMode() internal {
        maintenanceMode = !maintenanceMode;
    }

    function register(bytes32 _productName, bytes32 _policyFlow) internal {
        productService.register(_productName, _policyFlow);
    }

    function newApplication(
        bytes32 _customerExternalId,
        uint256 _premium,
        bytes32 _currency,
        uint256[] memory _payoutOptions
    ) internal returns (uint256 _applicationId) {
        _applicationId = productService.newApplication(
            _customerExternalId,
            _premium,
            _currency,
            _payoutOptions
        );
    }

    function underwrite(uint256 _applicationId)
        internal
        returns (uint256 _policyId)
    {
        _policyId = productService.underwrite(_applicationId);
    }

    function decline(uint256 _applicationId) internal {
        productService.decline(_applicationId);
    }

    function newClaim(uint256 _policyId) internal returns (uint256 _claimId) {
        _claimId = productService.newClaim(_policyId);
    }

    function confirmClaim(uint256 _claimId, uint256 _amount)
        internal
        returns (uint256 _payoutId)
    {
        _payoutId = productService.confirmClaim(_claimId, _amount);
    }

    function expire(uint256 _policyId) internal {
        productService.expire(_policyId);
    }

    function payout(uint256 _payoutId, uint256 _amount)
        internal
        returns (uint256 _remainder)
    {
        _remainder = productService.payout(_payoutId, _amount);
    }

    function getPayoutOptions(uint256 _applicationId)
        internal
        returns (uint256[] memory _payoutOptions)
    {
        _payoutOptions = productService.getPayoutOptions(_applicationId);
    }

    function getPremium(uint256 _applicationId)
        internal
        returns (uint256 _premium)
    {
        _premium = productService.getPremium(_applicationId);
    }

    function request(
        bytes memory _input,
        string memory _callbackMethodName,
        bytes32 _oracleTypeName,
        uint256 _responsibleOracleId
    ) internal returns (uint256 _requestId) {
        _requestId = productService.request(
            _input,
            _callbackMethodName,
            address(this),
            _oracleTypeName,
            _responsibleOracleId
        );
    }
}

// File: contracts/examples/FlightDelayManual/FlightDelayManual.sol

contract FlightDelayManual is Product {
    event LogRequestFlightStatistics(
        uint256 requestId,
        bytes32 carrierFlightNumber,
        uint256 departureTime,
        uint256 arrivalTime
    );

    event LogRequestFlightStatus(
        uint256 requestId,
        bytes32 carrierFlightNumber,
        uint256 arrivalTime
    );

    event LogRequestPayout(uint256 claimId, uint256 payoutId, uint256 amount);

    bytes32 public constant NAME = "FlightDelayManual";
    bytes32 public constant POLICY_FLOW = "PolicyFlowDefault";

    // Minimum observations for valid prediction
    uint256 public constant MIN_OBSERVATIONS = 10;
    // Minimum time before departure for applying
    uint256 public constant MIN_TIME_BEFORE_DEPARTURE = 24 hours;
    // Maximum duration of flight
    uint256 public constant MAX_FLIGHT_DURATION = 2 days;
    // Check for delay after .. minutes after scheduled arrival
    uint256 public constant CHECK_PAYOUT_OFFSET = 15 minutes;

    // All amounts expected to be provided in a currency’s smallest unit
    // E.g. 10 EUR = 1000 (1000 cents)
    uint256 public constant MIN_PREMIUM = 1500;
    uint256 public constant MAX_PREMIUM = 29000;
    uint256 public constant MAX_PAYOUT = 30000;

    bytes32[1] public currencies = [bytes32("EUR")];

    // ['observations','late15','late30','late45','cancelled','diverted']
    uint8[6] public weightPattern = [0, 0, 0, 30, 50, 50];

    // Maximum cumulated weighted premium per risk
    uint256 constant MAX_CUMULATED_WEIGHTED_PREMIUM = 6000000;

    struct Risk {
        bytes32 carrierFlightNumber;
        bytes32 departureYearMonthDay;
        uint256 departureTime;
        uint256 arrivalTime;
        uint delayInMinutes;
        uint8 delay;
        uint256 cumulatedWeightedPremium;
        uint256 premiumMultiplier;
        uint256 weight;
    }

    struct RequestMetadata {
        uint256 applicationId;
        uint256 policyId;
        bytes32 riskId;
    }

    mapping(bytes32 => Risk) public risks;

    RequestMetadata[] public requests;

    constructor(address _productController)
        public
        Product(_productController, NAME, POLICY_FLOW)
    {}

    function applyForPolicy(
        // domain specific
        bytes32 _carrierFlightNumber,
        uint256 _departureTime,
        uint256 _arrivalTime,
        // premium
        uint256 _premium,
        bytes32 _currency,
        uint256[] calldata _payoutOptions,
        // customer
        bytes32 _customerExternalId
    ) external {
        // Validate input parameters
        // Validate input parameters
        require(_premium >= MIN_PREMIUM, "ERROR::INVALID_PREMIUM");
        require(_premium <= MAX_PREMIUM, "ERROR::INVALID_PREMIUM");
        require(_currency == currencies[0], "ERROR:INVALID_CURRENCY");
        require(
            _departureTime < _departureTime,
            "ERROR::INVALID_ARRIVAL/DEPARTURE_TIME"
        );
        require(
            _departureTime > _departureTime + MAX_FLIGHT_DURATION,
            "ERROR::INVALID_ARRIVAL/DEPARTURE_TIME"
        );
        require(
            _departureTime < block.timestamp + MIN_TIME_BEFORE_DEPARTURE,
            "ERROR::INVALID_ARRIVAL/DEPARTURE_TIME"
        );

        // Create risk if not exists
        bytes32 riskId = keccak256(
            abi.encodePacked(_carrierFlightNumber, _departureTime, _arrivalTime)
        );
        Risk storage risk = risks[riskId];

        if (risk.carrierFlightNumber == "") {
            risk.carrierFlightNumber = _carrierFlightNumber;
            risk.departureTime = _departureTime;
            risk.arrivalTime = _arrivalTime;
        }

        require(
            _premium * risk.premiumMultiplier + risk.cumulatedWeightedPremium < MAX_CUMULATED_WEIGHTED_PREMIUM,
            "ERROR::CLUSTER_RISK"
        );

        if (risk.cumulatedWeightedPremium == 0) {
            risk.cumulatedWeightedPremium = MAX_CUMULATED_WEIGHTED_PREMIUM;
        }

        // Create new application
        uint256 applicationId = newApplication(
            _customerExternalId,
            _premium,
            _currency,
            _payoutOptions
        );

        // New request
        uint256 requestId = requests.length++;
        RequestMetadata storage requestMetadata = requests[requestId];
        requestMetadata.applicationId = applicationId;
        requestMetadata.riskId = riskId;

        emit LogRequestFlightStatistics(
            requestId,
            _carrierFlightNumber,
            _departureTime,
            _arrivalTime
        );
    }

    function flightStatisticsCallback(
        uint256 requestId,
        uint256[6] calldata _statistics
    ) external {
        // Statistics: ['observations','late15','late30','late45','cancelled','diverted']

        uint256 applicationId = requests[requestId].applicationId;

        if (_statistics[0] <= MIN_OBSERVATIONS) {
            decline(applicationId);
            return;
        }

        uint256 premium = getPremium(applicationId);
        uint256[] memory payoutOptions = getPayoutOptions(applicationId);
        (uint256 weight, uint256[5] memory calculatedPayouts) = calculatePayouts(
            premium,
            _statistics
        );

        require(
            payoutOptions.length == calculatedPayouts.length,
            "ERROR::INVALID_PAYOUT_OPTIONS_COUNT"
        );

        for (uint256 i = 0; i < 5; i++) {
            require(
                payoutOptions[i] == calculatedPayouts[i],
                "ERROR::INVALID_PAYOUT_OPTION"
            );
            assert(payoutOptions[i] <= MAX_PAYOUT);
        }

        bytes32 riskId = requests[requestId].riskId;

        if (risks[riskId].premiumMultiplier == 0) {
            // it's the first policy for this risk, we accept any premium
            risks[riskId].cumulatedWeightedPremium = premium * 100000;
            risks[riskId].premiumMultiplier = 100000 / weight;
        }else {
            risks[riskId].cumulatedWeightedPremium = risks[riskId].cumulatedWeightedPremium + premium * risks[riskId].premiumMultiplier;
        }

        risks[riskId].weight = weight;

        uint256 policyId = underwrite(applicationId);

        // New request
        uint256 newRequestId = requests.length++;
        RequestMetadata storage requestMetadata = requests[newRequestId];
        requestMetadata.policyId = policyId;

        emit LogRequestFlightStatus(
            newRequestId,
            risks[riskId].carrierFlightNumber,
            risks[riskId].arrivalTime
        );
    }

    function flightStatusCallback(
        uint256 requestId,
        uint256 _delay,
        bool _cancelled,
        bool _diverted
    ) external {
        uint256 policyId = requests[requestId].policyId;
        uint256 applicationId = requests[requestId].policyId;
        uint256[] memory payoutOptions = getPayoutOptions(applicationId);

        uint256 payoutAmount;

        if (_cancelled == true) {
            payoutAmount = payoutOptions[3];
        } else if (_diverted == true) {
            payoutAmount = payoutOptions[4];
        } else if (_delay > 30) {
            if (_delay > 45) {
                payoutAmount = payoutOptions[1];
            } else if (_delay > 60) {
                payoutAmount = payoutOptions[2];
            } else {
                payoutAmount = payoutOptions[0];
            }

            uint256 claimId = newClaim(policyId);
            uint256 payoutId = confirmClaim(claimId, payoutAmount);

            emit LogRequestPayout(claimId, payoutId, payoutAmount);
        } else {
            expire(policyId);
        }
    }

    function confirmPayout(uint256 _payoutId, uint256 _sum) external {
        payout(_payoutId, _sum);
    }

    function calculatePayouts(uint256 _premium, uint256[6] memory _statistics)
        public
        view
        returns (uint256 _weight, uint256[5] memory _payoutOptions)
    {
        require(_premium >= MIN_PREMIUM, "ERROR::INVALID_PREMIUM");
        require(_premium <= MAX_PREMIUM, "ERROR::INVALID_PREMIUM");
        require(_statistics[0] > MIN_OBSERVATIONS, "ERROR::LOW_OBSERVATIONS");

        for (uint256 i = 1; i < 6; i++) {
            _weight += weightPattern[i] * _statistics[i] * 10000 / _statistics[0];
            // 1% = 100 / 100% = 10,000
        }

        // To avoid div0 in the payout section, we have to make a minimal assumption on weight
        if (_weight == 0) {
            _weight = 100000 / _statistics[0];
        }

        for (uint256 i = 0; i < 5; i++) {
            _payoutOptions[i] = _premium * weightPattern[i + 1] * 10000 / _weight;

            if (_payoutOptions[i] > MAX_PAYOUT) {
                _payoutOptions[i] = MAX_PAYOUT;
            }
        }
    }
}
