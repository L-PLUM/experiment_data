/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;
pragma experimental ABIEncoderV2;


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

contract ConfigurableOperational is Configurable {
    
    
    
    modifier onlyOperationalModeNormal() {
        require(configuration.isOperationalModeNormal(), "Operational mode is not normal [ConfigurableOperational.sol:22]");
        _;
    }
}

library NahmiiTypesLib {
    
    
    
    enum ChallengePhase {Dispute, Closed}

    
    
    
    struct OriginFigure {
        uint256 originId;
        MonetaryTypesLib.Figure figure;
    }

    struct IntendedConjugateCurrency {
        MonetaryTypesLib.Currency intended;
        MonetaryTypesLib.Currency conjugate;
    }

    struct SingleFigureTotalOriginFigures {
        MonetaryTypesLib.Figure single;
        OriginFigure[] total;
    }

    struct TotalOriginFigures {
        OriginFigure[] total;
    }

    struct CurrentPreviousInt256 {
        int256 current;
        int256 previous;
    }

    struct SingleTotalInt256 {
        int256 single;
        int256 total;
    }

    struct IntendedConjugateCurrentPreviousInt256 {
        CurrentPreviousInt256 intended;
        CurrentPreviousInt256 conjugate;
    }

    struct IntendedConjugateSingleTotalInt256 {
        SingleTotalInt256 intended;
        SingleTotalInt256 conjugate;
    }

    struct WalletOperatorHashes {
        bytes32 wallet;
        bytes32 operator;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct Seal {
        bytes32 hash;
        Signature signature;
    }

    struct WalletOperatorSeal {
        Seal wallet;
        Seal operator;
    }
}

library PaymentTypesLib {
    
    
    
    enum PaymentPartyRole {Sender, Recipient}

    
    
    
    struct PaymentSenderParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;

        string data;
    }

    struct PaymentRecipientParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.TotalOriginFigures fees;
    }

    struct Operator {
        uint256 id;
        string data;
    }

    struct Payment {
        int256 amount;
        MonetaryTypesLib.Currency currency;

        PaymentSenderParty sender;
        PaymentRecipientParty recipient;

        
        NahmiiTypesLib.SingleTotalInt256 transfers;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;

        Operator operator;
    }

    
    
    
    function PAYMENT_KIND()
    public
    pure
    returns (string memory)
    {
        return "payment";
    }
}

library TradeTypesLib {
    
    
    
    enum CurrencyRole {Intended, Conjugate}
    enum LiquidityRole {Maker, Taker}
    enum Intention {Buy, Sell}
    enum TradePartyRole {Buyer, Seller}

    
    
    
    struct OrderPlacement {
        Intention intention;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct Order {
        uint256 nonce;
        address wallet;

        OrderPlacement placement;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;
        uint256 operatorId;
    }

    struct TradeOrder {
        int256 amount;
        NahmiiTypesLib.WalletOperatorHashes hashes;
        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct TradeParty {
        uint256 nonce;
        address wallet;

        uint256 rollingVolume;

        LiquidityRole liquidityRole;

        TradeOrder order;

        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;
    }

    struct Trade {
        uint256 nonce;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        TradeParty buyer;
        TradeParty seller;

        
        
        NahmiiTypesLib.IntendedConjugateSingleTotalInt256 transfers;

        NahmiiTypesLib.Seal seal;
        uint256 blockNumber;
        uint256 operatorId;
    }

    
    
    
    function TRADE_KIND()
    public
    pure
    returns (string memory)
    {
        return "trade";
    }

    function ORDER_KIND()
    public
    pure
    returns (string memory)
    {
        return "order";
    }
}

contract PaymentHasher is Ownable {
    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    function hashPaymentAsWallet(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        bytes32 amountCurrencyHash = hashPaymentAmountCurrency(payment);
        bytes32 senderHash = hashPaymentSenderPartyAsWallet(payment.sender);
        bytes32 recipientHash = hashAddress(payment.recipient.wallet);

        return keccak256(abi.encodePacked(amountCurrencyHash, senderHash, recipientHash));
    }

    function hashPaymentAsOperator(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        bytes32 walletSignatureHash = hashSignature(payment.seals.wallet.signature);
        bytes32 senderHash = hashPaymentSenderPartyAsOperator(payment.sender);
        bytes32 recipientHash = hashPaymentRecipientPartyAsOperator(payment.recipient);
        bytes32 transfersHash = hashSingleTotalInt256(payment.transfers);
        bytes32 operatorHash = hashString(payment.operator.data);

        return keccak256(abi.encodePacked(
                walletSignatureHash, senderHash, recipientHash, transfersHash, operatorHash
            ));
    }

    function hashPaymentAmountCurrency(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                payment.amount,
                payment.currency.ct,
                payment.currency.id
            ));
    }

    function hashPaymentSenderPartyAsWallet(
        PaymentTypesLib.PaymentSenderParty memory paymentSenderParty)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                paymentSenderParty.wallet,
                paymentSenderParty.data
            ));
    }

    function hashPaymentSenderPartyAsOperator(
        PaymentTypesLib.PaymentSenderParty memory paymentSenderParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(paymentSenderParty.nonce);
        bytes32 balancesHash = hashCurrentPreviousInt256(paymentSenderParty.balances);
        bytes32 singleFeeHash = hashFigure(paymentSenderParty.fees.single);
        bytes32 totalFeesHash = hashOriginFigures(paymentSenderParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, balancesHash, singleFeeHash, totalFeesHash
            ));
    }

    function hashPaymentRecipientPartyAsOperator(
        PaymentTypesLib.PaymentRecipientParty memory paymentRecipientParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(paymentRecipientParty.nonce);
        bytes32 balancesHash = hashCurrentPreviousInt256(paymentRecipientParty.balances);
        bytes32 totalFeesHash = hashOriginFigures(paymentRecipientParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, balancesHash, totalFeesHash
            ));
    }

    function hashCurrentPreviousInt256(
        NahmiiTypesLib.CurrentPreviousInt256 memory currentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                currentPreviousInt256.current,
                currentPreviousInt256.previous
            ));
    }

    function hashSingleTotalInt256(
        NahmiiTypesLib.SingleTotalInt256 memory singleTotalInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                singleTotalInt256.single,
                singleTotalInt256.total
            ));
    }

    function hashFigure(MonetaryTypesLib.Figure memory figure)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                figure.amount,
                figure.currency.ct,
                figure.currency.id
            ));
    }

    function hashOriginFigures(NahmiiTypesLib.OriginFigure[] memory originFigures)
    public
    pure
    returns (bytes32)
    {
        bytes32 hash;
        for (uint256 i = 0; i < originFigures.length; i++) {
            hash = keccak256(abi.encodePacked(
                    hash,
                    originFigures[i].originId,
                    originFigures[i].figure.amount,
                    originFigures[i].figure.currency.ct,
                    originFigures[i].figure.currency.id
                )
            );
        }
        return hash;
    }

    function hashUint256(uint256 _uint256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_uint256));
    }

    function hashString(string memory _string)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_string));
    }

    function hashAddress(address _address)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_address));
    }

    function hashSignature(NahmiiTypesLib.Signature memory signature)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                signature.v,
                signature.r,
                signature.s
            ));
    }
}

