/**
 *Submitted for verification at Etherscan.io on 2019-01-14
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint private constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint private constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint private reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE);
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

// File: contracts/Authorizable.sol

contract Authorizable is Ownable {
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    modifier onlyAuthorized() {
        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    function addAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            !authorized[target],
            "TARGET_ALREADY_AUTHORIZED"
        );

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    function removeAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );

        delete authorized[target];
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );
        require(
            index < authorities.length,
            "INDEX_OUT_OF_BOUNDS"
        );
        require(
            authorities[index] == target,
            "AUTHORIZED_ADDRESS_MISMATCH"
        );

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.length -= 1;
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    function getAuthorizedAddresses()
    external
    view
    returns (address[] memory)
    {
        return authorities;
    }
}

// File: contracts/Bank.sol

contract Bank is Authorizable, ReentrancyGuard {

    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool);

    function getAvailable(address token, address user, bytes memory data) public view returns (uint256);

    function balanceOf(address token, address user) public view returns (uint256);

    function deposit(address token, address user, uint256 amount, bytes data) external payable;

    function withdraw(address token, uint256 amount, bytes data) external;

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bool fromDeposit,
        bool toDeposit
    )
    external;
}

// File: contracts/Common.sol

contract Common {
    struct Order {
        bool allowPartial;
        // 0: maker
        // 1: taker
        // 2: makerToken
        // 3: takerToken
        // 4: feeRecipient / reseller
        // 5: sender
        // 6: verifier
        // 7: makerTokenBank
        // 8: takerTokenBank
        address[9] orderAddresses;
        // 0: makerAmount
        // 1: takerAmount
        // 2: expires
        // 3: nonce
        uint256[4] orderValues;
        bytes makerData;
        bytes takerData;
    }

    struct OrderInfo {
        uint8 orderStatus;
        bytes32 orderHash;
        uint256 filledTakerAmount;
    }

    struct FillResults {
        uint256 makerFilledAmount;
        uint256 makerFeeExchange;
        uint256 makerFeeReseller;
        uint256 takerFilledAmount;
        uint256 takerFeeExchange;
        uint256 takerFeeReseller;
    }

    struct MatchedFillResults {
        FillResults left;
        FillResults right;
        uint256 spreadAmount;
    }
}

// File: contracts/LibMath.sol

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

pragma solidity ^0.4.24;

contract LibMath {
    // Copied from openzeppelin Math lib
    function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {
        return _a >= _b ? _a : _b;
    }

    function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {
        return _a < _b ? _a : _b;
    }

    function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a >= _b ? _a : _b;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }

    // Copied from openzeppelin SafeMath lib
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }

    // Copied from 0x LibMath
    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = sub(denominator, remainder) % denominator;
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }
}

// File: contracts/LibBytes.sol

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

pragma solidity ^0.4.24;


library LibBytes {

    using LibBytes for bytes;

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
        if (from > to || to > b.length) {
            return "";
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
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
}

// File: contracts/Verifier.sol

pragma experimental ABIEncoderV2;



contract Verifier is ReentrancyGuard, Common {
    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    returns (bool);
}

// File: contracts/EverbloomExchange.sol

contract EverbloomExchange is Ownable, ReentrancyGuard, LibMath {

    using LibBytes for bytes;

    uint256 public constant MAX_FEE_PERCENTAGE = 0.005 * 10 ** 18; // 0.5%
    address public feeAccount;

    // TODO: Reevaluate fee sharing (users can skip fee by using undefined reseller; adding more logic costs more gas)
    // fees[reseller][0] is maker fee charged by exchange
    // fees[reseller][1] is maker fee charged by reseller
    // fees[reseller][2] is taker fee charged by exchange
    // fees[reseller][3] is taker fee charged by reseller
    // fees[0][0] is default maker fee charged by exchange if no reseller
    // fees[0][1] is always 0 if no reseller
    // fees[0][2] is default taker fee charged by exchange if no reseller
    // fees[0][3] is always 0 if no reseller
    mapping(address => uint256[4]) public fees;

    mapping(bytes32 => uint256) filled;
    mapping(bytes32 => bool) cancelled;
    mapping(address => bool) public banks;

    // No percentage fees for non-dividable tokens
    // Fees can be charged by verifier
    mapping(address => bool) public feeExemptBanks;

    mapping(address => bool) public verifiers;

    enum OrderStatus {
        INVALID,
        INVALID_MAKER_AMOUNT,
        INVALID_TAKER_AMOUNT,
        FILLABLE,
        EXPIRED,
        FULLY_FILLED,
        CANCELLED
    }
    enum EventTypes {
        BANK,
        FEE_EXEMPT_BANK,
        VERIFIER
    }

    event SetFeeAccount(address feeAccount);
    event SetFee(address reseller, uint256 makerFee, uint256 takerFee);
    event SetWhitelist(EventTypes eventType, address addr, bool allowed);
    event CancelOrder(bytes32 indexed orderHash);
    event FillOrder(bytes32 indexed orderHash, address taker, uint256 takerFilledAmount);

    function setFeeAccount(address _feeAccount) public onlyOwner {
        feeAccount = _feeAccount;
        emit SetFeeAccount(_feeAccount);
    }

    function setFee(address reseller, uint256[4] _fees) external onlyOwner {
        if (reseller == 0) {
            require(_fees[1] == 0 && _fees[3] == 0, "INVALID_NULL_RESELLER_FEE");
        }
        uint256 makerFee = add(_fees[0], _fees[1]);
        uint256 takerFee = add(_fees[2], _fees[3]);
        require(add(makerFee, takerFee) <= MAX_FEE_PERCENTAGE, "FEE_TOO_HIGH");
        fees[reseller] = _fees;
        emit SetFee(reseller, makerFee, takerFee);
    }

    function setBank(address bank, bool allowed) external onlyOwner {
        banks[bank] = allowed;
        emit SetWhitelist(EventTypes.BANK, bank, allowed);
    }

    function setFeeExemptBank(address bank, bool allowed) external onlyOwner {
        feeExemptBanks[bank] = allowed;
        emit SetWhitelist(EventTypes.FEE_EXEMPT_BANK, bank, allowed);
    }

    function setVerifier(address verifier, bool allowed) external onlyOwner {
        verifiers[verifier] = allowed;
        emit SetWhitelist(EventTypes.VERIFIER, verifier, allowed);
    }

    function cancelOrder(Common.Order memory order) public nonReentrant {
        cancelOrderInternal(order);
    }

    function cancelOrders(Common.Order[] memory orderList) public nonReentrant {
        for (uint256 i = 0; i < orderList.length; i++) {
            cancelOrderInternal(orderList[i]);
        }
    }

    function fillOrder(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient,
        bytes memory signature
    )
    public
    nonReentrant
    returns (Common.FillResults memory results)
    {
        results = fillOrderInternal(
            order,
            takerAmountToFill,
            allowInsufficient,
            signature
        );
        return results;
    }

    function fillOrderNoThrow(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient,
        bytes memory signature
    )
    public
    returns (Common.FillResults memory results)
    {
        bytes memory callData = abi.encodeWithSelector(
            this.fillOrder.selector,
            order,
            takerAmountToFill,
            allowInsufficient,
            signature
        );
        assembly {
            let success := delegatecall(
                gas,        // forward all gas
                address,    // call address of this contract
                add(callData, 32),  // pointer to start of input (skip array length in first 32 bytes)
                mload(callData),    // length of input
                callData,   // write output over input
                192         // output size is 192 bytes
            )
            if success {
                mstore(results, mload(callData))
                mstore(add(results, 32), mload(add(callData, 32)))
                mstore(add(results, 64), mload(add(callData, 64)))
                mstore(add(results, 96), mload(add(callData, 96)))
                mstore(add(results, 128), mload(add(callData, 128)))
                mstore(add(results, 160), mload(add(callData, 160)))
            }
        }
        return results;
    }

    function fillOrders(
        Common.Order[] memory orderList,
        uint256[] memory takerAmountToFillList,
        bool[] memory allowInsufficientList,
        bytes[] memory signatureList
    )
    public
    nonReentrant
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            fillOrderInternal(
                orderList[i],
                takerAmountToFillList[i],
                allowInsufficientList[i],
                signatureList[i]
            );
        }
    }

    function fillOrdersNoThrow(
        Common.Order[] memory orderList,
        uint256[] memory takerAmountToFillList,
        bool[] memory allowInsufficientList,
        bytes[] memory signatureList
    )
    public
    nonReentrant
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            fillOrderNoThrow(
                orderList[i],
                takerAmountToFillList[i],
                allowInsufficientList[i],
                signatureList[i]
            );
        }
    }

    function matchOrders(
        // (leftOrder.orderValues[0] / leftOrder.orderValues[1])
        // should be greater than or equal to
        // (rightOrder.orderValues[1] / rightOrder.orderValues[0])
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        address spreadReceiver,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
    public
    nonReentrant
    returns (Common.MatchedFillResults memory results)
    {
        require(
            leftOrder.orderAddresses[2] == rightOrder.orderAddresses[3] &&
            leftOrder.orderAddresses[3] == rightOrder.orderAddresses[2] &&
            mul(leftOrder.orderValues[0], rightOrder.orderValues[0]) >= mul(leftOrder.orderValues[1], rightOrder.orderValues[1]),
            "UNMATCHED_ORDERS"
        );
        Common.OrderInfo memory leftOrderInfo = getOrderInfo(leftOrder);
        Common.OrderInfo memory rightOrderInfo = getOrderInfo(rightOrder);
        results = calculateMatchedFillResults(
            leftOrder,
            rightOrder,
            leftOrderInfo.filledTakerAmount,
            rightOrderInfo.filledTakerAmount
        );
        assertFillableOrder(
            leftOrder,
            leftOrderInfo,
            msg.sender,
            results.left.takerFilledAmount,
            leftSignature
        );
        assertFillableOrder(
            rightOrder,
            rightOrderInfo,
            msg.sender,
            results.right.takerFilledAmount,
            rightSignature
        );
        settleMatchedOrder(leftOrder, rightOrder, results, spreadReceiver);
        filled[leftOrderInfo.orderHash] = add(leftOrderInfo.filledTakerAmount, results.left.takerFilledAmount);
        filled[rightOrderInfo.orderHash] = add(rightOrderInfo.filledTakerAmount, results.right.takerFilledAmount);
        emit FillOrder(
            leftOrderInfo.orderHash,
            msg.sender,
            results.left.takerFilledAmount
        );
        emit FillOrder(
            rightOrderInfo.orderHash,
            msg.sender,
            results.right.takerFilledAmount
        );
        return results;
    }

    function limitFillOrders(
        // All orders should be in the same token pair
        Common.Order[] memory orderList,
        bytes[] memory signatureList,
        uint256 totalMakerAmountToFill,
        uint256 totalTakerAmountToFill
    )
    public
    returns (Common.FillResults memory totalFillResults)
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            Common.FillResults memory singleFillResults = fillOrderNoThrow(
                orderList[i],
                min256(
                    sub(totalTakerAmountToFill, totalFillResults.takerFilledAmount),
                    getPartialAmountFloor(
                        orderList[i].orderValues[1], orderList[i].orderValues[0],
                        sub(totalMakerAmountToFill, totalFillResults.makerFilledAmount)
                    )
                ),
                true,
                signatureList[i]
            );
            addFillResults(totalFillResults, singleFillResults);
            if (totalFillResults.makerFilledAmount >= totalMakerAmountToFill || totalFillResults.takerFilledAmount >= totalTakerAmountToFill) {
                break;
            }
        }
        return totalFillResults;
    }

    function getOrderInfo(Common.Order memory order)
    public
    view
    returns (Common.OrderInfo memory orderInfo)
    {
        orderInfo.orderHash = getOrderHash(order);
        orderInfo.filledTakerAmount = filled[orderInfo.orderHash];
        if (order.orderValues[0] == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_MAKER_AMOUNT);
            return orderInfo;
        }
        if (order.orderValues[1] == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_TAKER_AMOUNT);
            return orderInfo;
        }
        if (orderInfo.filledTakerAmount >= order.orderValues[1]) {
            orderInfo.orderStatus = uint8(OrderStatus.FULLY_FILLED);
            return orderInfo;
        }
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= order.orderValues[2]) {
            orderInfo.orderStatus = uint8(OrderStatus.EXPIRED);
            return orderInfo;
        }
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }
        orderInfo.orderStatus = uint8(OrderStatus.FILLABLE);
        return orderInfo;
    }

    function isValidSignature(
        bytes32 hash,
        address signer,
        bytes memory signature
    )
    public
    pure
    returns (bool)
    {
        uint8 v = uint8(signature[0]);
        bytes32 r = signature.readBytes32(1);
        bytes32 s = signature.readBytes32(33);
        return signer == ecrecover(
            keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                hash
            )),
            v,
            r,
            s
        );
    }

    function getOrderHash(Common.Order memory order)
    public
    view
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                address(this),
                order.allowPartial,
                order.orderAddresses,
                order.orderValues,
                order.makerData,
                order.takerData
            ));
    }

    function cancelOrderInternal(Common.Order memory order) internal {
        Common.OrderInfo memory orderInfo = getOrderInfo(order);
        require(
            orderInfo.orderStatus == uint8(OrderStatus.FILLABLE),
            "ORDER_UNFILLABLE"
        );
        require(
            order.orderAddresses[0] == msg.sender,
            "INVALID_MAKER"
        );
        cancelled[orderInfo.orderHash] = true;
        emit CancelOrder(
            orderInfo.orderHash
        );
    }

    function fillOrderInternal(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient,
        bytes memory signature
    )
    internal
    returns (Common.FillResults memory results) {
        require(takerAmountToFill > 0, "INVALID_TAKER_AMOUNT");
        Common.OrderInfo memory orderInfo = getOrderInfo(order);
        uint256 remainingTakerAmount = sub(order.orderValues[1], orderInfo.filledTakerAmount);
        if (allowInsufficient) {
            takerAmountToFill = min256(takerAmountToFill, remainingTakerAmount);
        } else {
            require(takerAmountToFill <= remainingTakerAmount, "INSUFFICIENT_ORDER_REMAINING");
        }
        assertFillableOrder(
            order,
            orderInfo,
            msg.sender,
            takerAmountToFill,
            signature
        );
        results = settleOrder(order, takerAmountToFill);
        filled[orderInfo.orderHash] = add(orderInfo.filledTakerAmount, results.takerFilledAmount);
        emit FillOrder(
            orderInfo.orderHash,
            msg.sender,
            results.takerFilledAmount
        );
        return results;
    }

    function assertFillableOrder(
        Common.Order memory order,
        Common.OrderInfo memory orderInfo,
        address taker,
        uint256 takerAmountToFill,
        bytes memory signature
    )
    internal
    view
    {
        // An order can only be filled if its status is FILLABLE.
        require(
            orderInfo.orderStatus == uint8(OrderStatus.FILLABLE),
            "ORDER_UNFILLABLE"
        );

        // Validate sender is allowed to fill this order
        if (order.orderAddresses[5] != address(0)) {
            require(
                order.orderAddresses[5] == msg.sender,
                "INVALID_SENDER"
            );
        }

        // Validate taker is allowed to fill this order
        if (order.orderAddresses[1] != address(0)) {
            require(
                order.orderAddresses[1] == taker,
                "INVALID_TAKER"
            );
        }

        // Validate Maker signature (check only if first time seen)
        if (orderInfo.filledTakerAmount == 0) {
            require(
                isValidSignature(
                    orderInfo.orderHash,
                    order.orderAddresses[0],
                    signature
                ),
                "INVALID_ORDER_SIGNATURE"
            );
        }

        // Reject if this order doesn't allow partial filling
        if (!order.allowPartial) {
            require(takerAmountToFill >= order.orderValues[1], "PARTIAL_ORDER_NOT_ALLOWED");
        }

        // Go through Verifier
        if (order.orderAddresses[6] != address(0)) {
            require(Verifier(order.orderAddresses[6]).verify(
                    order,
                    takerAmountToFill,
                    msg.sender
                ), "FAILED_VALIDATION");
        }
    }

    function addFillResults(Common.FillResults memory totalFillResults, Common.FillResults memory singleFillResults)
    internal
    pure
    {
        totalFillResults.makerFilledAmount = add(totalFillResults.makerFilledAmount, singleFillResults.makerFilledAmount);
        totalFillResults.makerFeeExchange = add(totalFillResults.makerFeeExchange, singleFillResults.makerFeeExchange);
        totalFillResults.makerFeeReseller = add(totalFillResults.makerFeeReseller, singleFillResults.makerFeeReseller);
        totalFillResults.takerFilledAmount = add(totalFillResults.takerFilledAmount, singleFillResults.takerFilledAmount);
        totalFillResults.takerFeeExchange = add(totalFillResults.takerFeeExchange, singleFillResults.takerFeeExchange);
        totalFillResults.takerFeeReseller = add(totalFillResults.takerFeeReseller, singleFillResults.takerFeeReseller);
    }

    function settleOrder(
        Common.Order memory order,
        uint256 takerAmountToFill
    )
    internal
    returns (Common.FillResults memory results)
    {
        results.takerFilledAmount = takerAmountToFill;
        results.makerFilledAmount = safeGetPartialAmountFloor(order.orderValues[0], order.orderValues[1], results.takerFilledAmount);
        if (!feeExemptBanks[order.orderAddresses[7]]) {
            if (fees[order.orderAddresses[4]][0] > 0) {
                results.makerFeeExchange = mul(results.makerFilledAmount, fees[order.orderAddresses[4]][0]) / (1 ether);
            }
            if (fees[order.orderAddresses[4]][1] > 0) {
                results.makerFeeReseller = mul(results.makerFilledAmount, fees[order.orderAddresses[4]][1]) / (1 ether);
            }
        }
        if (!feeExemptBanks[order.orderAddresses[8]]) {
            if (fees[order.orderAddresses[4]][2] > 0) {
                results.takerFeeExchange = mul(results.takerFilledAmount, fees[order.orderAddresses[4]][2]) / (1 ether);
            }
            if (fees[order.orderAddresses[4]][3] > 0) {
                results.takerFeeReseller = mul(results.takerFilledAmount, fees[order.orderAddresses[4]][3]) / (1 ether);
            }
        }

        bool useMakerDeposit = Bank(order.orderAddresses[7]).hasDeposit(
            order.orderAddresses[2],
            order.orderAddresses[0],
            add(results.makerFilledAmount, add(results.makerFeeExchange, results.makerFeeReseller)),
            order.makerData
        );
        bool useTakerDeposit = Bank(order.orderAddresses[8]).hasDeposit(
            order.orderAddresses[3],
            msg.sender,
            add(results.takerFilledAmount, add(results.takerFeeExchange, results.takerFeeReseller)),
            order.takerData
        );
        if (results.makerFeeExchange > 0) {
            Bank(order.orderAddresses[7]).transferFrom(
                order.orderAddresses[2],
                order.orderAddresses[0],
                feeAccount,
                results.makerFeeExchange,
                order.makerData,
                useMakerDeposit,
                false
            );
        }
        if (results.makerFeeReseller > 0) {
            Bank(order.orderAddresses[7]).transferFrom(
                order.orderAddresses[2],
                order.orderAddresses[0],
                order.orderAddresses[4],
                results.makerFeeReseller,
                order.makerData,
                useMakerDeposit,
                false
            );
        }
        if (results.takerFeeExchange > 0) {
            Bank(order.orderAddresses[8]).transferFrom(
                order.orderAddresses[3],
                msg.sender,
                feeAccount,
                results.takerFeeExchange,
                order.takerData,
                useTakerDeposit,
                false
            );
        }
        if (results.takerFeeReseller > 0) {
            Bank(order.orderAddresses[8]).transferFrom(
                order.orderAddresses[3],
                msg.sender,
                order.orderAddresses[4],
                results.takerFeeReseller,
                order.takerData,
                useTakerDeposit,
                false
            );
        }
        Bank(order.orderAddresses[7]).transferFrom(
            order.orderAddresses[2],
            order.orderAddresses[0],
            msg.sender,
            results.makerFilledAmount,
            order.makerData,
            useMakerDeposit,
            useTakerDeposit
        );
        Bank(order.orderAddresses[8]).transferFrom(
            order.orderAddresses[3],
            msg.sender,
            order.orderAddresses[0],
            results.takerFilledAmount,
            order.takerData,
            useTakerDeposit,
            useMakerDeposit
        );
    }

    function calculateMatchedFillResults(
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        uint256 leftFilledTakerAmount,
        uint256 rightFilledTakerAmount
    )
    internal
    view
    returns (Common.MatchedFillResults memory results)
    {
        uint256 leftRemainingTakerAmount = sub(leftOrder.orderValues[1], leftFilledTakerAmount);
        uint256 leftRemainingMakerAmount = safeGetPartialAmountFloor(
            leftOrder.orderValues[0],
            leftOrder.orderValues[1],
            leftRemainingTakerAmount
        );
        uint256 rightRemainingTakerAmount = sub(rightOrder.orderValues[1], rightFilledTakerAmount);
        uint256 rightRemainingMakerAmount = safeGetPartialAmountFloor(
            rightOrder.orderValues[0],
            rightOrder.orderValues[1],
            rightRemainingTakerAmount
        );

        if (leftRemainingTakerAmount >= rightRemainingMakerAmount) {
            // Case 1: Right order is fully filled
            results.right.makerFilledAmount = rightRemainingMakerAmount;
            results.right.takerFilledAmount = rightRemainingTakerAmount;
            results.left.takerFilledAmount = results.right.makerFilledAmount;
            // Round down to ensure the maker's exchange rate does not exceed the price specified by the order.
            // We favor the maker when the exchange rate must be rounded.
            results.left.makerFilledAmount = safeGetPartialAmountFloor(
                leftOrder.orderValues[0],
                leftOrder.orderValues[1],
                results.left.takerFilledAmount
            );
        } else {
            // Case 2: Left order is fully filled
            results.left.makerFilledAmount = leftRemainingMakerAmount;
            results.left.takerFilledAmount = leftRemainingTakerAmount;
            results.right.makerFilledAmount = results.left.takerFilledAmount;
            // Round up to ensure the maker's exchange rate does not exceed the price specified by the order.
            // We favor the maker when the exchange rate must be rounded.
            results.right.takerFilledAmount = safeGetPartialAmountCeil(
                rightOrder.orderValues[1],
                rightOrder.orderValues[0],
                results.right.makerFilledAmount
            );
        }
        results.spreadAmount = sub(
            results.left.makerFilledAmount,
            results.right.takerFilledAmount
        );
        if (!feeExemptBanks[leftOrder.orderAddresses[7]]) {
            if (fees[leftOrder.orderAddresses[4]][0] > 0) {
                results.left.makerFeeExchange = mul(results.left.makerFilledAmount, fees[leftOrder.orderAddresses[4]][0]) / (1 ether);
            }
            if (fees[leftOrder.orderAddresses[4]][1] > 0) {
                results.left.makerFeeReseller = mul(results.left.makerFilledAmount, fees[leftOrder.orderAddresses[4]][1]) / (1 ether);
            }
        }
        if (!feeExemptBanks[rightOrder.orderAddresses[7]]) {
            if (fees[rightOrder.orderAddresses[4]][2] > 0) {
                results.right.makerFeeExchange = mul(results.right.makerFilledAmount, fees[rightOrder.orderAddresses[4]][2]) / (1 ether);
            }
            if (fees[rightOrder.orderAddresses[4]][3] > 0) {
                results.right.makerFeeReseller = mul(results.right.makerFilledAmount, fees[rightOrder.orderAddresses[4]][3]) / (1 ether);
            }
        }
        return results;
    }

    function settleMatchedOrder(
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        Common.MatchedFillResults memory results,
        address spreadReceiver
    )
    internal
    {
        bool useLeftDeposit = Bank(leftOrder.orderAddresses[7]).hasDeposit(
            leftOrder.orderAddresses[2],
            leftOrder.orderAddresses[0],
            add(results.left.makerFilledAmount, add(results.left.makerFeeExchange, results.left.makerFeeReseller)),
            leftOrder.makerData
        );
        bool useRightDeposit = Bank(rightOrder.orderAddresses[7]).hasDeposit(
            rightOrder.orderAddresses[2],
            rightOrder.orderAddresses[0],
            add(results.right.makerFilledAmount, add(results.right.makerFeeExchange, results.right.makerFeeReseller)),
            rightOrder.makerData
        );
        if (results.left.makerFeeExchange > 0) {
            Bank(leftOrder.orderAddresses[7]).transferFrom(
                leftOrder.orderAddresses[2],
                leftOrder.orderAddresses[0],
                feeAccount,
                results.left.makerFeeExchange,
                leftOrder.makerData,
                useLeftDeposit,
                false
            );
        }
        if (results.left.makerFeeReseller > 0) {
            Bank(leftOrder.orderAddresses[7]).transferFrom(
                leftOrder.orderAddresses[2],
                leftOrder.orderAddresses[0],
                leftOrder.orderAddresses[4],
                results.left.makerFeeReseller,
                leftOrder.makerData,
                useLeftDeposit,
                false
            );
        }
        if (results.right.makerFeeExchange > 0) {
            Bank(rightOrder.orderAddresses[7]).transferFrom(
                rightOrder.orderAddresses[2],
                rightOrder.orderAddresses[0],
                feeAccount,
                results.right.makerFeeExchange,
                rightOrder.makerData,
                useRightDeposit,
                false
            );
        }
        if (results.right.makerFeeReseller > 0) {
            Bank(rightOrder.orderAddresses[7]).transferFrom(
                rightOrder.orderAddresses[2],
                rightOrder.orderAddresses[0],
                rightOrder.orderAddresses[4],
                results.right.makerFeeReseller,
                rightOrder.makerData,
                useRightDeposit,
                false
            );
        }
        Bank(leftOrder.orderAddresses[7]).transferFrom(
            leftOrder.orderAddresses[2],
            leftOrder.orderAddresses[0],
            rightOrder.orderAddresses[0],
            results.right.takerFilledAmount,
            leftOrder.makerData,
            useLeftDeposit,
            useRightDeposit
        );
        Bank(rightOrder.orderAddresses[7]).transferFrom(
            rightOrder.orderAddresses[2],
            rightOrder.orderAddresses[0],
            leftOrder.orderAddresses[0],
            results.left.takerFilledAmount,
            rightOrder.makerData,
            useRightDeposit,
            useLeftDeposit
        );
        if (results.spreadAmount > 0) {
            Bank(leftOrder.orderAddresses[7]).transferFrom(
                leftOrder.orderAddresses[2],
                leftOrder.orderAddresses[0],
                spreadReceiver,
                results.spreadAmount,
                leftOrder.makerData,
                useLeftDeposit,
                false
            );
        }
    }
}
