/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;
pragma experimental ABIEncoderV2;


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

library BlockNumbUintsLib {
    
    
    
    struct Entry {
        uint256 blockNumber;
        uint256 value;
    }

    struct BlockNumbUints {
        Entry[] entries;
    }

    
    
    
    function currentValue(BlockNumbUints storage self)
    internal
    view
    returns (uint256)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbUints storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbUints storage self, uint256 _blockNumber)
    internal
    view
    returns (uint256)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbUints storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbUints storage self, uint256 blockNumber, uint256 value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbUintsLib.sol:62]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbUints storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbUints storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbUints storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbUintsLib.sol:92]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

library BlockNumbIntsLib {
    
    
    
    struct Entry {
        uint256 blockNumber;
        int256 value;
    }

    struct BlockNumbInts {
        Entry[] entries;
    }

    
    
    
    function currentValue(BlockNumbInts storage self)
    internal
    view
    returns (int256)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbInts storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbInts storage self, uint256 _blockNumber)
    internal
    view
    returns (int256)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbInts storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbInts storage self, uint256 blockNumber, int256 value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbIntsLib.sol:62]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbInts storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbInts storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbIntsLib.sol:92]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

library ConstantsLib {
    
    function PARTS_PER()
    public
    pure
    returns (int256)
    {
        return 1e18;
    }
}

library BlockNumbDisdIntsLib {
    using SafeMathIntLib for int256;

    
    
    
    struct Discount {
        int256 tier;
        int256 value;
    }

    struct Entry {
        uint256 blockNumber;
        int256 nominal;
        Discount[] discounts;
    }

    struct BlockNumbDisdInts {
        Entry[] entries;
    }

    
    
    
    function currentNominalValue(BlockNumbDisdInts storage self)
    internal
    view
    returns (int256)
    {
        return nominalValueAt(self, block.number);
    }

    function currentDiscountedValue(BlockNumbDisdInts storage self, int256 tier)
    internal
    view
    returns (int256)
    {
        return discountedValueAt(self, block.number, tier);
    }

    function currentEntry(BlockNumbDisdInts storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function nominalValueAt(BlockNumbDisdInts storage self, uint256 _blockNumber)
    internal
    view
    returns (int256)
    {
        return entryAt(self, _blockNumber).nominal;
    }

    function discountedValueAt(BlockNumbDisdInts storage self, uint256 _blockNumber, int256 tier)
    internal
    view
    returns (int256)
    {
        Entry memory entry = entryAt(self, _blockNumber);
        if (0 < entry.discounts.length) {
            uint256 index = indexByTier(entry.discounts, tier);
            if (0 < index)
                return entry.nominal.mul(
                    ConstantsLib.PARTS_PER().sub(entry.discounts[index - 1].value)
                ).div(
                    ConstantsLib.PARTS_PER()
                );
            else
                return entry.nominal;
        } else
            return entry.nominal;
    }

    function entryAt(BlockNumbDisdInts storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addNominalEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbDisdIntsLib.sol:101]"
        );

        self.entries.length++;
        Entry storage entry = self.entries[self.entries.length - 1];

        entry.blockNumber = blockNumber;
        entry.nominal = nominal;
    }

    function addDiscountedEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal,
        int256[] memory discountTiers, int256[] memory discountValues)
    internal
    {
        require(discountTiers.length == discountValues.length, "Parameter array lengths mismatch [BlockNumbDisdIntsLib.sol:118]");

        addNominalEntry(self, blockNumber, nominal);

        Entry storage entry = self.entries[self.entries.length - 1];
        for (uint256 i = 0; i < discountTiers.length; i++)
            entry.discounts.push(Discount(discountTiers[i], discountValues[i]));
    }

    function count(BlockNumbDisdInts storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbDisdInts storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbDisdInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbDisdIntsLib.sol:148]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }

    
    function indexByTier(Discount[] memory discounts, int256 tier)
    internal
    pure
    returns (uint256)
    {
        require(0 < discounts.length, "No discounts found [BlockNumbDisdIntsLib.sol:161]");
        for (uint256 i = discounts.length; i > 0; i--)
            if (tier >= discounts[i - 1].tier)
                return i;
        return 0;
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

library BlockNumbReferenceCurrenciesLib {
    
    
    
    struct Entry {
        uint256 blockNumber;
        MonetaryTypesLib.Currency currency;
    }

    struct BlockNumbReferenceCurrencies {
        mapping(address => mapping(uint256 => Entry[])) entriesByCurrency;
    }

    
    
    
    function currentCurrency(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return currencyAt(self, referenceCurrency, block.number);
    }

    function currentEntry(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (Entry storage)
    {
        return entryAt(self, referenceCurrency, block.number);
    }

    function currencyAt(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return entryAt(self, referenceCurrency, _blockNumber).currency;
    }

    function entryAt(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (Entry storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][indexByBlockNumber(self, referenceCurrency, _blockNumber)];
    }

    function addEntry(BlockNumbReferenceCurrencies storage self, uint256 blockNumber,
        MonetaryTypesLib.Currency memory referenceCurrency, MonetaryTypesLib.Currency memory currency)
    internal
    {
        require(
            0 == self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length ||
        blockNumber > self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length - 1].blockNumber,
            "Later entry found for currency [BlockNumbReferenceCurrenciesLib.sol:67]"
        );

        self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].push(Entry(blockNumber, currency));
    }

    function count(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (uint256)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length;
    }

    function entriesByCurrency(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (Entry[] storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id];
    }

    function indexByBlockNumber(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length, "No entries found for currency [BlockNumbReferenceCurrenciesLib.sol:97]");
        for (uint256 i = self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length - 1; i >= 0; i--)
            if (blockNumber >= self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][i].blockNumber)
                return i;
        revert();
    }
}

