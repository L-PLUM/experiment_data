/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

// File: contracts\KeyStore.sol

pragma solidity ^0.5.4;

/// @title KeyStorage
/// @author Mircea Pasoi
/// @notice Library for managing an arrray of ERC 725 keys

library KeyStore {
    struct Key {
        uint256[] purposes; //e.g., MANAGEMENT_KEY = 1, EXECUTION_KEY = 2, etc.
        uint256 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc.
        bytes32 key; // for non-hex and long keys, its the Keccak256 hash of the key
    }

    struct Keys {
        mapping (bytes32 => Key) keyData;
        mapping (uint256 => bytes32[]) keysByPurpose;
        uint numKeys;
    }

    /// @dev Find a key + purpose tuple
    /// @param key Key bytes to find
    /// @param purpose Purpose to find
    /// @return `true` if key + purpose tuple if found
    function find(Keys storage self, bytes32 key, uint256 purpose)
        internal
        view
        returns (bool)
    {
        Key memory k = self.keyData[key];
        if (k.key == 0) {
            return false;
        }
        for (uint i = 0; i < k.purposes.length; i++) {
            if (k.purposes[i] == purpose) {
                return true;
            }
        }
    }

    /// @dev Add a Key
    /// @param key Key bytes to add
    /// @param purpose Purpose to add
    /// @param keyType Key type to add
    function add(Keys storage self, bytes32 key, uint256 purpose, uint256 keyType)
        internal
    {
        Key storage k = self.keyData[key];
        k.purposes.push(purpose);
        if (k.key == 0) {
            k.key = key;
            k.keyType = keyType;
        }
        self.keysByPurpose[purpose].push(key);
        self.numKeys++;
    }

    /// @dev Remove Key
    /// @param key Key bytes to remove
    /// @param purpose Purpose to remove
    /// @return Key type of the key that was removed
    function remove(Keys storage self, bytes32 key, uint256 purpose)
        internal
        returns (uint256 keyType)
    {
        keyType = self.keyData[key].keyType;

        uint256[] storage p = self.keyData[key].purposes;
        // Delete purpose from keyData
        for (uint i = 0; i < p.length; i++) {
            if (p[i] == purpose) {
                p[i] = p[p.length - 1];
                delete p[p.length - 1];
                p.length--;
                self.numKeys--;
                break;
            }
        }
        // No more purposes
        if (p.length == 0) {
            delete self.keyData[key];
        }

        // Delete key from keysByPurpose
        bytes32[] storage k = self.keysByPurpose[purpose];
        for (uint i = 0; i < k.length; i++) {
            if (k[i] == key) {
                k[i] = k[k.length - 1];
                delete k[k.length - 1];
                k.length--;
            }
        }
    }
}

// File: contracts\KeyBase.sol

pragma solidity ^0.5.4;


/// @title KeyBase
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC725 implementation
/// @dev Key data is stored using KeyStore library

contract KeyBase {
    uint256 public constant MANAGEMENT_KEY = 1;

    // For multi-sig
    uint256 public managementRequired = 1;
    uint256 public executionRequired = 1;

    // Key storage
    using KeyStore for KeyStore.Keys;
    KeyStore.Keys internal allKeys;

    /// @dev Number of keys managed by the contract
    /// @return Unsigned integer number of keys
    function numKeys()
        external
        view
        returns (uint)
    {
        return allKeys.numKeys;
    }

    /// @dev Convert an Ethereum address (20 bytes) to an ERC725 key (32 bytes)
    function addrToKey(address addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(addr));
    }

    /// @dev Checks if sender is either the identity contract or a MANAGEMENT_KEY
    /// @dev If the multi-sig threshold for MANAGEMENT_KEY if >1, it will throw an error
    /// @return `true` if sender is either identity contract or a MANAGEMENT_KEY
    function _managementOrSelf()
        internal
        view
        returns (bool found)
    {
        if (tx.origin == address(this)) {
            // Identity contract itself
            return true;
        }
        // Only works with 1 key threshold, otherwise need multi-sig
        require(managementRequired == 1, "management threshold >1");
        return allKeys.find(addrToKey(tx.origin), MANAGEMENT_KEY);
    }

    /// @dev Modifier that only allows keys of purpose 1, or the identity itself
    modifier onlyManagementOrSelf {
        require(_managementOrSelf(), "only management or self");
        _;
    }
}

// File: contracts\Destructible.sol

pragma solidity ^0.5.4;


/// @title Destructible
/// @author Mircea Pasoi
/// @notice Base contract that can be destroyed by MANAGEMENT_KEY or the identity itself
/// @dev Inspired by https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Destructible.sol

contract Destructible is KeyBase {
    /// @dev Transfers the current balance and terminates the contract
    /// @param _recipient All funds in contract will be sent to this recipient
    function destroyAndSend(address _recipient)
        public
        onlyManagementOrSelf
    {
        require(_recipient != address(0), "recipient must exist");
        selfdestruct(address(uint160(_recipient)));
    }
}

