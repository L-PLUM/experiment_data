/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: ./contracts/modules/Registry/IRegistry.sol

interface IRegistry {
    event LogContractRegistered(
        uint256 release,
        bytes32 contractName,
        address contractAddress
    );

    event LogContractDeregistered(uint256 release, bytes32 contractName);

    event LogInterfaceIdRegistered(bytes4 interfaceId, bytes32 contractName);

    event LogReleasePrepared(uint256 release);
}

// File: ./contracts/modules/Registry/RegistryStorageModel.sol

contract RegistryStorageModel is IRegistry {
    /**
     * @dev Current release
     */
    uint256 public release;

    /**
     * @dev  Save number of items to iterate through
     */
    uint256 public maxContracts = 100;

    // release => contract name => contract address
    mapping(uint256 => mapping(bytes32 => address)) public contracts;
    // release => contract name []
    mapping(uint256 => bytes32[]) public contractNames;
    // controller name => address
    mapping(bytes32 => address) public controllers;
}

// File: ./contracts/shared/BaseModuleController.sol

contract BaseModuleController {
    address public delegator;

    function _assignStorage(address _storage) internal {
        delegator = _storage;
    }
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

// File: contracts/modules/Registry/RegistryController.sol

contract RegistryController is RegistryStorageModel, BaseModuleController, AccessModifiers {
    constructor() public {
        // Init
        controllers["DAO"] = msg.sender;
    }

    function assignStorage(address _storage) external onlyDAO {
        _assignStorage(_storage);
    }

    function registerService(bytes32 _name, address _addr) external onlyDAO {
        controllers[_name] = _addr;
    }

    function getRelease() external view returns (uint256 _release) {
        _release = release;
    }

    /**
     * @dev Register contract in certain release
     */
    function registerInRelease(
        uint256 _release,
        bytes32 _contractName,
        address _contractAddress
    ) public onlyDAO {
        require(
            contractNames[_release].length <= maxContracts,
            "ERROR::MAX_CONTRACTS_LIMIT"
        );

        if (contracts[_release][_contractName] == address(0)) {
            contractNames[_release].push(_contractName);
        }

        contracts[_release][_contractName] = _contractAddress;

        emit LogContractRegistered(_release, _contractName, _contractAddress);
    }

    /**
     * @dev Register contract in the latest release
     */
    function register(bytes32 _contractName, address _contractAddress)
        public
        onlyDAO
    {
        registerInRelease(release, _contractName, _contractAddress);
    }

    /**
     * @dev Deregister contract in certain release
     */
    function deregisterInRelease(uint256 _release, bytes32 _contractName)
        public
        onlyDAO
    {
        uint256 indexToDelete;
        uint256 countContracts = contractNames[_release].length;

        // todo: think about how to avoid this loop
        for (uint256 i = 0; i < countContracts; i++) {
            if (contractNames[_release][i] == _contractName) {
                indexToDelete = i;
                break;
            }
        }

        if (indexToDelete < countContracts - 1) {
            contractNames[_release][indexToDelete] = contractNames[_release][countContracts - 1];
        }

        contractNames[_release].length--;
        delete contracts[_release][_contractName];

        emit LogContractDeregistered(_release, _contractName);
    }

    /**
     * @dev Deregister contract in the latest release
     */
    function deregister(bytes32 _contractName) public onlyDAO {
        deregisterInRelease(release, _contractName);
    }

    /**
     * @dev Create new release, copy contracts from previous release
     */
    function prepareRelease() public onlyDAO returns (uint256 _release) {
        uint256 countContracts = contractNames[release].length;

        require(countContracts > 0, "ERROR::EMPTY_RELEASE");

        uint256 nextRelease = release + 1;

        // todo: think about how to avoid this loop
        for (uint256 i = 0; i < countContracts; i++) {
            bytes32 contractName = contractNames[release][i];
            registerInRelease(
                nextRelease,
                contractName,
                contracts[release][contractName]
            );
        }

        release = nextRelease;
        _release = release;

        emit LogReleasePrepared(release);
    }

    /**
     * @dev Get contract's address in certain release
     */
    function getContractInRelease(uint256 _release, bytes32 _contractName)
        public
        view
        returns (address _addr)
    {
        _addr = contracts[_release][_contractName];
    }

    /**
     * @dev Get contract's address in the latest release
     */
    function getContract(bytes32 _contractName)
        public
        view
        returns (address _addr)
    {
        _addr = getContractInRelease(release, _contractName);
    }

    function getService(bytes32 _contractName)
        public
        view
        returns (address _addr)
    {
        _addr = controllers[_contractName];
    }
}