library BlockNumbFiguresLib {
    
    
    
    struct Entry {
        uint256 blockNumber;
        MonetaryTypesLib.Figure value;
    }

    struct BlockNumbFigures {
        Entry[] entries;
    }

    
    
    
    function currentValue(BlockNumbFigures storage self)
    internal
    view
    returns (MonetaryTypesLib.Figure storage)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbFigures storage self)
    internal
    view
    returns (Entry storage)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbFigures storage self, uint256 _blockNumber)
    internal
    view
    returns (MonetaryTypesLib.Figure storage)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbFigures storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry storage)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbFigures storage self, uint256 blockNumber, MonetaryTypesLib.Figure memory value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbFiguresLib.sol:65]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbFigures storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbFigures storage self)
    internal
    view
    returns (Entry[] storage)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbFigures storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbFiguresLib.sol:95]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

contract Configuration is Modifiable, Ownable, Servable {
    using SafeMathIntLib for int256;
    using BlockNumbUintsLib for BlockNumbUintsLib.BlockNumbUints;
    using BlockNumbIntsLib for BlockNumbIntsLib.BlockNumbInts;
    using BlockNumbDisdIntsLib for BlockNumbDisdIntsLib.BlockNumbDisdInts;
    using BlockNumbReferenceCurrenciesLib for BlockNumbReferenceCurrenciesLib.BlockNumbReferenceCurrencies;
    using BlockNumbFiguresLib for BlockNumbFiguresLib.BlockNumbFigures;

    
    
    
    string constant public OPERATIONAL_MODE_ACTION = "operational_mode";

    
    
    
    enum OperationalMode {Normal, Exit}

    
    
    
    OperationalMode public operationalMode = OperationalMode.Normal;

    BlockNumbUintsLib.BlockNumbUints private updateDelayBlocksByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private confirmationBlocksByBlockNumber;

    BlockNumbDisdIntsLib.BlockNumbDisdInts private tradeMakerFeeByBlockNumber;
    BlockNumbDisdIntsLib.BlockNumbDisdInts private tradeTakerFeeByBlockNumber;
    BlockNumbDisdIntsLib.BlockNumbDisdInts private paymentFeeByBlockNumber;
    mapping(address => mapping(uint256 => BlockNumbDisdIntsLib.BlockNumbDisdInts)) private currencyPaymentFeeByBlockNumber;

    BlockNumbIntsLib.BlockNumbInts private tradeMakerMinimumFeeByBlockNumber;
    BlockNumbIntsLib.BlockNumbInts private tradeTakerMinimumFeeByBlockNumber;
    BlockNumbIntsLib.BlockNumbInts private paymentMinimumFeeByBlockNumber;
    mapping(address => mapping(uint256 => BlockNumbIntsLib.BlockNumbInts)) private currencyPaymentMinimumFeeByBlockNumber;

    BlockNumbReferenceCurrenciesLib.BlockNumbReferenceCurrencies private feeCurrencyByCurrencyBlockNumber;

    BlockNumbUintsLib.BlockNumbUints private walletLockTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private cancelOrderChallengeTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private settlementChallengeTimeoutByBlockNumber;

    BlockNumbUintsLib.BlockNumbUints private fraudStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private walletSettlementStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private operatorSettlementStakeFractionByBlockNumber;

    BlockNumbFiguresLib.BlockNumbFigures private operatorSettlementStakeByBlockNumber;

    uint256 public earliestSettlementBlockNumber;
    bool public earliestSettlementBlockNumberUpdateDisabled;

    
    
    
    event SetOperationalModeExitEvent();
    event SetUpdateDelayBlocksEvent(uint256 fromBlockNumber, uint256 newBlocks);
    event SetConfirmationBlocksEvent(uint256 fromBlockNumber, uint256 newBlocks);
    event SetTradeMakerFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetTradeTakerFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetPaymentFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetCurrencyPaymentFeeEvent(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal,
        int256[] discountTiers, int256[] discountValues);
    event SetTradeMakerMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetTradeTakerMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetPaymentMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetCurrencyPaymentMinimumFeeEvent(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal);
    event SetFeeCurrencyEvent(uint256 fromBlockNumber, address referenceCurrencyCt, uint256 referenceCurrencyId,
        address feeCurrencyCt, uint256 feeCurrencyId);
    event SetWalletLockTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetCancelOrderChallengeTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetSettlementChallengeTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetWalletSettlementStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetOperatorSettlementStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetOperatorSettlementStakeEvent(uint256 fromBlockNumber, int256 stakeAmount, address stakeCurrencyCt,
        uint256 stakeCurrencyId);
    event SetFraudStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetEarliestSettlementBlockNumberEvent(uint256 earliestSettlementBlockNumber);
    event DisableEarliestSettlementBlockNumberUpdateEvent();

    
    
    
    constructor(address deployer) Ownable(deployer) public {
        updateDelayBlocksByBlockNumber.addEntry(block.number, 0);
    }

    
    
    
    
    
    function setOperationalModeExit()
    public
    onlyEnabledServiceAction(OPERATIONAL_MODE_ACTION)
    {
        operationalMode = OperationalMode.Exit;
        emit SetOperationalModeExitEvent();
    }

    
    function isOperationalModeNormal()
    public
    view
    returns (bool)
    {
        return OperationalMode.Normal == operationalMode;
    }

    
    function isOperationalModeExit()
    public
    view
    returns (bool)
    {
        return OperationalMode.Exit == operationalMode;
    }

    
    
    function updateDelayBlocks()
    public
    view
    returns (uint256)
    {
        return updateDelayBlocksByBlockNumber.currentValue();
    }

    
    
    function updateDelayBlocksCount()
    public
    view
    returns (uint256)
    {
        return updateDelayBlocksByBlockNumber.count();
    }

    
    
    
    function setUpdateDelayBlocks(uint256 fromBlockNumber, uint256 newUpdateDelayBlocks)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        updateDelayBlocksByBlockNumber.addEntry(fromBlockNumber, newUpdateDelayBlocks);
        emit SetUpdateDelayBlocksEvent(fromBlockNumber, newUpdateDelayBlocks);
    }

    
    
    function confirmationBlocks()
    public
    view
    returns (uint256)
    {
        return confirmationBlocksByBlockNumber.currentValue();
    }

    
    
    function confirmationBlocksCount()
    public
    view
    returns (uint256)
    {
        return confirmationBlocksByBlockNumber.count();
    }

    
    
    
    function setConfirmationBlocks(uint256 fromBlockNumber, uint256 newConfirmationBlocks)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        confirmationBlocksByBlockNumber.addEntry(fromBlockNumber, newConfirmationBlocks);
        emit SetConfirmationBlocksEvent(fromBlockNumber, newConfirmationBlocks);
    }

    
    function tradeMakerFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeMakerFeeByBlockNumber.count();
    }

    
    
    
    function tradeMakerFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return tradeMakerFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    
    
    
    
    
    function setTradeMakerFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeMakerFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetTradeMakerFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    
    function tradeTakerFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeTakerFeeByBlockNumber.count();
    }

    
    
    
    function tradeTakerFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return tradeTakerFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    
    
    
    
    
    function setTradeTakerFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeTakerFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetTradeTakerFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    
    function paymentFeesCount()
    public
    view
    returns (uint256)
    {
        return paymentFeeByBlockNumber.count();
    }

    
    
    
    function paymentFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return paymentFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    
    
    
    
    
    function setPaymentFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        paymentFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetPaymentFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    
    
    
    function currencyPaymentFeesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return currencyPaymentFeeByBlockNumber[currencyCt][currencyId].count();
    }

    
    
    
    
    
    
    function currencyPaymentFee(uint256 blockNumber, address currencyCt, uint256 currencyId, int256 discountTier)
    public
    view
    returns (int256)
    {
        if (0 < currencyPaymentFeeByBlockNumber[currencyCt][currencyId].count())
            return currencyPaymentFeeByBlockNumber[currencyCt][currencyId].discountedValueAt(
                blockNumber, discountTier
            );
        else
            return paymentFee(blockNumber, discountTier);
    }

    
    
    
    
    
    
    
    
    function setCurrencyPaymentFee(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal,
        int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        currencyPaymentFeeByBlockNumber[currencyCt][currencyId].addDiscountedEntry(
            fromBlockNumber, nominal, discountTiers, discountValues
        );
        emit SetCurrencyPaymentFeeEvent(
            fromBlockNumber, currencyCt, currencyId, nominal, discountTiers, discountValues
        );
    }

    
    function tradeMakerMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeMakerMinimumFeeByBlockNumber.count();
    }

    
    
    function tradeMakerMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return tradeMakerMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    
    
    
    function setTradeMakerMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeMakerMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetTradeMakerMinimumFeeEvent(fromBlockNumber, nominal);
    }

    
    function tradeTakerMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeTakerMinimumFeeByBlockNumber.count();
    }

    
    
    function tradeTakerMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return tradeTakerMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    
    
    
    function setTradeTakerMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeTakerMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetTradeTakerMinimumFeeEvent(fromBlockNumber, nominal);
    }

    
    function paymentMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return paymentMinimumFeeByBlockNumber.count();
    }

    
    
    function paymentMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return paymentMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    
    
    
    function setPaymentMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        paymentMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetPaymentMinimumFeeEvent(fromBlockNumber, nominal);
    }

    
    
    
    function currencyPaymentMinimumFeesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].count();
    }

    
    
    
    
    function currencyPaymentMinimumFee(uint256 blockNumber, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        if (0 < currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].count())
            return currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].valueAt(blockNumber);
        else
            return paymentMinimumFee(blockNumber);
    }

    
    
    
    
    
    function setCurrencyPaymentMinimumFee(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].addEntry(fromBlockNumber, nominal);
        emit SetCurrencyPaymentMinimumFeeEvent(fromBlockNumber, currencyCt, currencyId, nominal);
    }

    
    
    
    function feeCurrenciesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return feeCurrencyByCurrencyBlockNumber.count(MonetaryTypesLib.Currency(currencyCt, currencyId));
    }

    
    
    
    
    function feeCurrency(uint256 blockNumber, address currencyCt, uint256 currencyId)
    public
    view
    returns (address ct, uint256 id)
    {
        MonetaryTypesLib.Currency storage _feeCurrency = feeCurrencyByCurrencyBlockNumber.currencyAt(
            MonetaryTypesLib.Currency(currencyCt, currencyId), blockNumber
        );
        ct = _feeCurrency.ct;
        id = _feeCurrency.id;
    }

    
    
    
    
    
    
    function setFeeCurrency(uint256 fromBlockNumber, address referenceCurrencyCt, uint256 referenceCurrencyId,
        address feeCurrencyCt, uint256 feeCurrencyId)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        feeCurrencyByCurrencyBlockNumber.addEntry(
            fromBlockNumber,
            MonetaryTypesLib.Currency(referenceCurrencyCt, referenceCurrencyId),
            MonetaryTypesLib.Currency(feeCurrencyCt, feeCurrencyId)
        );
        emit SetFeeCurrencyEvent(fromBlockNumber, referenceCurrencyCt, referenceCurrencyId,
            feeCurrencyCt, feeCurrencyId);
    }

    
    
    function walletLockTimeout()
    public
    view
    returns (uint256)
    {
        return walletLockTimeoutByBlockNumber.currentValue();
    }

    
    
    
    function setWalletLockTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        walletLockTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetWalletLockTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    
    
    function cancelOrderChallengeTimeout()
    public
    view
    returns (uint256)
    {
        return cancelOrderChallengeTimeoutByBlockNumber.currentValue();
    }

    
    
    
    function setCancelOrderChallengeTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        cancelOrderChallengeTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetCancelOrderChallengeTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    
    
    function settlementChallengeTimeout()
    public
    view
    returns (uint256)
    {
        return settlementChallengeTimeoutByBlockNumber.currentValue();
    }

    
    
    
    function setSettlementChallengeTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        settlementChallengeTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetSettlementChallengeTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    
    
    function fraudStakeFraction()
    public
    view
    returns (uint256)
    {
        return fraudStakeFractionByBlockNumber.currentValue();
    }

    
    
    
    
    function setFraudStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        fraudStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetFraudStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    
    
    function walletSettlementStakeFraction()
    public
    view
    returns (uint256)
    {
        return walletSettlementStakeFractionByBlockNumber.currentValue();
    }

    
    
    
    
    function setWalletSettlementStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        walletSettlementStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetWalletSettlementStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    
    
    function operatorSettlementStakeFraction()
    public
    view
    returns (uint256)
    {
        return operatorSettlementStakeFractionByBlockNumber.currentValue();
    }

    
    
    
    
    function setOperatorSettlementStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        operatorSettlementStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetOperatorSettlementStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    
    
    function operatorSettlementStake()
    public
    view
    returns (int256 amount, address currencyCt, uint256 currencyId)
    {
        MonetaryTypesLib.Figure storage stake = operatorSettlementStakeByBlockNumber.currentValue();
        amount = stake.amount;
        currencyCt = stake.currency.ct;
        currencyId = stake.currency.id;
    }

    
    
    
    
    
    
    function setOperatorSettlementStake(uint256 fromBlockNumber, int256 stakeAmount,
        address stakeCurrencyCt, uint256 stakeCurrencyId)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        MonetaryTypesLib.Figure memory stake = MonetaryTypesLib.Figure(stakeAmount, MonetaryTypesLib.Currency(stakeCurrencyCt, stakeCurrencyId));
        operatorSettlementStakeByBlockNumber.addEntry(fromBlockNumber, stake);
        emit SetOperatorSettlementStakeEvent(fromBlockNumber, stakeAmount, stakeCurrencyCt, stakeCurrencyId);
    }

    
    
    function setEarliestSettlementBlockNumber(uint256 _earliestSettlementBlockNumber)
    public
    onlyOperator
    {
        require(!earliestSettlementBlockNumberUpdateDisabled, "Earliest settlement block number update disabled [Configuration.sol:715]");

        earliestSettlementBlockNumber = _earliestSettlementBlockNumber;
        emit SetEarliestSettlementBlockNumberEvent(earliestSettlementBlockNumber);
    }

    
    
    function disableEarliestSettlementBlockNumberUpdate()
    public
    onlyOperator
    {
        earliestSettlementBlockNumberUpdateDisabled = true;
        emit DisableEarliestSettlementBlockNumberUpdateEvent();
    }

    
    
    
    modifier onlyDelayedBlockNumber(uint256 blockNumber) {
        require(
            0 == updateDelayBlocksByBlockNumber.count() ||
        blockNumber >= block.number + updateDelayBlocksByBlockNumber.currentValue(),
            "Block number not sufficiently delayed [Configuration.sol:735]"
        );
        _;
    }
}

