/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

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

// File: @etherisc/gif/contracts/shared/RBAC.sol

pragma solidity ^0.5.2;

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

// File: @etherisc/gif/contracts/services/IProductService.sol

pragma solidity ^0.5.2;

interface IProductService {
    function register(bytes32 _productName, bytes32 _policyFlow)
        external
        returns (uint256 _registrationId);

    function newApplication(
        bytes32 _bpExternalKey,
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

// File: @etherisc/gif/contracts/Product.sol

pragma solidity ^0.5.2;





contract Product is RBAC, Ownable {
    using SafeMath for *;

    bool public developmentMode = false;
    bool public maintenanceMode = false;

    modifier onlySandbox {
        // todo: Restrict to sandbox account
        _;
    }

    IProductService public productService;

    constructor(address _productService, bytes32 _name, bytes32 _policyFlow)
        internal
    {
        productService = IProductService(_productService);
        _register(_name, _policyFlow);
    }

    function toggleDevelopmentMode() internal {
        developmentMode = !developmentMode;
    }

    function toggleMaintenanceMode() internal {
        maintenanceMode = !maintenanceMode;
    }

    function _register(bytes32 _productName, bytes32 _policyFlow) internal {
        productService.register(_productName, _policyFlow);
    }

    function _newApplication(
        bytes32 _bpExternalKey,
        uint256 _premium,
        bytes32 _currency,
        uint256[] memory _payoutOptions
    ) internal returns (uint256 _applicationId) {
        _applicationId = productService.newApplication(
            _bpExternalKey,
            _premium,
            _currency,
            _payoutOptions
        );
    }

    function _underwrite(uint256 _applicationId)
        internal
        returns (uint256 _policyId)
    {
        _policyId = productService.underwrite(_applicationId);
    }

    function _decline(uint256 _applicationId) internal {
        productService.decline(_applicationId);
    }

    function _newClaim(uint256 _policyId) internal returns (uint256 _claimId) {
        _claimId = productService.newClaim(_policyId);
    }

    function _confirmClaim(uint256 _claimId, uint256 _amount)
        internal
        returns (uint256 _payoutId)
    {
        _payoutId = productService.confirmClaim(_claimId, _amount);
    }

    function _expire(uint256 _policyId) internal {
        productService.expire(_policyId);
    }

    function _payout(uint256 _payoutId, uint256 _amount)
        internal
        returns (uint256 _remainder)
    {
        _remainder = productService.payout(_payoutId, _amount);
    }

    function _getPayoutOptions(uint256 _applicationId)
        internal
        returns (uint256[] memory _payoutOptions)
    {
        _payoutOptions = productService.getPayoutOptions(_applicationId);
    }

    function _getPremium(uint256 _applicationId)
        internal
        returns (uint256 _premium)
    {
        _premium = productService.getPremium(_applicationId);
    }

    function _request(
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

// File: contracts/IPToken.sol

pragma solidity ^0.5.2;

interface IPToken {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function setAllowance(address _owner, address _spender, uint256 _value)
        external
        returns (bool _success);

    function burn(address _owner, address _spender, uint256 _value)
        external
        returns (bool _success);

    function addMinter(address account) external;

    function renounceMinter() external;

    function mint(address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/AtomicaMutual.sol

pragma solidity ^0.5.2;



contract AtomicaMutual is Product {
    event LogApplicationCreated(uint256 applicationID, address applicant, address sc, bytes32 roothash);
    event LogApplicationUnderwritten(uint256 policyID);
    event LogApplicationDeclined(uint256 applicationID);
    event LogRootHashAdded(bytes32 roothash);
    event LogRootHashRemoved(bytes32 roothash);
    event LogClaimCreated(uint256 claimID);
    event LogClaimConfirmed(uint256 payoutID);
    event LogPolicyExpired(uint256 _policyID);
    event LogPayoutConfirmed(uint256 _payoutID);
    event LogSetExpirePolicyRequest(uint256 _policyID);
    event LogExpiredPremiumPolicy(uint256 returnPremium);
    event LodMoveChargeFunds(address wallet, uint256 payment);
    event LogSetDailyCharge(
      uint256 policyID,
      uint256 coverage,
      uint256 startDate,
      uint256 dailyCharge,
      uint256 endDate,
      uint256 balance
    );

    mapping(bytes32 => bool) public roothashes;

    address public chairman;
    address payable accountant;
    address poolWallet;
    address atomicaWallet;

    IPToken ptoken;

    bytes32 public constant NAME = "AtomicaMutual";
    bytes32 public constant POLICY_FLOW = "PolicyFlowDefault";
    uint256 public constant PREMIUM_PERCENTAGE = 2;
    uint256 public constant ATOMICA_PERCENTAGE = 25;
    uint256 public constant DAY_IN_SECONDS = 86400;
    uint256 public constant MIN_COVERAGE_DAYS = 30;
    uint256 public constant MIN_COVERAGE = 1;
    uint256 public constant CHARGE_INTERVAL = 1;

    struct Application {
        address payable owner;
        address walletAddr;
        bytes32 roothash;
        uint256 commulatedPremium;
        uint256 expiration;
        uint256 coverageDays;
        uint256 coverage;
        uint256 applicationID;
        uint256 policyID;
    }

    struct Charge {
        uint256 policyID;
        uint256 coverage;
        uint256 startDate;
        uint256 dailyCharge;
        uint256 endDate;
        uint256 balance;
    }

    mapping(uint256 => Application) public applicationStructs;
    mapping(uint256 => uint256) public claimToApplication;
    mapping(uint256 => uint256) public policyToApplication;
    mapping(uint256 => uint256) public payoutToApplication;
    mapping(uint256 => bool) public expirationPolicyRequests;

    mapping(uint256 => Charge[]) public policyCharges;

    constructor(
        address _chairman,
        address _accountant,
        address _poolWallet,
        address payable _atomicaWallet,
        address payable _productService,
        address _ptoken
    ) public Product(_productService, NAME, POLICY_FLOW) {
        require(getCodeHash(_chairman) != 0, "ERROR::INVALID_ADDRESS");
        require(getCodeHash(_poolWallet) != 0, "ERROR::INVALID_WALLET");
        require(getCodeHash(_atomicaWallet) != 0, "ERROR::INVALID_WALLET");

        createRole("chairman");
        createRole("accountant");

        addRoleToAccount(_chairman, "chairman");
        addRoleToAccount(_accountant, "accountant");
        addRoleToAccount(msg.sender, "chairman");

        poolWallet = _poolWallet;
        atomicaWallet = _atomicaWallet;
        accountant = address(uint160(_accountant));
        ptoken = IPToken(_ptoken);
    }

    function addMinter(address _addr) external onlyWithRole("chairman") {
        ptoken.addMinter(_addr);
    }

    function renounceMinter() external onlyWithRole("chairman") {
        ptoken.renounceMinter();
    }

    function addRootHash(bytes32 _roothash) external {
        require(roothashes[_roothash] == false, "ERROR::ROOTHASH_EXIST");

        roothashes[_roothash] = true;

        emit LogRootHashAdded(_roothash);
    }

    function removeRootHash(bytes32 _roothash)
        external
        onlyWithRole("chairman")
    {
        require(roothashes[_roothash] == true, "ERROR::ROOTHASH_NOT_EXIST");
        roothashes[_roothash] = false;

        emit LogRootHashRemoved(_roothash);
    }

    function getCodeHash(address _addr) public view returns (bytes32 _hash) {
        assembly {
            _hash := extcodehash(_addr)
        }
    }

    function getQuote(address _addr, uint256 _coverage, uint256 _days)
        public
        view
        returns (uint256 _premium, bytes32 _roothash, bool _applicable)
    {
        _premium = _coverage.mul(PREMIUM_PERCENTAGE).mul(_days).div(36500); // 365 days for 2% per year
        _roothash = getCodeHash(_addr);
        _applicable = roothashes[_roothash];
    }

    function applyForPolicy(
        bytes32 _bpExternalKey,
        address _walletAddr,
        uint256 _coverage,
        uint256 _days
    ) external payable {
        require(msg.value > 0, "ERROR::INVALID_PREMIUM");
        require(_days >= MIN_COVERAGE_DAYS, "ERROR::INVALID_COVERAGE_DAYS");
        require(_coverage >= MIN_COVERAGE, "ERROR::INVALID_COVERAGE");

        (uint256 premium, bytes32 roothash, bool applicable) = getQuote(
            _walletAddr,
            _coverage,
            _days
        );

        require(applicable == true, "ERROR::UNKNOWN_CONTRACT_TYPE");
        require(premium == msg.value, "ERROR::INVALID_VALUE_PREMIUM");

        uint256[] memory payoutAtomicaOptions = new uint256[](1);
        payoutAtomicaOptions[0] = _coverage;

        uint256 applicationID = _newApplication(
            _bpExternalKey,
            premium,
            bytes32("ETH"), //tokens
            payoutAtomicaOptions
        );

        applicationStructs[applicationID].applicationID = applicationID;
        applicationStructs[applicationID].owner = msg.sender;
        applicationStructs[applicationID].walletAddr = _walletAddr;
        applicationStructs[applicationID].roothash = roothash;
        applicationStructs[applicationID].coverage = _coverage;
        applicationStructs[applicationID].coverageDays = _days;

        emit LogApplicationCreated(applicationID, msg.sender, _walletAddr, roothash);
    }

    function declineApplication(uint256 _applicationID)
        external
    {
        require(
            applicationStructs[_applicationID].applicationID > 0,
            "ERROR::NOT_EXISTING_APPLICATION"
        );
        uint256 premium = _getPremium(_applicationID);

        address(applicationStructs[_applicationID].owner).transfer(premium);

        _decline(_applicationID);

        emit LogApplicationDeclined(_applicationID);
    }

    function underwriteApplication(uint256 _applicationID)
        external
    {
        require(
            applicationStructs[_applicationID].applicationID > 0,
            "ERROR::NOT_EXISTING_APPLICATION"
        );
        uint256 policyID = _underwrite(_applicationID);
        uint256 premium = _getPremium(_applicationID);

        ptoken.mint(applicationStructs[_applicationID].walletAddr, premium);

        ptoken.setAllowance(
            applicationStructs[_applicationID].walletAddr,
            address(this),
            premium
        );

        applicationStructs[_applicationID].policyID = policyID;
        applicationStructs[_applicationID].expiration = block.timestamp + applicationStructs[_applicationID].coverageDays.mul(
            DAY_IN_SECONDS
        );

        accountant.transfer(premium);

        chargePolicy(_applicationID);

        policyToApplication[policyID] = applicationStructs[_applicationID].applicationID;

        emit LogApplicationUnderwritten(policyID);
    }

    function moveChargeFunds(address _wallet, uint256 _dailyPremium) internal {
        uint256 atomicaPayment = _dailyPremium.mul(ATOMICA_PERCENTAGE).div(100);
        uint256 poolPayment = _dailyPremium.sub(atomicaPayment);

        ptoken.transferFrom(_wallet, atomicaWallet, atomicaPayment);
        ptoken.transferFrom(_wallet, poolWallet, poolPayment);
    }

    function chargePolicy(uint256 _applicationID) public {
        uint256 balance = address(applicationStructs[_applicationID].walletAddr).balance;
        uint256 coverage = applicationStructs[_applicationID].coverage > balance ? balance : applicationStructs[_applicationID].coverage;
        (uint256 dailyPremium, ,) = getQuote(applicationStructs[_applicationID].walletAddr, coverage, CHARGE_INTERVAL);

        uint256 ptokenBalance = ptoken.balanceOf(applicationStructs[_applicationID].walletAddr);
        uint256 ptokenAllowance = ptoken.allowance(applicationStructs[_applicationID].walletAddr, address(this));
        uint256 length = policyCharges[_applicationID].length;
        uint256 previousBalance = (length == 0) ? 0 : balance.sub(policyCharges[_applicationID][length - 1].balance);

        uint256 dailyCharge = (length == 0) ? dailyPremium :
          dailyPremium.add(previousBalance.mul(PREMIUM_PERCENTAGE).mul(CHARGE_INTERVAL).div(36500));

        if ((ptokenBalance < dailyCharge) || (ptokenAllowance < dailyCharge)) {
            expirePolicy(applicationStructs[_applicationID].policyID);
        }

        uint256 startDate = (length == 0) ? block.timestamp : policyCharges[_applicationID][length - 1].endDate;
        uint256 endDate = startDate.add(DAY_IN_SECONDS);

        if (length > 0) {
          require(policyCharges[_applicationID][length - 1].endDate < block.timestamp, "ERROR::TOKENS_WAS_CHARGED");
        }

        moveChargeFunds(applicationStructs[_applicationID].walletAddr, dailyCharge);

        applicationStructs[_applicationID].commulatedPremium += dailyCharge;

        policyCharges[_applicationID].push(
            Charge(
                applicationStructs[_applicationID].policyID,
                coverage,
                startDate,
                dailyCharge,
                endDate,
                balance
            )
        );
        emit LogSetDailyCharge(
          applicationStructs[_applicationID].policyID,
          coverage,
          startDate,
          dailyCharge,
          endDate,
          balance
        );
    }

    function expirePolicyRequest(uint256 _policyID) public {
        expirationPolicyRequests[_policyID] = true;
        expirePolicy(_policyID);
        emit LogSetExpirePolicyRequest(_policyID);
    }

    function expirePolicy(uint256 _policyID) internal {
        _expire(_policyID);

        emit LogPolicyExpired(_policyID);
    }

    function confirmExpiredPolicy(uint256 _policyID)
        external
        payable
        onlyWithRole("accountant")
    {
        uint256 applicationID = policyToApplication[_policyID];

        uint256 returnPremium = _getPremium(
            applicationStructs[applicationID].applicationID
        ) - applicationStructs[applicationID].commulatedPremium;

        require(
            expirationPolicyRequests[_policyID] == true,
            "ERROR::NOT_EXPIRATION_POLICY_REQUEST"
        );
        require(returnPremium == msg.value, "ERROR::INVALID_VALUE");

        ptoken.burn(
            applicationStructs[applicationID].walletAddr,
            address(this),
            msg.value
        );
        applicationStructs[applicationID].owner.transfer(msg.value);

        expirationPolicyRequests[_policyID] = false;
    }

    function createClaim(uint256 _policyID) external {
        require(
            applicationStructs[policyToApplication[_policyID]].owner == msg.sender,
            "ERROR::USER_NOT_VALID"
        );
        uint256 claimID = _newClaim(_policyID);
        claimToApplication[claimID] = policyToApplication[_policyID];

        emit LogClaimCreated(claimID);
    }

    function confirmClaim(uint256 _claimID, uint256 _amount)
        external
        onlyWithRole("chairman")
    {
        uint256 payoutID = _confirmClaim(_claimID, _amount);
        payoutToApplication[payoutID] = claimToApplication[_claimID];

        emit LogClaimConfirmed(payoutID);
    }

    // @todo
    function declineClaim(uint256 _claimID) external onlyWithRole("chairman") {}

    function confirmPayout(uint256 _payoutID, uint256 _amount)
        external
        payable
        onlyWithRole("accountant")
    {
        _payout(_payoutID, _amount);

        require(
            applicationStructs[payoutToApplication[_payoutID]].coverage <= msg.value,
            "ERROR::INVALID_VALUE"
        );

        applicationStructs[payoutToApplication[_payoutID]].owner.transfer(
            msg.value
        );
        ptoken.burn(poolWallet, chairman, msg.value);
        expirePolicyRequest(
            applicationStructs[payoutToApplication[_payoutID]].policyID
        );

        emit LogPayoutConfirmed(_payoutID);
    }
}
