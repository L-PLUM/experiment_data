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


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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



/* Deadline
 *
 * TODO:
 * - Review if isAfterDeadline() behaves correctly when _deadline not set
 */
contract Deadline {

    uint256 private _deadline;

    event DeadlineSet(uint256 deadline);

    // state functions

    function _setDeadline(uint256 deadline) internal {
        _deadline = deadline;
        emit DeadlineSet(deadline);
    }

    // view functions

    function getDeadline() public view returns (uint256 deadline) {
        deadline = _deadline;
    }

    // if the _deadline is not set yet, isAfterDeadline will return true
    // due to now - 0 = now
    function isAfterDeadline() public view returns (bool status) {
        if (_deadline == 0) {
            status = false;
        } else {
            status = (now >= _deadline);
        }
    }

}



contract iNMR {

    // ERC20
    function totalSupply() external returns (uint256);
    function balanceOf(address _owner) external returns (uint256);
    function allowance(address _owner, address _spender) external returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool ok);
    function approve(address _spender, uint256 _value) external returns (bool ok);
    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) external returns (bool ok);

    // burn
    function mint(uint256 _value) external returns (bool ok);
    // burnFrom
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);
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




/* Countdown timer
 */
contract Countdown is Deadline {

    using SafeMath for uint256;

    uint256 private _length;

    event LengthSet(uint256 length);

    // state functions

    function _setLength(uint256 length) internal {
        _length = length;
        emit LengthSet(length);
    }

    function _start() internal returns (uint256 deadline) {
        require(_length != 0, 'length not set');
        deadline = _length.add(now);
        Deadline._setDeadline(deadline);
    }

    // view functions

    function getLength() public view returns (uint256 length) {
        length = _length;
    }

    // if Deadline._setDeadline or Countdown._setLength is not called,
    // isOver will yield false
    function isOver() public view returns (bool status) {
        // when length and deadline not set,
        // countdown has not started, hence not isOver
        if (_length == 0 && Deadline.getDeadline() == 0) {
            status = false;
        } else {
            status = Deadline.isAfterDeadline();
        }
    }

    // timeRemaining will default to 0 if _setDeadline is not called
    // if the now exceeds deadline, just return 0 as the timeRemaining
    function timeRemaining() public view returns (uint256 time) {
        if (now >= Deadline.getDeadline()) {
            time = 0;
        } else {
            time = Deadline.getDeadline().sub(now);
        }
    }

}


/**
 * @title NMR token burning helper
 * @dev Allows for calling NMR burn functions using regular openzeppelin ERC20Burnable interface and revert on failure.
 */
