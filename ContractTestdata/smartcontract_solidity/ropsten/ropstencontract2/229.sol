/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;


contract Modifiable {
    
    
    
    modifier notNullAddress(address _address) {
        require(_address != address(0));
        _;
    }

    modifier notThisAddress(address _address) {
        require(_address != address(this));
        _;
    }

    modifier notNullOrThisAddress(address _address) {
        require(_address != address(0));
        require(_address != address(this));
        _;
    }

    modifier notSameAddresses(address _address1, address _address2) {
        if (_address1 != _address2)
            _;
    }
}

contract SelfDestructible {
    
    
    
    bool public selfDestructionDisabled;

    
    
    
    event SelfDestructionDisabledEvent(address wallet);
    event TriggerSelfDestructionEvent(address wallet);

    
    
    
    
    function destructor()
    public
    view
    returns (address);

    
    
    function disableSelfDestruction()
    public
    {
        
        require(destructor() == msg.sender);

        
        selfDestructionDisabled = true;

        
        emit SelfDestructionDisabledEvent(msg.sender);
    }

    
    function triggerSelfDestruction()
    public
    {
        
        require(destructor() == msg.sender);

        
        require(!selfDestructionDisabled);

        
        emit TriggerSelfDestructionEvent(msg.sender);

        
        selfdestruct(msg.sender);
    }
}

contract Ownable is Modifiable, SelfDestructible {
    
    
    
    address public deployer;
    address public operator;

    
    
    
    event SetDeployerEvent(address oldDeployer, address newDeployer);
    event SetOperatorEvent(address oldOperator, address newOperator);

    
    
    
    constructor(address _deployer) internal notNullOrThisAddress(_deployer) {
        deployer = _deployer;
        operator = _deployer;
    }

    
    
    
    
    function destructor()
    public
    view
    returns (address)
    {
        return deployer;
    }

    
    
    function setDeployer(address newDeployer)
    public
    onlyDeployer
    notNullOrThisAddress(newDeployer)
    {
        if (newDeployer != deployer) {
            
            address oldDeployer = deployer;
            deployer = newDeployer;

            
            emit SetDeployerEvent(oldDeployer, newDeployer);
        }
    }

    
    
    function setOperator(address newOperator)
    public
    onlyOperator
    notNullOrThisAddress(newOperator)
    {
        if (newOperator != operator) {
            
            address oldOperator = operator;
            operator = newOperator;

            
            emit SetOperatorEvent(oldOperator, newOperator);
        }
    }

    
    
    function isDeployer()
    internal
    view
    returns (bool)
    {
        return msg.sender == deployer;
    }

    
    
    function isOperator()
    internal
    view
    returns (bool)
    {
        return msg.sender == operator;
    }

    
    
    
    function isDeployerOrOperator()
    internal
    view
    returns (bool)
    {
        return isDeployer() || isOperator();
    }

    
    
    modifier onlyDeployer() {
        require(isDeployer());
        _;
    }

    modifier notDeployer() {
        require(!isDeployer());
        _;
    }

    modifier onlyOperator() {
        require(isOperator());
        _;
    }

    modifier notOperator() {
        require(!isOperator());
        _;
    }

    modifier onlyDeployerOrOperator() {
        require(isDeployerOrOperator());
        _;
    }

    modifier notDeployerOrOperator() {
        require(!isDeployerOrOperator());
        _;
    }
}

