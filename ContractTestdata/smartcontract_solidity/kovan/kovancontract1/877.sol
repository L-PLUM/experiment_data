/**
 *Submitted for verification at Etherscan.io on 2018-12-19
*/

pragma solidity ^0.4.24;

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
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



contract Gaselle is Ownable {
  mapping(bytes32 => bool) public performed;

  /** OPERATION STATUSES
  * 1 - SUCCESS
  * 2 - FAILED
  * 3 - FAILED_ALREADY_PERFORMED
  * 4 - FAILED_BAD_SIGNATURE
  * 5 - FAILED_TOKEN_TRANSFER
  * 6 - FAILED_FEE_TRANSFER
  */
  event OperationStatus(bytes32 indexed operationalHash, uint8 status);

  /**
   * @dev Public function which check conditions and call `dispatchTransferFrom` function.
   * @param _fromAddress address - Address to transfer token from.
   * @param _toAddress address - Address to transfer token to.
   * @param _tokenAmount uint256 - Amount of token to transfer.
   * @param _tokenAddress address - Address of token to transfer.
   * @param _feeAmount uint256 - Amount of fee in token to transfer to owner.
   * @param _salt uint256 - Random value.
   * @param _signature bytes - fromAddress signature.
   * @return status uint8
   */
  function settleTransfer(
    address _fromAddress,
    address _toAddress,
    uint256 _tokenAmount,
    address _tokenAddress,
    uint256 _feeAmount,
    uint256 _salt,
    bytes _signature
  ) public returns (uint8 status) {
    bytes32 operationalHash = keccak256(
      abi.encodePacked(
        _fromAddress,
        _toAddress,
        _tokenAmount,
        _tokenAddress,
        _feeAmount,
        _salt
      )
    );
    if (performed[operationalHash]) {
      emit OperationStatus(operationalHash, 3);
    }
    else if (!_isSigned(operationalHash, _signature, _fromAddress)) {
      emit OperationStatus(operationalHash, 4);
    }
    else if (!_dispatchTransferFrom(_fromAddress, _toAddress, _tokenAmount, _tokenAddress)) {
      emit OperationStatus(operationalHash, 5);
    }
    else if (!_dispatchTransferFrom(_fromAddress, msg.sender, _feeAmount, _tokenAddress)) {
      emit OperationStatus(operationalHash, 6);
    }
    else {
      emit OperationStatus(operationalHash, 1);
    }
    performed[operationalHash] = true;
  }

  /**
   * @dev Internal function to convert a msgHash to an eth signed message.
   * and then recover the signature and check it against the signerAddress
   * @param _operationalHash bytes32 - Data hashed by sha3(keccak256)
   * @param _signature bytes - signerAddress signature.
   * @param _signerAddress address
   * @return bool
   */
  function _isSigned(
    bytes32 _operationalHash,
    bytes _signature,
    address _signerAddress
  ) internal pure returns (bool) {
    address signer = ECDSA.recover(
      ECDSA.toEthSignedMessageHash(_operationalHash),
      _signature);
    return signer == _signerAddress;
  }

  /**
   * @dev Forwards arguments to ERC20 token and calls `transferFrom`.
   * @param _from address - Address to transfer token from.
   * @param _to address - Address to transfer token to.
   * @param _amount uint256 - Amount of token to transfer.
   * @param _token address - ERC20 token address.
   * @return bool
   */
  function _dispatchTransferFrom(
    address _from,
    address _to,
    uint256 _amount,
    address _token
  )
  internal returns (bool)
  {
    bool transferReturnValue;
    bool didntRaise;

    // We construct calldata for the `token.transferFrom` ABI.
    // The layout of this calldata is in the table below.
    //
    // | Area     | Offset | Length  | Contents                                    |
    // | -------- |--------|---------|-------------------------------------------- |
    // | Header   | 0      | 4       | function selector                           |
    // | Params   |        | 3 * 32  | function parameters:                        |
    // |          | 4      |         |   1. from                                   |
    // |          | 36     |         |   2. to                                     |
    // |          | 68     |         |   3. amount                                 |

    assembly {
    /////// Setup State ///////
      // `cdStart` is the start of the calldata for `token.transferFrom` (equal to free memory ptr).
      let cdStart := mload(64)

    /////// Setup Header Area ///////
      // This area holds the 4-byte `transferFrom` selector.
      // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd
      mstore(cdStart, 0x23b872dd00000000000000000000000000000000000000000000000000000000)

    /////// Setup Params Area ///////
      // Each parameter is padded to 32-bytes. The entire Params Area is 128 bytes.
      mstore(add(cdStart, 4), and(_from, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(cdStart, 36), and(_to, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(cdStart, 68), _amount)

    /////// Call `token.transferFrom` using the constructed calldata ///////
      let success := call(
      50000,              // forward only 50000 gas
      _token,             // call address of token ERC20
      0,                  // don't send any ETH
      cdStart,            // pointer to start of input
      100,                // length of input
      cdStart,            // write output (transferFrom return value in bool) over input
      32                  // reserve 32 bytes for output (bool)
      )
      didntRaise := success
      transferReturnValue := cdStart
    }
    return didntRaise && transferReturnValue;
  }
}
