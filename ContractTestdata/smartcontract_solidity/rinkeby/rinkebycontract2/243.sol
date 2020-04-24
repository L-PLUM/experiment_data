/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.0;


/**
 * @title Spawn
 * @author 0age
 * @notice This contract provides creation code that is used by Spawner in order
 * to initialize and deploy eip-1167 minimal proxies for a given logic contract.
 */
contract Spawn {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    // delegatecall into the logic contract to perform initialization.
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      // pass along failure message from delegatecall and revert.
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // place eip-1167 runtime code in memory.
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    // return eip-1167 code to write it to spawned contract runtime.
    assembly {
      return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
    }
  }
}


/**
 * @title SpawnCompact
 * @author 0age
 * @notice This contract provides creation code that is used by Spawner in order
 * to initialize and deploy eip-1167 minimal proxies for a given logic contract.
 * It expects the address of the logic contract to begin with at least five zero
 * bytes.
 */
/* contract SpawnCompact {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    // delegatecall into the logic contract to perform initialization.
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      // pass along failure message from delegatecall and revert.
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // place eip-1167 runtime code in memory.
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d6e),
      uint120(uint160(logicContract)),
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    // return eip-1167 code to write it to spawned contract runtime.
    assembly {
      return(add(0x20, runtimeCode), 40) // eip-1167 runtime code, length
    }
  }
} */


/**
 * @title Spawner
 * @author 0age
 * @notice This contract spawns and initializes eip-1167 minimal proxies that
 * point to existing logic contracts. The logic contracts need to have an
 * intitializer function that should only callable when no contract exists at
 * their current address (i.e. it is being `DELEGATECALL`ed from a constructor).
 */