contract Servable is Ownable {
    
    
    
    struct ServiceInfo {
        bool registered;
        uint256 activationTimestamp;
        mapping(bytes32 => bool) actionsEnabledMap;
        bytes32[] actionsList;
    }

    
    
    
    mapping(address => ServiceInfo) internal registeredServicesMap;
    uint256 public serviceActivationTimeout;

    
    
    
    event ServiceActivationTimeoutEvent(uint256 timeoutInSeconds);
    event RegisterServiceEvent(address service);
    event RegisterServiceDeferredEvent(address service, uint256 timeout);
    event DeregisterServiceEvent(address service);
    event EnableServiceActionEvent(address service, string action);
    event DisableServiceActionEvent(address service, string action);

    
    
    
    
    
    function setServiceActivationTimeout(uint256 timeoutInSeconds)
    public
    onlyDeployer
    {
        serviceActivationTimeout = timeoutInSeconds;

        
        emit ServiceActivationTimeoutEvent(timeoutInSeconds);
    }

    
    
    function registerService(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        _registerService(service, 0);

        
        emit RegisterServiceEvent(service);
    }

    
    
    function registerServiceDeferred(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        _registerService(service, serviceActivationTimeout);

        
        emit RegisterServiceDeferredEvent(service, serviceActivationTimeout);
    }

    
    
    function deregisterService(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        require(registeredServicesMap[service].registered);

        registeredServicesMap[service].registered = false;

        
        emit DeregisterServiceEvent(service);
    }

    
    
    
    function enableServiceAction(address service, string memory action)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        require(registeredServicesMap[service].registered);

        bytes32 actionHash = hashString(action);

        require(!registeredServicesMap[service].actionsEnabledMap[actionHash]);

        registeredServicesMap[service].actionsEnabledMap[actionHash] = true;
        registeredServicesMap[service].actionsList.push(actionHash);

        
        emit EnableServiceActionEvent(service, action);
    }

    
    
    
    function disableServiceAction(address service, string memory action)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        bytes32 actionHash = hashString(action);

        require(registeredServicesMap[service].actionsEnabledMap[actionHash]);

        registeredServicesMap[service].actionsEnabledMap[actionHash] = false;

        
        emit DisableServiceActionEvent(service, action);
    }

    
    
    
    function isRegisteredService(address service)
    public
    view
    returns (bool)
    {
        return registeredServicesMap[service].registered;
    }

    
    
    
    function isRegisteredActiveService(address service)
    public
    view
    returns (bool)
    {
        return isRegisteredService(service) && block.timestamp >= registeredServicesMap[service].activationTimestamp;
    }

    
    
    
    function isEnabledServiceAction(address service, string memory action)
    public
    view
    returns (bool)
    {
        bytes32 actionHash = hashString(action);
        return isRegisteredActiveService(service) && registeredServicesMap[service].actionsEnabledMap[actionHash];
    }

    
    
    
    function hashString(string memory _string)
    internal
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_string));
    }

    
    
    
    function _registerService(address service, uint256 timeout)
    private
    {
        if (!registeredServicesMap[service].registered) {
            registeredServicesMap[service].registered = true;
            registeredServicesMap[service].activationTimestamp = block.timestamp + timeout;
        }
    }

    
    
    
    modifier onlyActiveService() {
        require(isRegisteredActiveService(msg.sender));
        _;
    }

    modifier onlyEnabledServiceAction(string memory action) {
        require(isEnabledServiceAction(msg.sender, action));
        _;
    }
}

library SafeMathIntLib {
    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    
    
    
    function div(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != INT256_MIN || b != - 1);
        return a / b;
    }

    function mul(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != - 1 || b != INT256_MIN);
        
        require(b != - 1 || a != INT256_MIN);
        
        int256 c = a * b;
        require((b == 0) || (c / b == a));
        return c;
    }

    function sub(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
        return a - b;
    }

    function add(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    
    
    
    function div_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b > 0);
        return a / b;
    }

    function mul_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a * b;
        require(a == 0 || c / a == b);
        require(c >= 0);
        return c;
    }

    function sub_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0 && b <= a);
        return a - b;
    }

    function add_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a + b;
        require(c >= a);
        return c;
    }

    
    
    
    function abs(int256 a)
    public
    pure
    returns (int256)
    {
        return a < 0 ? neg(a) : a;
    }

    function neg(int256 a)
    public
    pure
    returns (int256)
    {
        return mul(a, - 1);
    }

    function toNonZeroInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a > 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a >= 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toUInt256(int256 a)
    public
    pure
    returns (uint256)
    {
        require(a >= 0);
        return uint256(a);
    }

    function isNonZeroPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a > 0);
    }

    function isPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a >= 0);
    }

    function isNonZeroNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a < 0);
    }

    function isNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a <= 0);
    }

    
    
    
    function clamp(int256 a, int256 min, int256 max)
    public
    pure
    returns (int256)
    {
        if (a < min)
            return min;
        return (a > max) ? max : a;
    }

    function clampMin(int256 a, int256 min)
    public
    pure
    returns (int256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(int256 a, int256 max)
    public
    pure
    returns (int256)
    {
        return (a > max) ? max : a;
    }
}