contract BurnNMR {

    // address of the token
    address private _Token; // can be hardcoded on mainnet deployment to reduce cost

    function _setToken(address token) internal {
        // set storage
        _Token = token;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function _burn(uint256 value) internal {
        require(iNMR(_Token).mint(value), "nmr burn failed");
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance.
     * @param from address The account whose tokens will be burned.
     * @param value uint256 The amount of token to be burned.
     */
    function _burnFrom(address from, uint256 value) internal {
        require(iNMR(_Token).numeraiTransfer(from, value), "nmr burnFrom failed");
    }

    function getToken() public view returns (address token) {
        token = _Token;
    }

}





contract Staking is BurnNMR {

    using SafeMath for uint256;

    mapping (address => uint256) private _stake;

    event TokenSet(address token);
    event StakeAdded(address staker, address funder, uint256 amount, uint256 newStake);
    event StakeTaken(address staker, address recipient, uint256 amount, uint256 newStake);
    event StakeBurned(address staker, uint256 amount, uint256 newStake);

    modifier tokenMustBeSet() {
        require(BurnNMR.getToken() != address(0), "token not set yet");
        _;
    }

    // state functions

    function _setToken(address token) internal {
        // set storage
        BurnNMR._setToken(token);

        // emit event
        emit TokenSet(token);
    }

    function _addStake(address staker, address funder, uint256 currentStake, uint256 amountToAdd) internal tokenMustBeSet {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to add
        require(amountToAdd > 0, "no stake to add");

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transferFrom(funder, address(this), amountToAdd), "token transfer failed");

        // calculate new stake amount
        uint256 newStake = currentStake.add(amountToAdd);

        // set new stake to storage
        _stake[staker] = newStake;

        // emit event
        emit StakeAdded(staker, funder, amountToAdd, newStake);
    }

    function _takeStake(address staker, address recipient, uint256 currentStake, uint256 amountToTake) internal tokenMustBeSet {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to take
        require(amountToTake > 0, "no stake to take");

        // amountToTake has to be less than equal currentStake
        require(amountToTake <= currentStake, "cannot take more than currentStake");

        // transfer the stake amount
        require(IERC20(BurnNMR.getToken()).transfer(recipient, amountToTake), "token transfer failed");

        // calculate new stake amount
        uint256 newStake = currentStake.sub(amountToTake);

        // set new stake to storage
        _stake[staker] = newStake;

        // emit event
        emit StakeTaken(staker, recipient, amountToTake, newStake);
    }

    function _takeFullStake(address staker, address recipient) internal tokenMustBeSet returns (uint256 stake) {
        // get stake from storage
        stake = _stake[staker];

        // take full stake
        _takeStake(staker, recipient, stake, stake);
    }

    function _burnStake(address staker, uint256 currentStake, uint256 amountToBurn) tokenMustBeSet internal {
        // require current stake amount matches expected amount
        require(currentStake == _stake[staker], "current stake incorrect");

        // require non-zero stake to burn
        require(amountToBurn > 0, "no stake to burn");

        // amountToTake has to be less than equal currentStake
        require(amountToBurn <= currentStake, "cannot burn more than currentStake");

        // burn the stake amount
        BurnNMR._burn(amountToBurn);

        // calculate new stake amount
        uint256 newStake = currentStake.sub(amountToBurn);

        // set new stake to storage
        _stake[staker] = newStake;

        // emit event
        emit StakeBurned(staker, amountToBurn, newStake);
    }

    function _burnFullStake(address staker) internal tokenMustBeSet returns (uint256 stake) {
        // get stake from storage
        stake = _stake[staker];

        // burn full stake
        _burnStake(staker, stake, stake);
    }

    // view functions

    function getStake(address staker) public view returns (uint256 stake) {
        stake = _stake[staker];
    }

}



contract Griefing is Staking {

    enum RatioType { NaN, CgtP, CltP, CeqP, Inf }

    mapping (address => GriefRatio) private _griefRatio;
    struct GriefRatio {
        uint256 ratio;
        RatioType ratioType;
    }

    event RatioSet(address staker, uint256 ratio, RatioType ratioType);
    event Griefed(address punisher, address staker, uint256 punishment, uint256 cost, bytes message);

    // state functions

    function _setRatio(address staker, uint256 ratio, RatioType ratioType) internal {
        // set data in storage
        _griefRatio[staker].ratio = ratio;
        _griefRatio[staker].ratioType = ratioType;

        // emit event
        emit RatioSet(staker, ratio, ratioType);
    }

    function _grief(address punisher, address staker, uint256 punishment, bytes memory message) internal returns (uint256 cost) {
        require(BurnNMR.getToken() != address(0), "token not set");

        // get grief data from storage
        uint256 ratio = _griefRatio[staker].ratio;
        RatioType ratioType = _griefRatio[staker].ratioType;

        require(ratioType != RatioType.NaN, "no punishment allowed");

        // calculate cost
        // getCost also acts as a guard when _setRatio is not called before
        cost = getCost(ratio, punishment, ratioType);

        // burn the cost from the punisher's balance
        BurnNMR._burnFrom(punisher, cost);

        // get stake from storage
        uint256 currentStake = Staking.getStake(staker);

        // burn the punishment from the target's stake
        Staking._burnStake(staker, currentStake, punishment);

        // emit event
        emit Griefed(punisher, staker, punishment, cost, message);
    }

    // view functions

    function getRatio(address staker) public view returns (uint256 ratio, RatioType ratioType) {
        // get stake data from storage
        ratio = _griefRatio[staker].ratio;
        ratioType = _griefRatio[staker].ratioType;
    }

    // pure functions

    function getCost(uint256 ratio, uint256 punishment, RatioType ratioType) public pure returns(uint256 cost) {
        /*  CgtP: Cost greater than Punishment
         *  CltP: Cost less than Punishment
         *  CeqP: Cost equal to Punishment
         *  Inf:  Punishment at no cost
         *  NaN:  No Punishment */
        if (ratioType == RatioType.CgtP)
            return punishment.mul(ratio);
        if (ratioType == RatioType.CltP)
            return punishment.div(ratio);
        if (ratioType == RatioType.CeqP)
            return punishment;
        if (ratioType == RatioType.Inf)
            return 0;
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

    function getPunishment(uint256 ratio, uint256 cost, RatioType ratioType) public pure returns(uint256 punishment) {
        /*  CgtP: Cost greater than Punishment
         *  CltP: Cost less than Punishment
         *  CeqP: Cost equal to Punishment
         *  Inf:  Punishment at no cost
         *  NaN:  No Punishment */
        if (ratioType == RatioType.CgtP)
            return cost.div(ratio);
        if (ratioType == RatioType.CltP)
            return cost.mul(ratio);
        if (ratioType == RatioType.CeqP)
            return cost;
        if (ratioType == RatioType.Inf)
            revert("ratioType cannot be RatioType.Inf");
        if (ratioType == RatioType.NaN)
            revert("ratioType cannot be RatioType.NaN");
    }

}







/* Immediately engage with specific buyer
 * - Stake can be increased at any time
 * - Agreement is defined at the user level.
 * - Request to end agreement and recover stake takes 40 days to complete.
 * - No escrow of funds required.
 * - Buyer has Inf griefing.
 * - Payments are separate.
 *
 * TODO:
 * - Validate if state machine works as expected in edge cases
 *
 * NOTE:
 * - This top level contract should only perform access control and state transitions
 *
 */
contract OneWayGriefing is Countdown, Griefing, Metadata, Operated {

    using SafeMath for uint256;

    Data private _data;
    struct Data {
        address token;
        address staker;
        address counterparty;
    }

    function initialize(
        address token,
        address operator,
        address staker,
        address counterparty,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes memory staticMetadata
    ) public {
        // only allow function to be delegatecalled from within a constructor.
        assembly { if extcodesize(address) { revert(0, 0) } }

        // set storage values
        _data.token = token;
        _data.staker = staker;
        _data.counterparty = counterparty;

        // set operator
        if (operator != address(0)) {
            Operated._setOperator(operator);
            Operated._activate();
        }

        // set griefing ratio
        Griefing._setRatio(staker, ratio, ratioType);

        // set countdown length
        Countdown._setLength(countdownLength);

        // set static metadata
        Metadata._setStaticMetadata(staticMetadata);
    }

    // state functions

    function setVariableMetadata(bytes memory variableMetadata) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or operator");

        // update metadata
        Metadata._setVariableMetadata(variableMetadata);
    }

    function increaseStake(address funder, uint256 currentStake, uint256 amountToAdd) public {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or operator");

        // require agreement is not ended
        require(!Countdown.isOver(), "agreement not ended");

        // add stake
        Staking._addStake(_data.staker, funder, currentStake, amountToAdd);
    }

    function punish(address from, uint256 punishment, bytes memory message) public returns (uint256 cost) {
        // restrict access
        require(isCounterparty(msg.sender) || Operated.isActiveOperator(msg.sender), "only counterparty or operator");

        // require agreement is not ended
        require(!Countdown.isOver(), "agreement not ended");

        // execute griefing
        cost = Griefing._grief(from, _data.staker, punishment, message);
    }

    function startCountdown() public returns (uint256 deadline) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or operator");

        // require countdown is not started
        require(Deadline.getDeadline() == 0, "deadline already set");

        // start countdown
        deadline = Countdown._start();
    }

    function retrieveStake(address recipient) public returns (uint256 amount) {
        // restrict access
        require(isStaker(msg.sender) || Operated.isActiveOperator(msg.sender), "only staker or operator");

        // require deadline is passed
        require(Deadline.isAfterDeadline(),"deadline not passed");

        // retrieve stake
        amount = Staking._takeFullStake(_data.staker, recipient);
    }

    // view functions

    function isStaker(address caller) public view returns (bool validity) {
        validity = (caller == _data.staker);
    }

    function isCounterparty(address caller) public view returns (bool validity) {
        validity = (caller == _data.counterparty);
    }
}