contract Spawner {
  /**
   * @notice Internal function for spawning an eip-1167 minimal proxy using
   * `CREATE2`.
   * @param logicContract address The address of the logic contract.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the newly-spawned contract.
   */
  function _spawn(
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    // spawn the contract using `CREATE2`.
    spawnedContract = _spawnCreate2(initCode);
  }

  /**
   * @notice Internal function for spawning a compact eip-1167 minimal proxy
   * using `CREATE2`. This method will save ~1000 gas per deployment, but requires
   * that the logic contract has a contract address that begins with at least
   * five zero bytes.
   * @param compactLogicContract address The address of the logic contract. It
   * must begin with at least five zero bytes, or ten zeroes.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the newly-spawned contract.
   */
  /* function _spawnCompact(
    address compactLogicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // ensure that the address is sufficiently compact.
    _ensureCompact(compactLogicContract);

    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(SpawnCompact).creationCode,
      abi.encode(compactLogicContract, initializationCalldata)
    );

    // spawn the contract using `CREATE2`.
    spawnedContract = _spawnCreate2(initCode);
  } */

  /**
   * @notice Internal function for spawning an eip-1167 minimal proxy using
   * `CREATE`. This method will be slightly cheaper than standard _spawn in
   * cases where counterfactual address derivation is not required.
   * @param logicContract address The address of the logic contract.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the newly-spawned contract.
   */
  /* function _spawnOldSchool(
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    // spawn the contract using `CREATE`.
    spawnedContract = _spawnCreate(initCode);
  } */

  /**
   * @notice Internal function for spawning a compact eip-1167 minimal proxy
   * using `CREATE`. This method will save the most gas per deployment, but
   * requires that the logic contract has a contract address that begins with at
   * least five zero bytes and will not be viable in cases where counterfactual
   * address derivation is not required.
   * @param compactLogicContract address The address of the logic contract. It
   * must begin with at least five zero bytes, or ten zeroes.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the newly-spawned contract.
   */
  /* function _spawnCompactOldSchool(
    address compactLogicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // ensure that the address is sufficiently compact.
    _ensureCompact(compactLogicContract);

    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(SpawnCompact).creationCode,
      abi.encode(compactLogicContract, initializationCalldata)
    );

    // spawn the contract using `CREATE`.
    spawnedContract = _spawnCreate(initCode);
  } */

  /**
   * @notice Private function for spawning a compact eip-1167 minimal proxy
   * using `CREATE`. Provides logic that is reused by internal functions.
   * @param initCode bytes The contract creation code.
   * @return The address of the newly-spawned contract.
   */
  /* function _spawnCreate(
    bytes memory initCode
  ) private returns (address spawnedContract) {
    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create(              // call `CREATE` with 3 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size                          // pass in init code's length.
      )

      // pass along failure message from failed contract deployment and revert.
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  } */

  /**
   * @notice Private function for spawning a compact eip-1167 minimal proxy
   * using `CREATE2`. Provides logic that is reused by internal functions. A
   * salt will also be chosen based on the calling address and a computed nonce
   * that prevents deployments to existing addresses.
   * @param initCode bytes The contract creation code.
   * @return The address of the newly-spawned contract.
   */
  function _spawnCreate2(
    bytes memory initCode
  ) private returns (address spawnedContract) {
    // get the keccak256 hash of the init code for address derivation.
    bytes32 initCodeHash = keccak256(initCode);

    // set the initial nonce to be provided when constructing the salt.
    uint256 nonce = 0;

    // declare variables for salt value and code size of derived address.
    bytes32 salt;
    uint256 codeSize;

    while (true) {
      // derive `CREATE2` salt using `msg.sender` and nonce.
      salt = keccak256(abi.encodePacked(msg.sender, nonce));

      address target = address(    // derive the target deployment address.
        uint160(                   // downcast to match the address type.
          uint256(                 // cast to uint to truncate upper digits.
            keccak256(             // compute CREATE2 hash using 4 inputs.
              abi.encodePacked(    // pack all inputs to the hash together.
                bytes1(0xff),      // pass in the control character.
                address(this),     // pass in the address of this contract.
                salt,              // pass in the salt from above.
                initCodeHash       // pass in hash of contract creation code.
              )
            )
          )
        )
      );

      // determine if a contract is already deployed to the target address.
      assembly { codeSize := extcodesize(target) }

      // exit the loop if no contract is deployed to the target address.
      if (codeSize == 0) {
        break;
      }

      // otherwise, increment the nonce and derive a new salt.
      nonce++;
    }

    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create2(             // call `CREATE2` w/ 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        salt                                  // pass in the salt value.
      )

      // pass along failure message from failed contract deployment and revert.
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  /**
   * @notice Private function for ensuring that a compact logic contract address
   * is supplied. Provides logic that is reused by internal functions.
   * @param logicContract address The address of the logic contract.
   */
  /* function _ensureCompact(address logicContract) private pure {
    // ensure that the address is sufficiently compact.
    require(
      uint160(logicContract) <= 0xffffffffffffffffffffffffffffff,
      "Logic contract address must start with at least five zero bytes."
    );
  }   */
}



interface iRegistry {

    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address instance, uint256 instanceIndex, address indexed creator, address indexed factory, uint256 indexed factoryID);

    // factory state functions

    function addFactory(address factory, bytes calldata extraData ) external;
    function retireFactory(address factory) external;

    // factory view functions

    function getFactoryCount() external view returns (uint256 count);
    function getFactoryStatus(address factory) external view returns (FactoryStatus status);
    function getFactoryID(address factory) external view returns (uint16 factoryID);
    function getFactoryData(address factory) external view returns (bytes memory extraData);
    function getFactoryAddress(uint16 factoryID) external view returns (address factory);
    function getFactory(address factory) external view returns (FactoryStatus state, uint16 factoryID, bytes memory extraData);
    function getFactories() external view returns (address[] memory factories);
    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories);

    // instance state functions

    function register(address instance, address creator, uint64 extraData) external;

    // instance view functions

    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}



contract Metadata {

    bytes private _staticMetadata;
    bytes private _variableMetadata;

    event StaticMetadataSet(bytes staticMetadata);
    event VariableMetadataSet(bytes variableMetadata);

    // state functions

    function _setStaticMetadata(bytes memory staticMetadata) internal {
        require(_staticMetadata.length == 0, "static metadata cannot be changed");
        _staticMetadata = staticMetadata;
        emit StaticMetadataSet(staticMetadata);
    }

    function _setVariableMetadata(bytes memory variableMetadata) internal {
        _variableMetadata = variableMetadata;
        emit VariableMetadataSet(variableMetadata);
    }

    // view functions

    function getMetadata() public view returns (bytes memory staticMetadata, bytes memory variableMetadata) {
        staticMetadata = _staticMetadata;
        variableMetadata = _variableMetadata;
    }
}



contract Operated {

    OperatorData private _operatorData;

    struct OperatorData {
        address operator;
        bool status;
    }

    event StatusUpdated(address operator, bool status);

    // state functions

    function _setOperator(address operator) internal {
        require(_operatorData.operator != operator, "same operator set");
        _operatorData.operator = operator;
        emit StatusUpdated(operator, _operatorData.status);
    }

    function _activate() internal {
        require(_operatorData.status == false, "already active");
        _operatorData.status = true;
        emit StatusUpdated(_operatorData.operator, true);
    }

    function _deactivate() internal {
        require(_operatorData.status == true, "already deactivated");
        _operatorData.status = false;
        emit StatusUpdated(_operatorData.operator, false);
    }

    // view functions

    function getOperator() public view returns (address operator) {
        operator = _operatorData.operator;
    }

    function isOperator(address caller) public view returns (bool validity) {
        validity = (caller == getOperator());
    }

    function isActive() public view returns (bool status) {
        status = _operatorData.status;
    }

    function isActiveOperator(address caller) public view returns (bool validity) {
        validity = (isOperator(caller) && isActive());
    }

}