// File: contracts\ERC165.sol

pragma solidity ^0.5.4;

/// @title ERC165
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC165
/// @dev Based on https://github.com/ethereum/EIPs/pull/881

contract ERC165 {
    /// @dev You must not set element 0xffffffff to true
    mapping(bytes4 => bool) internal supportedInterfaces;

    /// @dev Constructor that adds ERC165 as a supported interface
    constructor() internal {
        supportedInterfaces[ERC165ID()] = true;
    }

    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return supportedInterfaces[interfaceID];
    }

    /// @dev ID for ERC165 pseudo-introspection
    /// @return ID for ERC165 interface
    // solhint-disable-next-line func-name-mixedcase
    function ERC165ID() public pure returns (bytes4) {
        return this.supportsInterface.selector;
    }
}

// File: contracts\ERC735.sol

pragma solidity ^0.5.4;


/// @title ERC735
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC735

contract ERC735 is ERC165 {
    /// @dev Constructor that adds ERC735 as a supported interface
    constructor() internal {
        supportedInterfaces[ERC735ID()] = true;
    }

    /// @dev ID for ERC165 pseudo-introspection
    /// @return ID for ERC725 interface
    // solhint-disable-next-line func-name-mixedcase
    function ERC735ID() public pure returns (bytes4) {
        return (
            this.getClaim.selector ^ this.getClaimIdsByType.selector ^
            this.addClaim.selector ^ this.removeClaim.selector
        );
    }

    // Topic
    uint256 public constant BIOMETRIC_TOPIC = 1; // you're a person and not a business
    uint256 public constant RESIDENCE_TOPIC = 2; // you have a physical address or reference point
    uint256 public constant REGISTRY_TOPIC = 3;
    uint256 public constant PROFILE_TOPIC = 4; // TODO: social media profiles, blogs, etc.
    uint256 public constant LABEL_TOPIC = 5; // TODO: real name, business name, nick name, brand name, alias, etc.

    // Scheme
    uint256 public constant ECDSA_SCHEME = 1;
    // https://medium.com/@alexberegszaszi/lets-bring-the-70s-to-ethereum-48daa16a4b51
    uint256 public constant RSA_SCHEME = 2;
    // 3 is contract verification, where the data will be call data, and the issuer a contract address to call
    uint256 public constant CONTRACT_SCHEME = 3;

    // Events
    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    // Functions
    function getClaim(bytes32 _claimId) public view returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);
    function getClaimIdsByType(uint256 _topic) public view returns(bytes32[] memory claimIds);
    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes memory _signature, bytes memory _data, string memory _uri) public returns (uint256 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}

// File: contracts\KeyGetters.sol

pragma solidity ^0.5.4;


/// @title KeyGetters
/// @author Mircea Pasoi
/// @notice Implement getter functions from ERC725 spec
/// @dev Key data is stored using KeyStore library

contract KeyGetters is KeyBase {
    /// @dev Find the key data, if held by the identity
    /// @param _key Key bytes to find
    /// @return `(purposes, keyType, key)` tuple if the key exists
    function getKey(
        bytes32 _key
    )
        public
        view
        returns(uint256[] memory purposes, uint256 keyType, bytes32 key)
    {
        KeyStore.Key memory k = allKeys.keyData[_key];
        purposes = k.purposes;
        keyType = k.keyType;
        key = k.key;
    }

    /// @dev Find if a key has is present and has the given purpose
    /// @param _key Key bytes to find
    /// @param purpose Purpose to find
    /// @return Boolean indicating whether the key exists or not
    function keyHasPurpose(
        bytes32 _key,
        uint256 purpose
    )
        public
        view
        returns(bool exists)
    {
        return allKeys.find(_key, purpose);
    }

    /// @dev Find all the keys held by this identity for a given purpose
    /// @param _purpose Purpose to find
    /// @return Array with key bytes for that purpose (empty if none)
    function getKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[] memory keys)
    {
        return allKeys.keysByPurpose[_purpose];
    }
}

// File: contracts\Pausable.sol

pragma solidity ^0.5.4;


/// @title Pausable
/// @author Mircea Pasoi
/// @notice Base contract which allows children to implement an emergency stop mechanism
/// @dev Inspired by https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol

contract Pausable is KeyBase {
    event LogPause();
    event LogUnpause();

    bool public paused = false;

    /// @dev Modifier to make a function callable only when the contract is not paused
    modifier whenNotPaused() {
        require(!paused, "contract paused");
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused
    modifier whenPaused() {
        require(paused, "contract not paused");
        _;
    }

    /// @dev called by a MANAGEMENT_KEY or the identity itself to pause, triggers stopped state
    function pause()
        public
        onlyManagementOrSelf
        whenNotPaused
    {
        paused = true;
        emit LogPause();
    }

      /// @dev called by a MANAGEMENT_KEY or the identity itself to unpause, returns to normal state
    function unpause()
        public
        onlyManagementOrSelf
        whenPaused
    {
        paused = false;
        emit LogUnpause();
    }
}

// File: contracts\ERC725.sol

pragma solidity ^0.5.4;


/// @title ERC725
/// @author Mircea Pasoi
/// @notice Abstract contract for ERC725

contract ERC725 is ERC165 {
    /// @dev Constructor that adds ERC725 as a supported interface
    constructor() internal {
        supportedInterfaces[ERC725ID()] = true;
    }

    /// @dev ID for ERC165 pseudo-introspection
    /// @return ID for ERC725 interface
    // solhint-disable-next-line func-name-mixedcase
    function ERC725ID() public pure returns (bytes4) {
        return (
            this.getKey.selector ^ this.keyHasPurpose.selector ^
            this.getKeysByPurpose.selector ^
            this.addKey.selector ^ this.removeKey.selector ^
            this.execute.selector ^ this.approve.selector ^
            this.changeKeysRequired.selector ^ this.getKeysRequired.selector
        );
    }

    // Purpose
    // 1: MANAGEMENT keys, which can manage the identity
    uint256 public constant MANAGEMENT_KEY = 1;
    // 2: EXECUTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
    uint256 public constant EXECUTION_KEY = 2;
    // 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
    uint256 public constant CLAIM_SIGNER_KEY = 3;
    // 4: ENCRYPTION keys, used to encrypt data e.g. hold in claims.
    uint256 public constant ENCRYPTION_KEY = 4;

    // KeyType
    uint256 public constant ECDSA_TYPE = 1;
    // https://medium.com/@alexberegszaszi/lets-bring-the-70s-to-ethereum-48daa16a4b51
    uint256 public constant RSA_TYPE = 2;

    // Events
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);
    event KeysRequiredChanged(uint256 indexed purpose, uint256 indexed number);
    // TODO: Extra event, not part of the standard
    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    // Functions
    function getKey(bytes32 _key) public view returns(uint256[] memory purposes, uint256 keyType, bytes32 key);
    function keyHasPurpose(bytes32 _key, uint256 purpose) public view returns(bool exists);
    function getKeysByPurpose(uint256 _purpose) public view returns(bytes32[] memory keys);
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success);
    function removeKey(bytes32 _key, uint256 _purpose) public returns (bool success);
    function changeKeysRequired(uint256 purpose, uint256 number) external;
    function getKeysRequired(uint256 purpose) external view returns(uint256);
    function execute(address _to, uint256 _value, bytes memory _data) public returns (uint256 executionId);
    function approve(uint256 _id, bool _approve) public returns (bool success);
}

// File: contracts\KeyManager.sol

pragma solidity ^0.5.4;



/// @title KeyManager
/// @author Mircea Pasoi
/// @notice Implement add/remove functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the events

contract KeyManager is Pausable, ERC725 {
    /// @dev Add key data to the identity if key + purpose tuple doesn't already exist
    /// @param _key Key bytes to add
    /// @param _purpose Purpose to add
    /// @param _keyType Key type to add
    /// @return `true` if key was added, `false` if it already exists
    function addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    )
        public
        onlyManagementOrSelf
        whenNotPaused
        returns (bool success)
    {
        if (allKeys.find(_key, _purpose)) {
            return false;
        }
        _addKey(_key, _purpose, _keyType);
        return true;
    }

    /// @dev Remove key data from the identity
    /// @param _key Key bytes to remove
    /// @param _purpose Purpose to remove
    /// @return `true` if key was found and removed, `false` if it wasn't found
    function removeKey(
        bytes32 _key,
        uint256 _purpose
    )
        public
        onlyManagementOrSelf
        whenNotPaused
        returns (bool success)
    {
        if (!allKeys.find(_key, _purpose)) {
            return false;
        }
        uint256 keyType = allKeys.remove(_key, _purpose);
        emit KeyRemoved(_key, _purpose, keyType);
        return true;
    }

    /// @dev Add key data to the identity without checking if it already exists
    /// @param _key Key bytes to add
    /// @param _purpose Purpose to add
    /// @param _keyType Key type to add
    function _addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _keyType
    )
        internal
    {
        allKeys.add(_key, _purpose, _keyType);
        emit KeyAdded(_key, _purpose, _keyType);
    }
}

// File: contracts\MultiSig.sol

pragma solidity ^0.5.4;



/// @title MultiSig
/// @author Mircea Pasoi
/// @notice Implement execute and multi-sig functions from ERC725 spec
/// @dev Key data is stored using KeyStore library. Inheriting ERC725 for the getters