contract Configurable is Ownable {
    
    
    
    Configuration public configuration;

    
    
    
    event SetConfigurationEvent(Configuration oldConfiguration, Configuration newConfiguration);

    
    
    
    
    
    function setConfiguration(Configuration newConfiguration)
    public
    onlyDeployer
    notNullAddress(address(newConfiguration))
    notSameAddresses(address(newConfiguration), address(configuration))
    {
        
        Configuration oldConfiguration = configuration;
        configuration = newConfiguration;

        
        emit SetConfigurationEvent(oldConfiguration, newConfiguration);
    }

    
    
    
    modifier configurationInitialized() {
        require(address(configuration) != address(0), "Configuration not initialized [Configurable.sol:52]");
        _;
    }
}

contract Beneficiary {
    
    
    
    function receiveEthersTo(address wallet, string memory balanceType)
    public
    payable;

    
    
    
    
    
    
    
    
    function receiveTokensTo(address wallet, string memory balanceType, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public;
}

contract AccrualBeneficiary is Beneficiary {
    
    
    
    event CloseAccrualPeriodEvent();

    
    
    
    function closeAccrualPeriod(MonetaryTypesLib.Currency[] memory)
    public
    {
        emit CloseAccrualPeriodEvent();
    }
}

contract TransferController {
    
    
    
    event CurrencyTransferred(address from, address to, uint256 value,
        address currencyCt, uint256 currencyId);

    
    
    
    function isFungible()
    public
    view
    returns (bool);

    function standard()
    public
    view
    returns (string memory);

    
    function receive(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function approve(address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function dispatch(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    

    function getReceiveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("receive(address,address,uint256,address,uint256)"));
    }

    function getApproveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("approve(address,uint256,address,uint256)"));
    }

    function getDispatchSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("dispatch(address,address,uint256,address,uint256)"));
    }
}

