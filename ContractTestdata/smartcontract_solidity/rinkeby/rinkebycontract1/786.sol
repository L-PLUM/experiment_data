/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

contract NoteRegistry {
    using NoteUtilities for bytes;

    struct Note {
        uint8 status;
        bytes5 createdOn;
        bytes5 destroyedOn;
        address owner;
    }

    uint256 public totalSupply;
    bytes32 public confidentialTotalSupply;

    struct Flags {
        bool canMint;
        bool canBurn;
        bool canConvert;
    }

    Flags public flags;
    ERC20 public linkedToken;
    ACE public ace;

    uint256 public linkedTokenScalingFactor;
    address public registryOwner;
    mapping(bytes32 => Note) public registry;
    mapping(address => mapping(bytes32 => uint256)) publicApprovals;

    constructor(
        bool _canMint,
        bool _canBurn,
        bool _canConvert,
        uint256 _linkedTokenScalingFactor,
        address _linkedToken,
        address _ace,
        address _owner
    ) public {
        flags = Flags(_canMint, _canBurn, _canConvert);
        if (_linkedToken != address(0)) {
            linkedToken = ERC20(_linkedToken);
        }
        linkedTokenScalingFactor = _linkedTokenScalingFactor;
        registryOwner = _owner;
        ace = ACE(_ace);
    }

    function mint(bytes _proofOutput, address _proofSender) public returns (bool) {
        require(msg.sender == registryOwner, "message sender is not registry owner!");
        require(flags.canMint == true, "this asset is not mintable!");
        bytes32 proofHash = _proofOutput.hashProofOutput();
        require(
            ace.validateProofByHash(1, proofHash, _proofSender) == true,
            "ACE has not validated a matching proof!"
        );
        (
            bytes memory inputNotes,
            bytes memory outputNotes,
            ,
            int256 publicValue
        ) = _proofOutput.extractProofOutput();
        require(publicValue == 0, "mint transactions cannot have a public value!");

        require(outputNotes.getLength() > 0, "mint transactions require at least one output note");
        require(inputNotes.getLength() == 1, "mint transactions can only have one input note");
        (
            ,
            bytes32 noteHash,
        ) = outputNotes.get(0).extractNote();
        require(noteHash == confidentialTotalSupply, "provided total supply note does not match!");
        (
            ,
            noteHash,
        ) = inputNotes.get(0).extractNote();

        confidentialTotalSupply = noteHash;

        for (uint i = 1; i < outputNotes.getLength(); i += 1) {
            address owner;
            (owner, noteHash, ) = outputNotes.get(i).extractNote();
            Note storage note = registry[noteHash];
            require(note.status == 0, "output note exists!");
            note.status = uint8(1);
            // AZTEC uses timestamps to measure the age of a note on timescales of days/months
            // The 900-ish seconds a miner can manipulate a timestamp should have little effect
            // solhint-disable-next-line not-rely-on-time
            note.createdOn = bytes5(now);
            note.owner = owner;
        }
    }

    function burn(bytes _proofOutput, address _proofSender) public returns (bool) {
        require(msg.sender == registryOwner, "message sender is not registry owner!");
        require(flags.canBurn == true, "this asset is not burnable!");
        bytes32 proofHash = _proofOutput.hashProofOutput();
        require(
            ace.validateProofByHash(1, proofHash, _proofSender) == true,
            "ACE has not validated a matching proof!"
        );
        (
            bytes memory inputNotes,
            bytes memory outputNotes,
            ,
            int256 publicValue
        ) = _proofOutput.extractProofOutput();
        require(publicValue == 0, "mint transactions cannot have a public value!");

        require(inputNotes.getLength() > 0, "burn transactions require at least one input note");
        require(outputNotes.getLength() == 1, "burn transactions can only have one output note");
        (
            ,
            bytes32 noteHash,
        ) = inputNotes.get(0).extractNote();
        require(noteHash == confidentialTotalSupply, "provided total supply note does not match!");
        (
            ,
            noteHash,
        ) = outputNotes.get(0).extractNote();

        confidentialTotalSupply = noteHash;

        for (uint i = 1; i < inputNotes.getLength(); i += 1) {
            address owner;
            (owner, noteHash, ) = outputNotes.get(i).extractNote();
            Note storage note = registry[noteHash];
            require(note.status == 1, "input note does not exist!");
            require(note.owner == owner, "input note owner does not match!");
            note.status = uint8(2);
            // AZTEC uses timestamps to measure the age of a note, on timescales of days/months
            // The 900-ish seconds a miner can manipulate a timestamp should have little effect
            // solhint-disable-next-line not-rely-on-time
            note.destroyedOn = bytes5(now);
        }
    }

    function updateNoteRegistry(bytes _proofOutput, uint16 _proofType, address _proofSender) public returns (bool) {
        require(msg.sender == registryOwner, "message sender is not registry owner!");
        bytes32 proofHash = _proofOutput.hashProofOutput();
        require(
            ace.validateProofByHash(_proofType, proofHash, _proofSender) == true,
            "ACE has not validated a matching proof!"
        );

        (bytes memory inputNotes,
        bytes memory outputNotes,
        address publicOwner,
        int256 publicValue) = _proofOutput.extractProofOutput();

        updateInputNotes(inputNotes);
        updateOutputNotes(outputNotes);


        if (publicValue != 0) {
            require(flags.canMint == false, "mintable assets cannot be converted into public tokens!");
            require(flags.canBurn == false, "burnable assets cannot be converted into public tokens!");
            require(flags.canConvert == true, "this asset cannot be converted into public tokens!");
            if (publicValue < 0) {
                totalSupply += uint256(-publicValue);
                require(
                    publicApprovals[publicOwner][proofHash] >= uint256(-publicValue),
                    "public owner has not validated a transfer of tokens"
                );
                publicApprovals[publicOwner][proofHash] -= uint256(-publicValue);
                require(linkedToken.transferFrom(publicOwner, this, uint256(-publicValue)), "transfer failed!");
            } else {
                totalSupply -= uint256(publicValue);
                require(linkedToken.transfer(publicOwner, uint256(publicValue)), "transfer failed!");
            }
        }

        return true;
    }

    function publicApprove(bytes32 proofHash, uint256 value) public returns (bool) {
        publicApprovals[msg.sender][proofHash] = value;
        return true;
    }

    function updateInputNotes(bytes memory inputNotes) internal {
        for (uint i = 0; i < inputNotes.getLength(); i += 1) {
            (address owner, bytes32 noteHash,) = inputNotes.get(i).extractNote();
            Note storage note = registry[noteHash];
            require(note.status == 1, "input note does not exist!");
            require(note.owner == owner, "input note owner does not match!");
            note.status = uint8(2);
            // AZTEC uses timestamps to measure the age of a note, on timescales of days/months
            // The 900-ish seconds a miner can manipulate a timestamp should have little effect
            // solhint-disable-next-line not-rely-on-time
            note.destroyedOn = bytes5(now);
        }
    }

    function updateOutputNotes(bytes memory outputNotes) internal {
        for (uint i = 0; i < outputNotes.getLength(); i += 1) {
            (address owner, bytes32 noteHash,) = outputNotes.get(i).extractNote();
            Note storage note = registry[noteHash];
            require(note.status == 0, "output note exists!");
            note.status = uint8(1);
            // AZTEC uses timestamps to measure the age of a note on timescales of days/months
            // The 900-ish seconds a miner can manipulate a timestamp should have little effect
            // solhint-disable-next-line not-rely-on-time
            note.createdOn = bytes5(now);
            note.owner = owner;
        }
    }
}

