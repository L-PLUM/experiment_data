/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.2;

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
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: openzeppelin-eth/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.2;

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

// File: tabookey-gasless/contracts/IRelayHub.sol

pragma solidity ^0.5.5;

contract IRelayHub {
    // Relay management

    // Add stake to a relay and sets its unstakeDelay.
    // If the relay does not exist, it is created, and the caller
    // of this function becomes its owner. If the relay already exists, only the owner can call this function. A relay
    // cannot be its own owner.
    // All Ether in this function call will be added to the relay's stake.
    // Its unstake delay will be assigned to unstakeDelay, but the new value must be greater or equal to the current one.
    // Emits a Staked event.
    function stake(address relayaddr, uint256 unstakeDelay) external payable;

    // Emited when a relay's stake or unstakeDelay are increased, including the amount the stake was increased by.
    event Staked(address indexed relay, uint256 stake);

    // Returns a relay's owner, the account that can stake for it and remove it.
    function ownerOf(address relayaddr) external view returns (address);

    // Returns a relay's stake.
    function stakeOf(address relayaddr) external view returns (uint256);

    // Registers the caller as a relay.
    // The relay must be staked for, and not be a contract (i.e. this function must be called directly from an EOA).
    // Emits a RelayAdded event.
    // This function can be called multiple times, emitting new RelayAdded events. Note that the received transactionFee
    // is not enforced by relayCall.
    function registerRelay(uint256 transactionFee, string memory url) public;

    // Emitted when a relay is registered or re-registerd. Looking at these events (and filtering out RelayRemoved
    // events) lets a client discover the list of available relays.
    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    // Removes (deregisters) a relay. Unregistered (but staked for) relays can also be removed. Can only be called by
    // the owner of the relay. After the relay's unstakeDelay has elapsed, unstake will be callable.
    // Emits a RelayRemoved event.
    function removeRelayByOwner(address relay) public;

    // Emitted when a relay is removed (deregistered). unstakeTime is the time when unstake will be callable.
    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    // Deletes the relay from the system, and gives back its stake to the owner. Can only be called by the relay owner,
    // after unstakeDelay has elapsed since removeRelayByOwner was called.
    // Emits an Unstaked event.
    function unstake(address relay) public;

    // Emitted when a relay is unstaked for, including the returned stake.
    event Unstaked(address indexed relay, uint256 stake);

    // Balance management

    // Deposits ether for a contract, so that it can receive (and pay for) relayed transactions. Unused balance can only
    // be withdrawn by the contract itself, by callingn withdraw.
    // Emits a Deposited event.
    function depositFor(address target) public payable;

    // Emitted when depositFor is called, including the amount and account that was funded.
    event Deposited(address src, uint256 amount);

    // Returns an account's deposits. These can be either a contnract's funds, or a relay owner's revenue.
    function balanceOf(address target) external view returns (uint256);

    // Withdraws from an account's balance, sending it back to it. Relay owners call this to retrieve their revenue, and
    // contracts can also use it to reduce their funding.
    // Emits a Withdrawn event.
    function withdraw(uint256 amount) public;

    // Emitted when an account withdraws funds from RelayHub.
    event Withdrawn(address dest, uint256 amount);

    // Relaying

    // Check if the RelayHub will accept a relayed operation. Multiple things must be true for this to happen:
    //  - all arguments must be signed for by the sender (from)
    //  - the sender's nonce must be the current one
    //  - the recipient must accept this transaction (via acceptRelayedCall)
    // Returns a PreconditionCheck value (OK when the transaction can be relayed), or a recipient-specific error code if
    // it returns one in acceptRelayedCall.
    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256);

    // Preconditions for relaying, checked by canRelay and returned as the corresponding numeric values.
    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    // Relays a transaction. For this to suceed, multiple conditions must be met:
    //  - canRelay must return PreconditionCheck.OK
    //  - the sender must be a registered relay
    //  - the transaction's gas price must be larger or equal to the one that was requested by the sender
    //  - the transaction must have enough gas to not run out of gas if all internal transactions (calls to the
    // recipient) use all gas available to them
    //  - the recipient must have enough balance to pay the relay for the worst-case scenario (i.e. when all gas is
    // spent)
    //
    // If all conditions are met, the call will be relayed and the recipient charged. preRelayedCall, the encoded
    // function and postRelayedCall will be called in order.
    //
    // Arguments:
    //  - from: the client originating the request
    //  - recipient: the target IRelayRecipient contract
    //  - encodedFunction: the function call to relay, including data
    //  - transactionFee: fee (%) the relay takes over actual gas cost
    //  - gasPrice: gas price the client is willing to pay
    //  - gasLimit: gas to forward when calling the encoded function
    //  - nonce: client's nonce
    //  - signature: client's signature over all previous params, plus the relay and RelayHub addresses
    //  - approvalData: dapp-specific data forwared to acceptRelayedCall. This value is *not* verified by the Hub, but
    //    it still can be used for e.g. a signature.
    //
    // Emits a TransactionRelayed event.
    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;

    // Emitted when a transaction is relayed. Note that the actual encoded function might be reverted: this will be
    // indicated in the status field, which is a RelayCallStatus value.
    // Useful when monitoring a relay's operation and relayed calls to a contract.
    // Field chargeOrCanRelayStatus is the charge deducted from recipient's balance, paid to the relay, except when status
    // is RelayCallStatus.CanRelayFailed. In that case, this value is a PreconditionCheck value, and the recipient is not charged.
    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 status, uint256 chargeOrCanRelayStatus);

    // Status flags for the TransactionRelayed event
    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful
        CanRelayFailed,          // The transaction was not relayed due to canRelay failing
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    // Relay penalization. Any account can penalize relays, removing them from the system immediately, and rewarding the
    // reporter with half of the relay's stake. The other half is burned so that, even if the relay penalizes itself, it
    // still loses half of its stake.

    // Penalize a relay that signed two transactions using the same nonce (making only the first one valid) and
    // different data (gas price, gas limit, etc. may be different). The (unsigned) transaction data and signature for
    // both transactions must be provided.
    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;

    // Penalize a relay that sent a transaction that didn't target RelayHub's registerRelay or relayCall.
    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;

    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) view external returns (uint256);
}

