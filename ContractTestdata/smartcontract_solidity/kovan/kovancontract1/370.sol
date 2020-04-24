/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity 0.4.24;

// File: contracts/external/Token.sol

/*
  Abstract contract for the full ERC 20 Token standard
  https://github.com/ethereum/EIPs/issues/20
*/
contract Token {
  /* This is a slight change to the ERC20 base standard.
  function totalSupply() view returns (uint supply);
  is replaced map:
  uint public totalSupply;
  This automatically creates a getter function for the totalSupply.
  This is moved to the base contract since public getter functions are not
  currently recognised as an implementation of the matching abstract
  function by the compiler.
  */
  /// total amount of tokens
  uint public totalSupply;

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public view returns (uint balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint _value) public returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint _value) public returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public view returns (uint remaining);

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: contracts/external/MerkleProof.sol

contract MerkleProof {

  /*
   * Verifies the inclusion of a leaf in a Merkle tree using a Merkle proof.
   *
   * Based on https://github.com/ameensol/merkle-tree-solidity/src/MerkleProof.sol
   */
  function checkProof(bytes proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    if (proof.length % 32 != 0) return false; // Check if proof is made of bytes32 slices

    bytes memory elements = proof;
    bytes32 element;
    bytes32 hash = leaf;
    for (uint i = 32; i <= proof.length; i += 32) {
      assembly {
      // Load the current element of the proofOfInclusion (optimal way to get a bytes32 slice)
        element := mload(add(elements, i))
      }
      hash = keccak256(hash < element ? abi.encodePacked(hash, element) : abi.encodePacked(element, hash));
    }
    return hash == root;
  }

  // from StorJ -- https://github.com/nginnever/storj-audit-verifier/contracts/MerkleVerifyv3.sol
  function checkProofOrdered(bytes proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    if (proof.length % 32 != 0) return false; // Check if proof is made of bytes32 slices

    // use the index to determine the node ordering (index ranges 1 to n)
    bytes32 element;
    bytes32 hash = leaf;
    uint remaining;
    for (uint j = 32; j <= proof.length; j += 32) {
      assembly {
        element := mload(add(proof, j))
      }

      // calculate remaining elements in proof
      remaining = (proof.length - j + 32) / 32;

      // we don't assume that the tree is padded to a power of 2
      // if the index is odd then the proof will start with a hash at a higher layer,
      // so we have to adjust the index to be the index at that layer
      while (remaining > 0 && index % 2 == 1 && index > 2 ** remaining) {
        index = uint(index) / 2 + 1;
      }

      if (index % 2 == 0) {
        hash = keccak256(abi.encodePacked(element, hash));
        index = index / 2;
      } else {
        hash = keccak256(abi.encodePacked(hash, element));
        index = uint(index) / 2 + 1;
      }
    }
    return hash == root;
  }

  /** Verifies the inclusion of a leaf in a Merkle tree using a Merkle proof */
  function verifyIncluded(bytes proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    return checkProof(proof, root, leaf);
  }

  /** Verifies the inclusion of a leaf is at a specific place in an ordered Merkle tree using a Merkle proof */
  function verifyIncludedAtIndex(bytes proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    return checkProofOrdered(proof, root, leaf, index);
  }
}

// File: contracts/Stoppable.sol

/* using a master switch, allowing to permanently turn-off functionality */
contract Stoppable {

  /************************************ abstract **********************************/
  modifier onlyOwner { _; }
  /********************************************************************************/

  bool public isOn = true;

  modifier whenOn() { require(isOn, "must be on"); _; }
  modifier whenOff() { require(!isOn, "must be off"); _; }

  function switchOff() external onlyOwner {
    if (isOn) {
      isOn = false;
      emit Off();
    }
  }
  event Off();
}

// File: contracts/Validating.sol


// File: contracts/HasOwners.sol

contract HasOwners {
      modifier notEmpty(string text) { require(bytes(text).length != 0, "invalid empty string"); _; }
  modifier validAddress(address value) { require(value != address(0x0), "invalid address");  _; }
    address public owner; 

  constructor() public {
    owner=msg.sender;
  }

    function isOwner(address _owner) public returns(bool){
        return owner == _owner;
    }

  modifier onlyOwner { require(isOwner(msg.sender), "invalid sender; must be owner"); _; }

}