library NoteUtilities {

    function getLength(bytes memory proofOutputsOrNotes) internal pure returns (
        uint len
    ) {
        assembly {
            len := mload(add(proofOutputsOrNotes, 0x20))
        }
    }

    function get(bytes memory proofOutputsOrNotes, uint i) internal pure returns (
        bytes memory out
    ) {
        assembly {
            let base := add(add(proofOutputsOrNotes, 0x40), mul(i, 0x20))
            out := add(proofOutputsOrNotes, mload(base))
        }
    }

    function extractProofOutput(bytes memory proofOutput) internal pure returns (
        bytes memory inputNotes,
        bytes memory outputNotes,
        address publicOwner,
        int256 publicValue
    ) {
        assembly {
            inputNotes := add(proofOutput, mload(add(proofOutput, 0x20)))
            outputNotes := add(proofOutput, mload(add(proofOutput, 0x40)))
            publicOwner := mload(add(proofOutput, 0x60))
            publicValue := mload(add(proofOutput, 0x80))
        }
    }

    function extractNote(bytes memory note) internal pure returns (
            address owner,
            bytes32 noteHash,
            bytes memory metadata
        ) {
        assembly {
            owner := mload(add(note, 0x20))
            noteHash := mload(add(note, 0x40))
            metadata := add(note, 0x60)
        }
    }

    function hashProofOutput(bytes memory proofOutput) internal pure returns (
        bytes32 proofHash
    ) {
        assembly {
            let len := add(mload(proofOutput), 0x20)
            proofHash := keccak256(proofOutput, len)
        }
    }
}

