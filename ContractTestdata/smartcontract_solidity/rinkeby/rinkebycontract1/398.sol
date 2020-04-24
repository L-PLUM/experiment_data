/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.4;

// File: /usr/src/app/blockchain_hk2019tokyo_demo/sample/erc725/contracts/ERC735.sol

contract ERC735 {

    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, address indexed issuer, uint256 signatureType, bytes32 signature, bytes claim, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer;
        bytes signature;
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) public view returns(uint256 claimType, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);
    function getClaimIdsByType(uint256 _claimType) public view returns(bytes32[] memory claimIds);
    function addClaim(uint256 _claimType, uint256 _scheme, address issuer, bytes memory _signature, bytes memory _data, string memory _uri) public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}

// File: /usr/src/app/blockchain_hk2019tokyo_demo/sample/erc725/contracts/KeyManager.sol

contract KeyManager {
    event KeySet(bytes32 indexed key, uint256 indexed purposes, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purposes, uint256 indexed keyType);

    uint256 constant MANAGEMENT_KEY = 1;
    uint256 constant EXECUTION_KEY = 2;

    uint256 constant ECDSA_TYPE = 1;
    uint256 constant RSA_TYPE = 2;

    struct Key {
        // Purposes are represented via bitmasks
        // Maximum number of purposes is 256 and must be integers that are power of 2 e.g.:
        // 1, 2, 4, 8, 16, 32, 64 ...
        // All other integers represent multiple purposes e.g:
        // Integer 3 (011) represent both 1 (001) and 2 (010) purpose
        uint256 purposes;
        uint256 keyType;
    }

    mapping (bytes32 => Key) keys;
    bool initialized;

    modifier onlyManagementKeyOrSelf() {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), MANAGEMENT_KEY), "sender-must-have-management-key");
        }
        _;
    }

    function initialize() public {
        require(!initialized, "contract-already-initialized");
        initialized = true;
        bytes32 key = keccak256(abi.encodePacked(msg.sender));
        keys[key].keyType = ECDSA_TYPE;
        keys[key].purposes = MANAGEMENT_KEY;
    }

    function getKey(bytes32 _key) public view returns (uint256 _purposes, uint256 _keyType) {
        return (keys[_key].purposes, keys[_key].keyType);
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool) {
        // Only purposes that are power of 2 are allowed e.g.:
        // 1, 2, 4, 8, 16, 32, 64 ...
        // Integers that represent multiple purposes are not allowed
        require(_purpose != 0 && (_purpose & (_purpose - uint256(1))) == 0, "purpose-must-be-power-of-2");
        return (keys[_key].purposes & _purpose) != 0;
    }

    function setKey(bytes32 _key, uint256 _purposes, uint256 _keyType) public onlyManagementKeyOrSelf {
        require(_key != 0x0, "invalid-key");
        keys[_key].purposes = _purposes;
        keys[_key].keyType = _keyType;
        emit KeySet(_key, _purposes, _keyType);
    }

    function removeKey(bytes32 _key) public onlyManagementKeyOrSelf {
        require(_key != 0x0, "invalid-key");
        Key memory key = keys[_key];
        delete keys[_key];
        emit KeyRemoved(_key, key.purposes, key.keyType);
    }
}

// File: contracts/ClaimHolder.sol

contract ClaimHolder is KeyManager, ERC735 {

    uint256 constant MANAGEMENT_EXECUTION_KEY = 3;

    mapping (bytes32 => Claim) claims;
    mapping (uint256 => bytes32[]) claimsByType;

    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    )
        public
        returns (bytes32 claimRequestId)
    {
        bytes32 claimId = keccak256(abi.encodePacked(_issuer, _claimType));

        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), MANAGEMENT_EXECUTION_KEY), "Sender does not MANAGEMENT or EXECUTION key");
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

    function removeClaim(bytes32 _claimId) public returns (bool success) {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), MANAGEMENT_KEY), "Sender does not have MANAGEMENT_KEY key");
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

        delete claims[_claimId];
        return true;
    }

    function getClaim(bytes32 _claimId)
        public
        view
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
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

    function getClaimIdsByType(uint256 _claimType)
        public
        view
        returns(bytes32[] memory claimIds)
    {
        return claimsByType[_claimType];
    }

}
