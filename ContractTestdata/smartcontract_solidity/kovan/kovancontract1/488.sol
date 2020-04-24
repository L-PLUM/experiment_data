/**
 *Submitted for verification at Etherscan.io on 2019-01-23
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

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
}

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

// File: contracts/Authorizable.sol

// Modified from 0x
contract Authorizable is Ownable {
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressUserApproved(
        address indexed target,
        address indexed caller,
        bool approved
    );

    modifier onlyAuthorized() {
        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    modifier onlyUserApproved(address user) {
        require(
            userApproved[msg.sender][user],
            "SENDER_NOT_APPROVED"
        );
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    // User approved authorities
    // userApproved[authority][user] = bool
    mapping (address => mapping (address => bool)) public userApproved;

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

    function approve(address target, bool approved)
    external
    {
        userApproved[target][msg.sender] = approved;
        emit AuthorizedAddressUserApproved(target, msg.sender, approved);
    }

    function getAuthorizedAddresses()
    external
    view
    returns (address[] memory)
    {
        return authorities;
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

// File: contracts/Bank.sol

contract Bank is Authorizable, ReentrancyGuard {

    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool);

    function getAvailable(address token, address user, bytes data) external view returns (uint256);

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

// File: contracts/LibBytes.sol

// Modified from 0x LibBytes
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

// File: contracts/ERC721Bank.sol

contract ERC721 {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address);
}

contract ERC721Bank is Bank {

    using LibBytes for bytes;

    mapping (address => mapping (address => uint256[])) public deposits;

    event Deposit(address token, address user, uint256 tokenId, uint256[] balance);
    event Withdraw(address token, address user, uint256 tokenId, uint256[] balance);
    event TransferFallback(address token);

    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool) {
        for (uint256 i = 0; i < deposits[token][user].length; i++) {
            if (data.readUint256(0) == deposits[token][user][i]) {
                return true;
            }
        }
        return false;
    }

    function getAvailable(address token, address user, bytes data) external view returns (uint256) {
        uint256 tokenId = data.readUint256(0);
        if ((ERC721(token).getApproved(tokenId) == address(this) && ERC721(token).ownerOf(tokenId) == user) ||
            this.hasDeposit(token, user, 1, data)) {
            return 1;
        }
        return 0;
    }

    function balanceOf(address token, address user) public view returns (uint256) {
        return deposits[token][user].length;
    }

    function getTokenIds(address token, address user) external view returns (uint256[] memory) {
        return deposits[token][user];
    }

    function deposit(address token, address user, uint256 amount, bytes data) external nonReentrant payable {
        uint256 tokenId = data.readUint256(0);
        ERC721(token).transferFrom(msg.sender, this, tokenId);
        deposits[token][user].push(tokenId);
        emit Deposit(token, user, tokenId, deposits[token][user]);
    }

    function withdraw(address token, uint256 amount, bytes data) external nonReentrant {
        uint256 tokenId = data.readUint256(0);
        require(hasDeposit(token, msg.sender, tokenId, data), "INSUFFICIENT_DEPOSIT");
        removeToken(token, msg.sender, tokenId);
        transferFallback(token, msg.sender, tokenId);
        emit Withdraw(token, msg.sender, tokenId, deposits[token][msg.sender]);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bool fromDeposit,
        bool toDeposit
    )
    external
    onlyAuthorized
    onlyUserApproved(from)
    nonReentrant
    {
        if (amount == 0 || from == to) {
            return;
        }
        uint256 tokenId = data.readUint256(0);
        if (fromDeposit) {
            require(hasDeposit(token, from, tokenId, data));
            removeToken(token, from, tokenId);
            if (toDeposit) {
                // Deposit to deposit
                deposits[token][to].push(tokenId);
            } else {
                // Deposit to wallet
                transferFallback(token, to, tokenId);
            }
        } else {
            if (toDeposit) {
                // Wallet to deposit
                ERC721(token).transferFrom(from, this, tokenId);
                deposits[token][to].push(tokenId);
            } else {
                // Wallet to wallet
                ERC721(token).transferFrom(from, to, tokenId);
            }
        }
    }

    function transferFallback(address token, address to, uint256 tokenId) internal {
        bytes memory callData = abi.encodeWithSelector(
            ERC721(token).transferFrom.selector,
            address(this),
            to,
            tokenId
        );
        bool result;
        assembly {
            let cdStart := add(callData, 32)
            result := call(
            gas,                // forward all gas
            token,              // address of token contract
            0,                  // don't send any ETH
            cdStart,            // pointer to start of input
            mload(callData),    // length of input
            cdStart,            // write output over input
            0                   // output size is 0
            )
        }
        if (!result) {
            ERC721(token).transfer(to, tokenId);
            emit TransferFallback(token);
        }
    }

    function removeToken(address token, address user, uint256 tokenId) internal {
        for (uint256 i = 0; i < deposits[token][user].length; i++) {
            if (tokenId == deposits[token][user][i]) {
                deposits[token][user][i] = deposits[token][user][deposits[token][user].length - 1];
                delete deposits[token][user][deposits[token][user].length - 1];
                deposits[token][user].length--;
                return;
            }
        }
    }
}