/**
 * @title The AZTEC Cryptography Engine
 * @author AZTEC
 * @dev ACE validates the AZTEC protocol's family of zero-knowledge proofs, which enables
 * digital asset builders to construct fungible confidential digital assets according to the AZTEC token standard.
 **/
contract ACE {
    // the commonReferenceString contains one G1 group element and one G2 group element,
    // that are created via the AZTEC protocol's trusted setup. All zero-knowledge proofs supported
    // by ACE use the same common reference string.
    bytes32[6] private commonReferenceString;

    // TODO: add a consensus mechanism! This contract is for testing purposes only until then
    address public owner;

    // `validators` contains the validator smart contracts that validate specific proof types
    mapping(uint16 => address) public validators;

    // `balancedProofs` identifies whether a proof type satisfies a balancing relationship.
    // Proofs are split into two categories - those that prove a balancing relationship and those that don't
    //      The latter are 'utility' proofs that can be used by developers to add some requirements on top of
    //      a proof that satisfies a balancing relationship.
    //      e.g. for a given asset, one might want to only process a join-split transaction if the transaction
    //      sender can prove that the new note owners do not own > 50% of the total supply of an asset.
    //
    //      For the former category, ACE will record that a given proof has satisfied a balancing relationship in
    //      `validatedProofs`. This proof can then be queried by confidential assets without having to re-validate
    //      the proof.
    //      For example, in a bilateral swap proof - a balancing relationship is satisfied for two confidential assets.
    //      If a DApp validates this proof, it can then send transfer instructions
    //          to the relevant confidential digital assets.
    //      These assets can directly query ACE, which will attest to the cryptographic legitimacy of the
    //          transfer instruction without having to validate another zero-knowledge proof.
    mapping(uint16 => bool) public balancedProofs;
    mapping(bytes32 => bool) private validatedProofs;

    mapping(address => NoteRegistry) public noteRegistries;

    event LogSetProof(uint16 _proofType, address _validatorAddress, bool _isBalanced);
    event LogSetCommonReferenceString(bytes32[6] _commonReferenceString);

    /**
    * @dev contract constructor. Sets the owner of ACE.
    **/
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Validate an AZTEC zero-knowledge proof. ACE will issue a validation transaction to the smart contract
    *       linked to `_proofType`. The validator smart contract will have the following interface:
    *       ```
    *           function validate(
    *               bytes _proofData,
    *               address _sender,
    *               bytes32[6] _commonReferenceString
    *           ) public returns (bytes)
    *       ```
    * @param _proofType the AZTEC proof type
    * @param _sender the Ethereum address of the original transaction sender. It is explicitly assumed that
    *   an asset using ACE supplies this field correctly - if they don't their asset is vulnerable to front-running
    * Unnamed param is the AZTEC zero-knowledge proof data
    * @return a `bytes proofOutputs` variable formatted according to the Cryptography Engine standard
    */
    function validateProof(
        uint16 _proofType,
        address _sender,
        bytes
    ) external returns (
        bytes memory
    ) {
        // validate that the provided _proofType maps to a corresponding validator
        address validatorAddress = validators[_proofType];
        require(validatorAddress != address(0), "expect validator address to exist");
        assembly {
            let m := mload(0x40)
            let _proofData := add(0x04, calldataload(0x44)) // calldata location of start of `proofData`

            // manually construct validator calldata map
            mstore(add(m, 0x04), 0x100) // location in calldata of the start of `bytes _proofData` (0x100)
            mstore(add(m, 0x24), _sender)
            mstore(add(m, 0x44), sload(commonReferenceString_slot))
            mstore(add(m, 0x64), sload(add(0x01, commonReferenceString_slot)))
            mstore(add(m, 0x84), sload(add(0x02, commonReferenceString_slot)))
            mstore(add(m, 0xa4), sload(add(0x03, commonReferenceString_slot)))
            mstore(add(m, 0xc4), sload(add(0x04, commonReferenceString_slot)))
            mstore(add(m, 0xe4), sload(add(0x05, commonReferenceString_slot)))
            calldatacopy(add(m, 0x104), _proofData, add(calldataload(_proofData), 0x20))

            // call our validator smart contract, and validate the call succeeded
            
            if iszero(staticcall(gas, validatorAddress, m, add(calldataload(_proofData), 0x124), 0x00, 0x00)) {
                mstore(0x00, 400) revert(0x00, 0x20) // call failed - proof is invalid!
            }
            returndatacopy(m, 0x00, returndatasize) // copy returndata to memory
            let returnStart := m
            let proofOutputs := add(m, mload(m)) // proofOutputs points to the start of return data
            m := add(add(m, 0x20), returndatasize)
            // does this proof satisfy a balancing relationship? If it does, we need to record the proof
            mstore(0x00, _proofType) mstore(0x20, balancedProofs_slot)
            switch sload(keccak256(0x00, 0x40)) // index `balanceProofs[_profType]`
            case 1 {
                // we must iterate over each `proofOutput` and record the proof hash
                let numProofOutputs := mload(add(proofOutputs, 0x20))
                for { let i := 0 } lt(i, numProofOutputs) { i := add(i, 0x01) } {
                    // get the location in memory of `proofOutput`
                    let loc := add(proofOutputs, mload(add(add(proofOutputs, 0x40), mul(i, 0x20))))
                    let proofHash := keccak256(loc, add(mload(loc), 0x20)) // hash the proof output
                    // combine the following: proofHash, _proofType, msg.sender
                    // hashing the above creates a unique key that we can log against this proof, in `validatedProofs`
                    mstore(m, proofHash)
                    mstore(add(m, 0x20), _proofType)
                    mstore(add(m, 0x40), caller)
                    mstore(0x00, keccak256(m, 0x60)) mstore(0x20, validatedProofs_slot)
                    sstore(keccak256(0x00, 0x40), 0x01)
                }
            }
            return(returnStart, returndatasize) // return `proofOutputs` to caller
        }
    }

    /**
    * @dev Clear storage variables set when validating zero-knowledge proofs.
    *      The only address that can clear data from `validatedProofs` is the address that created the proof.
    *      Function is designed to utilize [EIP-1283](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1283.md)
    *      to reduce gas costs. It is highly likely that any storage variables set by `validateProof`
    *      are only required for the duration of a single transaction.
    *      E.g. a decentralized exchange validating a swap proof and sending transfer instructions to
    *      two confidential assets.
    *      This method allows the calling smart contract to recover most of the gas spent by setting `validatedProofs`
    * @param _proofType the AZTEC proof type
    * Unnamed param is a dynamic array of proof hashes
    */
    function clearProofByHashes(uint16 _proofType, bytes32[]) external {
        assembly {
            let m := mload(0x40)
            let proofHashes := add(0x04, calldataload(0x24))
            let length := calldataload(proofHashes)
            mstore(add(m, 0x20), _proofType)
            mstore(add(m, 0x40), caller)
            mstore(0x20, validatedProofs_slot)
            for { let i := 0 } lt(i, length) { i := add(i, 0x01) } {
                let proofHash := calldataload(add(add(proofHashes, mul(i, 0x20)), 0x20))
                switch iszero(proofHash)
                case 1 {
                    mstore(0x00, 400)
                    revert(0x00, 0x20)
                }
                mstore(m, proofHash)
                mstore(0x00, keccak256(m, 0x60))
                sstore(keccak256(0x00, 0x40), 0x00)
            }
        }
    }

    /**
    * @dev Validate a previously validated AZTEC proof via its hash
    *      This enables confidential assets to receive transfer instructions from a Dapp that
    *      has already validated an AZTEC proof that satisfies a balancing relationship.
    * @param _proofType the AZTEC proof type
    * @param _proofHash the hash of the `proofOutput` received by the asset
    * @param _sender the Ethereum address of the contract issuing the transfer instruction
    * @return a boolean that signifies whether the corresponding AZTEC proof has been validated
    */
    function validateProofByHash(
        uint16 _proofType,
        bytes32 _proofHash,
        address _sender
    ) external view returns (bool) {
        assembly {
            let m := mload(0x40)
            mstore(m, _proofHash)
            mstore(add(m, 0x20), _proofType)
            mstore(add(m, 0x40), _sender)
            mstore(0x00, keccak256(m, 0x60))
            mstore(0x20, validatedProofs_slot)
            mstore(m, sload(keccak256(0x00, 0x40)))
            return(m, 0x20)
        }
    }

    function createNoteRegistry(
        bool _canMint,
        bool _canBurn,
        bool _canConvert,
        uint256 _scalingFactor,
        address _linkedToken
    ) public returns (address) {
        require(noteRegistries[msg.sender] == NoteRegistry(0), "address already has a linked Note Registry");
        NoteRegistry registry = new NoteRegistry(
            _canMint,
            _canBurn,
            _canConvert,
            _scalingFactor,
            _linkedToken,
            this,
            this);
        noteRegistries[msg.sender] = registry;
        return address(registry);
    }

    function updateNoteRegistry(bytes _proofOutput, uint16 _proofType, address _proofSender) public returns (bool) {
        NoteRegistry registry = noteRegistries[msg.sender];
        require(registry != NoteRegistry(0), "sender does not have a linked Note Registry");
        require(registry.updateNoteRegistry(_proofOutput, _proofType, _proofSender), "update failed!");
        return true;
    }

    /**
    * @dev Set the common reference string
    *      If the trusted setup is re-run, we will need to be able to change the crs
    * @param _commonReferenceString the new commonReferenceString
    */
    function setCommonReferenceString(bytes32[6] memory _commonReferenceString) public {
        require(msg.sender == owner, "only the owner can set the common reference string!");
        commonReferenceString = _commonReferenceString;
        emit LogSetCommonReferenceString(_commonReferenceString);
    }

    /**
    * @dev Adds or modifies a proofType into the Cryptography Engine.
    *      This method links a given `_proofType` to a smart contract validator.
    * @param _proofType the AZTEC proof type
    * @param _validatorAddress the address of the smart contract validator
    * @param _isBalanced does this proof satisfy a balancing relationship?
    */
    function setProof(
        uint16 _proofType,
        address _validatorAddress,
        bool _isBalanced
    ) public {
        require(msg.sender == owner, "only the owner can set the proof type!");
        validators[_proofType] = _validatorAddress;
        balancedProofs[_proofType] = _isBalanced;
        emit LogSetProof(_proofType, _validatorAddress, _isBalanced);
    }
    
    /**
    * @dev Returns the validator address for a given proof type
    */
    function getValidatorAddress(uint16 _proofType) public view returns (address) {
        return validators[_proofType];
    }
    
    /**
    * @dev Returns the validator address for a given proof type
    */
    function getIsProofBalanced(uint16 _proofType) public view returns (bool) {
        return balancedProofs[_proofType];
    }

    /**
    * @dev Returns the common reference string.
    * we use a custom getter for `commonReferenceString` - the default getter created by making the storage
    * variable public indexes individual elements of the array, and we want to return the whole array
    */
    function getCommonReferenceString() public view returns (bytes32[6] memory) {
        return commonReferenceString;
    }
}