contract OneWayGriefing_Factory is Factory {

    constructor(address instanceRegistry) public {
        // deploy template contract
        address templateContract = address(new OneWayGriefing());

        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Agreement')));

        // set initABI
        string memory initABI = '(bytes4,address,address,address,address,uint256,Griefing.RatioType,uint256,bytes)';

        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initABI);
    }

    event ExplicitInitData(address indexed staker, address indexed counterparty, uint256 ratio, Griefing.RatioType ratioType, address token, uint256 countdownLength, bytes staticMetadata);

    function createExplicit(
        address token,
        address operator,
        address staker,
        address counterparty,
        uint256 ratio,
        Griefing.RatioType ratioType,
        uint256 countdownLength,
        bytes memory staticMetadata
    ) public returns (address instance) {
        // declare template in memory
        OneWayGriefing template;

        // construct the data payload used when initializing the new contract.
        bytes memory initData = abi.encodeWithSelector(
            template.initialize.selector, // selector
            token,           // token
            operator,        // operator
            staker,          // staker
            counterparty,    // counterparty
            ratio,           // ratio
            ratioType,       // ratioType
            countdownLength, // countdownLength
            staticMetadata   // staticMetadata
        );

        // deploy instance
        instance = Factory.create(initData);

        // emit event
        emit ExplicitInitData(staker, counterparty, ratio, ratioType, token, countdownLength, staticMetadata);
    }

}