contract MultiSig is Pausable, ERC725 {
    // To prevent replay attacks
    // uint256 private nonce = 1;

    // struct Execution {
    //     address to;
    //     uint256 value;
    //     bytes data;
    //     uint256 needsApprove;
    // }
    
    uint256 executionNonce;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    mapping (uint256 => Execution) public executions;
    mapping (uint256 => address[]) public approved;

    /// @dev Generate a unique ID for an execution request
    /// @param _to address being called (msg.sender)
    /// @param _value ether being sent (msg.value)
    /// @param _data ABI encoded call data (msg.data)
    function execute(address _to, uint256 _value, bytes memory _data)
        public
        returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(abi.encodePacked(tx.origin)),1) || keyHasPurpose(keccak256(abi.encodePacked(tx.origin)),2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }
    // function execute(
    //     address _to,
    //     uint256 _value,
    //     bytes memory _data
    // )
    //     public
    //     whenNotPaused
    //     returns (uint256 executionId)
    // {
    //     // TODO: Using threshold at time of execution
    //     uint threshold;
    //     if (_to == address(this)) {
    //         if (msg.sender == address(this)) {
    //             // Contract calling itself to act on itself
    //             threshold = managementRequired;
    //         } else {
    //             // Only management keys can operate on this contract
    //             require(allKeys.find(addrToKey(msg.sender), MANAGEMENT_KEY), "need management key for execute");
    //             threshold = managementRequired - 1;
    //         }
    //     } else {
    //         require(_to != address(0), "null execute to");
    //         if (msg.sender == address(this)) {
    //             // Contract calling itself to act on other address
    //             threshold = executionRequired;
    //         } else {
    //             // Execution keys can operate on other addresses
    //             require(allKeys.find(addrToKey(msg.sender), EXECUTION_KEY), "need execution key for execute");
    //             threshold = executionRequired - 1;
    //         }
    //     }

    //     // Generate id and increment nonce
    //     executionId = getExecutionId(address(this), _to, _value, _data, nonce);
    //     emit ExecutionRequested(executionId, _to, _value, _data);
    //     nonce++;

    //     Execution memory e = Execution(_to, _value, _data, threshold);
    //     if (threshold == 0) {
    //         // One approval is enough, execute directly
    //         _execute(executionId, e, false);
    //     } else {
    //         //execution[executionId] = e;
    //         execution[executionId].to = _to;
    //         execution[executionId].value = _value;
    //         execution[executionId].data = _data;
    //         execution[executionId].needsApprove = threshold;
    //         approved[executionId].push(msg.sender);
    //     }

    //     return executionId;
    // }

    /// @dev Approves an execution. If the execution is being approved multiple times,
    ///  it will throw an error. Disapproving multiple times will work i.e. not do anything.
    ///  The approval could potentially trigger an execution (if the threshold is met).
    /// @param _id Execution ID
    /// @param _approve `true` if it's an approval, `false` if it's a disapproval
    /// @return `false` if it's a disapproval and there's no previous approval from the sender OR
    ///  if it's an approval that triggered a failed execution. `true` if it's a disapproval that
    ///  undos a previous approval from the sender OR if it's an approval that succeded OR
    ///  if it's an approval that triggered a succesful execution
    function approve(uint256 _id, bool _approve)
        public
        returns (bool success)
    {
        require(keyHasPurpose(keccak256(abi.encodePacked(tx.origin)), 2), "Sender does not have action key");

        emit Approved(_id, _approve);
        bytes memory tmp;
        if (_approve == true) {
            executions[_id].approved = true;
            //string memory data = string(executions[_id].data);
            (success, tmp) = executions[_id].to.call(executions[_id].data);
            if (success) {
                executions[_id].executed = true;
                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                //return;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                //return;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }
    // function approve(uint256 _id, bool _approve)
    //     public
    //     whenNotPaused
    //     returns (bool success)
    // {
    //     require(_id != 0, "null execution ID");
    //     Execution storage e = execution[_id];
    //     // Must exist
    //     require(e.to != address(0), "null execution");

    //     // Must be approved with the right key
    //     if (e.to == address(this)) {
    //         require(allKeys.find(addrToKey(msg.sender), MANAGEMENT_KEY), "need management key for approve");
    //     } else {
    //         require(allKeys.find(addrToKey(msg.sender), EXECUTION_KEY), "need execution key for approve");
    //     }

    //     emit Approved(_id, _approve);

    //     address[] storage approvals = approved[_id];
    //     if (!_approve) {
    //         // Find in approvals
    //         for (uint i = 0; i < approvals.length; i++) {
    //             if (approvals[i] == msg.sender) {
    //                 // Undo approval
    //                 approvals[i] = approvals[approvals.length - 1];
    //                 delete approvals[approvals.length - 1];
    //                 approvals.length--;
    //                 e.needsApprove += 1;
    //                 return true;
    //             }
    //         }
    //         return false;
    //     } else {
    //         // Only approve once
    //         for (uint i = 0; i < approvals.length; i++) {
    //             require(approvals[i] != msg.sender, "already approved");
    //         }

    //         // Approve
    //         approvals.push(msg.sender);
    //         e.needsApprove -= 1;

    //         // Do we need more approvals?
    //         if (e.needsApprove == 0) {
    //             return _execute(_id, e, true);
    //         }
    //         return true;
    //     }
    // }

    /// @dev Change multi-sig threshold for key purpose
    /// @param purpose Key purpose to change
    /// @param number New threshold to change it to (will throw if 0 or larger than available keys)
    function changeKeysRequired(uint256 purpose, uint256 number)
        external
        whenNotPaused
        onlyManagementOrSelf
    {
        require(purpose == MANAGEMENT_KEY || purpose == EXECUTION_KEY, "unknown purpose");
        require(number > 0, "keys required too low");
        // Don't lock yourself out
        uint numKeys = getKeysByPurpose(purpose).length;
        require(number <= numKeys, "keys required too high");
        if (purpose == MANAGEMENT_KEY) {
            managementRequired = number;
        } else {
            executionRequired = number;
        }
        emit KeysRequiredChanged(purpose, number);
    }

    /// @dev Return multi-sig threshold for key purpose
    /// @param purpose Key purpose to change
    function getKeysRequired(uint256 purpose)
        external
        view
        returns(uint256)
    {
        require(purpose == MANAGEMENT_KEY || purpose == EXECUTION_KEY, "unknown purpose");
        if (purpose == MANAGEMENT_KEY) {
            return managementRequired;
        }
        return executionRequired;
    }

    /// @dev Generate a unique ID for an execution request
    /// @param self address of identity contract
    /// @param _to address being called (msg.sender)
    /// @param _value ether being sent (msg.value)
    /// @param _data ABI encoded call data (msg.data)
    /// @param _nonce nonce to prevent replay attacks
    /// @return Integer ID of execution request
    function getExecutionId(
        address self,
        address _to,
        uint256 _value,
        bytes memory _data,
        uint _nonce
    )
        private
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(self, _to, _value, _data, _nonce)));
    }

    /// @dev Executes an action on other contracts, or itself, or a transfer of ether
    /// @param _id Execution ID
    /// @param e Execution data
    /// @param clean `true` if the internal state should be cleaned up after the execution
    /// @return `true` if the execution succeeded, `false` otherwise
    function _execute(
        uint256 _id,
        Execution memory e,
        bool clean
    )
        private
        returns (bool)
    {
        // Must exist
        require(e.to != address(0), "null execute to");
        // Call
        // TODO: Should we also support DelegateCall and Create (new contract)?
        // solhint-disable-next-line avoid-call-value
        (bool success, ) = e.to.call.value(e.value)(e.data);
        if (!success) {
            emit ExecutionFailed(_id, e.to, e.value, e.data);
            return false;
        }
        emit Executed(_id, e.to, e.value, e.data);
        // Clean up
        if (!clean) {
            return true;
        }
        delete executions[_id];
        delete approved[_id];
        return true;
    }
}