contract PaymentHashable is Ownable {
    
    
    
    PaymentHasher public paymentHasher;

    
    
    
    event SetPaymentHasherEvent(PaymentHasher oldPaymentHasher, PaymentHasher newPaymentHasher);

    
    
    
    
    
    function setPaymentHasher(PaymentHasher newPaymentHasher)
    public
    onlyDeployer
    notNullAddress(address(newPaymentHasher))
    notSameAddresses(address(newPaymentHasher), address(paymentHasher))
    {
        
        PaymentHasher oldPaymentHasher = paymentHasher;
        paymentHasher = newPaymentHasher;

        
        emit SetPaymentHasherEvent(oldPaymentHasher, newPaymentHasher);
    }

    
    
    
    modifier paymentHasherInitialized() {
        require(address(paymentHasher) != address(0), "Payment hasher not initialized [PaymentHashable.sol:52]");
        _;
    }
}

contract TradeHasher is Ownable {
    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    function hashOrderAsWallet(TradeTypesLib.Order memory order)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashAddress(order.wallet);
        bytes32 placementHash = hashOrderPlacement(order.placement);

        return keccak256(abi.encodePacked(rootHash, placementHash));
    }

    function hashOrderAsOperator(TradeTypesLib.Order memory order)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(order.nonce);
        bytes32 walletSignatureHash = hashSignature(order.seals.wallet.signature);
        bytes32 placementResidualsHash = hashCurrentPreviousInt256(order.placement.residuals);

        return keccak256(abi.encodePacked(rootHash, walletSignatureHash, placementResidualsHash));
    }

    function hashTrade(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashTradeRoot(trade);
        bytes32 buyerHash = hashTradeParty(trade.buyer);
        bytes32 sellerHash = hashTradeParty(trade.seller);
        bytes32 transfersHash = hashIntendedConjugateSingleTotalInt256(trade.transfers);

        return keccak256(abi.encodePacked(rootHash, buyerHash, sellerHash, transfersHash));
    }

    function hashOrderPlacement(TradeTypesLib.OrderPlacement memory orderPlacement)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                orderPlacement.intention,
                orderPlacement.amount,
                orderPlacement.currencies.intended.ct,
                orderPlacement.currencies.intended.id,
                orderPlacement.currencies.conjugate.ct,
                orderPlacement.currencies.conjugate.id,
                orderPlacement.rate
            ));
    }

    function hashTradeRoot(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                trade.nonce,
                trade.amount,
                trade.currencies.intended.ct,
                trade.currencies.intended.id,
                trade.currencies.conjugate.ct,
                trade.currencies.conjugate.id,
                trade.rate
            ));
    }

    function hashTradeParty(TradeTypesLib.TradeParty memory tradeParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashTradePartyRoot(tradeParty);
        bytes32 orderHash = hashTradeOrder(tradeParty.order);
        bytes32 balancesHash = hashIntendedConjugateCurrentPreviousInt256(tradeParty.balances);
        bytes32 singleFeeHash = hashFigure(tradeParty.fees.single);
        bytes32 totalFeesHash = hashOriginFigures(tradeParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, orderHash, balancesHash, singleFeeHash, totalFeesHash
            ));
    }

    function hashTradePartyRoot(TradeTypesLib.TradeParty memory tradeParty)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                tradeParty.nonce,
                tradeParty.wallet,
                tradeParty.rollingVolume,
                tradeParty.liquidityRole
            ));
    }

    function hashTradeOrder(TradeTypesLib.TradeOrder memory tradeOrder)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                tradeOrder.hashes.wallet,
                tradeOrder.hashes.operator,
                tradeOrder.amount,
                tradeOrder.residuals.current,
                tradeOrder.residuals.previous
            ));
    }

    function hashIntendedConjugateSingleTotalInt256(
        NahmiiTypesLib.IntendedConjugateSingleTotalInt256 memory intededConjugateSingleTotalInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                intededConjugateSingleTotalInt256.intended.single,
                intededConjugateSingleTotalInt256.intended.total,
                intededConjugateSingleTotalInt256.conjugate.single,
                intededConjugateSingleTotalInt256.conjugate.total
            ));
    }

    function hashCurrentPreviousInt256(
        NahmiiTypesLib.CurrentPreviousInt256 memory currentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                currentPreviousInt256.current,
                currentPreviousInt256.previous
            ));
    }

    function hashIntendedConjugateCurrentPreviousInt256(
        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory intendedConjugateCurrentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                intendedConjugateCurrentPreviousInt256.intended.current,
                intendedConjugateCurrentPreviousInt256.intended.previous,
                intendedConjugateCurrentPreviousInt256.conjugate.current,
                intendedConjugateCurrentPreviousInt256.conjugate.previous
            ));
    }

    function hashFigure(MonetaryTypesLib.Figure memory figure)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                figure.amount,
                figure.currency.ct,
                figure.currency.id
            ));
    }

    function hashOriginFigures(NahmiiTypesLib.OriginFigure[] memory originFigures)
    public
    pure
    returns (bytes32)
    {
        bytes32 hash;
        for (uint256 i = 0; i < originFigures.length; i++) {
            hash = keccak256(abi.encodePacked(
                    hash,
                    originFigures[i].originId,
                    originFigures[i].figure.amount,
                    originFigures[i].figure.currency.ct,
                    originFigures[i].figure.currency.id
                )
            );
        }
        return hash;
    }

    function hashUint256(uint256 _uint256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_uint256));
    }

    function hashAddress(address _address)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_address));
    }

    function hashSignature(NahmiiTypesLib.Signature memory signature)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                signature.v,
                signature.r,
                signature.s
            ));
    }
}

