/**
 *Submitted for verification at Etherscan.io on 2019-01-30
*/

pragma solidity ^0.4.24;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract TrustedIssuersRegistry is Ownable {

    //Mapping between a trusted issuer index and its corresponding identity contract address.
    mapping (uint => ClaimHolder) trustedIssuers;

    //Array stores the trusted issuer indexes
    uint[] indexes;

    event trustedIssuerAdded(uint indexed index, ClaimHolder indexed trustedIssuer);
    event trustedIssuerRemoved(uint indexed index, ClaimHolder indexed trustedIssuer);
    event trustedIssuerUpdated(uint indexed index, ClaimHolder indexed oldTrustedIssuer, ClaimHolder indexed newTrustedIssuer);

   /**
    * @notice Adds the identity contract of a trusted claim issuer corresponding
    * to the index provided.
    * Requires the index to be greater than zero.
    * Requires that an identity contract doesnt already exist corresponding to the index.
    * Only owner can
    *
    * @param _trustedIssuer The identity contract address of the trusted claim issuer.
    * @param index The desired index of the claim issuer
    */
    function addTrustedIssuer(ClaimHolder _trustedIssuer, uint index) onlyOwner public {
        require(index > 0);
        require(trustedIssuers[index]==address(0), "A trustedIssuer already exists by this name");
        require(_trustedIssuer != address(0));
        uint length = indexes.length;
        for (uint i = 0; i<length; i++) {
            require(_trustedIssuer != trustedIssuers[indexes[i]], "Issuer address already exists in another index");
        }
        trustedIssuers[index] = _trustedIssuer;
        indexes.push(index);
        emit trustedIssuerAdded(index, _trustedIssuer);
    }

   /**
    * @notice Removes the identity contract of a trusted claim issuer corresponding
    * to the index provided.
    * Requires the index to be greater than zero.
    * Requires that an identity contract exists corresponding to the index.
    * Only owner can call.
    *
    * @param index The desired index of the claim issuer to be removed.
    */
    function removeTrustedIssuer(uint index) public onlyOwner {
        require(index > 0);
        require(trustedIssuers[index]!=address(0), "No such issuer exists");
        delete trustedIssuers[index];
        emit trustedIssuerRemoved(index, trustedIssuers[index]);
        uint length = indexes.length;
        for (uint i = 0; i<length; i++) {
            if(indexes[i] == index) {
                delete indexes[i];
                indexes[i] = indexes[length-1];
                delete indexes[length-1];
                indexes.length--;
                return;
            }
        }
    }

   /**
    * @notice Function for getting all the trusted claim issuer indexes stored.
    *
    * @return array of indexes of all the trusted claim issuer indexes stored.
    */
    function getTrustedIssuers() public view returns (uint[]) {
        return indexes;
    }

   /**
    * @notice Function for getting the trusted claim issuer's
    * identity contract address corresponding to the index provided.
    * Requires the provided index to have an identity contract stored.
    * Only owner can call.
    *
    * @param index The index corresponding to which identity contract address is required.
    *
    * @return Address of the identity contract address of the trusted claim issuer.
    */
    function getTrustedIssuer(uint index) public view returns (ClaimHolder) {
        require(index > 0);
        require(trustedIssuers[index]!=address(0), "No such issuer exists");
        return trustedIssuers[index];
    }

   /**
    * @notice Updates the identity contract of a trusted claim issuer corresponding
    * to the index provided.
    * Requires the index to be greater than zero.
    * Requires that an identity contract already exists corresponding to the provided index.
    * Only owner can call.
    *
    * @param index The desired index of the claim issuer to be updated.
    * @param _newTrustedIssuer The new identity contract address of the trusted claim issuer.
    */
    function updateIssuerContract(uint index, ClaimHolder _newTrustedIssuer) public onlyOwner {
        require(index > 0);
        require(trustedIssuers[index]!=address(0), "No such issuer exists");
        uint length = indexes.length;
        for (uint i = 0; i<length; i++) {
            require(trustedIssuers[indexes[i]]!=_newTrustedIssuer,"Address already exists");
        }
        emit trustedIssuerUpdated(index, trustedIssuers[index], _newTrustedIssuer);
        trustedIssuers[index] = _newTrustedIssuer;
    }
}
contract ClaimVerifier{

    uint[] issuerIndexes;
    ClaimHolder trustedClaimHolder;
    TrustedIssuersRegistry issuersRegistry;

    event ClaimValid(ClaimHolder _identity, uint256 claimType);
    event ClaimInvalid(ClaimHolder _identity, uint256 claimType);

    function claimIsValid(ClaimHolder _identity, uint256 claimType)
    public
    constant
    returns (bool claimValid)
    {
        uint256 foundClaimType;
        uint256 scheme;
        address issuer;
        bytes memory sig;
        bytes memory data;

        issuerIndexes = issuersRegistry.getTrustedIssuers();

        for(uint i = 0; i<issuerIndexes.length; i++) {
            trustedClaimHolder = issuersRegistry.getTrustedIssuer(issuerIndexes[i]);
            // Construct claimId (identifier + claim type)
            bytes32 claimId = keccak256(trustedClaimHolder, claimType);

            // Fetch claim from user
            ( foundClaimType, scheme, issuer, sig, data, ) = _identity.getClaim(claimId);

            bytes32 dataHash = keccak256(_identity, claimType, data);
            bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", dataHash);

            // Recover address of data signer
            address recovered = getRecoveredAddress(sig, prefixedHash);

            // Take hash of recovered address
            bytes32 hashedAddr = keccak256(recovered);

            // Does the trusted identifier have they key which signed the user's claim?
            if(trustedClaimHolder.keyHasPurpose(hashedAddr, 3)) {
                emit ClaimValid(_identity, claimType);
                return true;
            }
        }
        emit ClaimInvalid(_identity, claimType);
        return false;
    }

    function getRecoveredAddress(bytes sig, bytes32 dataHash)
        public
        view
        returns (address addr)
    {
        bytes32 ra;
        bytes32 sa;
        uint8 va;

        // Check the signature length
        if (sig.length != 65) {
            return (0);
        }

        // Divide the signature in r, s and v variables
        assembly {
          ra := mload(add(sig, 32))
          sa := mload(add(sig, 64))
          va := byte(0, mload(add(sig, 96)))
        }

        if (va < 27) {
            va += 27;
        }

        address recoveredAddress = ecrecover(dataHash, va, ra, sa);

        return (recoveredAddress);
    }
}