// File: contracts\ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * (.note) This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * (.warning) `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise)
     * be too long), and then calling `toEthSignedMessageHash` on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)
     * JSON-RPC method.
     *
     * See `recover`.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts\ERC165Query.sol

pragma solidity ^0.5.4;

/// @title ERC165
/// @author @fulldecent and @jbaylina
/// @notice A library that detects which interfaces other contracts implement
/// @dev Based on https://github.com/ethereum/EIPs/pull/881

library ERC165Query {
    bytes4 constant internal INVALID_ID = 0xffffffff;
    bytes4 constant internal ERC165_ID = 0x01ffc9a7;

    /// @dev Checks if a given contract address implement a given interface using
    ///  pseudo-introspection (ERC165)
    /// @param _contract Smart contract to check
    /// @param _interfaceId Interface to check
    /// @return `true` if the contract implements both ERC165 and `_interfaceId`
    function doesContractImplementInterface(address _contract, bytes4 _interfaceId)
        internal
        view
        returns (bool)
    {
        bool success;
        bool result;

        (success, result) = noThrowCall(_contract, ERC165_ID);
        if (!success || !result) {
            return false;
        }

        (success, result) = noThrowCall(_contract, INVALID_ID);
        if (!success || result) {
            return false;
        }

        (success, result) = noThrowCall(_contract, _interfaceId);
        if (success && result) {
            return true;
        }
        return false;
    }

    /// @dev `Calls supportsInterface(_interfaceId)` on a contract without throwing an error
    /// @param _contract Smart contract to call
    /// @param _interfaceId Interface to call
    /// @return `success` is `true` if the call was successful; `result` is the result of the call
    function noThrowCall(address _contract, bytes4 _interfaceId)
        internal
        view
        returns (bool success, bool result)
    {
        bytes memory payload = abi.encodeWithSelector(ERC165_ID, _interfaceId);
        bytes memory resultData;
        // solhint-disable-next-line avoid-low-level-calls
        (success, resultData) = _contract.staticcall(payload);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            result := mload(add(resultData, 0x20))
        }
    }
}

// File: contracts\ClaimManager.sol

pragma solidity ^0.5.4;






/// @title ClaimManager
/// @author Mircea Pasoi
/// @notice Implement functions from ERC735 spec
/// @dev  Key data is stored using KeyStore library. Inheriting ERC725 for the getters