// File: tabookey-gasless/contracts/IRelayRecipient.sol

pragma solidity ^0.5.5;

contract IRelayRecipient {

    /**
     * return the relayHub of this contract.
     */
    function getHubAddr() public view returns (address);

    /**
     * return the contract's balance on the RelayHub.
     * can be used to determine if the contract can pay for incoming calls,
     * before making any.
     */
    function getRecipientBalance() public view returns (uint);

    /*
     * Called by Relay (and RelayHub), to validate if this recipient accepts this call.
     * Note: Accepting this call means paying for the tx whether the relayed call reverted or not.
     *
     *  @return "0" if the the contract is willing to accept the charges from this sender, for this function call.
     *      any other value is a failure. actual value is for diagnostics only.
     *      ** Note: values below 10 are reserved by canRelay

     *  @param relay the relay that attempts to relay this function call.
     *          the contract may restrict some encoded functions to specific known relays.
     *  @param from the sender (signer) of this function call.
     *  @param encodedFunction the encoded function call (without any ethereum signature).
     *          the contract may check the method-id for valid methods
     *  @param gasPrice - the gas price for this transaction
     *  @param transactionFee - the relay compensation (in %) for this transaction
     *  @param signature - sender's signature over all parameters except approvalData
     *  @param approvalData - extra dapp-specific data (e.g. signature from trusted party)
     */
    function acceptRelayedCall(address relay, address from, bytes memory encodedFunction, uint gasPrice, uint transactionFee, bytes memory signature, bytes memory approvalData) public view returns (uint);

    /** this method is called before the actual relayed function call.
     * It may be used to charge the caller before (in conjuction with refunding him later in postRelayedCall for example).
     * the method is given all parameters of acceptRelayedCall and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function preRelayedCall(address relay, address from, bytes memory encodedFunction, uint transactionFee) public returns (bytes32);

    /** this method is called after the actual relayed function call.
     * It may be used to record the transaction (e.g. charge the caller by some contract logic) for this call.
     * the method is given all parameters of acceptRelayedCall, and also the success/failure status and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * @param success - true if the relayed call succeeded, false if it reverted
     * @param usedGas - gas used up to this point. The recipient may use this information to perform local booking and
     *   charge the sender for this call (e.g. in tokens).
     * @param preRetVal - preRelayedCall() return value passed back to the recipient
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function postRelayedCall(address relay, address from, bytes memory encodedFunction, bool success, uint usedGas, uint transactionFee, bytes32 preRetVal) public;

}

// File: @0x/contracts-utils/contracts/src/LibBytes.sol

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.5;


library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }
                    
                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }
                    
                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    /// @dev Returns a slice from a byte array without preserving the input.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The 20 byte address that was popped off.
    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Store last 20 bytes.
        result = readAddress(b, b.length - 20);

        assembly {
            // Subtract 20 from byte array length.
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return True if arrays are the same. False otherwise.
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Reads nested bytes from a specific position.
    /// @dev NOTE: the returned value overlaps with the input value.
    ///            Both should be treated as immutable.
    /// @param b Byte array containing nested bytes.
    /// @param index Index of nested bytes.
    /// @return result Nested bytes.
    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Read length of nested bytes
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        // Assert length of <b> is valid, given
        // length of nested bytes
        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        // Return a pointer to the byte array as it exists inside `b`
        assembly {
            result := add(b, index)
        }
        return result;
    }

    /// @dev Inserts bytes at a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes to insert.
    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        // Assert length of <b> is valid, given
        // length of input
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        // Copy <input> into <b>
        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.
    /// @param dest Byte array that will be overwritten with source bytes.
    /// @param source Byte array to copy onto dest bytes.
    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        // Dest length must be >= source length, or some bytes would not be copied.
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}

// File: tabookey-gasless/contracts/RelayRecipient.sol

pragma solidity ^0.5.5;

// Contract that implements the relay recipient protocol.  Inherited by Gatekeeper, or any other relay recipient.
//
// The recipient contract is responsible to:
// * pass a trusted IRelayHub singleton to the constructor.
// * Implement acceptRelayedCall, which acts as a whitelist/blacklist of senders.  It is advised that the recipient's owner will be able to update that list to remove abusers.
// * In every function that cares about the sender, use "address sender = getSender()" instead of msg.sender.  It'll return msg.sender for non-relayed transactions, or the real sender in case of relayed transactions.




contract RelayRecipient is IRelayRecipient {

    IRelayHub private relayHub; // The IRelayHub singleton which is allowed to call us

    function getHubAddr() public view returns (address) {
        return address(relayHub);
    }

    /**
     * Initialize the RelayHub of this contract.
     * Must be called at least once (e.g. from the constructor), so that the contract can accept relayed calls.
     * For ownable contracts, there should be a method to update the RelayHub, in case a new hub is deployed (since
     * the RelayHub itself is not upgradeable)
     * Otherwise, the contract might be locked on a dead hub, with no relays.
     */
    function setRelayHub(IRelayHub _rhub) internal {
        relayHub = _rhub;

        //attempt a read method, just to validate the relay is a valid RelayHub contract.
        getRecipientBalance();
    }

    function getRelayHub() internal view returns (IRelayHub) {
        return relayHub;
    }

    /**
     * return the balance of this contract.
     * Note that this method will revert on configuration error (invalid relay address)
     */
    function getRecipientBalance() public view returns (uint) {
        return getRelayHub().balanceOf(address(this));
    }

    function getSenderFromData(address origSender, bytes memory msgData) public view returns (address) {
        address sender = origSender;
        if (origSender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            sender = LibBytes.readAddress(msgData, msgData.length - 20);
        }
        return sender;
    }

    /**
     * return the sender of this call.
     * if the call came through the valid RelayHub, return the original sender.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function getSender() public view returns (address) {
        return getSenderFromData(msg.sender, msg.data);
    }

    function getMessageData() public view returns (bytes memory) {
        bytes memory origMsgData = msg.data;
        if (msg.sender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract original message data from the start of msg.data
            origMsgData = new bytes(msg.data.length - 20);
            for (uint256 i = 0; i < origMsgData.length; i++)
            {
                origMsgData[i] = msg.data[i];
            }
        }
        return origMsgData;
    }
}

// File: openzeppelin-eth/contracts/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-eth/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

    uint256[50] private ______gap;
}

// File: contracts/access/ServerRole.sol

pragma solidity ^0.5.10;





contract ServerRole is Initializable, Ownable {
    using Roles for Roles.Role;

    event ServerAdded(address indexed account);
    event ServerRemoved(address indexed account);

    Roles.Role private _servers;

    modifier onlyServer() {
        require(isServer(msg.sender), "ServerRole: caller does not have the Server role");
        _;
    }

    function addServer(address account) external onlyOwner {
        _addServer(account);
    }

    function removeServer(address account) external onlyOwner {
        _removeServer(msg.sender);
    }

    function initialize (address account, address owner) public initializer {
        Ownable.initialize(owner);
        _addServer(account);
    }

    function isServer(address account) public view returns (bool) {
        return _servers.has(account);
    }

    function _addServer(address account) internal {
        _servers.add(account);
        emit ServerAdded(account);
    }

    function _removeServer(address account) internal {
        _servers.remove(account);
        emit ServerRemoved(account);
    }
}

// File: contracts/utils/parser/BytesParserLib.sol

pragma solidity 0.5.10;


library BytesParserLib {
    function toUint(bytes memory self, uint start, uint len) public pure returns(uint res) {
        uint base = 256;
        uint mask = base**len-1;
        assembly{
            res := and(mload(add(self,add(start,len))),mask)
        }
    }

    function toInt(bytes memory self, uint start, uint len) public pure returns(int res) {
        return int(toUint(self, start, len));
    }

    function toBool(bytes memory self, uint position) public pure returns(bool) {
        if (self[position] == 0) {
            return false;
        } else {
            return true;
        }
    }

    function toBytes32(bytes memory self, uint start) public pure returns (bytes32) {
        uint res = toUint(self,start,32);
        return bytes32(res);
    }

    function slice(bytes memory self, uint start, uint length) public pure returns (bytes memory) {
        bytes memory res = new bytes(length);
        for (uint i = 0; i < length; i++) {
            res[i] = self[start+i];
        }

        return res;
    }

    function toAddress(bytes memory self, uint start) public pure returns (address) {
        uint res = toUint(self, start, 20);
        return address(res);
    }

    function toTable(bytes memory self, uint start, uint elements) public pure returns(uint[] memory) {
        uint[] memory table = new uint[](elements);
        for (uint i = 0; i < elements; i++) {
            table[i] = toUint(self, start + i * 32, 32);
        }

        return table;
    }

    function createHash(bytes memory self) public pure returns (bytes32) {
        return toEthSignedMessageHash(keccak256(self));
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/utils/parser/ReceiptParserLib.sol

pragma solidity 0.5.10;



library ReceiptParserLib {
    using BytesParserLib for bytes;

    uint public constant CHANNEL_RECEIPT_LENGTH = 149;
    uint public constant TRADE_RECEIPT_LENGTH = 277;
    uint public constant RESULT_RECEIPT_LENGTH = 245;

    struct ChannelReceipt {
        address account;
        uint channelNumber;
        uint nonce;
        int tokensRelative;
        uint fee;
        bool close;
    }

    struct TradeReceipt {
        bytes32 gameHash;
        uint beta;
        uint tokensCommited;
        uint rangeSelected;
    }

    struct ResultReceipt {
        bytes32 tradeReceiptHash;
        uint tokensWon;
        uint feePaid;
    }

    function parseChannel(bytes memory receipt) internal pure returns(ChannelReceipt memory) {
        require(
            receipt.length == CHANNEL_RECEIPT_LENGTH || receipt.length == TRADE_RECEIPT_LENGTH || receipt.length == RESULT_RECEIPT_LENGTH,
            "Receipt length has to have fixed length of 149, 277 or 245"
        );

        address account = receipt.toAddress(0);
        uint channelNumber = receipt.toUint(20, 32);
        uint nonce = receipt.toUint(52, 32);
        int tokensRelative = receipt.toInt(84, 32);
        uint fee = receipt.toUint(116, 32);
        bool close = receipt.toBool(148);

        return ChannelReceipt(
            account,
            channelNumber,
            nonce,
            tokensRelative,
            fee,
            close
        );
    }

    function parseTrade(bytes memory receipt) internal pure returns(TradeReceipt memory) {
        require(receipt.length == TRADE_RECEIPT_LENGTH, "Trade receipt has to have fixed length of 277");

        bytes32 gameHash = receipt.toBytes32(149);
        uint beta = receipt.toUint(181, 32);
        uint tokensCommited = receipt.toUint(213, 32);
        uint rangeSelected = receipt.toUint(245, 32);

        return TradeReceipt(
            gameHash,
            beta,
            tokensCommited,
            rangeSelected
        );
    }

    function parseResult(bytes memory receipt) internal pure returns(ResultReceipt memory) {
        require(receipt.length == RESULT_RECEIPT_LENGTH, "Result receipt has to have fixed length of 245");

        bytes32 tradeReceiptHash = receipt.toBytes32(149);
        uint tokensWon = receipt.toUint(181, 32);
        uint feePaid = receipt.toUint(213, 32);

        return ResultReceipt(tradeReceiptHash, tokensWon, feePaid);
    }

    function parseChannelCompatible(bytes memory receipt) public pure returns(
        address account,
        uint channelNumber,
        uint nonce,
        int tokensRelative,
        uint fee,
        bool close)
    {
        ChannelReceipt memory result = parseChannel(receipt);

        return (result.account, result.channelNumber, result.nonce, result.tokensRelative, result.fee, result.close);
    }

    function parseTradeCompatible(bytes memory receipt) public pure returns(
        bytes32 gameHash,
        uint beta,
        uint tokensCommited,
        uint rangeSelected)
    {
        TradeReceipt memory result = parseTrade(receipt);

        return(result.gameHash, result.beta, result.tokensCommited, result.rangeSelected);
    }

    function parseResultCompatible(bytes memory receipt) public pure returns(
        bytes32 tradeReceiptHash,
        uint tokensWon,
        uint feePaid)
    {
        ResultReceipt memory result = parseResult(receipt);

        return (result.tradeReceiptHash, result.tokensWon, result.feePaid);
    }
}

// File: openzeppelin-eth/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
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
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-eth/contracts/drafts/SignedSafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error
 */
library SignedSafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
     * @dev Multiplies two signed integers, reverts on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Subtracts two signed integers, reverts on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
     * @dev Adds two signed integers, reverts on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }
}