/**
 * @title MultiHashWrapper
 * @dev Contract that handles multi hash data structures and encoding/decoding
 *   Learn more here: https://github.com/multiformats/multihash
 */
contract MultiHashWrapper {

  struct MultiHash {
    uint8 hashFunction;
    uint8 digestSize;
    bytes32 hash;
  }

  // CONSTRUCTOR

  constructor () public {

  }

  // INTERNAL FUNCTIONS

  /**
   * @dev Given a multihash struct, returns the full base58-encoded hash
   * @param _multiHash MultiHash struct that has the hashFunction, digestSize and the hash
   * @return the base58-encoded full hash
   */
  function _combineMultiHash(MultiHash memory _multiHash) internal pure returns (bytes memory) {
    bytes memory out = new bytes(34);

    out[0] = byte(_multiHash.hashFunction);
    out[1] = byte(_multiHash.digestSize);

    uint8 i;
    for (i = 0; i < 32; i++) {
      out[i+2] = _multiHash.hash[i];
    }

    return out;
  }

  /**
   * @dev Given a base58-encoded  hash, divides into its individual parts and returns a struct
   * @param _source base58-encoded  hash
   * @return MultiHash that has the hashFunction, digestSize and the hash
   */
  function _splitMultiHash(bytes memory _source) internal pure returns (MultiHash memory) {
    uint8 hashFunction = uint8(_source[0]);
    uint8 digestSize = uint8(_source[1]);
    bytes32 hash;

    assembly {
      hash := mload(add(_source, 34))
    }

    return (MultiHash({
      hashFunction: hashFunction,
      digestSize: digestSize,
      hash: hash
    }));
  }
}




contract Factory is Spawner {

    address[] private _instances;

    /* NOTE: The following items can be hardcoded as constant to save ~200 gas/create */
    address private _templateContract;
    string private _Init_ABI;
    address private _instanceRegistry;
    bytes4 private _Instance_Type;

    event InstanceCreated(address indexed instance, address indexed creator, string initABI, bytes initData);

    function _initialize(address instanceRegistry, address templateContract, bytes4 instanceType, string memory initABI) internal {
        // set instance registry
        _instanceRegistry = instanceRegistry;

        // set logic contract
        _templateContract = templateContract;

        // set initABI
        _Init_ABI = initABI;

        // validate correct instance registry
        require(instanceType == iRegistry(instanceRegistry).getInstanceType(), 'incorrect instance type');

        // set instanceType
        _Instance_Type = instanceType;
    }

    // IFactory methods

    function create(bytes memory initData) public returns (address instance) {
        // deploy new contract: initialize it & write minimal proxy to runtime.
        instance = Spawner._spawn(getTemplate(), initData);

        // add the instance to the array
        _instances.push(instance);

        // add the instance to the instance registry
        iRegistry(getInstanceRegistry()).register(instance, msg.sender, uint64(0));

        // emit event
        emit InstanceCreated(instance, msg.sender, getInitABI(), initData);
    }

    function getInstanceType() public view returns (bytes4 instanceType) {
        instanceType = _Instance_Type;
    }

    function getInitABI() public view returns (string memory initABI) {
        initABI = _Init_ABI;
    }

    function getInstanceRegistry() public view returns (address instanceRegistry) {
        instanceRegistry = _instanceRegistry;
    }

    function getTemplate() public view returns (address template) {
        template = _templateContract;
    }

    function getInstanceCount() public view returns (uint256 count) {
        count = _instances.length;
    }

    function getInstance(uint256 index) public view returns (address instance) {
        require(index < _instances.length, "index out of range");
        instance = _instances[index];
    }

    function getInstances() public view returns (address[] memory instances) {
        instances = _instances;
    }

    // Note: startIndex is inclusive, endIndex exclusive
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) public view returns (address[] memory instances) {
        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _instances.length, "end index out of range");

        // initialize fixed size memory array
        address[] memory range = new address[](endIndex - startIndex);

        // Populate array with addresses in range
        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _instances[i];
        }

        // return array of addresses
        instances = range;
    }

}