contract ClaimManager is Pausable, ERC725, ERC735 {
    using ECDSA for bytes32;
    using ERC165Query for address;

    bytes constant internal ETH_PREFIX = "\x19Ethereum Signed Message:\n32";

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + topic + data
        bytes data;
        string uri;
    }

    mapping(bytes32 => Claim) internal claims;
    mapping(uint256 => bytes32[]) internal claimsByTopic;
    uint public numClaims;

  /// @dev Requests the ADDITION or the CHANGE of a claim from an issuer.
    ///  Claims can requested to be added by anybody, including the claim holder itself (self issued).
    /// @param _topic Type of claim
    /// @param _scheme Scheme used for the signatures
    /// @param issuer Address of issuer
    /// @param _signature The actual signature
    /// @param _data The data that was signed
    /// @param _uri The location of the claim
    /// @return claimRequestId COULD be send to the approve function, to approve or reject this claim
    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes memory  _signature,
        bytes memory _data,
        string memory _uri
    )
        public
        whenNotPaused
        returns (uint256 claimRequestId)
    {
        // Check signature
        require(_validSignature(_topic, _scheme, issuer, _signature, _data), "addClaim invalid signature");
        // Check we can perform action
        bool noApproval = _managementOrSelf();

        if (!noApproval) {
            // SHOULD be approved or rejected by n of m approve calls from keys of purpose 1
            claimRequestId = this.execute(address(this), 0, msg.data);
            emit ClaimRequested(claimRequestId, _topic, _scheme, issuer, _signature, _data, _uri);
            return claimRequestId;
        }

        bytes32 claimId = getClaimId(issuer, _topic);
        if (claims[claimId].issuer == address(0)) {
            _addClaim(claimId, _topic, _scheme, issuer, _signature, _data, _uri);
        } else {
            // Existing claim
            Claim storage c = claims[claimId];
            c.scheme = _scheme;
            c.signature = _signature;
            c.data = _data;
            c.uri = _uri;
            // You can't change issuer or topic without affecting the claimId, so we
            // don't need to update those two fields
            emit ClaimChanged(claimId, _topic, _scheme, issuer, _signature, _data, _uri);
        }
    }

    /// @dev Removes a claim. Can only be removed by the claim issuer, or the claim holder itself.
    /// @param _claimId Claim ID to remove
    /// @return `true` if the claim is found and removed
    function removeClaim(bytes32 _claimId)
        public
        whenNotPaused
        onlyManagementOrSelfOrIssuer(_claimId)
        returns (bool success)
    {
        Claim memory c = claims[_claimId];
        // Must exist
        require(c.issuer != address(0), "issuer must exist");
        // Remove from mapping
        delete claims[_claimId];
        // Remove from type array
        bytes32[] storage topics = claimsByTopic[c.topic];
        for (uint i = 0; i < topics.length; i++) {
            if (topics[i] == _claimId) {
                topics[i] = topics[topics.length - 1];
                delete topics[topics.length - 1];
                topics.length--;
                break;
            }
        }
        // Decrement
        numClaims--;
        // Event
        emit ClaimRemoved(_claimId, c.topic, c.scheme, c.issuer, c.signature, c.data, c.uri);
        return true;
    }

    /// @dev Returns a claim by ID
    /// @return (topic, scheme, issuer, signature, data, uri) tuple with claim data
    function getClaim(bytes32 _claimId)
        public
        view
        returns (
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {
        Claim memory c = claims[_claimId];
        require(c.issuer != address(0), "issuer must exist");
        topic = c.topic;
        scheme = c.scheme;
        issuer = c.issuer;
        signature = c.signature;
        data = c.data;
        uri = c.uri;
    }

    /// @dev Returns claims by type
    /// @param _topic Type of claims to return
    /// @return array of claim IDs
    function getClaimIdsByType(uint256 _topic)
        public
        view
        returns(bytes32[] memory claimIds)
    {
        claimIds = claimsByTopic[_topic];
    }

    /// @dev Refresh a given claim. If no longer valid, it will remove it
    /// @param _claimId Claim ID to refresh
    /// @return `true` if claim is still valid, `false` if it was invalid and removed
    function refreshClaim(bytes32 _claimId)
        public
        whenNotPaused
        onlyManagementOrSelfOrIssuer(_claimId)
        returns (bool)
    {
        // Must exist
        Claim memory c = claims[_claimId];
        require(c.issuer != address(0), "issuer must exist");
        // Check claim is still valid
        if (!_validSignature(c.topic, c.scheme, c.issuer, c.signature, c.data)) {
            // Remove claim
            removeClaim(_claimId);
            return false;
        }

        // Return true if claim is still valid
        return true;
    }

    /// @dev Generate claim ID. Especially useful in tests
    /// @param issuer Address of issuer
    /// @param topic Claim topic
    /// @return Claim ID hash
    function getClaimId(address issuer, uint256 topic)
        public
        pure
        returns (bytes32)
    {
        // TODO: Doesn't allow multiple claims from the same issuer with the same type
        // This is particularly inconvenient for self-claims (e.g. self-claim multiple labels)
        return keccak256(abi.encodePacked(issuer, topic));
    }

    /// @dev Generate claim to sign. Especially useful in tests
    /// @param subject Address about which we're making a claim
    /// @param topic Claim topic
    /// @param data Data for the claim
    /// @return Hash to be signed by claim issuer
    function claimToSign(address subject, uint256 topic, bytes memory data)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(subject, topic, data));
    }

    /// @dev Recover address used to sign a claim
    /// @param toSign Hash to be signed, potentially generated with `claimToSign`
    /// @param signature Signature data i.e. signed hash
    /// @return address recovered from `signature` which signed the `toSign` hash
    function getSignatureAddress(bytes32 toSign, bytes memory signature)
        public
        pure
        returns (address)
    {
        return keccak256(abi.encodePacked(ETH_PREFIX, toSign)).recover(signature);
    }

    /// @dev Checks if a given claim is valid
    /// @param _topic Type of claim
    /// @param _scheme Scheme used for the signatures
    /// @param issuer Address of issuer
    /// @param _signature The actual signature
    /// @param _data The data that was signed
    /// @return `false` if the signature is invalid or if the scheme is not implemented
    function _validSignature(
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes memory _signature,
        bytes memory _data
    )
        internal
        view
        returns (bool)
    {
        if (_scheme == ECDSA_SCHEME) {
            address signedBy = getSignatureAddress(claimToSign(address(this), _topic, _data), _signature);
            if (issuer == signedBy) {
                // Issuer signed the signature
                return true;
            } else
            if (issuer == address(this)) {
                return allKeys.find(addrToKey(signedBy), CLAIM_SIGNER_KEY);
            } else {
                if (issuer.doesContractImplementInterface(ERC725ID())) {
                    // Issuer is an Identity contract
                    // It should hold the key with which the above message was signed.
                    // If the key is not present anymore, the claim SHOULD be treated as invalid.
                    return ERC725(issuer).keyHasPurpose(addrToKey(signedBy), CLAIM_SIGNER_KEY);
                }
            }
            // Invalid
            return false;
        } else {
            // Not implemented
            return false;
        }
    }

    /// @dev Modifier that only allows keys of purpose 1, the identity itself, or the issuer or the claim
    modifier onlyManagementOrSelfOrIssuer(bytes32 _claimId) {
        address issuer = claims[_claimId].issuer;
        // Must exist
        require(issuer != address(0), "issuer must exist");

        // Can perform action on claim
        // solhint-disable-next-line no-empty-blocks
        if (_managementOrSelf()) {
            // Valid
        } else
        // solhint-disable-next-line no-empty-blocks
        if (tx.origin == issuer) {
            // MUST only be done by the issuer of the claim
        } else
        if (issuer.doesContractImplementInterface(ERC725ID())) {
            // Issuer is another Identity contract, is this an execution key?
            require(ERC725(issuer).keyHasPurpose(addrToKey(tx.origin), EXECUTION_KEY), "issuer contract missing execution key");
        } else {
            // Invalid! Sender is NOT Management or Self or Issuer
            revert();
        }
        _;
    }

    /// @dev Add key data to the identity without checking if it already exists
    /// @param _claimId Claim ID
    /// @param _topic Type of claim
    /// @param _scheme Scheme used for the signatures
    /// @param issuer Address of issuer
    /// @param _signature The actual signature
    /// @param _data The data that was signed
    /// @param _uri The location of the claim
    function _addClaim(
        bytes32 _claimId,
        uint256 _topic,
        uint256 _scheme,
        address issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    )
        internal
    {
        // New claim
        claims[_claimId] = Claim(_topic, _scheme, issuer, _signature, _data, _uri);
        claimsByTopic[_topic].push(_claimId);
        numClaims++;
        emit ClaimAdded(_claimId, _topic, _scheme, issuer, _signature, _data, _uri);
    }

    /// @dev Update the URI of an existing claim without any checks
    /// @param _topic Type of claim
    /// @param issuer Address of issuer
    /// @param _uri The location of the claim
    function _updateClaimUri(
        uint256 _topic,
        address issuer,
        string memory _uri
    )
    internal
    {
        claims[getClaimId(issuer, _topic)].uri = _uri;
    }
}