contract ClaimTypesRegistry is Ownable{

    uint256[] claimTypes;

    event claimTypeAdded(uint256 indexed claimType);
    event claimTypeRemoved(uint256 indexed claimType);

    /**
    * @notice Add a trusted claim type (For example: KYC=1, AML=2).
    * Only owner can call.
    *
    * @param claimType The claim type index
    */
    function addClaimType(uint256 claimType) public onlyOwner{
        uint length = claimTypes.length;
        for(uint i = 0; i<length; i++){
            require(claimTypes[i]!=claimType, "claimType already exists");
        }
        claimTypes.push(claimType);
        emit claimTypeAdded(claimType);
    }
    /**
    * @notice Remove a trusted claim type (For example: KYC=1, AML=2).
    * Only owner can call.
    *
    * @param claimType The claim type index
    */

    function removeClaimType(uint256 claimType) public onlyOwner {
        uint length = claimTypes.length;
        for (uint i = 0; i<length; i++) {
            if(claimTypes[i] == claimType) {
                delete claimTypes[i];
                claimTypes[i] = claimTypes[length-1];
                delete claimTypes[length-1];
                claimTypes.length--;
                emit claimTypeRemoved(claimType);
                return;
            }
        }
    }
    /**
    * @notice Get the trusted claim types for the security token
    *
    * @return Array of trusted claim types
    */

    function getClaimTypes() public view returns (uint256[]) {
        return claimTypes;
    }
}

contract ERC725 {

    uint256 constant MANAGEMENT_KEY = 1;
    uint256 constant ACTION_KEY = 2;
    uint256 constant CLAIM_SIGNER_KEY = 3;
    uint256 constant ENCRYPTION_KEY = 4;

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);

    struct Key {
        uint256 purpose; //e.g., MANAGEMENT_KEY = 1, ACTION_KEY = 2, etc.
        uint256 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc.
        bytes32 key;
    }

    function getKey(bytes32 _key) public constant returns(uint256 purpose, uint256 keyType, bytes32 key);
    function getKeyPurpose(bytes32 _key) public constant returns(uint256 purpose);
    function getKeysByPurpose(uint256 _purpose) public constant returns(bytes32[] keys);
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success);
    function execute(address _to, uint256 _value, bytes _data) public payable returns (uint256 executionId);
    function approve(uint256 _id, bool _approve) public returns (bool success);
}