library SafeMathUintLib {
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    
    
    
    function clamp(uint256 a, uint256 min, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : ((a < min) ? min : a);
    }

    function clampMin(uint256 a, uint256 min)
    public
    pure
    returns (uint256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(uint256 a, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : a;
    }
}

library MonetaryTypesLib {
    
    
    
    struct Currency {
        address ct;
        uint256 id;
    }

    struct Figure {
        int256 amount;
        Currency currency;
    }

    struct NoncedAmount {
        uint256 nonce;
        int256 amount;
    }
}

library CurrenciesLib {
    using SafeMathUintLib for uint256;

    
    
    
    struct Currencies {
        MonetaryTypesLib.Currency[] currencies;
        mapping(address => mapping(uint256 => uint256)) indexByCurrency;
    }

    
    
    
    function add(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        
        if (0 == self.indexByCurrency[currencyCt][currencyId]) {
            self.currencies.push(MonetaryTypesLib.Currency(currencyCt, currencyId));
            self.indexByCurrency[currencyCt][currencyId] = self.currencies.length;
        }
    }

    function removeByCurrency(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        
        uint256 index = self.indexByCurrency[currencyCt][currencyId];
        if (0 < index)
            removeByIndex(self, index - 1);
    }

    function removeByIndex(Currencies storage self, uint256 index)
    internal
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:51]");

        address currencyCt = self.currencies[index].ct;
        uint256 currencyId = self.currencies[index].id;

        if (index < self.currencies.length - 1) {
            self.currencies[index] = self.currencies[self.currencies.length - 1];
            self.indexByCurrency[self.currencies[index].ct][self.currencies[index].id] = index + 1;
        }
        self.currencies.length--;
        self.indexByCurrency[currencyCt][currencyId] = 0;
    }

    function count(Currencies storage self)
    internal
    view
    returns (uint256)
    {
        return self.currencies.length;
    }

    function has(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 != self.indexByCurrency[currencyCt][currencyId];
    }

    function getByIndex(Currencies storage self, uint256 index)
    internal
    view
    returns (MonetaryTypesLib.Currency memory)
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:85]");
        return self.currencies[index];
    }

    function getByIndices(Currencies storage self, uint256 low, uint256 up)
    internal
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        require(0 < self.currencies.length, "No currencies found [CurrenciesLib.sol:94]");
        require(low <= up, "Bounds parameters mismatch [CurrenciesLib.sol:95]");

        up = up.clampMax(self.currencies.length - 1);
        MonetaryTypesLib.Currency[] memory _currencies = new MonetaryTypesLib.Currency[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _currencies[i - low] = self.currencies[i];

        return _currencies;
    }
}

library FungibleBalanceLib {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    
    
    
    struct Record {
        int256 amount;
        uint256 blockNumber;
    }

    struct Balance {
        mapping(address => mapping(uint256 => int256)) amountByCurrency;
        mapping(address => mapping(uint256 => Record[])) recordsByCurrency;

        CurrenciesLib.Currencies inUseCurrencies;
        CurrenciesLib.Currencies everUsedCurrencies;
    }

    
    
    
    function get(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256)
    {
        return self.amountByCurrency[currencyCt][currencyId];
    }

    function getByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256)
    {
        (int256 amount,) = recordByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return amount;
    }

    function set(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = amount;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function add(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].add(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function sub(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].sub(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function transfer(Balance storage _from, Balance storage _to, int256 amount,
        address currencyCt, uint256 currencyId)
    internal
    {
        sub(_from, amount, currencyCt, currencyId);
        add(_to, amount, currencyCt, currencyId);
    }

    function add_nn(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].add_nn(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function sub_nn(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].sub_nn(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function transfer_nn(Balance storage _from, Balance storage _to, int256 amount,
        address currencyCt, uint256 currencyId)
    internal
    {
        sub_nn(_from, amount, currencyCt, currencyId);
        add_nn(_to, amount, currencyCt, currencyId);
    }

    function recordsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.recordsByCurrency[currencyCt][currencyId].length;
    }

    function recordByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256, uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (0, 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (0, 0);

        index = index.clampMax(self.recordsByCurrency[currencyCt][currencyId].length - 1);
        Record storage record = self.recordsByCurrency[currencyCt][currencyId][index];
        return (record.amount, record.blockNumber);
    }

    function lastRecord(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (0, 0);

        Record storage record = self.recordsByCurrency[currencyCt][currencyId][self.recordsByCurrency[currencyCt][currencyId].length - 1];
        return (record.amount, record.blockNumber);
    }

    function hasInUseCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.inUseCurrencies.has(currencyCt, currencyId);
    }

    function hasEverUsedCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.everUsedCurrencies.has(currencyCt, currencyId);
    }

    function updateCurrencies(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        if (0 == self.amountByCurrency[currencyCt][currencyId] && self.inUseCurrencies.has(currencyCt, currencyId))
            self.inUseCurrencies.removeByCurrency(currencyCt, currencyId);
        else if (!self.inUseCurrencies.has(currencyCt, currencyId)) {
            self.inUseCurrencies.add(currencyCt, currencyId);
            self.everUsedCurrencies.add(currencyCt, currencyId);
        }
    }

    function indexByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return 0;
        for (uint256 i = self.recordsByCurrency[currencyCt][currencyId].length; i > 0; i--)
            if (self.recordsByCurrency[currencyCt][currencyId][i - 1].blockNumber <= blockNumber)
                return i;
        return 0;
    }
}