contract TransferControllerManager is Ownable {
    
    
    
    struct CurrencyInfo {
        bytes32 standard;
        bool blacklisted;
    }

    
    
    
    mapping(bytes32 => address) public registeredTransferControllers;
    mapping(address => CurrencyInfo) public registeredCurrencies;

    
    
    
    event RegisterTransferControllerEvent(string standard, address controller);
    event ReassociateTransferControllerEvent(string oldStandard, string newStandard, address controller);

    event RegisterCurrencyEvent(address currencyCt, string standard);
    event DeregisterCurrencyEvent(address currencyCt);
    event BlacklistCurrencyEvent(address currencyCt);
    event WhitelistCurrencyEvent(address currencyCt);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    function registerTransferController(string calldata standard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(standard).length > 0, "Empty standard not supported [TransferControllerManager.sol:58]");
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        registeredTransferControllers[standardHash] = controller;

        
        emit RegisterTransferControllerEvent(standard, controller);
    }

    function reassociateTransferController(string calldata oldStandard, string calldata newStandard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(newStandard).length > 0, "Empty new standard not supported [TransferControllerManager.sol:72]");
        bytes32 oldStandardHash = keccak256(abi.encodePacked(oldStandard));
        bytes32 newStandardHash = keccak256(abi.encodePacked(newStandard));

        require(registeredTransferControllers[oldStandardHash] != address(0), "Old standard not registered [TransferControllerManager.sol:76]");
        require(registeredTransferControllers[newStandardHash] == address(0), "New standard previously registered [TransferControllerManager.sol:77]");

        registeredTransferControllers[newStandardHash] = registeredTransferControllers[oldStandardHash];
        registeredTransferControllers[oldStandardHash] = address(0);

        
        emit ReassociateTransferControllerEvent(oldStandard, newStandard, controller);
    }

    function registerCurrency(address currencyCt, string calldata standard)
    external
    onlyOperator
    notNullAddress(currencyCt)
    {
        require(bytes(standard).length > 0, "Empty standard not supported [TransferControllerManager.sol:91]");
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        require(registeredCurrencies[currencyCt].standard == bytes32(0), "Currency previously registered [TransferControllerManager.sol:94]");

        registeredCurrencies[currencyCt].standard = standardHash;

        
        emit RegisterCurrencyEvent(currencyCt, standard);
    }

    function deregisterCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != 0, "Currency not registered [TransferControllerManager.sol:106]");

        registeredCurrencies[currencyCt].standard = bytes32(0);
        registeredCurrencies[currencyCt].blacklisted = false;

        
        emit DeregisterCurrencyEvent(currencyCt);
    }

    function blacklistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:119]");

        registeredCurrencies[currencyCt].blacklisted = true;

        
        emit BlacklistCurrencyEvent(currencyCt);
    }

    function whitelistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:131]");

        registeredCurrencies[currencyCt].blacklisted = false;

        
        emit WhitelistCurrencyEvent(currencyCt);
    }

    
    function transferController(address currencyCt, string memory standard)
    public
    view
    returns (TransferController)
    {
        if (bytes(standard).length > 0) {
            bytes32 standardHash = keccak256(abi.encodePacked(standard));

            require(registeredTransferControllers[standardHash] != address(0), "Standard not registered [TransferControllerManager.sol:150]");
            return TransferController(registeredTransferControllers[standardHash]);
        }

        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:154]");
        require(!registeredCurrencies[currencyCt].blacklisted, "Currency blacklisted [TransferControllerManager.sol:155]");

        address controllerAddress = registeredTransferControllers[registeredCurrencies[currencyCt].standard];
        require(controllerAddress != address(0), "No matching transfer controller [TransferControllerManager.sol:158]");

        return TransferController(controllerAddress);
    }
}