contract KeyHolder is ERC725 {

    uint256 executionNonce;

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    mapping (bytes32 => Key) keys;
    mapping (uint256 => bytes32[]) keysByPurpose;
    mapping (uint256 => Execution) executions;

    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    constructor() public {
        bytes32 _key = keccak256(msg.sender);
        keys[_key].key = _key;
        keys[_key].purpose = 1;
        keys[_key].keyType = 1;
        keysByPurpose[1].push(_key);
        emit KeyAdded(_key, keys[_key].purpose, 1);
    }

 /**
    * @notice Implementation of the getKey function from the ERC-725 standard
    *
    * @param _key The public key.  for non-hex and long keys, its the Keccak256 hash of the key
    *
    * @return Returns the full key data, if present in the identity.
    */

    function getKey(bytes32 _key)
        public
        view
        returns(uint256 purpose, uint256 keyType, bytes32 key)
    {
        return (keys[_key].purpose, keys[_key].keyType, keys[_key].key);
    }

/**
    * @notice gets the purpose of a key
    *
    * @param _key The public key.  for non-hex and long keys, its the Keccak256 hash of the key
    *
    * @return Returns the purpose of the specified key
    */

    function getKeyPurpose(bytes32 _key)
        public
        view
        returns(uint256 purpose)
    {
        return (keys[_key].purpose);
    }

/**
    * @notice gets all the keys with a specific purpose from an identity
    *
    * @param _purpose a uint256[] Array of the key types, like 1 = MANAGEMENT, 2 = ACTION, 3 = CLAIM, 4 = ENCRYPTION
    *
    * @return Returns an array of public key bytes32 hold by this identity and having the specified purpose
    */

    function getKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[] _keys)
    {
        return keysByPurpose[_purpose];
    }

/**
    * @notice implementation of the addKey function of the ERC-725 standard
    * Adds a _key to the identity. The _purpose specifies the purpose of key. Initially we propose four purposes:
    * 1: MANAGEMENT keys, which can manage the identity
    * 2: ACTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
    * 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
    * 4: ENCRYPTION keys, used to encrypt data e.g. hold in claims.
    * MUST only be done by keys of purpose 1, or the identity itself.
    * If its the identity itself, the approval process will determine its approval.
    *
    * @param _key keccak256 representation of an ethereum address
    * @param _type type of key used, which would be a uint256 for different key types. e.g. 1 = ECDSA, 2 = RSA, etc.
    * @param _purpose a uint256[] Array of the key types, like 1 = MANAGEMENT, 2 = ACTION, 3 = CLAIM, 4 = ENCRYPTION
    *
    * @return Returns TRUE if the addition was successful and FALSE if not
    */

    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        require(keys[_key].key != _key, "Key already exists"); // Key should not already exist
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(msg.sender), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        keys[_key].key = _key;
        keys[_key].purpose = _purpose;
        keys[_key].keyType = _type;

        keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }

    function approve(uint256 _id, bool _approve)
        public
        returns (bool success)
    {
        require(keyHasPurpose(keccak256(msg.sender), 2), "Sender does not have action key");

        emit Approved(_id, _approve);

        if (_approve == true) {
            executions[_id].approved = true;
            success = executions[_id].to.call.value(executions[_id].value)(executions[_id].data, 0);
            if (success) {
                executions[_id].executed = true;
                emit Executed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return;
            } else {
                emit ExecutionFailed(
                    _id,
                    executions[_id].to,
                    executions[_id].value,
                    executions[_id].data
                );
                return;
            }
        } else {
            executions[_id].approved = false;
        }
        return true;
    }

    function execute(address _to, uint256 _value, bytes _data)
        public
        payable
        returns (uint256 executionId)
    {
        require(!executions[executionNonce].executed, "Already executed");
        executions[executionNonce].to = _to;
        executions[executionNonce].value = _value;
        executions[executionNonce].data = _data;

        emit ExecutionRequested(executionNonce, _to, _value, _data);

        if (keyHasPurpose(keccak256(msg.sender),1) || keyHasPurpose(keccak256(msg.sender),2)) {
            approve(executionNonce, true);
        }

        executionNonce++;
        return executionNonce-1;
    }

    function removeKey(bytes32 _key)
        public
        returns (bool success)
    {
        require(keys[_key].key == _key, "No such key");
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(msg.sender), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }
        emit KeyRemoved(keys[_key].key, keys[_key].purpose, keys[_key].keyType);

        /* uint index;
        (index,) = keysByPurpose[keys[_key].purpose.indexOf(_key);
        keysByPurpose[keys[_key].purpose.removeByIndex(index); */

        bytes32[] keyList = keysByPurpose[keys[_key].purpose];

        for(uint i = 0; i<keyList.length; i++) {
            if(keyList[i] == _key) {
                delete keyList[i];
                keyList[i] = keyList[keyList.length-1];
                keyList.length--;
            }
        }

        delete keys[_key];

        return true;
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose)
        public
        view
        returns(bool result)
    {
        bool isThere;
        if (keys[_key].key == 0) return false;
        isThere = keys[_key].purpose <= _purpose;
        return isThere;
    }
}