library NonFungibleBalanceLib {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    
    
    
    struct Record {
        int256[] ids;
        uint256 blockNumber;
    }

    struct Balance {
        mapping(address => mapping(uint256 => int256[])) idsByCurrency;
        mapping(address => mapping(uint256 => mapping(int256 => uint256))) idIndexById;
        mapping(address => mapping(uint256 => Record[])) recordsByCurrency;

        CurrenciesLib.Currencies inUseCurrencies;
        CurrenciesLib.Currencies everUsedCurrencies;
    }

    
    
    
    function get(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory)
    {
        return self.idsByCurrency[currencyCt][currencyId];
    }

    function getByIndices(Balance storage self, address currencyCt, uint256 currencyId, uint256 indexLow, uint256 indexUp)
    internal
    view
    returns (int256[] memory)
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length)
            return new int256[](0);

        indexUp = indexUp.clampMax(self.idsByCurrency[currencyCt][currencyId].length - 1);

        int256[] memory idsByCurrency = new int256[](indexUp - indexLow + 1);
        for (uint256 i = indexLow; i < indexUp; i++)
            idsByCurrency[i - indexLow] = self.idsByCurrency[currencyCt][currencyId][i];

        return idsByCurrency;
    }

    function idsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.idsByCurrency[currencyCt][currencyId].length;
    }

    function hasId(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 < self.idIndexById[currencyCt][currencyId][id];
    }

    function recordByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256[] memory, uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (new int256[](0), 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        index = index.clampMax(self.recordsByCurrency[currencyCt][currencyId].length - 1);
        Record storage record = self.recordsByCurrency[currencyCt][currencyId][index];
        return (record.ids, record.blockNumber);
    }

    function lastRecord(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        Record storage record = self.recordsByCurrency[currencyCt][currencyId][self.recordsByCurrency[currencyCt][currencyId].length - 1];
        return (record.ids, record.blockNumber);
    }

    function recordsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.recordsByCurrency[currencyCt][currencyId].length;
    }

    function set(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    {
        int256[] memory ids = new int256[](1);
        ids[0] = id;
        set(self, ids, currencyCt, currencyId);
    }

    function set(Balance storage self, int256[] memory ids, address currencyCt, uint256 currencyId)
    internal
    {
        uint256 i;
        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId] = ids;

        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = i + 1;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function reset(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        for (uint256 i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId].length = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function add(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        if (0 < self.idIndexById[currencyCt][currencyId][id])
            return false;

        self.idsByCurrency[currencyCt][currencyId].push(id);

        self.idIndexById[currencyCt][currencyId][id] = self.idsByCurrency[currencyCt][currencyId].length;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function sub(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        uint256 index = self.idIndexById[currencyCt][currencyId][id];

        if (0 == index)
            return false;

        if (index < self.idsByCurrency[currencyCt][currencyId].length) {
            self.idsByCurrency[currencyCt][currencyId][index - 1] = self.idsByCurrency[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId].length - 1];
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][index - 1]] = index;
        }
        self.idsByCurrency[currencyCt][currencyId].length--;
        self.idIndexById[currencyCt][currencyId][id] = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function transfer(Balance storage _from, Balance storage _to, int256 id,
        address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        return sub(_from, id, currencyCt, currencyId) && add(_to, id, currencyCt, currencyId);
    }

    function hasInUseCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.inUseCurrencies.has(currencyCt, currencyId);
    }

    function hasEverUsedCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.everUsedCurrencies.has(currencyCt, currencyId);
    }

    function updateInUseCurrencies(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length && self.inUseCurrencies.has(currencyCt, currencyId))
            self.inUseCurrencies.removeByCurrency(currencyCt, currencyId);
        else if (!self.inUseCurrencies.has(currencyCt, currencyId)) {
            self.inUseCurrencies.add(currencyCt, currencyId);
            self.everUsedCurrencies.add(currencyCt, currencyId);
        }
    }

    function indexByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return 0;
        for (uint256 i = self.recordsByCurrency[currencyCt][currencyId].length; i > 0; i--)
            if (self.recordsByCurrency[currencyCt][currencyId][i - 1].blockNumber <= blockNumber)
                return i;
        return 0;
    }
}