contract Post is MultiHashWrapper, Operated, Metadata {

    MultiHash private _proofHash;

    event Created(address operator, bytes proofHash, bytes staticMetadata, bytes variableMetadata);

    function initialize(
        address operator,
        bytes memory proofHash,
        bytes memory staticMetadata,
        bytes memory variableMetadata
    ) public {
        // only allow function to be delegatecalled from within a constructor.
        assembly { if extcodesize(address) { revert(0, 0) } }

        // set storage variables
        _proofHash = MultiHashWrapper._splitMultiHash(proofHash);

        // set operator
        Operated._setOperator(operator);
        Operated._activate();

        // set static metadata
        Metadata._setStaticMetadata(staticMetadata);

        // set variable metadata
        Metadata._setVariableMetadata(variableMetadata);

        // emit event
        emit Created(operator, proofHash, staticMetadata, variableMetadata);
    }

    // state functions

    function setVariableMetadata(bytes memory variableMetadata) public {
        // only operator
        require(Operated.isOperator(msg.sender), "only operator");

        // set metadata in storage
        Metadata._setVariableMetadata(variableMetadata);
    }

    // view functions

    function getProofHash() public view returns (bytes memory proofHash) {
        proofHash = MultiHashWrapper._combineMultiHash(_proofHash);
    }

}




contract Post_Factory is Factory {

    constructor(address instanceRegistry) public {
        // deploy template contract
        address templateContract = address(new Post());

        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Post')));

        // set initABI
        string memory initABI = '(bytes4,bytes,bytes,bytes)';

        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initABI);
    }

    event ExplicitInitData(address operator,bytes proofHash, bytes staticMetadata, bytes variableMetadata);

    function createExplicit(
        address operator,
        bytes memory proofHash,
        bytes memory staticMetadata,
        bytes memory variableMetadata
    ) public returns (address instance) {
        // declare template in memory
        Post template;

        // construct the data payload used when initializing the new contract.
        bytes memory initData = abi.encodeWithSelector(
            template.initialize.selector, // selector
            operator,
            proofHash,
            staticMetadata,
            variableMetadata
        );

        // deploy instance
        instance = Factory.create(initData);

        // emit event
        emit ExplicitInitData(operator, proofHash, staticMetadata, variableMetadata);
    }

}






contract Feed is Operated, Metadata {

    address[] private _posts;
    address private _postRegistry;

    event PostCreated(address post, address postFactory, bytes initData);

    function initialize(
        address operator,
        address postRegistry,
        bytes memory feedStaticMetadata
    ) public {
        // only allow function to be delegatecalled from within a constructor.
        assembly { if extcodesize(address) { revert(0, 0) } }

        // set operator
        Operated._setOperator(operator);
        Operated._activate();

        // set post registry
        _postRegistry = postRegistry;

        // set static metadata
        Metadata._setStaticMetadata(feedStaticMetadata);
    }

    // state functions

    function createPost(address postFactory, bytes memory initData) public returns (address post) {
        // only operator
        require(Operated.isOperator(msg.sender), "only operator");

        // validate factory is registered
        require(
            iRegistry(_postRegistry).getFactoryStatus(postFactory) == iRegistry.FactoryStatus.Registered,
            "Factory is not actively registered."
        );

        // spawn new post contract
        post = Post_Factory(postFactory).create(initData);

        // add to array of posts
        _posts.push(post);

        // emit event
        emit PostCreated(post, postFactory, initData);
    }

    function setFeedVariableMetadata(bytes memory feedVariableMetadata) public {
        // only operator
        require(Operated.isOperator(msg.sender), "only operator");

        Metadata._setVariableMetadata(feedVariableMetadata);
    }

    // view functions

    function getPosts() public view returns (address[] memory posts) {
        posts = _posts;
    }

}




contract Feed_Factory is Factory {

    constructor(address instanceRegistry) public {
        // deploy template contract
        address templateContract = address(new Feed());

        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Feed')));

        // set initABI
        string memory initABI = '(bytes4,address,address,bytes)';

        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initABI);
    }

    event ExplicitInitData(address operator, address postRegistry, bytes feedStaticMetadata);

    function createExplicit(
        address operator,
        address postRegistry,
        bytes memory feedStaticMetadata
    ) public returns (address instance) {
        // declare template in memory
        Feed template;

        // construct the data payload used when initializing the new contract.
        bytes memory initData = abi.encodeWithSelector(
            template.initialize.selector, // selector
            operator,
            postRegistry,
            feedStaticMetadata
        );

        // deploy instance
        instance = Factory.create(initData);

        // emit event
        emit ExplicitInitData(operator, postRegistry, feedStaticMetadata);
    }

}