// File: contracts\Identity.sol

pragma solidity ^0.5.5;

//pragma experimental ABIEncoderV2;

/// @title Identity
/// @author Mircea Pasoi
/// @notice Identity contract implementing both ERC 725 and ERC 735

contract Identity is KeyManager, MultiSig, ClaimManager, Destructible, KeyGetters {
    
    address public storageSpace;
    string public globalIdentifierNumber;
    
    constructor
    (
        string memory _globalIdentifierNumber,
        address _storageSpace,
        bytes32[] memory _keys,
        uint256[] memory _purposes,
        uint256 _managementRequired,
        uint256 _executionRequired
    )
    public {
        globalIdentifierNumber = _globalIdentifierNumber;
        storageSpace = _storageSpace;
        
        _validateKeys(_keys, _purposes);

        _addKeys(_keys, _purposes, _managementRequired, _executionRequired);

        // Supports both ERC 725 & 735
        supportedInterfaces[ERC725ID() ^ ERC735ID()] = true;
    }

    // Fallback function accepts Ether transactions
    // solhint-disable-next-line no-empty-blocks
    function () external payable {
    }

    /// @dev Validate keys are sorted and unique
    /// @param _keys Keys to start contract with, in ascending order; in case of equality, purposes must be ascending
    /// @param _purposes Key purposes (in the same order as _keys)
    function _validateKeys
    (
        bytes32[] memory _keys,
        uint256[] memory _purposes
    )
    private
    pure
    {
        // Validate keys are sorted and unique
        require(_keys.length == _purposes.length, "keys length != purposes length");
        for (uint i = 1; i < _keys.length; i++) {
            // Expect input to be in sorted order, first by keys, then by purposes
            // Sorted order guarantees (key, purpose) pairs are unique and we can use
            // _addKey insteaad of addKey (which also checks for existance)
            bytes32 prevKey = _keys[i - 1];
            require(_keys[i] > prevKey || (_keys[i] == prevKey && _purposes[i] > _purposes[i - 1]), "keys not sorted");
        }
    }

    /// @dev Add keys to contract and set multi-sig thresholds
    /// @param _keys Keys to start contract with, in ascending order; in case of equality, purposes must be ascending
    /// @param _purposes Key purposes (in the same order as _keys)
    /// @param _managementRequired Multi-sig threshold for MANAGEMENT_KEY
    /// @param _executionRequired Multi-sig threshold for EXECUTION_KEY
    function _addKeys
    (
        bytes32[] memory _keys,
        uint256[] memory _purposes,
        uint256 _managementRequired,
        uint256 _executionRequired
    )
    private
    {
        uint256 executionCount;
        uint256 managementCount;
        if (_keys.length == 0) {
            bytes32 senderKey = addrToKey(tx.origin);
            // Add key that deployed the contract for MANAGEMENT, EXECUTION, CLAIM
            _addKey(senderKey, MANAGEMENT_KEY, ECDSA_TYPE);
            _addKey(senderKey, EXECUTION_KEY, ECDSA_TYPE);
            _addKey(senderKey, CLAIM_SIGNER_KEY, ECDSA_TYPE);
            executionCount = 1;
            managementCount = 1;
        } else {
            // Add constructor keys
            for (uint i = 0; i < _keys.length; i++) {
                _addKey(_keys[i], _purposes[i], ECDSA_TYPE);
                if (_purposes[i] == MANAGEMENT_KEY) {
                    managementCount++;
                } else
                if (_purposes[i] == EXECUTION_KEY) {
                    executionCount++;
                }
            }
        }

        require(_managementRequired > 0, "management threshold too low");
        require(_managementRequired <= managementCount, "management threshold too high");
        require(_executionRequired > 0, "execution threshold too low");
        require(_executionRequired <= executionCount, "execution threshold too high");
        managementRequired = _managementRequired;
        executionRequired = _executionRequired;
    }

    /// @dev Validate claims are sorted and unique
    /// @param _issuers Claim issuers to start contract with, in ascending order; in case of equality, topics must be ascending
    /// @param _topics Claim topics (in the same order as _issuers)
    function _validateClaims
    (
        address[] memory _issuers,
        uint256[] memory _topics
    )
    private
    pure
    {
        // Validate claims are sorted and unique
        require(_issuers.length == _topics.length, "issuers length != topics length");
        for (uint i = 1; i < _issuers.length; i++) {
            // Expect input to be in sorted order, first by issuer, then by topic
            // Sorted order guarantees (issuer, topic) pairs are unique
            address prevIssuer = _issuers[i - 1];
            require(_issuers[i] != prevIssuer || (_issuers[i] == prevIssuer && _topics[i] > _topics[i - 1]), "issuers not sorted");
        }
    }

    /// @dev Add claims to contract without an URI
    /// @param _issuers Claim issuers to start contract with, in ascending order; in case of equality, topics must be ascending
    /// @param _topics Claim topics (in the same order as _issuers)
    /// @param _signatures All the initial claim signatures
    /// @param _datas All the initial claim data
    /// @param _uris All the initial claim URIs
    function _addClaims
    (
        address[] memory _issuers,
        uint256[] memory _topics,
        bytes[] memory _signatures,
        bytes[] memory _datas,
        string[] memory _uris
    )
    private
    {
        for (uint i = 0; i < _issuers.length; i++) {
            // Check signature
            require(_validSignature(
                _topics[i],
                ECDSA_SCHEME,
                _issuers[i],
                _signatures[i],
                _datas[i]
            ), "addClaims signature invalid");
            // Add claim
            _addClaim(
                getClaimId(_issuers[i], _topics[i]),
                _topics[i],
                ECDSA_SCHEME,
                _issuers[i],
                _signatures[i],
                _datas[i],
                _uris[i]
            );
        }
    }
}