contract BalanceTracker is Ownable, Servable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using NonFungibleBalanceLib for NonFungibleBalanceLib.Balance;

    
    
    
    string constant public DEPOSITED_BALANCE_TYPE = "deposited";
    string constant public SETTLED_BALANCE_TYPE = "settled";
    string constant public STAGED_BALANCE_TYPE = "staged";

    
    
    
    struct Wallet {
        mapping(bytes32 => FungibleBalanceLib.Balance) fungibleBalanceByType;
        mapping(bytes32 => NonFungibleBalanceLib.Balance) nonFungibleBalanceByType;
    }

    
    
    
    bytes32 public depositedBalanceType;
    bytes32 public settledBalanceType;
    bytes32 public stagedBalanceType;

    bytes32[] public _allBalanceTypes;
    bytes32[] public _activeBalanceTypes;

    bytes32[] public trackedBalanceTypes;
    mapping(bytes32 => bool) public trackedBalanceTypeMap;

    mapping(address => Wallet) private walletMap;

    address[] public trackedWallets;
    mapping(address => uint256) public trackedWalletIndexByWallet;

    
    
    
    constructor(address deployer) Ownable(deployer)
    public
    {
        depositedBalanceType = keccak256(abi.encodePacked(DEPOSITED_BALANCE_TYPE));
        settledBalanceType = keccak256(abi.encodePacked(SETTLED_BALANCE_TYPE));
        stagedBalanceType = keccak256(abi.encodePacked(STAGED_BALANCE_TYPE));

        _allBalanceTypes.push(settledBalanceType);
        _allBalanceTypes.push(depositedBalanceType);
        _allBalanceTypes.push(stagedBalanceType);

        _activeBalanceTypes.push(settledBalanceType);
        _activeBalanceTypes.push(depositedBalanceType);
    }

    
    
    
    
    
    
    
    
    
    function get(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].get(currencyCt, currencyId);
    }

    
    
    
    
    
    
    
    
    function getByIndices(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 indexLow, uint256 indexUp)
    public
    view
    returns (int256[] memory)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].getByIndices(
            currencyCt, currencyId, indexLow, indexUp
        );
    }

    
    
    
    
    
    
    function getAll(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256[] memory)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].get(
            currencyCt, currencyId
        );
    }

    
    
    
    
    
    
    function idsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].idsCount(
            currencyCt, currencyId
        );
    }

    
    
    
    
    
    
    
    function hasId(address wallet, bytes32 _type, int256 id, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].hasId(
            id, currencyCt, currencyId
        );
    }

    
    
    
    
    
    
    
    function set(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId, bool fungible)
    public
    onlyActiveService
    {
        
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].set(
                value, currencyCt, currencyId
            );

        else
            walletMap[wallet].nonFungibleBalanceByType[_type].set(
                value, currencyCt, currencyId
            );

        
        _updateTrackedBalanceTypes(_type);

        
        _updateTrackedWallets(wallet);
    }

    
    
    
    
    
    
    function setIds(address wallet, bytes32 _type, int256[] memory ids, address currencyCt, uint256 currencyId)
    public
    onlyActiveService
    {
        
        walletMap[wallet].nonFungibleBalanceByType[_type].set(
            ids, currencyCt, currencyId
        );

        
        _updateTrackedBalanceTypes(_type);

        
        _updateTrackedWallets(wallet);
    }

    
    
    
    
    
    
    
    function add(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId,
        bool fungible)
    public
    onlyActiveService
    {
        
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].add(
                value, currencyCt, currencyId
            );
        else
            walletMap[wallet].nonFungibleBalanceByType[_type].add(
                value, currencyCt, currencyId
            );

        
        _updateTrackedBalanceTypes(_type);

        
        _updateTrackedWallets(wallet);
    }

    
    
    
    
    
    
    
    function sub(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId,
        bool fungible)
    public
    onlyActiveService
    {
        
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].sub(
                value, currencyCt, currencyId
            );
        else
            walletMap[wallet].nonFungibleBalanceByType[_type].sub(
                value, currencyCt, currencyId
            );

        
        _updateTrackedWallets(wallet);
    }

    
    
    
    
    
    
    function hasInUseCurrency(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].hasInUseCurrency(currencyCt, currencyId)
        || walletMap[wallet].nonFungibleBalanceByType[_type].hasInUseCurrency(currencyCt, currencyId);
    }

    
    
    
    
    
    
    function hasEverUsedCurrency(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].hasEverUsedCurrency(currencyCt, currencyId)
        || walletMap[wallet].nonFungibleBalanceByType[_type].hasEverUsedCurrency(currencyCt, currencyId);
    }

    
    
    
    
    
    
    function fungibleRecordsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordsCount(currencyCt, currencyId);
    }

    
    
    
    
    
    
    
    
    function fungibleRecordByIndex(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 index)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordByIndex(currencyCt, currencyId, index);
    }

    
    
    
    
    
    
    
    
    function fungibleRecordByBlockNumber(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 _blockNumber)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordByBlockNumber(currencyCt, currencyId, _blockNumber);
    }

    
    
    
    
    
    
    function lastFungibleRecord(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].lastRecord(currencyCt, currencyId);
    }

    
    
    
    
    
    
    function nonFungibleRecordsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordsCount(currencyCt, currencyId);
    }

    
    
    
    
    
    
    
    
    function nonFungibleRecordByIndex(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 index)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordByIndex(currencyCt, currencyId, index);
    }

    
    
    
    
    
    
    
    
    function nonFungibleRecordByBlockNumber(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 _blockNumber)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordByBlockNumber(currencyCt, currencyId, _blockNumber);
    }

    
    
    
    
    
    
    function lastNonFungibleRecord(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].lastRecord(currencyCt, currencyId);
    }

    
    
    function trackedBalanceTypesCount()
    public
    view
    returns (uint256)
    {
        return trackedBalanceTypes.length;
    }

    
    
    function trackedWalletsCount()
    public
    view
    returns (uint256)
    {
        return trackedWallets.length;
    }

    
    
    function allBalanceTypes()
    public
    view
    returns (bytes32[] memory)
    {
        return _allBalanceTypes;
    }

    
    
    function activeBalanceTypes()
    public
    view
    returns (bytes32[] memory)
    {
        return _activeBalanceTypes;
    }

    
    
    
    
    function trackedWalletsByIndices(uint256 low, uint256 up)
    public
    view
    returns (address[] memory)
    {
        require(0 < trackedWallets.length, "No tracked wallets found [BalanceTracker.sol:473]");
        require(low <= up, "Bounds parameters mismatch [BalanceTracker.sol:474]");

        up = up.clampMax(trackedWallets.length - 1);
        address[] memory _trackedWallets = new address[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _trackedWallets[i - low] = trackedWallets[i];

        return _trackedWallets;
    }

    
    
    
    function _updateTrackedBalanceTypes(bytes32 _type)
    private
    {
        if (!trackedBalanceTypeMap[_type]) {
            trackedBalanceTypeMap[_type] = true;
            trackedBalanceTypes.push(_type);
        }
    }

    function _updateTrackedWallets(address wallet)
    private
    {
        if (0 == trackedWalletIndexByWallet[wallet]) {
            trackedWallets.push(wallet);
            trackedWalletIndexByWallet[wallet] = trackedWallets.length;
        }
    }
}