contract TradeHashable is Ownable {
    
    
    
    TradeHasher public tradeHasher;

    
    
    
    event SetTradeHasherEvent(TradeHasher oldTradeHasher, TradeHasher newTradeHasher);

    
    
    
    
    
    function setTradeHasher(TradeHasher newTradeHasher)
    public
    onlyDeployer
    notNullAddress(address(newTradeHasher))
    notSameAddresses(address(newTradeHasher), address(tradeHasher))
    {
        
        TradeHasher oldTradeHasher = tradeHasher;
        tradeHasher = newTradeHasher;

        
        emit SetTradeHasherEvent(oldTradeHasher, newTradeHasher);
    }

    
    
    
    modifier tradeHasherInitialized() {
        require(address(tradeHasher) != address(0), "Trade hasher not initialized [TradeHashable.sol:52]");
        _;
    }
}

contract SignerManager is Ownable {
    using SafeMathUintLib for uint256;
    
    
    
    
    mapping(address => uint256) public signerIndicesMap; 
    address[] public signers;

    
    
    
    event RegisterSignerEvent(address signer);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
        registerSigner(deployer);
    }

    
    
    
    
    
    
    function isSigner(address _address)
    public
    view
    returns (bool)
    {
        return 0 < signerIndicesMap[_address];
    }

    
    
    function signersCount()
    public
    view
    returns (uint256)
    {
        return signers.length;
    }

    
    
    
    function signerIndex(address _address)
    public
    view
    returns (uint256)
    {
        require(isSigner(_address), "Address not signer [SignerManager.sol:71]");
        return signerIndicesMap[_address] - 1;
    }

    
    
    function registerSigner(address newSigner)
    public
    onlyOperator
    notNullOrThisAddress(newSigner)
    {
        if (0 == signerIndicesMap[newSigner]) {
            
            signers.push(newSigner);
            signerIndicesMap[newSigner] = signers.length;

            
            emit RegisterSignerEvent(newSigner);
        }
    }

    
    
    
    
    function signersByIndices(uint256 low, uint256 up)
    public
    view
    returns (address[] memory)
    {
        require(0 < signers.length, "No signers found [SignerManager.sol:101]");
        require(low <= up, "Bounds parameters mismatch [SignerManager.sol:102]");

        up = up.clampMax(signers.length - 1);
        address[] memory _signers = new address[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _signers[i - low] = signers[i];

        return _signers;
    }
}

contract SignerManageable is Ownable {
    
    
    
    SignerManager public signerManager;

    
    
    
    event SetSignerManagerEvent(address oldSignerManager, address newSignerManager);

    
    
    
    constructor(address manager) public notNullAddress(manager) {
        signerManager = SignerManager(manager);
    }

    
    
    
    
    
    function setSignerManager(address newSignerManager)
    public
    onlyDeployer
    notNullOrThisAddress(newSignerManager)
    {
        if (newSignerManager != address(signerManager)) {
            
            address oldSignerManager = address(signerManager);
            signerManager = SignerManager(newSignerManager);

            
            emit SetSignerManagerEvent(oldSignerManager, newSignerManager);
        }
    }

    
    
    
    
    
    
    function ethrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
    public
    pure
    returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s);
    }

    
    
    
    
    
    
    function isSignedByRegisteredSigner(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
    public
    view
    returns (bool)
    {
        return signerManager.isSigner(ethrecover(hash, v, r, s));
    }

    
    
    
    
    
    
    
    function isSignedBy(bytes32 hash, uint8 v, bytes32 r, bytes32 s, address signer)
    public
    pure
    returns (bool)
    {
        return signer == ethrecover(hash, v, r, s);
    }

    
    
    modifier signerManagerInitialized() {
        require(address(signerManager) != address(0), "Signer manager not initialized [SignerManageable.sol:105]");
        _;
    }
}

