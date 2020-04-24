/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.24;

contract EthereumDIDRegistry {

  enum Ownership { Default, Revoked, Granted }

  mapping(address => mapping(address => Ownership)) public owners;
  mapping(address => address) public reverseOwners;
  mapping(address => mapping(bytes32 => mapping(address => uint))) public delegates;
  mapping(address => uint) public changed;
  mapping(address => uint) public nonce;

  modifier onlyOwner(address identity, address actor) {
    require (isIdentityOwner(identity, actor));
    _;
  }

  event DIDOwnerChanged(
    address indexed identity,
    address newOwner,
    Ownership ownership,
    uint previousChange
  );

  event DIDDelegateChanged(
    address indexed identity,
    bytes32 delegateType,
    address delegate,
    uint validTo,
    uint previousChange
  );

  event DIDAttributeChanged(
    address indexed identity,
    bytes32 name,
    bytes value,
    uint validTo,
    uint previousChange
  );

  function getIdentity(address actor) public view returns(address) {
    address identity = reverseOwners[actor];
    if (identity != address(0)) {
        return identity;
    } else if(isIdentityOwner(actor, actor)){
        return actor;
    } else {
        return identity;
    }
  }

  function isIdentityOwner(address identity, address actor) public view returns(bool) {
    if (identity == actor && reverseOwners[actor] == address(0)) {
      return owners[identity][actor] != Ownership.Revoked;
    }
    return owners[identity][actor] == Ownership.Granted;
  }

  function checkSignature(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hash) internal returns(address) {
    address signer = ecrecover(hash, sigV, sigR, sigS);
    require(nonce[signer] == _nonce);
    require(isIdentityOwner(identity, signer));
    nonce[signer]++;
    return signer;
  }

  function validDelegate(address identity, bytes32 delegateType, address delegate) public view returns(bool) {
    uint validity = delegates[identity][keccak256(abi.encodePacked(delegateType))][delegate];
    return (validity > now);
  }

  function addOwner(address identity, address actor, address newOwner) internal onlyOwner(identity, actor) {
    require(reverseOwners[newOwner] == address(0),
      'Key cannot be assigned to two identities at the same time');
    owners[identity][newOwner] = Ownership.Granted;
    reverseOwners[newOwner] = identity;
    emit DIDOwnerChanged(identity, newOwner, Ownership.Granted, changed[identity]);
    changed[identity] = block.number;
    require(getIdentity(newOwner) == identity,
      'Key cannot be assigned to two identities at the same time');
  }

  function addOwner(address identity, address newOwner) public {
    addOwner(identity, msg.sender, newOwner);
  }

  function addOwnerSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, address newOwner) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "addOwner", newOwner));
    addOwner(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), newOwner);
  }

  function revokeOwner(address identity, address actor, address oldOwner) internal onlyOwner(identity, actor) {
    owners[identity][oldOwner] = Ownership.Revoked;
    reverseOwners[oldOwner] = address(0);
    emit DIDOwnerChanged(identity, oldOwner, Ownership.Revoked, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeOwner(address identity, address oldOwner) public {
    revokeOwner(identity, msg.sender, oldOwner);
  }

  function revokeOwnerSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, address oldOwner) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "revokeOwner", oldOwner));
    revokeOwner(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), oldOwner);
  }

  function addDelegate(address identity, address actor, bytes32 delegateType, address delegate, uint validity) internal onlyOwner(identity, actor) {
    delegates[identity][keccak256(abi.encodePacked(delegateType))][delegate] = now + validity;
    emit DIDDelegateChanged(identity, delegateType, delegate, now + validity, changed[identity]);
    changed[identity] = block.number;
  }

  function addDelegate(address identity, bytes32 delegateType, address delegate, uint validity) public {
    addDelegate(identity, msg.sender, delegateType, delegate, validity);
  }

  function addDelegateSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate, uint validity) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "addDelegate", delegateType, delegate, validity));
    addDelegate(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), delegateType, delegate, validity);
  }

  function revokeDelegate(address identity, address actor, bytes32 delegateType, address delegate) internal onlyOwner(identity, actor) {
    delegates[identity][keccak256(abi.encodePacked(delegateType))][delegate] = now;
    emit DIDDelegateChanged(identity, delegateType, delegate, now, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeDelegate(address identity, bytes32 delegateType, address delegate) public {
    revokeDelegate(identity, msg.sender, delegateType, delegate);
  }

  function revokeDelegateSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "revokeDelegate", delegateType, delegate));
    revokeDelegate(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), delegateType, delegate);
  }

  function setAttribute(address identity, address actor, bytes32 name, bytes value, uint validity ) internal onlyOwner(identity, actor) {
    emit DIDAttributeChanged(identity, name, value, now + validity, changed[identity]);
    changed[identity] = block.number;
  }

  function setAttribute(address identity, bytes32 name, bytes value, uint validity) public {
    setAttribute(identity, msg.sender, name, value, validity);
  }

  function setAttributeSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes value, uint validity) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "setAttribute", name, value, validity));
    setAttribute(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), name, value, validity);
  }

  function revokeAttribute(address identity, address actor, bytes32 name, bytes value ) internal onlyOwner(identity, actor) {
    emit DIDAttributeChanged(identity, name, value, 0, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeAttribute(address identity, bytes32 name, bytes value) public {
    revokeAttribute(identity, msg.sender, name, value);
  }

 function revokeAttributeSigned(address identity, uint256 _nonce, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes value) public {
    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), this, _nonce, identity, "revokeAttribute", name, value));
    revokeAttribute(identity, checkSignature(identity, _nonce, sigV, sigR, sigS, hash), name, value);
  }

}
