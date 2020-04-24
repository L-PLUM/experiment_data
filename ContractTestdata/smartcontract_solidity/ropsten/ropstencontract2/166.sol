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

contract TransactionTracker is Ownable, Servable {

    
    
    
    struct TransactionRecord {
        int256 value;
        uint256 blockNumber;
        address currencyCt;
        uint256 currencyId;
    }

    struct TransactionLog {
        TransactionRecord[] records;
        mapping(address => mapping(uint256 => uint256[])) recordIndicesByCurrency;
    }

    
    
    
    string constant public DEPOSIT_TRANSACTION_TYPE = "deposit";
    string constant public WITHDRAWAL_TRANSACTION_TYPE = "withdrawal";

    
    
    
    bytes32 public depositTransactionType;
    bytes32 public withdrawalTransactionType;

    mapping(address => mapping(bytes32 => TransactionLog)) private transactionLogByWalletType;

    
    
    
    constructor(address deployer) Ownable(deployer)
    public
    {
        depositTransactionType = keccak256(abi.encodePacked(DEPOSIT_TRANSACTION_TYPE));
        withdrawalTransactionType = keccak256(abi.encodePacked(WITHDRAWAL_TRANSACTION_TYPE));
    }

    
    
    
    
    
    
    
    
    
    function add(address wallet, bytes32 _type, int256 value, address currencyCt,
        uint256 currencyId)
    public
    onlyActiveService
    {
        transactionLogByWalletType[wallet][_type].records.length++;

        uint256 index = transactionLogByWalletType[wallet][_type].records.length - 1;

        transactionLogByWalletType[wallet][_type].records[index].value = value;
        transactionLogByWalletType[wallet][_type].records[index].blockNumber = block.number;
        transactionLogByWalletType[wallet][_type].records[index].currencyCt = currencyCt;
        transactionLogByWalletType[wallet][_type].records[index].currencyId = currencyId;

        transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].push(index);
    }

    
    
    
    
    function count(address wallet, bytes32 _type)
    public
    view
    returns (uint256)
    {
        return transactionLogByWalletType[wallet][_type].records.length;
    }

    
    
    
    
    
    function getByIndex(address wallet, bytes32 _type, uint256 index)
    public
    view
    returns (int256 value, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        TransactionRecord storage entry = transactionLogByWalletType[wallet][_type].records[index];
        value = entry.value;
        blockNumber = entry.blockNumber;
        currencyCt = entry.currencyCt;
        currencyId = entry.currencyId;
    }

    
    
    
    
    
    function getByBlockNumber(address wallet, bytes32 _type, uint256 _blockNumber)
    public
    view
    returns (int256 value, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        return getByIndex(wallet, _type, _indexByBlockNumber(wallet, _type, _blockNumber));
    }

    
    
    
    
    
    
    function countByCurrency(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length;
    }

    
    
    
    
    
    function getByCurrencyIndex(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 index)
    public
    view
    returns (int256 value, uint256 blockNumber)
    {
        uint256 entryIndex = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId][index];

        TransactionRecord storage entry = transactionLogByWalletType[wallet][_type].records[entryIndex];
        value = entry.value;
        blockNumber = entry.blockNumber;
    }

    
    
    
    
    
    function getByCurrencyBlockNumber(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 _blockNumber)
    public
    view
    returns (int256 value, uint256 blockNumber)
    {
        return getByCurrencyIndex(
            wallet, _type, currencyCt, currencyId,
            _indexByCurrencyBlockNumber(
                wallet, _type, currencyCt, currencyId, _blockNumber
            )
        );
    }

    
    
    
    function _indexByBlockNumber(address wallet, bytes32 _type, uint256 blockNumber)
    private
    view
    returns (uint256)
    {
        require(
            0 < transactionLogByWalletType[wallet][_type].records.length,
            "No transactions found for wallet and type [TransactionTracker.sol:187]"
        );
        for (uint256 i = transactionLogByWalletType[wallet][_type].records.length - 1; i >= 0; i--)
            if (blockNumber >= transactionLogByWalletType[wallet][_type].records[i].blockNumber)
                return i;
        revert();
    }

    function _indexByCurrencyBlockNumber(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 blockNumber)
    private
    view
    returns (uint256)
    {
        require(
            0 < transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length,
            "No transactions found for wallet, type and currency [TransactionTracker.sol:203]"
        );
        for (uint256 i = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length - 1; i >= 0; i--) {
            uint256 j = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId][i];
            if (blockNumber >= transactionLogByWalletType[wallet][_type].records[j].blockNumber)
                return j;
        }
        revert();
    }
}