contract ValidatorV2 is Ownable, SignerManageable, Configurable, PaymentHashable, TradeHashable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    
    
    
    constructor(address deployer, address signerManager) Ownable(deployer) SignerManageable(signerManager) public {
    }

    
    
    
    
    function isGenuineTradeBuyerFeeOfFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        int256 feePartsPer = ConstantsLib.PARTS_PER();
        int256 discountTier = int256(trade.buyer.rollingVolume);

        int256 feeAmount;
        if (TradeTypesLib.LiquidityRole.Maker == trade.buyer.liquidityRole) {
            feeAmount = trade.amount
            .mul(configuration.tradeMakerFee(trade.blockNumber, discountTier))
            .div(feePartsPer);

            if (1 > feeAmount)
                feeAmount = 1;

            return (trade.buyer.fees.single.amount == feeAmount);

        } else {
            feeAmount = trade.amount
            .mul(configuration.tradeTakerFee(trade.blockNumber, discountTier))
            .div(feePartsPer);

            if (1 > feeAmount)
                feeAmount = 1;

            return (trade.buyer.fees.single.amount == feeAmount);
        }
    }

    
    function isGenuineTradeSellerFeeOfFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        int256 feePartsPer = ConstantsLib.PARTS_PER();
        int256 discountTier = int256(trade.seller.rollingVolume);

        int256 feeAmount;
        if (TradeTypesLib.LiquidityRole.Maker == trade.seller.liquidityRole) {
            feeAmount = trade.amount
            .mul(configuration.tradeMakerFee(trade.blockNumber, discountTier))
            .div(trade.rate.mul(feePartsPer));

            if (1 > feeAmount)
                feeAmount = 1;

            return (trade.seller.fees.single.amount == feeAmount);

        } else {
            feeAmount = trade.amount
            .mul(configuration.tradeTakerFee(trade.blockNumber, discountTier))
            .div(trade.rate.mul(feePartsPer));

            if (1 > feeAmount)
                feeAmount = 1;

            return (trade.seller.fees.single.amount == feeAmount);
        }
    }

    
    function isGenuineTradeBuyerFeeOfNonFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        (address feeCurrencyCt, uint256 feeCurrencyId) = configuration.feeCurrency(
            trade.blockNumber, trade.currencies.intended.ct, trade.currencies.intended.id
        );

        return feeCurrencyCt == trade.buyer.fees.single.currency.ct
        && feeCurrencyId == trade.buyer.fees.single.currency.id;
    }

    
    function isGenuineTradeSellerFeeOfNonFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        (address feeCurrencyCt, uint256 feeCurrencyId) = configuration.feeCurrency(
            trade.blockNumber, trade.currencies.conjugate.ct, trade.currencies.conjugate.id
        );

        return feeCurrencyCt == trade.seller.fees.single.currency.ct
        && feeCurrencyId == trade.seller.fees.single.currency.id;
    }

    
    function isGenuineTradeBuyerOfFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return (trade.buyer.wallet != trade.seller.wallet)
        && (!signerManager.isSigner(trade.buyer.wallet))
        && (trade.buyer.balances.intended.current == trade.buyer.balances.intended.previous.add(trade.transfers.intended.single).sub(trade.buyer.fees.single.amount))
        && (trade.buyer.balances.conjugate.current == trade.buyer.balances.conjugate.previous.sub(trade.transfers.conjugate.single))
        && (trade.buyer.order.amount >= trade.buyer.order.residuals.current)
        && (trade.buyer.order.amount >= trade.buyer.order.residuals.previous)
        && (trade.buyer.order.residuals.previous >= trade.buyer.order.residuals.current);
    }

    
    function isGenuineTradeSellerOfFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return (trade.buyer.wallet != trade.seller.wallet)
        && (!signerManager.isSigner(trade.seller.wallet))
        && (trade.seller.balances.intended.current == trade.seller.balances.intended.previous.sub(trade.transfers.intended.single))
        && (trade.seller.balances.conjugate.current == trade.seller.balances.conjugate.previous.add(trade.transfers.conjugate.single).sub(trade.seller.fees.single.amount))
        && (trade.seller.order.amount >= trade.seller.order.residuals.current)
        && (trade.seller.order.amount >= trade.seller.order.residuals.previous)
        && (trade.seller.order.residuals.previous >= trade.seller.order.residuals.current);
    }

    
    function isGenuineTradeBuyerOfNonFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return (trade.buyer.wallet != trade.seller.wallet)
        && (!signerManager.isSigner(trade.buyer.wallet));
    }

    
    function isGenuineTradeSellerOfNonFungible(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return (trade.buyer.wallet != trade.seller.wallet)
        && (!signerManager.isSigner(trade.seller.wallet));
    }

    function isGenuineOrderWalletHash(TradeTypesLib.Order memory order)
    public
    view
    returns (bool)
    {
        return tradeHasher.hashOrderAsWallet(order) == order.seals.wallet.hash;
    }

    function isGenuineOrderOperatorHash(TradeTypesLib.Order memory order)
    public
    view
    returns (bool)
    {
        return tradeHasher.hashOrderAsOperator(order) == order.seals.operator.hash;
    }

    function isGenuineOperatorSignature(bytes32 hash, NahmiiTypesLib.Signature memory signature)
    public
    view
    returns (bool)
    {
        return isSignedByRegisteredSigner(hash, signature.v, signature.r, signature.s);
    }

    function isGenuineWalletSignature(bytes32 hash, NahmiiTypesLib.Signature memory signature, address wallet)
    public
    pure
    returns (bool)
    {
        return isSignedBy(hash, signature.v, signature.r, signature.s, wallet);
    }

    function isGenuineOrderWalletSeal(TradeTypesLib.Order memory order)
    public
    view
    returns (bool)
    {
        return isGenuineOrderWalletHash(order)
        && isGenuineWalletSignature(order.seals.wallet.hash, order.seals.wallet.signature, order.wallet);
    }

    function isGenuineOrderOperatorSeal(TradeTypesLib.Order memory order)
    public
    view
    returns (bool)
    {
        return isGenuineOrderOperatorHash(order)
        && isGenuineOperatorSignature(order.seals.operator.hash, order.seals.operator.signature);
    }

    function isGenuineOrderSeals(TradeTypesLib.Order memory order)
    public
    view
    returns (bool)
    {
        return isGenuineOrderWalletSeal(order) && isGenuineOrderOperatorSeal(order);
    }

    function isGenuineTradeHash(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return tradeHasher.hashTrade(trade) == trade.seal.hash;
    }

    function isGenuineTradeSeal(TradeTypesLib.Trade memory trade)
    public
    view
    returns (bool)
    {
        return isGenuineTradeHash(trade)
        && isGenuineOperatorSignature(trade.seal.hash, trade.seal.signature);
    }

    function isGenuinePaymentWalletHash(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return paymentHasher.hashPaymentAsWallet(payment) == payment.seals.wallet.hash;
    }

    function isGenuinePaymentOperatorHash(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return paymentHasher.hashPaymentAsOperator(payment) == payment.seals.operator.hash;
    }

    function isGenuinePaymentWalletSeal(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentWalletHash(payment)
        && isGenuineWalletSignature(payment.seals.wallet.hash, payment.seals.wallet.signature, payment.sender.wallet);
    }

    function isGenuinePaymentOperatorSeal(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentOperatorHash(payment)
        && isGenuineOperatorSignature(payment.seals.operator.hash, payment.seals.operator.signature);
    }

    function isGenuinePaymentSeals(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentWalletSeal(payment) && isGenuinePaymentOperatorSeal(payment);
    }

    
    function isGenuinePaymentFeeOfFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        int256 feePartsPer = int256(ConstantsLib.PARTS_PER());

        int256 feeAmount = payment.amount
        .mul(
            configuration.currencyPaymentFee(
                payment.blockNumber, payment.currency.ct, payment.currency.id, payment.amount
            )
        ).div(feePartsPer);

        if (1 > feeAmount)
            feeAmount = 1;

        return (payment.sender.fees.single.amount == feeAmount);
    }

    
    function isGenuinePaymentFeeOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        (address feeCurrencyCt, uint256 feeCurrencyId) = configuration.feeCurrency(
            payment.blockNumber, payment.currency.ct, payment.currency.id
        );

        return feeCurrencyCt == payment.sender.fees.single.currency.ct
        && feeCurrencyId == payment.sender.fees.single.currency.id;
    }

    
    function isGenuinePaymentSenderOfFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (!signerManager.isSigner(payment.sender.wallet))
        && (payment.sender.balances.current == payment.sender.balances.previous.sub(payment.transfers.single).sub(payment.sender.fees.single.amount));
    }

    
    function isGenuinePaymentRecipientOfFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (payment.recipient.balances.current == payment.recipient.balances.previous.add(payment.transfers.single));
    }

    
    function isGenuinePaymentSenderOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (!signerManager.isSigner(payment.sender.wallet));
    }

    
    function isGenuinePaymentRecipientOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet);
    }

    function isSuccessiveTradesPartyNonces(
        TradeTypesLib.Trade memory firstTrade,
        TradeTypesLib.TradePartyRole firstTradePartyRole,
        TradeTypesLib.Trade memory lastTrade,
        TradeTypesLib.TradePartyRole lastTradePartyRole
    )
    public
    pure
    returns (bool)
    {
        uint256 firstNonce = (TradeTypesLib.TradePartyRole.Buyer == firstTradePartyRole ? firstTrade.buyer.nonce : firstTrade.seller.nonce);
        uint256 lastNonce = (TradeTypesLib.TradePartyRole.Buyer == lastTradePartyRole ? lastTrade.buyer.nonce : lastTrade.seller.nonce);
        return lastNonce == firstNonce.add(1);
    }

    function isSuccessivePaymentsPartyNonces(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.PaymentPartyRole firstPaymentPartyRole,
        PaymentTypesLib.Payment memory lastPayment,
        PaymentTypesLib.PaymentPartyRole lastPaymentPartyRole
    )
    public
    pure
    returns (bool)
    {
        uint256 firstNonce = (PaymentTypesLib.PaymentPartyRole.Sender == firstPaymentPartyRole ? firstPayment.sender.nonce : firstPayment.recipient.nonce);
        uint256 lastNonce = (PaymentTypesLib.PaymentPartyRole.Sender == lastPaymentPartyRole ? lastPayment.sender.nonce : lastPayment.recipient.nonce);
        return lastNonce == firstNonce.add(1);
    }

    function isSuccessiveTradePaymentPartyNonces(
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole,
        PaymentTypesLib.Payment memory payment,
        PaymentTypesLib.PaymentPartyRole paymentPartyRole
    )
    public
    pure
    returns (bool)
    {
        uint256 firstNonce = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.nonce : trade.seller.nonce);
        uint256 lastNonce = (PaymentTypesLib.PaymentPartyRole.Sender == paymentPartyRole ? payment.sender.nonce : payment.recipient.nonce);
        return lastNonce == firstNonce.add(1);
    }

    function isSuccessivePaymentTradePartyNonces(
        PaymentTypesLib.Payment memory payment,
        PaymentTypesLib.PaymentPartyRole paymentPartyRole,
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole
    )
    public
    pure
    returns (bool)
    {
        uint256 firstNonce = (PaymentTypesLib.PaymentPartyRole.Sender == paymentPartyRole ? payment.sender.nonce : payment.recipient.nonce);
        uint256 lastNonce = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.nonce : trade.seller.nonce);
        return lastNonce == firstNonce.add(1);
    }

    function isGenuineSuccessiveTradesBalances(
        TradeTypesLib.Trade memory firstTrade,
        TradeTypesLib.TradePartyRole firstTradePartyRole,
        TradeTypesLib.CurrencyRole firstTradeCurrencyRole,
        TradeTypesLib.Trade memory lastTrade,
        TradeTypesLib.TradePartyRole lastTradePartyRole,
        TradeTypesLib.CurrencyRole lastTradeCurrencyRole,
        int256 delta
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory firstIntendedConjugateCurrentPreviousBalances = (TradeTypesLib.TradePartyRole.Buyer == firstTradePartyRole ? firstTrade.buyer.balances : firstTrade.seller.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory firstCurrentPreviousBalances = (TradeTypesLib.CurrencyRole.Intended == firstTradeCurrencyRole ? firstIntendedConjugateCurrentPreviousBalances.intended : firstIntendedConjugateCurrentPreviousBalances.conjugate);

        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory lastIntendedConjugateCurrentPreviousBalances = (TradeTypesLib.TradePartyRole.Buyer == lastTradePartyRole ? lastTrade.buyer.balances : lastTrade.seller.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory lastCurrentPreviousBalances = (TradeTypesLib.CurrencyRole.Intended == lastTradeCurrencyRole ? lastIntendedConjugateCurrentPreviousBalances.intended : lastIntendedConjugateCurrentPreviousBalances.conjugate);

        return lastCurrentPreviousBalances.previous == firstCurrentPreviousBalances.current.add(delta);
    }

    function isGenuineSuccessivePaymentsBalances(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.PaymentPartyRole firstPaymentPartyRole,
        PaymentTypesLib.Payment memory lastPayment,
        PaymentTypesLib.PaymentPartyRole lastPaymentPartyRole,
        int256 delta
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.CurrentPreviousInt256 memory firstCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == firstPaymentPartyRole ? firstPayment.sender.balances : firstPayment.recipient.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory lastCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == lastPaymentPartyRole ? lastPayment.sender.balances : lastPayment.recipient.balances);

        return lastCurrentPreviousBalances.previous == firstCurrentPreviousBalances.current.add(delta);
    }

    function isGenuineSuccessiveTradePaymentBalances(
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole,
        TradeTypesLib.CurrencyRole tradeCurrencyRole,
        PaymentTypesLib.Payment memory payment,
        PaymentTypesLib.PaymentPartyRole paymentPartyRole,
        int256 delta
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory firstIntendedConjugateCurrentPreviousBalances = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.balances : trade.seller.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory firstCurrentPreviousBalances = (TradeTypesLib.CurrencyRole.Intended == tradeCurrencyRole ? firstIntendedConjugateCurrentPreviousBalances.intended : firstIntendedConjugateCurrentPreviousBalances.conjugate);

        NahmiiTypesLib.CurrentPreviousInt256 memory lastCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == paymentPartyRole ? payment.sender.balances : payment.recipient.balances);

        return lastCurrentPreviousBalances.previous == firstCurrentPreviousBalances.current.add(delta);
    }

    function isGenuineSuccessivePaymentTradeBalances(
        PaymentTypesLib.Payment memory payment,
        PaymentTypesLib.PaymentPartyRole paymentPartyRole,
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole,
        TradeTypesLib.CurrencyRole tradeCurrencyRole,
        int256 delta
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.CurrentPreviousInt256 memory firstCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == paymentPartyRole ? payment.sender.balances : payment.recipient.balances);

        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory firstIntendedConjugateCurrentPreviousBalances = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.balances : trade.seller.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory lastCurrentPreviousBalances = (TradeTypesLib.CurrencyRole.Intended == tradeCurrencyRole ? firstIntendedConjugateCurrentPreviousBalances.intended : firstIntendedConjugateCurrentPreviousBalances.conjugate);

        return lastCurrentPreviousBalances.previous == firstCurrentPreviousBalances.current.add(delta);
    }

    function isGenuineSuccessiveTradesTotalFees(
        TradeTypesLib.Trade memory firstTrade,
        TradeTypesLib.TradePartyRole firstTradePartyRole,
        TradeTypesLib.Trade memory lastTrade,
        TradeTypesLib.TradePartyRole lastTradePartyRole
    )
    public
    pure
    returns (bool)
    {
        MonetaryTypesLib.Figure memory lastSingleFee;
        if (TradeTypesLib.TradePartyRole.Buyer == lastTradePartyRole)
            lastSingleFee = lastTrade.buyer.fees.single;
        else if (TradeTypesLib.TradePartyRole.Seller == lastTradePartyRole)
            lastSingleFee = lastTrade.seller.fees.single;

        NahmiiTypesLib.OriginFigure[] memory firstTotalFees = (TradeTypesLib.TradePartyRole.Buyer == firstTradePartyRole ? firstTrade.buyer.fees.total : firstTrade.seller.fees.total);
        MonetaryTypesLib.Figure memory firstTotalFee = getProtocolFigureByCurrency(firstTotalFees, lastSingleFee.currency);

        NahmiiTypesLib.OriginFigure[] memory lastTotalFees = (TradeTypesLib.TradePartyRole.Buyer == lastTradePartyRole ? lastTrade.buyer.fees.total : lastTrade.seller.fees.total);
        MonetaryTypesLib.Figure memory lastTotalFee = getProtocolFigureByCurrency(lastTotalFees, lastSingleFee.currency);

        return lastTotalFee.amount == firstTotalFee.amount.add(lastSingleFee.amount);
    }

    function isGenuineSuccessiveTradeOrderResiduals(
        TradeTypesLib.Trade memory firstTrade,
        TradeTypesLib.Trade memory lastTrade,
        TradeTypesLib.TradePartyRole tradePartyRole
    )
    public
    pure
    returns (bool)
    {
        (int256 firstCurrentResiduals, int256 lastPreviousResiduals) = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole) ?
        (firstTrade.buyer.order.residuals.current, lastTrade.buyer.order.residuals.previous) :
    (firstTrade.seller.order.residuals.current, lastTrade.seller.order.residuals.previous);

        return firstCurrentResiduals == lastPreviousResiduals;
    }

    function isGenuineSuccessivePaymentsTotalFees(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.Payment memory lastPayment
    )
    public
    pure
    returns (bool)
    {
        MonetaryTypesLib.Figure memory firstTotalFee = getProtocolFigureByCurrency(firstPayment.sender.fees.total, lastPayment.sender.fees.single.currency);
        MonetaryTypesLib.Figure memory lastTotalFee = getProtocolFigureByCurrency(lastPayment.sender.fees.total, lastPayment.sender.fees.single.currency);
        return lastTotalFee.amount == firstTotalFee.amount.add(lastPayment.sender.fees.single.amount);
    }

    function isGenuineSuccessiveTradePaymentTotalFees(
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole,
        PaymentTypesLib.Payment memory payment
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.OriginFigure[] memory firstTotalFees = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.fees.total : trade.seller.fees.total);
        MonetaryTypesLib.Figure memory firstTotalFee = getProtocolFigureByCurrency(firstTotalFees, payment.sender.fees.single.currency);

        MonetaryTypesLib.Figure memory lastTotalFee = getProtocolFigureByCurrency(payment.sender.fees.total, payment.sender.fees.single.currency);

        return lastTotalFee.amount == firstTotalFee.amount.add(payment.sender.fees.single.amount);
    }

    function isGenuineSuccessivePaymentTradeTotalFees(
        PaymentTypesLib.Payment memory payment,
        PaymentTypesLib.PaymentPartyRole paymentPartyRole,
        TradeTypesLib.Trade memory trade,
        TradeTypesLib.TradePartyRole tradePartyRole
    )
    public
    pure
    returns (bool)
    {
        MonetaryTypesLib.Figure memory lastSingleFee;
        if (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole)
            lastSingleFee = trade.buyer.fees.single;
        else if (TradeTypesLib.TradePartyRole.Seller == tradePartyRole)
            lastSingleFee = trade.seller.fees.single;

        NahmiiTypesLib.OriginFigure[] memory firstTotalFees = (PaymentTypesLib.PaymentPartyRole.Sender == paymentPartyRole ? payment.sender.fees.total : payment.recipient.fees.total);
        MonetaryTypesLib.Figure memory firstTotalFee = getProtocolFigureByCurrency(firstTotalFees, lastSingleFee.currency);

        NahmiiTypesLib.OriginFigure[] memory lastTotalFees = (TradeTypesLib.TradePartyRole.Buyer == tradePartyRole ? trade.buyer.fees.total : trade.seller.fees.total);
        MonetaryTypesLib.Figure memory lastTotalFee = getProtocolFigureByCurrency(lastTotalFees, lastSingleFee.currency);

        return lastTotalFee.amount == firstTotalFee.amount.add(lastSingleFee.amount);
    }

    function isTradeParty(TradeTypesLib.Trade memory trade, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == trade.buyer.wallet || wallet == trade.seller.wallet;
    }

    function isTradeBuyer(TradeTypesLib.Trade memory trade, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == trade.buyer.wallet;
    }

    function isTradeSeller(TradeTypesLib.Trade memory trade, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == trade.seller.wallet;
    }

    function isTradeOrder(TradeTypesLib.Trade memory trade, TradeTypesLib.Order memory order)
    public
    pure
    returns (bool)
    {
        return (trade.buyer.order.hashes.operator == order.seals.operator.hash ||
        trade.seller.order.hashes.operator == order.seals.operator.hash);
    }

    function isTradeIntendedCurrency(TradeTypesLib.Trade memory trade, MonetaryTypesLib.Currency memory currency)
    public
    pure
    returns (bool)
    {
        return currency.ct == trade.currencies.intended.ct && currency.id == trade.currencies.intended.id;
    }

    function isTradeConjugateCurrency(TradeTypesLib.Trade memory trade, MonetaryTypesLib.Currency memory currency)
    public
    pure
    returns (bool)
    {
        return currency.ct == trade.currencies.conjugate.ct && currency.id == trade.currencies.conjugate.id;
    }

    function isTradeCurrency(TradeTypesLib.Trade memory trade, MonetaryTypesLib.Currency memory currency)
    public
    pure
    returns (bool)
    {
        return isTradeIntendedCurrency(trade, currency) || isTradeConjugateCurrency(trade, currency);
    }

    function isTradeIntendedCurrencyNonFungible(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bool)
    {
        return trade.currencies.intended.ct != trade.buyer.fees.single.currency.ct
        || trade.currencies.intended.id != trade.buyer.fees.single.currency.id;
    }

    function isTradeConjugateCurrencyNonFungible(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bool)
    {
        return trade.currencies.conjugate.ct != trade.seller.fees.single.currency.ct
        || trade.currencies.conjugate.id != trade.seller.fees.single.currency.id;
    }

    function isPaymentParty(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.sender.wallet || wallet == payment.recipient.wallet;
    }

    function isPaymentSender(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.sender.wallet;
    }

    function isPaymentRecipient(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.recipient.wallet;
    }

    function isPaymentCurrency(PaymentTypesLib.Payment memory payment, MonetaryTypesLib.Currency memory currency)
    public
    pure
    returns (bool)
    {
        return currency.ct == payment.currency.ct && currency.id == payment.currency.id;
    }

    function isPaymentCurrencyNonFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return payment.currency.ct != payment.sender.fees.single.currency.ct
        || payment.currency.id != payment.sender.fees.single.currency.id;
    }

    
    
    
    function getProtocolFigureByCurrency(NahmiiTypesLib.OriginFigure[] memory originFigures, MonetaryTypesLib.Currency memory currency)
    private
    pure
    returns (MonetaryTypesLib.Figure memory) {
        for (uint256 i = 0; i < originFigures.length; i++)
            if (originFigures[i].figure.currency.ct == currency.ct && originFigures[i].figure.currency.id == currency.id
            && originFigures[i].originId == 0)
                return originFigures[i].figure;
        return MonetaryTypesLib.Figure(0, currency);
    }
}