contract TransferControllerManageable is Ownable {
    
    
    
    TransferControllerManager public transferControllerManager;

    
    
    
    event SetTransferControllerManagerEvent(TransferControllerManager oldTransferControllerManager,
        TransferControllerManager newTransferControllerManager);

    
    
    
    
    
    function setTransferControllerManager(TransferControllerManager newTransferControllerManager)
    public
    onlyDeployer
    notNullAddress(address(newTransferControllerManager))
    notSameAddresses(address(newTransferControllerManager), address(transferControllerManager))
    {
        
        TransferControllerManager oldTransferControllerManager = transferControllerManager;
        transferControllerManager = newTransferControllerManager;

        
        emit SetTransferControllerManagerEvent(oldTransferControllerManager, newTransferControllerManager);
    }

    
    function transferController(address currencyCt, string memory standard)
    internal
    view
    returns (TransferController)
    {
        return transferControllerManager.transferController(currencyCt, standard);
    }

    
    
    
    modifier transferControllerManagerInitialized() {
        require(address(transferControllerManager) != address(0), "Transfer controller manager not initialized [TransferControllerManageable.sol:63]");
        _;
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

library TxHistoryLib {
    
    
    
    struct AssetEntry {
        int256 amount;
        uint256 blockNumber;
        address currencyCt;      
        uint256 currencyId;
    }

    struct TxHistory {
        AssetEntry[] deposits;
        mapping(address => mapping(uint256 => AssetEntry[])) currencyDeposits;

        AssetEntry[] withdrawals;
        mapping(address => mapping(uint256 => AssetEntry[])) currencyWithdrawals;
    }

    
    
    
    function addDeposit(TxHistory storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        AssetEntry memory deposit = AssetEntry(amount, block.number, currencyCt, currencyId);
        self.deposits.push(deposit);
        self.currencyDeposits[currencyCt][currencyId].push(deposit);
    }

    function addWithdrawal(TxHistory storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        AssetEntry memory withdrawal = AssetEntry(amount, block.number, currencyCt, currencyId);
        self.withdrawals.push(withdrawal);
        self.currencyWithdrawals[currencyCt][currencyId].push(withdrawal);
    }

    

    function deposit(TxHistory storage self, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(index < self.deposits.length, "Index ouf of bounds [TxHistoryLib.sol:56]");

        amount = self.deposits[index].amount;
        blockNumber = self.deposits[index].blockNumber;
        currencyCt = self.deposits[index].currencyCt;
        currencyId = self.deposits[index].currencyId;
    }

    function depositsCount(TxHistory storage self)
    internal
    view
    returns (uint256)
    {
        return self.deposits.length;
    }

    function currencyDeposit(TxHistory storage self, address currencyCt, uint256 currencyId, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber)
    {
        require(index < self.currencyDeposits[currencyCt][currencyId].length, "Index out of bounds [TxHistoryLib.sol:77]");

        amount = self.currencyDeposits[currencyCt][currencyId][index].amount;
        blockNumber = self.currencyDeposits[currencyCt][currencyId][index].blockNumber;
    }

    function currencyDepositsCount(TxHistory storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.currencyDeposits[currencyCt][currencyId].length;
    }

    

    function withdrawal(TxHistory storage self, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(index < self.withdrawals.length, "Index out of bounds [TxHistoryLib.sol:98]");

        amount = self.withdrawals[index].amount;
        blockNumber = self.withdrawals[index].blockNumber;
        currencyCt = self.withdrawals[index].currencyCt;
        currencyId = self.withdrawals[index].currencyId;
    }

    function withdrawalsCount(TxHistory storage self)
    internal
    view
    returns (uint256)
    {
        return self.withdrawals.length;
    }

    function currencyWithdrawal(TxHistory storage self, address currencyCt, uint256 currencyId, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber)
    {
        require(index < self.currencyWithdrawals[currencyCt][currencyId].length, "Index out of bounds [TxHistoryLib.sol:119]");

        amount = self.currencyWithdrawals[currencyCt][currencyId][index].amount;
        blockNumber = self.currencyWithdrawals[currencyCt][currencyId][index].blockNumber;
    }

    function currencyWithdrawalsCount(TxHistory storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.currencyWithdrawals[currencyCt][currencyId].length;
    }
}

contract SecurityBond is Ownable, Configurable, AccrualBeneficiary, Servable, TransferControllerManageable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using TxHistoryLib for TxHistoryLib.TxHistory;
    using CurrenciesLib for CurrenciesLib.Currencies;

    
    
    
    string constant public REWARD_ACTION = "reward";
    string constant public DEPRIVE_ACTION = "deprive";

    
    
    
    struct FractionalReward {
        uint256 fraction;
        uint256 nonce;
        uint256 unlockTime;
    }

    struct AbsoluteReward {
        int256 amount;
        uint256 nonce;
        uint256 unlockTime;
    }

    
    
    
    FungibleBalanceLib.Balance private deposited;
    TxHistoryLib.TxHistory private txHistory;
    CurrenciesLib.Currencies private inUseCurrencies;

    mapping(address => FractionalReward) public fractionalRewardByWallet;

    mapping(address => mapping(address => mapping(uint256 => AbsoluteReward))) public absoluteRewardByWallet;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public claimNonceByWalletCurrency;

    mapping(address => FungibleBalanceLib.Balance) private stagedByWallet;

    mapping(address => uint256) public nonceByWallet;

    
    
    
    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event RewardFractionalEvent(address wallet, uint256 fraction, uint256 unlockTimeoutInSeconds);
    event RewardAbsoluteEvent(address wallet, int256 amount, address currencyCt, uint256 currencyId,
        uint256 unlockTimeoutInSeconds);
    event DepriveFractionalEvent(address wallet);
    event DepriveAbsoluteEvent(address wallet, address currencyCt, uint256 currencyId);
    event ClaimAndTransferToBeneficiaryEvent(address from, Beneficiary beneficiary, string balanceType, int256 amount,
        address currencyCt, uint256 currencyId, string standard);
    event ClaimAndStageEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event WithdrawEvent(address from, int256 amount, address currencyCt, uint256 currencyId, string standard);

    
    
    
    constructor(address deployer) Ownable(deployer) Servable() public {
    }

    
    
    
    
    function() external payable {
        receiveEthersTo(msg.sender, "");
    }

    
    
    function receiveEthersTo(address wallet, string memory)
    public
    payable
    {
        int256 amount = SafeMathIntLib.toNonZeroInt256(msg.value);

        
        deposited.add(amount, address(0), 0);
        txHistory.addDeposit(amount, address(0), 0);

        
        inUseCurrencies.add(address(0), 0);

        
        emit ReceiveEvent(wallet, amount, address(0), 0);
    }

    
    
    
    
    
    function receiveTokens(string memory, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        receiveTokensTo(msg.sender, "", amount, currencyCt, currencyId, standard);
    }

    
    
    
    
    
    
    function receiveTokensTo(address wallet, string memory, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        require(amount.isNonZeroPositiveInt256(), "Amount not strictly positive [SecurityBond.sol:145]");

        
        TransferController controller = transferController(currencyCt, standard);
        (bool success,) = address(controller).delegatecall(
            abi.encodeWithSelector(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );
        require(success, "Reception by controller failed [SecurityBond.sol:154]");

        
        deposited.add(amount, currencyCt, currencyId);
        txHistory.addDeposit(amount, currencyCt, currencyId);

        
        inUseCurrencies.add(currencyCt, currencyId);

        
        emit ReceiveEvent(wallet, amount, currencyCt, currencyId);
    }

    
    
    function depositsCount()
    public
    view
    returns (uint256)
    {
        return txHistory.depositsCount();
    }

    
    
    function deposit(uint index)
    public
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        return txHistory.deposit(index);
    }

    
    
    
    
    function depositedBalance(address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return deposited.get(currencyCt, currencyId);
    }

    
    
    
    
    
    function depositedFractionalBalance(address currencyCt, uint256 currencyId, uint256 fraction)
    public
    view
    returns (int256)
    {
        return deposited.get(currencyCt, currencyId)
        .mul(SafeMathIntLib.toInt256(fraction))
        .div(ConstantsLib.PARTS_PER());
    }

    
    
    
    
    function stagedBalance(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return stagedByWallet[wallet].get(currencyCt, currencyId);
    }

    
    
    function inUseCurrenciesCount()
    public
    view
    returns (uint256)
    {
        return inUseCurrencies.count();
    }

    
    
    
    
    function inUseCurrenciesByIndices(uint256 low, uint256 up)
    public
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        return inUseCurrencies.getByIndices(low, up);
    }

    
    
    
    
    
    
    function rewardFractional(address wallet, uint256 fraction, uint256 unlockTimeoutInSeconds)
    public
    notNullAddress(wallet)
    onlyEnabledServiceAction(REWARD_ACTION)
    {
        
        fractionalRewardByWallet[wallet].fraction = fraction.clampMax(uint256(ConstantsLib.PARTS_PER()));
        fractionalRewardByWallet[wallet].nonce = ++nonceByWallet[wallet];
        fractionalRewardByWallet[wallet].unlockTime = block.timestamp.add(unlockTimeoutInSeconds);

        
        emit RewardFractionalEvent(wallet, fraction, unlockTimeoutInSeconds);
    }

    
    
    
    
    
    
    
    
    function rewardAbsolute(address wallet, int256 amount, address currencyCt, uint256 currencyId,
        uint256 unlockTimeoutInSeconds)
    public
    notNullAddress(wallet)
    onlyEnabledServiceAction(REWARD_ACTION)
    {
        
        absoluteRewardByWallet[wallet][currencyCt][currencyId].amount = amount;
        absoluteRewardByWallet[wallet][currencyCt][currencyId].nonce = ++nonceByWallet[wallet];
        absoluteRewardByWallet[wallet][currencyCt][currencyId].unlockTime = block.timestamp.add(unlockTimeoutInSeconds);

        
        emit RewardAbsoluteEvent(wallet, amount, currencyCt, currencyId, unlockTimeoutInSeconds);
    }

    
    
    function depriveFractional(address wallet)
    public
    onlyEnabledServiceAction(DEPRIVE_ACTION)
    {
        
        fractionalRewardByWallet[wallet].fraction = 0;
        fractionalRewardByWallet[wallet].nonce = ++nonceByWallet[wallet];
        fractionalRewardByWallet[wallet].unlockTime = 0;

        
        emit DepriveFractionalEvent(wallet);
    }

    
    
    
    
    function depriveAbsolute(address wallet, address currencyCt, uint256 currencyId)
    public
    onlyEnabledServiceAction(DEPRIVE_ACTION)
    {
        
        absoluteRewardByWallet[wallet][currencyCt][currencyId].amount = 0;
        absoluteRewardByWallet[wallet][currencyCt][currencyId].nonce = ++nonceByWallet[wallet];
        absoluteRewardByWallet[wallet][currencyCt][currencyId].unlockTime = 0;

        
        emit DepriveAbsoluteEvent(wallet, currencyCt, currencyId);
    }

    
    
    
    
    
    
    function claimAndTransferToBeneficiary(Beneficiary beneficiary, string memory balanceType, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        
        int256 claimedAmount = _claim(msg.sender, currencyCt, currencyId);

        
        deposited.sub(claimedAmount, currencyCt, currencyId);

        
        if (address(0) == currencyCt && 0 == currencyId)
            beneficiary.receiveEthersTo.value(uint256(claimedAmount))(msg.sender, balanceType);

        else {
            TransferController controller = transferController(currencyCt, standard);
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getApproveSignature(), address(beneficiary), uint256(claimedAmount), currencyCt, currencyId
                )
            );
            require(success, "Approval by controller failed [SecurityBond.sol:350]");
            beneficiary.receiveTokensTo(msg.sender, balanceType, claimedAmount, currencyCt, currencyId, standard);
        }

        
        emit ClaimAndTransferToBeneficiaryEvent(msg.sender, beneficiary, balanceType, claimedAmount, currencyCt, currencyId, standard);
    }

    
    
    
    function claimAndStage(address currencyCt, uint256 currencyId)
    public
    {
        
        int256 claimedAmount = _claim(msg.sender, currencyCt, currencyId);

        
        deposited.sub(claimedAmount, currencyCt, currencyId);

        
        stagedByWallet[msg.sender].add(claimedAmount, currencyCt, currencyId);

        
        emit ClaimAndStageEvent(msg.sender, claimedAmount, currencyCt, currencyId);
    }

    
    
    
    
    
    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        
        require(amount.isNonZeroPositiveInt256(), "Amount not strictly positive [SecurityBond.sol:386]");

        
        amount = amount.clampMax(stagedByWallet[msg.sender].get(currencyCt, currencyId));

        
        stagedByWallet[msg.sender].sub(amount, currencyCt, currencyId);

        
        if (address(0) == currencyCt && 0 == currencyId)
            msg.sender.transfer(uint256(amount));

        else {
            TransferController controller = transferController(currencyCt, standard);
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getDispatchSignature(), address(this), msg.sender, uint256(amount), currencyCt, currencyId
                )
            );
            require(success, "Dispatch by controller failed [SecurityBond.sol:405]");
        }

        
        emit WithdrawEvent(msg.sender, amount, currencyCt, currencyId, standard);
    }

    
    
    
    function _claim(address wallet, address currencyCt, uint256 currencyId)
    private
    returns (int256)
    {
        
        uint256 claimNonce = fractionalRewardByWallet[wallet].nonce.clampMin(
            absoluteRewardByWallet[wallet][currencyCt][currencyId].nonce
        );

        
        require(
            claimNonce > claimNonceByWalletCurrency[wallet][currencyCt][currencyId],
            "Claim nonce not strictly greater than previously claimed nonce [SecurityBond.sol:425]"
        );

        
        int256 claimAmount = _fractionalRewardAmountByWalletCurrency(wallet, currencyCt, currencyId).add(
            _absoluteRewardAmountByWalletCurrency(wallet, currencyCt, currencyId)
        ).clampMax(
            deposited.get(currencyCt, currencyId)
        );

        
        require(claimAmount.isNonZeroPositiveInt256(), "Claim amount not strictly positive [SecurityBond.sol:438]");

        
        claimNonceByWalletCurrency[wallet][currencyCt][currencyId] = claimNonce;

        return claimAmount;
    }

    function _fractionalRewardAmountByWalletCurrency(address wallet, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        if (
            claimNonceByWalletCurrency[wallet][currencyCt][currencyId] < fractionalRewardByWallet[wallet].nonce &&
            block.timestamp >= fractionalRewardByWallet[wallet].unlockTime
        )
            return deposited.get(currencyCt, currencyId)
            .mul(SafeMathIntLib.toInt256(fractionalRewardByWallet[wallet].fraction))
            .div(ConstantsLib.PARTS_PER());

        else
            return 0;
    }

    function _absoluteRewardAmountByWalletCurrency(address wallet, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        if (
            claimNonceByWalletCurrency[wallet][currencyCt][currencyId] < absoluteRewardByWallet[wallet][currencyCt][currencyId].nonce &&
            block.timestamp >= absoluteRewardByWallet[wallet][currencyCt][currencyId].unlockTime
        )
            return absoluteRewardByWallet[wallet][currencyCt][currencyId].amount.clampMax(
                deposited.get(currencyCt, currencyId)
            );

        else
            return 0;
    }
}