contract ERC735 {

    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + claimType + data
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) public constant returns(uint256 claimType, uint256 scheme, address issuer, bytes signature, bytes data, string uri);
    function getClaimIdsByType(uint256 _claimType) public constant returns(bytes32[] claimIds);
    function addClaim(uint256 _claimType, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri) public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}


contract ClaimHolder is KeyHolder, ERC735 {

    mapping (bytes32 => Claim) claims;
    mapping (uint256 => bytes32[]) claimsByType;

 /**
    * @notice Implementation of the addClaim function from the ERC-735 standard
    *  Require that the msg.sender has claim signer key.
    *
    * @param _claimType The type of claim
    * @param _scheme The scheme with which this claim SHOULD be verified or how it should be processed.
    * @param _issuer The issuers identity contract address, or the address used to sign the above signature.
    * @param _signature Signature which is the proof that the claim issuer issued a claim of claimType for this identity.
    * it MUST be a signed message of the following structure: keccak256(address identityHolder_address, uint256 _ claimType, bytes data)
    * or keccak256(abi.encode(identityHolder_address, claimType, data))
    * @param _data The hash of the claim data, sitting in another location, a bit-mask, call data, or actual data based on the claim scheme.
    * @param _uri The location of the claim, this can be HTTP links, swarm hashes, IPFS hashes, and such.
    *
    * @return Returns claimRequestId: COULD be send to the approve function, to approve or reject this claim.
    * triggers ClaimAdded event.
    */

    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    )
        public
        returns (bytes32 claimRequestId)
    {
        bytes32 claimId = keccak256(_issuer, _claimType);

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(msg.sender), 3), "Sender does not have claim signer key");
        }

        if (claims[claimId].issuer != _issuer) {
            claimsByType[_claimType].push(claimId);
        }

        claims[claimId].claimType = _claimType;
        claims[claimId].scheme = _scheme;
        claims[claimId].issuer = _issuer;
        claims[claimId].signature = _signature;
        claims[claimId].data = _data;
        claims[claimId].uri = _uri;

        emit ClaimAdded(
            claimId,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

 /**
    * @notice Implementation of the removeClaim function from the ERC-735 standard
    * Require that the msg.sender has management key.
    * Can only be removed by the claim issuer, or the claim holder itself.
    *
    * @param _claimId The identity of the claim i.e. keccak256(address issuer_address + uint256 claimType)
    *
    * @return Returns TRUE when the claim was removed.
    * triggers ClaimRemoved event
    */

    function removeClaim(bytes32 _claimId) public returns (bool success) {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(msg.sender), 1), "Sender does not have management key");
        }

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        bytes32[] claimList = claimsByType[claims[_claimId].claimType];

        for(uint i = 0; i<claimList.length; i++) {
            if(claimList[i] == _claimId) {
                delete claimList[i];
                claimList[i] = claimList[claimList.length-1];
                claimList.length--;
            }
        }

        delete claims[_claimId];

        return true;
    }

/**
    * @notice Implementation of the getClaim function from the ERC-735 standard.
    *
    * @param _claimId The identity of the claim i.e. keccak256(address issuer_address + uint256 claimType)
    *
    * @return Returns all the parameters of the claim for the specified _claimId (claimType, scheme, signature, issuer, data, uri) .
    */

    function getClaim(bytes32 _claimId)
        public
        constant
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes signature,
            bytes data,
            string uri
        )
    {
        return (
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );
    }

/**
    * @notice Implementation of the getClaimIdsByTopic function from the ERC-735 standard.
    * used to get all the claims from the specified claimType
    *
    * @param _claimType The identity of the claim i.e. keccak256(address issuer_address + uint256 claimType)
    *
    * @return Returns an array of claim IDs by claimType.
    */

    function getClaimIdsByType(uint256 _claimType)
        public
        constant
        returns(bytes32[] claimIds)
    {
        return claimsByType[_claimType];
    }
}