contract ValidatableV2 is Ownable {
    
    
    
    ValidatorV2 public validator;

    
    
    
    event SetValidatorEvent(ValidatorV2 oldValidator, ValidatorV2 newValidator);

    
    
    
    
    
    function setValidator(ValidatorV2 newValidator)
    public
    onlyDeployer
    notNullAddress(address(newValidator))
    notSameAddresses(address(newValidator), address(validator))
    {
        
        ValidatorV2 oldValidator = validator;
        validator = newValidator;

        
        emit SetValidatorEvent(oldValidator, newValidator);
    }

    
    
    
    modifier validatorInitialized() {
        require(address(validator) != address(0), "Validator not initialized [ValidatableV2.sol:55]");
        _;
    }

    modifier onlySealedOrder(TradeTypesLib.Order memory order) {
        require(validator.isGenuineOrderSeals(order), "Order seals not genuine [ValidatableV2.sol:60]");
        _;
    }

    modifier onlyOperatorSealedOrder(TradeTypesLib.Order memory order) {
        require(validator.isGenuineOrderOperatorSeal(order), "Order operator seal not genuine [ValidatableV2.sol:65]");
        _;
    }

    modifier onlySealedTrade(TradeTypesLib.Trade memory trade) {
        require(validator.isGenuineTradeSeal(trade), "Trade seal not genuine [ValidatableV2.sol:70]");
        _;
    }

    modifier onlyOperatorSealedPayment(PaymentTypesLib.Payment memory payment) {
        require(validator.isGenuinePaymentOperatorSeal(payment), "Paymet operator seal not genuine [ValidatableV2.sol:75]");
        _;
    }

    modifier onlySealedPayment(PaymentTypesLib.Payment memory payment) {
        require(validator.isGenuinePaymentSeals(payment), "Paymet seals not genuine [ValidatableV2.sol:80]");
        _;
    }

    modifier onlyTradeParty(TradeTypesLib.Trade memory trade, address wallet) {
        require(validator.isTradeParty(trade, wallet), "Wallet not trade party [ValidatableV2.sol:85]");
        _;
    }

    modifier onlyPaymentParty(PaymentTypesLib.Payment memory payment, address wallet) {
        require(validator.isPaymentParty(payment, wallet), "Wallet not payment party [ValidatableV2.sol:90]");
        _;
    }

    modifier onlyPaymentSender(PaymentTypesLib.Payment memory payment, address wallet) {
        require(validator.isPaymentSender(payment, wallet), "Wallet not payment sender [ValidatableV2.sol:95]");
        _;
    }
}