// File: contracts/Versioned.sol

contract Versioned {
  string public version;

  constructor(string _version) public {
    version = _version;
  }

}

// File: contracts/custodian/Ledger.sol

contract Ledger {

  function extractEntry(address[] addresses, uint[] uints) internal view returns (Entry result) {
    addresses[0] = address(this);  /* ledgerId */
    result.account = addresses[1];
    result.asset = addresses[2];
    result.entryType = EntryType(uints[0]);
    result.action = uints[1];
    result.timestamp = uints[2];
    result.id = uints[3];
    result.quantity = uints[4];
    result.balance = uints[5];
    result.previous = uints[6];
    result.addresses = addresses;
    result.uints = uints;
    result.hash = calculateEvmConstrainedHash(result.entryType, addresses, uints);
  }

  /**
   * the Evm hasValue a limit of psuedo 16 local variables (including parameters and return parameters).
   * on exceeding this constraint, the Solidity compiler will bail out map:
   *    'Error: Stack too deep, try removing local variables'
   * so ... we opt to calculate the hash in chunks
   */
  function calculateEvmConstrainedHash(EntryType entryType, address[] addresses, uint[] uints) internal view returns (bytes32) {
    bytes32 entryHash = calculateEntryHash(addresses, uints);
    bytes32 witnessHash = calculateWitnessHash(entryType, addresses, uints);
    return keccak256(abi.encodePacked(entryHash, witnessHash));
  }
  function calculateEntryHash(address[] addresses, uint[] uints) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[0],
        addresses[1],
        addresses[2],
        uints[0],
        uints[1],
        uints[2],
        uints[3],
        uints[4],
        uints[5],
        uints[6]
      ));
  }
  function calculateWitnessHash(EntryType entryType, address[] addresses, uint[] uints) private view returns (bytes32) {
    if (entryType == EntryType.Deposit) return calculateDepositInfoWitnessHash(uints);
    if (entryType == EntryType.Withdrawal) return calculateWithdrawalRequestWitnessHash(addresses, uints);
    if (entryType == EntryType.Trade || entryType == EntryType.Fee) return calculateMatchWitnessHash(addresses, uints);
    return keccak256(abi.encodePacked(uint(0)));
  }
  function calculateDepositInfoWitnessHash(uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        uints[offsets.uints.witness + 0],
        uints[offsets.uints.witness + 1]
      ));
  }
  function calculateWithdrawalRequestWitnessHash(address[] addresses, uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[offsets.addresses.witness + 0],
        addresses[offsets.addresses.witness + 1],
        uints[offsets.uints.witness + 0],
        uints[offsets.uints.witness + 1]
      ));
  }
  function calculateMatchWitnessHash(address[] addresses, uint[] uints) private view returns (bytes32) {
    return keccak256(abi.encodePacked(
        calculateFillHash(addresses, uints, offsets.addresses.witness, offsets.uints.witness),    // fill
        calculateOrderHash(addresses, uints, offsets.addresses.maker, offsets.uints.maker), // maker
        calculateOrderHash(addresses, uints, offsets.addresses.taker, offsets.uints.taker)  // taker
      ));
  }
  function calculateFillHash(address[] addresses, uint[] uints, uint8 addressesOffset, uint8 uintsOffset) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[addressesOffset + 0],
        uints[uintsOffset + 0],
        uints[uintsOffset + 1],
        uints[uintsOffset + 2]
      ));
  }
  function calculateOrderHash(address[] addresses, uint[] uints, uint8 addressesOffset, uint8 uintsOffset) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(
        addresses[addressesOffset + 0],
        addresses[addressesOffset + 1],
        uints[uintsOffset + 0],
        uints[uintsOffset + 1],
        uints[uintsOffset + 2],
        uints[uintsOffset + 3],
        uints[uintsOffset + 4],
        uints[uintsOffset + 5],
        uints[uintsOffset + 6]
      ));
  }

  function getDepositWitness(Entry entry) internal view returns (DepositInfo result) {
    require(entry.entryType == EntryType.Deposit, "entry must be of type Deposit");
    result.nonce = entry.uints[offsets.uints.witness + 1];
    result.designatedGblock = entry.uints[offsets.uints.witness + 1];
  }

  function getWithdrawalRequestWitness(Entry entry) internal view returns (WithdrawalRequest result) {
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    result.account = entry.addresses[offsets.addresses.witness + 0];
    result.asset = entry.addresses[offsets.addresses.witness + 1];
    result.quantity = entry.uints[offsets.uints.witness + 0];
    result.originatorTimestamp = entry.uints[offsets.uints.witness + 1];
  }

  function getMatchWitness(Entry entry) internal view returns (Match match_) {
    require(entry.entryType == EntryType.Trade || entry.entryType == EntryType.Fee, "entry must of type Trade or Fee");
    match_.fill = getFill(entry, offsets.addresses.witness, offsets.uints.witness);
    match_.maker = getOrder(entry, offsets.addresses.maker, offsets.uints.maker);
    match_.taker = getOrder(entry, offsets.addresses.taker, offsets.uints.taker);
  }

  function getFill(Entry entry, uint8 addressesOffset, uint8 uintsOffset) private pure returns (Fill result) {
    result.token = entry.addresses[addressesOffset + 0];
    result.timestamp = entry.uints[uintsOffset + 0];
    result.quantity = entry.uints[uintsOffset + 1];
    result.price = entry.uints[uintsOffset + 2];
  }

  function getOrder(Entry entry, uint8 addressesOffset, uint8 uintsOffset) private pure returns (Order result) {
    result.account = entry.addresses[addressesOffset + 0];
    result.token = entry.addresses[addressesOffset + 1];
    result.originatorTimestamp = entry.uints[uintsOffset + 0];
    result.orderType = entry.uints[uintsOffset + 1];
    result.side = entry.uints[uintsOffset + 2];
    result.quantity = entry.uints[uintsOffset + 3];
    result.price = entry.uints[uintsOffset + 4];
    result.operatorTimestamp = entry.uints[uintsOffset + 5];
    result.filled = entry.uints[uintsOffset + 6];
  }

  enum EntryType { Unknown, Origin, Deposit, Withdrawal, Exited, Trade, Fee }

  struct Entry {
    EntryType entryType;
    uint action;
    uint timestamp;
    uint id;
    address account;
    address asset;
    uint quantity;
    uint balance;
    uint previous;
    address[] addresses;
    uint[] uints;
    bytes32 hash;
  }

  struct DepositCommitmentRecord {
    address account;
    address asset;
    uint quantity;
    uint nonce;
    uint designatedGblock;
    bytes32 hash;
  }

  struct DepositInfo {
    uint nonce;
    uint designatedGblock;
  }

  struct WithdrawalRequest {
    address account;
    address asset;
    uint quantity;
    uint originatorTimestamp;
  }

  struct Match { Fill fill; Order maker; Order taker; }

  struct Fill {
    uint timestamp;
    address token;
    uint quantity;
    uint price;
  }

  struct Order {
    uint originatorTimestamp;
    uint orderType;
    address account;
    address token;
    uint side;
    uint quantity;
    uint price;
    uint operatorTimestamp;
    uint filled;
  }

  Offsets private offsets = getOffsets();
  function getOffsets() private pure returns (Offsets) {
    uint8 addressesInEntry = 3;
    uint8 uintsInEntry = 7;
    uint8 addressesInFill = 1;
    uint8 uintsInFill = 3;
    uint8 addressesInOrder = 2;
    uint8 uintsInOrder = 7;
    uint8 addressesInDeposit = 3;
    uint8 uintsInDeposit = 3;
    return Offsets({
      addresses: OffsetKind({
        deposit: addressesInDeposit,
        witness: addressesInEntry,
        maker: addressesInEntry + addressesInFill,
        taker: addressesInEntry + addressesInFill + addressesInOrder
        }),
      uints: OffsetKind({
        deposit: uintsInDeposit,
        witness: uintsInEntry,
        maker: uintsInEntry + uintsInFill,
        taker: uintsInEntry + uintsInFill + uintsInOrder
        })
      });
  }
  struct OffsetKind { uint8 deposit; uint8 witness; uint8 maker; uint8 taker; }
  struct Offsets { OffsetKind addresses; OffsetKind uints; }
}