contract IdentityRegistry is Ownable, ClaimVerifier {
    //mapping between a user address and the corresponding identity contract
    mapping (address => ClaimHolder) public identity;

    mapping (address => uint16) public investorCountry;

    //Array storing trusted claim types of the security token.
    uint256[] claimTypes;

    ClaimTypesRegistry typesRegistry;

    event identityRegistered(address indexed investorAddress, ClaimHolder indexed identity);
    event identityRemoved(address indexed investorAddress, ClaimHolder indexed identity);
    event identityUpdated(ClaimHolder indexed old_identity, ClaimHolder indexed new_identity);
    event countryUpdated(address indexed investorAddress, uint16 indexed country);
    event claimTypesRegistrySet(address indexed _claimTypesRegistry);
    event trustedIssuersRegistrySet(address indexed _trustedIssuersRegistry);

    constructor (
        address _trustedIssuersRegistry,
        address _claimTypesRegistry
    ) public {
        typesRegistry = ClaimTypesRegistry(_claimTypesRegistry);
        issuersRegistry = TrustedIssuersRegistry(_trustedIssuersRegistry);
    }

    /**
    * @notice Register an identity contract corresponding to a user address.
    * Requires that the user address should be the owner of the identity contract.
    * Requires that the user doesn't have an identity contract already deployed.
    * Only owner can call.
    *
    * @param _user The address of the user
    * @param _identity The address of the user's identity contract
    * @param _country The country of the investor
    */
    function registerIdentity(address _user, ClaimHolder _identity, uint16 _country) public onlyOwner {
        require(identity[_user] == address(0), "identity contract already exists, please use update");
        require(_identity != address(0), "contract address can't be a zero address");
        identity[_user] = _identity;
        investorCountry[_user] = _country;
        emit identityRegistered(_user, _identity);
    }

    /**
    * @notice Updates an identity contract corresponding to a user address.
    * Requires that the user address should be the owner of the identity contract.
    * Requires that the user should have an identity contract already deployed that will be replaced.
    * Only owner can call.
    *
    * @param _user The address of the user
    * @param _identity The address of the user's new identity contract
    */
    function updateIdentity(address _user, ClaimHolder _identity) public onlyOwner {
        require(identity[_user] != address(0));
        require(_identity != address(0), "contract address can't be a zero address");
        emit identityUpdated(identity[_user], _identity);
        identity[_user] = _identity;
    }


    /**
    * @notice Updates the country corresponding to a user address.
    * Requires that the user should have an identity contract already deployed that will be replaced.
    * Only owner can call.
    *
    * @param _user The address of the user
    * @param _country The new country of the user
    */

    function updateCountry(address _user, uint16 _country) public onlyOwner {
        require(identity[_user] != address(0));
        investorCountry[_user] = _country;
        emit countryUpdated(_user, _country);
    }

    /**
    * @notice Removes an user from the identity registry.
    * Requires that the user have an identity contract already deployed that will be deleted.
    * Only owner can call.
    *
    * @param _user The address of the user to be removed
    */
    function deleteIdentity(address _user) public onlyOwner {
        require(identity[_user] != address(0), "you haven't registered an identity yet");
        delete identity[_user];
        emit identityRemoved(_user, identity[_user]);
    }

    /**
    * @notice This functions checks whether an identity contract
    * corresponding to the provided user address has the required claims or not based
    * on the security token.
    *
    * @param _userAddress The address of the user to be verified.
    *
    * @return 'True' if the address is verified, 'false' if not.
    */
    function isVerified(address _userAddress) public view returns (bool) {
        if (identity[_userAddress]==address(0)){
            return false;
        }

        claimTypes = typesRegistry.getClaimTypes();
        uint length = claimTypes.length;

        for(uint i = 0; i<length; i++) {
            if(claimIsValid(identity[_userAddress], claimTypes[i])) {
                return true;
            }
        }
        return false;
    }

    // Registry setters
    function setClaimTypesRegistry(address _claimTypesRegistry) public onlyOwner {
        typesRegistry = ClaimTypesRegistry(_claimTypesRegistry);
        emit claimTypesRegistrySet(_claimTypesRegistry);
    }

    function setTrustedIssuerRegistry(address _trustedIssuersRegistry) public onlyOwner {
        issuersRegistry = TrustedIssuersRegistry(_trustedIssuersRegistry);
        emit trustedIssuersRegistrySet(_trustedIssuersRegistry);
    }
}