contract CancelOrdersChallenge is Ownable, ConfigurableOperational, ValidatableV2 {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    
    
    
    address[] public cancellingWallets;

    mapping(address => mapping(bytes32 => bool)) public walletOrderOperatorHashCancelledMap;

    mapping(address => bytes32[]) public walletCancelledOrderOperatorHashes;
    mapping(address => mapping(bytes32 => uint256)) public walletCancelledOrderOperatorHashIndexMap;

    mapping(address => uint256) public walletOrderCancelledTimeoutMap;

    
    
    
    event CancelOrdersEvent(bytes32[] orderOperatorHashes, address wallet);
    event ChallengeEvent(bytes32 orderOperatorHash, bytes32 tradeHash, address wallet);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    
    
    function cancellingWalletsCount()
    public
    view
    returns (uint256)
    {
        return cancellingWallets.length;
    }

    
    
    
    function cancelledOrdersCount(address wallet)
    public
    view
    returns (uint256)
    {
        uint256 count = 0;
        for (uint256 i = 0; i < walletCancelledOrderOperatorHashes[wallet].length; i++) {
            bytes32 operatorHash = walletCancelledOrderOperatorHashes[wallet][i];
            if (walletOrderOperatorHashCancelledMap[wallet][operatorHash])
                count++;
        }
        return count;
    }

    
    
    
    
    function isOrderCancelled(address wallet, bytes32 orderHash)
    public
    view
    returns (bool)
    {
        return walletOrderOperatorHashCancelledMap[wallet][orderHash];
    }

    
    
    
    
    
    function cancelledOrderHashesByIndices(address wallet, uint256 low, uint256 up)
    public
    view
    returns (bytes32[] memory)
    {
        require(0 < walletCancelledOrderOperatorHashes[wallet].length, "No cancelled order operator hash for wallet [CancelOrdersChallenge.sol:104]");
        require(low <= up, "Bounds parameters mismatch [CancelOrdersChallenge.sol:105]");

        up = up > walletCancelledOrderOperatorHashes[wallet].length - 1 ? walletCancelledOrderOperatorHashes[wallet].length - 1 : up;
        bytes32[] memory hashes = new bytes32[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            hashes[i - low] = walletCancelledOrderOperatorHashes[wallet][i];
        return hashes;
    }

    
    
    function cancelOrders(TradeTypesLib.Order[] memory orders)
    public
    onlyOperationalModeNormal
    {
        for (uint256 i = 0; i < orders.length; i++) {
            require(msg.sender == orders[i].wallet, "Message sender is not order wallet [CancelOrdersChallenge.sol:121]");
            require(validator.isGenuineOrderSeals(orders[i]), "Not genuine order seals found [CancelOrdersChallenge.sol:122]");

            if (0 == walletCancelledOrderOperatorHashes[msg.sender].length)
                cancellingWallets.push(msg.sender);

            walletOrderOperatorHashCancelledMap[msg.sender][orders[i].seals.operator.hash] = true;
            walletCancelledOrderOperatorHashes[msg.sender].push(orders[i].seals.operator.hash);
            walletCancelledOrderOperatorHashIndexMap[msg.sender][orders[i].seals.operator.hash] = walletCancelledOrderOperatorHashes[msg.sender].length - 1;
        }

        walletOrderCancelledTimeoutMap[msg.sender] = block.timestamp.add(configuration.cancelOrderChallengeTimeout());

        emit CancelOrdersEvent(_orderOperatorHashes(orders), msg.sender);
    }

    
    
    
    function challenge(TradeTypesLib.Trade memory trade, address wallet)
    public
    onlyOperationalModeNormal
    onlySealedTrade(trade)
    {
        require(block.timestamp < walletOrderCancelledTimeoutMap[wallet], "Order cancellation timer expired for wallet [CancelOrdersChallenge.sol:145]");

        bytes32 tradeOrderOperatorHash = (
        wallet == trade.buyer.wallet ?
        trade.buyer.order.hashes.operator :
        trade.seller.order.hashes.operator
        );

        require(walletOrderOperatorHashCancelledMap[wallet][tradeOrderOperatorHash], "Order not cancelled [CancelOrdersChallenge.sol:153]");

        walletOrderOperatorHashCancelledMap[wallet][tradeOrderOperatorHash] = false;

        emit ChallengeEvent(tradeOrderOperatorHash, trade.seal.hash, msg.sender);
    }

    
    
    
    function challengePhase(address wallet)
    public
    view
    returns (NahmiiTypesLib.ChallengePhase)
    {
        if (0 < walletCancelledOrderOperatorHashes[wallet].length && block.timestamp < walletOrderCancelledTimeoutMap[wallet])
            return NahmiiTypesLib.ChallengePhase.Dispute;
        else
            return NahmiiTypesLib.ChallengePhase.Closed;
    }

    
    
    
    function _orderOperatorHashes(TradeTypesLib.Order[] memory orders)
    private
    pure
    returns (bytes32[] memory)
    {
        bytes32[] memory operatorHashes = new bytes32[](orders.length);
        for (uint256 i = 0; i < orders.length; i++)
            operatorHashes[i] = orders[i].seals.operator.hash;
        return operatorHashes;
    }
}