// File: contracts/custodian/Depositing.sol

interface Depositing {

  function depositEther() external payable;

  function depositToken(address token, uint quantity) external;

  function reclaimDeposit(address[] addresses, uint[] uints, bytes32[] leaves, uint[] indexes, bytes predecessor, bytes successor) external;
}

// File: contracts/custodian/Withdrawing.sol

interface Withdrawing {

  function withdraw(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external;

  function claimExit(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external;

  function exit(bytes32 entryHash, bytes proof, bytes32 root) external;

  function exitOnHalt(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external;
}

// File: contracts/custodian/Custodian.sol

contract Custodian is Stoppable, HasOwners, MerkleProof, Ledger, Depositing, Withdrawing, Versioned {

  address public constant ETH = address(0x0);
  uint public constant confirmationDelay = 2;
  uint public constant visibilityDelay = 3;
  uint private nonceGenerator = 0;

  address public operator;
  address public registry;

  constructor(address _registry, address _operator, uint _submissionInterval, string _version)
    // HasOwners(_owners)
    Versioned(_version)
    public validAddress(_registry) validAddress(_operator)
  {
    operator = _operator;
    registry = _registry;
    submissionInterval = _submissionInterval;
  }

  function transfer(uint quantity, address asset, address account) internal {
    asset == ETH ?
      require(account.send(quantity), "failed to transfer ether") :
      require(Token(asset).transfer(account, quantity), "failed to transfer token");
  }

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes generated using web3.eth.account.sign().signature
   *
   * Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
   * TODO: Remove this library once solidity supports passing a signature to ecrecover.
   * See https://github.com/ethereum/solidity/issues/864
   */
  function recover(bytes32 hash, bytes signature) private pure returns (address) {
    bytes32 r; bytes32 s; uint8 v;
    if (signature.length != 65) return (address(0)); //Check the signature length

    // Divide the signature into r, s and v variables
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) v += 27;

    // If the version is correct return the signer address
    return (v != 27 && v != 28) ? (address(0)) : ecrecover(hash, v, r, s);
  }

  function verifySignedBy(bytes32 hash, bytes signature, address signer) internal pure {
    require(recover(hash, signature) == signer, "failed to verify signature");
  }

  /**************************************************** Depositing ****************************************************/

  mapping (bytes32 => bool) public deposits;

  modifier validToken(address value) { require(value != ETH, "value must be a valid ERC20 token address"); _; }

  function () external payable { deposit(msg.sender, ETH, msg.value); }
  function depositEther() external payable { deposit(msg.sender, ETH, msg.value); }

  // note: an account must call token.approve(custodian, quantity) beforehand
  function depositToken(address token, uint quantity) external validToken(token) {
    require(Token(token).transferFrom(msg.sender, this, quantity), "failure to transfer quantity from token");
    deposit(msg.sender, token, quantity);
  }

  function deposit(address account, address asset, uint quantity) private whenOn {
    uint nonce = ++nonceGenerator;
    uint designatedGblock = currentGblockNumber + visibilityDelay;
    DepositCommitmentRecord memory record = toDepositCommitmentRecord(account, asset, quantity, nonce, designatedGblock);
    deposits[record.hash] = true;
    emit Deposited(address(this), account, asset, quantity, nonce, designatedGblock);
  }

  function reclaimDeposit(address[] addresses, uint[] uints, bytes32[] leaves, uint[] indexes, bytes predecessor, bytes successor) external {
    ProofOfExclusionOfDeposit memory proof = extractProofOfExclusionOfDeposit(addresses, uints, leaves, indexes, predecessor, successor);
    DepositCommitmentRecord memory record = proof.excluded;
    require(currentGblockNumber > record.designatedGblock && record.designatedGblock != 0, "designated gblock is unconfirmed or unknown");

    Gblock memory designatedGblock = gblocksByNumber[record.designatedGblock];
    require(proveIsExcludedFromDeposits(designatedGblock.depositsRoot, proof), "failed to proof exclusion of deposit");

    _reclaimDeposit_(record);
  }

  function proveIsExcludedFromDeposits(bytes32 root, ProofOfExclusionOfDeposit proof) private pure returns (bool) {
    return
    proof.successor.index == proof.predecessor.index + 1 && // predecessor & successor must be consecutive
    verifyIncludedAtIndex(proof.predecessor.proof, root, proof.predecessor.leaf, proof.predecessor.index) &&
    verifyIncludedAtIndex(proof.successor.proof, root, proof.successor.leaf, proof.successor.index);
  }

  function reclaimDepositOnHalt(address asset, uint quantity, uint nonce, uint designatedGblock) external whenOff {
    DepositCommitmentRecord memory record = toDepositCommitmentRecord(msg.sender, asset, quantity, nonce, designatedGblock);
    require(record.designatedGblock >= currentGblockNumber, "designated gblock is already confirmed; use exitOnHalt instead");
    _reclaimDeposit_(record);
  }

  function _reclaimDeposit_(DepositCommitmentRecord record) private {
    require(deposits[record.hash], "unknown deposit");
    delete deposits[record.hash];
    transfer(record.quantity, record.asset, record.account);
    emit DepositReclaimed(address(this), record.account, record.asset, record.quantity, record.nonce);
  }

  function extractProofOfExclusionOfDeposit(
    address[] addresses,
    uint[] uints,
    bytes32[] leaves,
    uint[] indexes,
    bytes predecessor,
    bytes successor
  ) private view returns (ProofOfExclusionOfDeposit result) {
    result.excluded = extractDepositCommitmentRecord(addresses, uints);
    result.predecessor = ProofOfInclusionAtIndex(leaves[0], indexes[0], predecessor);
    result.successor = ProofOfInclusionAtIndex(leaves[1], indexes[1], successor);
  }

  function extractDepositCommitmentRecord(address[] addresses, uint[] uints) private view returns (DepositCommitmentRecord) {
    return toDepositCommitmentRecord(
      addresses[1],
      addresses[2],
      uints[0],
      uints[1],
      uints[2]
    );
  }

  function toDepositCommitmentRecord(
    address account,
    address asset,
    uint quantity,
    uint nonce,
    uint designatedGblock
  ) private view returns (DepositCommitmentRecord result) {
    result.account = account;
    result.asset = asset;
    result.quantity = quantity;
    result.nonce = nonce;
    result.designatedGblock = designatedGblock;
    result.hash = keccak256(abi.encodePacked(
      address(this),
      account,
      asset,
      quantity,
      nonce,
      designatedGblock
    ));
  }

  event Deposited(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce, uint designatedGblock);
  event DepositReclaimed(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce);

  struct ProofOfInclusionAtIndex { bytes32 leaf; uint index; bytes proof; }
  struct ProofOfExclusionOfDeposit { DepositCommitmentRecord excluded; ProofOfInclusionAtIndex predecessor; ProofOfInclusionAtIndex successor; }

  /**************************************************** Withdrawing ***************************************************/

  mapping (bytes32 => bool) public withdrawn;
  mapping (bytes32 => ExitClaim) public exitClaims;
  mapping (address => mapping (address => bool)) public exited; // account => asset => did-exit

  function withdraw(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    require(proveInConfirmedWithdrawals(proof, root, entry.hash), "invalid entry proof");
    require(!withdrawn[entry.hash], "entry already withdrawn");
    withdrawn[entry.hash] = true;
    transfer(entry.quantity, entry.asset, entry.account);
    emit Withdrawn(entry.hash, entry.account, entry.asset, entry.quantity);
  }

  function claimExit(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external whenOn {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry's account");
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");

    uint confirmationThreshold = currentGblockNumber + confirmationDelay;
    exitClaims[entry.hash] = ExitClaim(entry, confirmationThreshold);
    emit ExitClaimed(entry.hash, entry.account, entry.asset, entry.balance, entry.timestamp, confirmationThreshold);
  }

  function exit(bytes32 entryHash, bytes proof, bytes32 root) external {
    ExitClaim memory claim = exitClaims[entryHash];
    require(claim.confirmationThreshold != 0, "no prior claim found to withdraw");
    require(currentGblockNumber >= claim.confirmationThreshold, "balances are yet to be confirmed");
    require(
      isOn ?
        proveInConfirmedBalances(proof, root, entryHash) :
        proveInUnconfirmedBalances(proof, root, entryHash),
      "invalid balance proof");
    delete exitClaims[entryHash];
    _exit_(claim.entry);
  }

  function exitOnHalt(address[] addresses, uint[] uints, bytes signature, bytes proof, bytes32 root) external whenOff {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry's account");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");
    _exit_(entry);
  }

  function _exit_(Entry entry) private {
    require(!hasExited(entry.account, entry.asset), "previously exited");
    exited[entry.account][entry.asset] = true;
    transfer(entry.balance, entry.asset, entry.account);
    emit Exited(entry.account, entry.asset, entry.balance);
  }

  function hasExited(address account, address asset) public view returns (bool) { return exited[account][asset]; }

  function canExit(bytes32 entryHash) public view returns (bool) {
    return
      exitClaims[entryHash].confirmationThreshold != 0 &&  // exists
      currentGblockNumber >= exitClaims[entryHash].confirmationThreshold;
  }

  event ExitClaimed(bytes32 hash, address indexed account, address indexed asset, uint quantity, uint timestamp, uint confirmationThreshold);
  event Exited(address indexed account, address indexed asset, uint quantity);
  event Withdrawn(bytes32 hash, address indexed account, address indexed asset, uint quantity);

  struct ExitClaim { Entry entry; uint confirmationThreshold; }

  /**************************************************** FraudProof ****************************************************/

  uint public currentGblockNumber;
  mapping(bytes32 => Gblock) public gblocksByRoot;
  mapping(uint => Gblock) public gblocksByNumber;
  uint public submissionInterval;
  uint public submissionBlock = block.number;

  function canSubmit() public view returns (bool) { return block.number >= submissionBlock; }

  function submit(uint gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot) external whenOn {
    require(canSubmit(), "cannot submit yet");
    require(msg.sender == operator, "submitter must be the operator");
    require(gblockNumber == currentGblockNumber + 1, "gblock must be the next in sequence");
    Gblock memory gblock = Gblock(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot);
    gblocksByRoot[withdrawalsRoot] = gblock;
    gblocksByNumber[gblockNumber] = gblock;
    currentGblockNumber = gblockNumber;
    emit Submitted(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot);
  }

  function proveInConfirmedWithdrawals(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return isConfirmedGblock(root) && verifyIncluded(proof, root, entryHash);
  }

  function proveInConfirmedBalances(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return root == confirmedGblock().balancesRoot && verifyIncluded(proof, root, entryHash);
  }

  function proveInUnconfirmedBalances(bytes proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return root == unconfirmedGblock().balancesRoot && verifyIncluded(proof, root, entryHash);
  }

  function isConfirmedGblock(bytes32 root) public view returns (bool) { return includesGblock(root) && !isUnconfirmedGblock(root); }

  function isUnconfirmedGblock(bytes32 root) public view returns (bool) { return gblocksByRoot[root].gblockNumber == unconfirmedGblock().gblockNumber; }

  function includesGblock(bytes32 root) public view returns (bool) { return gblocksByRoot[root].gblockNumber != 0; }

  function confirmedGblock() private view returns (Gblock) { return getGblockWithOffsetFromCurrent(1); }

  function unconfirmedGblock() private view returns (Gblock) { return getGblockWithOffsetFromCurrent(0); }

  function getGblockWithOffsetFromCurrent(uint8 offset) private view returns (Gblock) {
    return gblocksByNumber[currentGblockNumber - offset];
  }

  event Submitted(uint gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot);

  struct Gblock { uint gblockNumber; bytes32 withdrawalsRoot; bytes32 depositsRoot; bytes32 balancesRoot; }

  /********************************************************************************************************************/
}