// File: contracts/utils/math/SafeMathInt.sol

pragma solidity 0.5.10;




library SafeMathInt {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    function addInt(uint256 a, int256 b) public pure returns(uint256) {
        if (b < 0) {
            return a.sub(uint(b.mul(-1)));
        } else {
            return a.add(uint(b));
        }
    }
}

// File: contracts/payment/PaymentChannelManager.sol

pragma solidity 0.5.10;











contract PaymentChannelManager is Initializable, ServerRole {
    using SafeMathInt for uint256;
    using SafeMath for uint256;
    using ECDSA for bytes32;
    using ReceiptParserLib for bytes;

    enum ChannelState { NOT_EXIST, OPEN, CLOSED, WITHDRAWN }

    struct Channel {
        uint tokensPaid;
        uint tokensToWithdraw;
        uint fee;
        ChannelState state;
        uint nonce;
        uint closedDate;
    }

    uint public withdrawAfterTimeout;
    address public feeBeneficiary;
    mapping(address => Channel[]) public channels;
    IERC20 token;

    event ChannelOpen(address account, uint channelNumber);
    event ChannelFill(address account, uint channelNumber, uint tokens);
    event ChannelClose(address account, uint channelNumber, uint nonce);
    event ChannelChallenge(address account, uint channelNumber, uint nonce);
    event ChannelWithdraw(address account, uint channelNumber);

    function initialize(
        IERC20 _token,
        address _serverAddress,
        address _feeBeneficiary,
        uint _closingTimeout,
        address _owner
    ) public initializer
    {
        ServerRole.initialize(_serverAddress, _owner);
        token = _token;
        feeBeneficiary = _feeBeneficiary;
        withdrawAfterTimeout = _closingTimeout;
    }

    function addFunds(uint _tokens) public {
        address sender = msg.sender;
        _addFunds(sender, _tokens);
    }

    function closeChannelWithoutReceipt() public {
        _closeChannelWithoutReceipt(msg.sender);
    }

    function closeChannel(bytes memory _receipt, bytes memory  _clientSignature, bytes memory _serverSignature) public {
        address sender = msg.sender;
        ReceiptParserLib.ChannelReceipt memory receiptStruct = getVerifiedReceipt(_receipt, _clientSignature, _serverSignature);
        require(sender == receiptStruct.account || isServer(sender), "Sender has to be channel owner or server");
        Channel storage channel = channels[receiptStruct.account][receiptStruct.channelNumber];
        require(channel.state == ChannelState.OPEN, "Channel has to be in OPEN state");

        channel.closedDate = now;
        channel.tokensToWithdraw = channel.tokensPaid.addInt(receiptStruct.tokensRelative);
        channel.fee = receiptStruct.fee;
        channel.nonce = receiptStruct.nonce;

        openChannel(receiptStruct.account);

        if (receiptStruct.close) {
            processWithdrawal(channel, receiptStruct.account, receiptStruct.channelNumber);
        } else {
            channel.state = ChannelState.CLOSED;
            emit ChannelClose(receiptStruct.account, receiptStruct.channelNumber, receiptStruct.nonce);
        }
    }

    function challengeChannel(bytes memory _receipt, bytes memory _clientSignature, bytes memory _serverSignature) public {
        ReceiptParserLib.ChannelReceipt memory receiptStruct = getVerifiedReceipt(_receipt, _clientSignature, _serverSignature);
        Channel storage channel = channels[receiptStruct.account][receiptStruct.channelNumber];
        require(channel.state == ChannelState.CLOSED, "Channel has to be in CLOSED state");
        require(receiptStruct.nonce > channel.nonce, "Receipt channel nonce has to be greater than current channel nonce");

        channel.tokensToWithdraw = channel.tokensPaid.addInt(receiptStruct.tokensRelative);
        channel.fee = receiptStruct.fee;
        channel.nonce = receiptStruct.nonce;

        emit ChannelChallenge(receiptStruct.account, receiptStruct.channelNumber, receiptStruct.nonce);

        if (receiptStruct.close) {
            processWithdrawal(channel, receiptStruct.account, receiptStruct.channelNumber);
        }
    }

    function withdrawChannel(address _clientAddress, uint256 _channelCounter) public onlyClientOrServer(_clientAddress) {
        Channel storage channel = channels[_clientAddress][_channelCounter];
        require(channel.state == ChannelState.CLOSED, "Channel has to be in CLOSED state");
        require(channel.closedDate + withdrawAfterTimeout < now, "Challenge timeout has not passed yet");

        processWithdrawal(channel, _clientAddress, _channelCounter);
    }

    function withdrawAllChannels(address _clientAddress) public onlyClientOrServer(_clientAddress) {
        uint count = userChannelsCount(_clientAddress);
        for (uint i = 0; i < count; i++) {
            if (
                channels[_clientAddress][i].state == ChannelState.CLOSED &&
                channels[_clientAddress][i].closedDate + withdrawAfterTimeout < now
            ) {
                processWithdrawal(channels[_clientAddress][i], _clientAddress, i);
            }

            if (gasleft() < 100000) {
                return;
            }
        }
    }

    function userChannelsCount(address _owner) public view returns(uint) {
        return channels[_owner].length;
    }

    function _addFunds(address _user, uint _tokens) internal {
        require(_tokens > 0, "The number of tokens must be greater than zero");
        token.transferFrom(_user, address(this), _tokens);
        uint channelCount = channels[_user].length;

        if (channelCount == 0) {
            openChannel(_user);
        }

        fillChannel(_user, _tokens);
    }

    function _closeChannelWithoutReceipt(address _user) internal {
        uint channelNumber = channels[_user].length-1;
        Channel storage channel = channels[_user][channelNumber];
        require(channel.state == ChannelState.OPEN, "Channel has to be in OPEN state");
        require(channel.tokensPaid > 0, "Cannot close channel with zero tokens paid");

        channel.closedDate = now;
        channel.tokensToWithdraw = channel.tokensPaid;

        openChannel(_user);

        channel.state = ChannelState.CLOSED;
        emit ChannelClose(_user, channelNumber, 0);
    }

    function getVerifiedReceipt(
        bytes memory _receipt,
        bytes memory _clientSignature,
        bytes memory _serverSignature
        ) internal view returns (ReceiptParserLib.ChannelReceipt memory)
    {
        ReceiptParserLib.ChannelReceipt memory receiptStruct = _receipt.parseChannel();
        checkSignatures(
            _receipt,
            _clientSignature,
            _serverSignature,
            receiptStruct.account
        );

        return receiptStruct;
    }

    function processWithdrawal(Channel storage _channel, address _clientAddress, uint _channelCounter) internal {
        _channel.state = ChannelState.WITHDRAWN;
        if (_channel.tokensToWithdraw > 0) {
            token.transfer(_clientAddress, _channel.tokensToWithdraw);
        }
        if (_channel.fee > 0) {
            token.transfer(feeBeneficiary, _channel.fee);
        }


        emit ChannelWithdraw(_clientAddress, _channelCounter);
    }

    function openChannel(address _user) internal {
        Channel memory channel = Channel(
            0,
            0,
            0,
            ChannelState.OPEN,
            0,
            0
        );
        channels[_user].push(channel);

        emit ChannelOpen(_user, channels[_user].length-1);
    }

    function fillChannel(address _user, uint _tokens) private {
        uint lastChannelNumber = channels[_user].length - 1;
        require(lastChannelNumber >= 0, "Cannot fill channel other than last one");
        require(channels[_user][lastChannelNumber].state == ChannelState.OPEN, "Filling channel has to be in OPEN state");

        channels[_user][lastChannelNumber].tokensPaid = channels[_user][lastChannelNumber].tokensPaid.add(_tokens);

        emit ChannelFill(_user, lastChannelNumber, _tokens);
    }

    function checkSignatures(
        bytes memory _receipt,
        bytes memory _clientSignature,
        bytes memory _serverSignature,
        address _clientAddress
    ) private view
    {
        bytes32 receiptHash = keccak256(_receipt).toEthSignedMessageHash();
        require(receiptHash.recover(_clientSignature) == _clientAddress, "_User signature doesn't match");
        require(isServer(receiptHash.recover(_serverSignature)), "Server signature doesn't match");
    }

    modifier onlyServer() {
        require(isServer(msg.sender), "This action can be performed only by server");
        _;
    }

    modifier onlyClientOrServer(address _client) {
        require(msg.sender == _client || isServer(msg.sender), "This action can be performed only by server or given _user");
        _;
    }
}
