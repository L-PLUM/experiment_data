/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.4.24;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DocumentStore is Ownable {
  string public name;
  string public version = "2.2.0";

  /// A mapping of the document hash to the block number that was issued
  mapping(bytes32 => uint) documentIssued;
  /// A mapping of the hash of the claim being revoked to the revocation block number
  mapping(bytes32 => uint) documentRevoked;

  event DocumentIssued(bytes32 indexed document);
  event DocumentRevoked(
    bytes32 indexed document
  );

  constructor(
    string _name
  ) public
  {
    name = _name;
  }

  function issue(
    bytes32 document
  ) public onlyOwner onlyNotIssued(document)
  {
    documentIssued[document] = block.number;
    emit DocumentIssued(document);
  }

  function bulkIssue(
    bytes32[] documents
  ) public {
    for (uint i = 0; i < documents.length; i++) {
      issue(documents[i]);
    }
  }

  function getIssuedBlock(
    bytes32 document
  ) public onlyIssued(document) view returns (uint)
  {
    return documentIssued[document];
  }

  function isIssued(
    bytes32 document
  ) public view returns (bool)
  {
    return (documentIssued[document] != 0);
  }

  function isIssuedBefore(
    bytes32 document,
    uint blockNumber
  ) public view returns (bool)
  {
    return documentIssued[document] != 0 && documentIssued[document] <= blockNumber;
  }

  function revoke(
    bytes32 document
  ) public onlyOwner onlyNotRevoked(document) returns (bool)
  {
    documentRevoked[document] = block.number;
    emit DocumentRevoked(document);
  }

  function bulkRevoke(
    bytes32[] documents
  ) public {
    for (uint i = 0; i < documents.length; i++) {
      revoke(documents[i]);
    }
  }


  function isRevoked(
    bytes32 document
  ) public view returns (bool)
  {
    return documentRevoked[document] != 0;
  }

  function isRevokedBefore(
    bytes32 document,
    uint blockNumber
  ) public view returns (bool)
  {
    return documentRevoked[document] <= blockNumber && documentRevoked[document] != 0;
  }

  modifier onlyIssued(bytes32 document) {
    require(isIssued(document), "Error: Only issued document hashes can be revoked");
    _;
  }

  modifier onlyNotIssued(bytes32 document) {
    require(!isIssued(document), "Error: Only hashes that have not been issued can be issued");
    _;
  }

  modifier onlyNotRevoked(bytes32 claim) {
    require(!isRevoked(claim), "Error: Hash has been revoked previously");
    _;
  }
}
