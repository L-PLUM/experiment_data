/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity ^0.4.24;

// File: /Users/mike/projects/bot/git/contract/contracts/strings.sol

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <[email protected]>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */

pragma solidity ^0.4.14;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal pure returns (slice ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice self) internal pure returns (slice) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice self) internal pure returns (string) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice self) internal pure returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice self, slice other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice self, slice other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice self, slice rune) internal pure returns (slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice self) internal pure returns (slice ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    event log_bytemask(bytes32 mask);

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice self, slice needle) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice self, slice needle) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice self, slice needle) internal pure returns (slice token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice self, slice needle) internal pure returns (slice token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice self, slice needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice self, slice needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice self, slice other) internal pure returns (string) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice self, slice[] parts) internal pure returns (string) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

// File: /Users/mike/projects/bot/git/contract/contracts/ibankroll.sol

interface IBankroll {
  function placeBets() external;
  function() payable external;
}

// File: /Users/mike/projects/bot/git/contract/contracts/ibook.sol

interface IBook {
  function placeBetOnIndex(uint) payable external;
  function getMinBet() external returns (uint);
  function getNumWords() external returns (uint);
}

// File: /Users/mike/projects/bot/git/contract/contracts/safemath.sol

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: /Users/mike/projects/bot/git/contract/contracts/owned.sol

contract Owned {

    address public _owner;
    address public _ownerCandidate;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function transferOwnership(address candidate) public onlyOwner {
        _ownerCandidate = candidate;
    }

    function acceptOwnership() public {
        require(msg.sender == _ownerCandidate);
        emit OwnershipTransferred(_owner, _ownerCandidate);
        _owner = _ownerCandidate;
        _ownerCandidate = address(0);
    }
}

// File: contracts/book.sol

library StringUtils {
  function toLower(string str) public pure returns (string) {
    bytes memory bStr = bytes(str);
    bytes memory bLower = new bytes(bStr.length);
    for (uint i = 0; i < bStr.length; i++) {
      // convert only if uppercase character
      if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
        // So we add 32 to make it lowercase
        bLower[i] = bytes1(int(bStr[i]) + 32);
      } else {
        bLower[i] = bStr[i];
      }
    }
    return string(bLower);
  }

  function stringsEqual(string storage _a, string memory _b) public view returns (bool) {
    bytes storage a = bytes(_a);
    bytes memory b = bytes(_b);
    
    if (a.length != b.length)
      return false;

    for (uint i = 0; i < a.length; i ++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }

  function strArrayConcat(string[] strings) internal pure returns (string) {
    uint len;
    string memory separator = ",";
    uint separatorLen = bytes(separator).length;
    for (uint i = 0; i < strings.length; i++) {
      if (bytes(strings[i]).length > 0) {
        len += bytes(strings[i]).length + separatorLen;
      }
    }
    len -= separatorLen;

    string memory result = new string(len);
    bytes memory bresult = bytes(result);
    uint k;

    for (i = 0; i < strings.length; i++) {
      if (bytes(strings[i]).length > 0) {
        for (uint j = 0; j < bytes(strings[i]).length; j++) {
          bresult[k++] = bytes(strings[i])[j];
        }
        // skip the last comma
        if (k < bresult.length) {
          for (j = 0; j < separatorLen; j++) {
            bresult[k++] = bytes(separator)[j];
          }
        }
      }
    }
    return string(bresult);
  }
}


contract Book is IBook, Owned {
  using SafeMath for uint256;
  using strings for *;

  struct Bet {
    address account;
    uint stake;
    uint time;
  }

  struct Bets {
    Bet[] bets;
    uint total;
  }

  struct GetWinningBetsResult {
    string[] words;
    uint total;
  }

  struct Payout {
    address account;
    uint payout;
  }

  event PlacedBet(address account, string word, uint stake, uint time);

  event WinningWords(uint id, uint time, string words, string text);

  event Retired(bool canceled);

  uint public constant MIN_BET = 0.01 ether;

  string public constant WORDS = "big,america,fake,wall,deal";

  uint public constant BET_DELAY = 30;

  uint constant COMISSION_PERCENTAGE = 5;

  uint constant RETIREMENT_DURATION = 60*60*24*30;

  string public constant FEED_NAME = "realDonaldTrump";

  string[] _words;

  uint public _maxNumBets = 100;

  mapping (bytes32 => Bets) _bets;
  uint public _betsTotal = 0;

  address public _feeder;

  mapping (uint => bool) _processed;
  uint public _lastId;

  mapping (address => uint) public _balances;

  Payout[] public _top10;
  uint public _top10Length;

  uint public _lastWinningId;
  uint public _lastWinningBlock;

  IBankroll public _bankroll;

  uint public _retirementTime;

  modifier onlyFeeder {
    require(msg.sender == _feeder);
    _;
  }

  modifier onlySelf(){
    require(msg.sender == address(this));
    _;
  }

  modifier onlyIfActive {
    require(_retirementTime == 0);
    _;
  }

  constructor() public {
  }

  function init() public onlyOwner {
    strings.slice memory delim = ",".toSlice();
    strings.slice memory slices = WORDS.toSlice();
    string[] memory parts = new string[](slices.count(delim) + 1);
    for(uint i = 0; i < parts.length; i++) {
      parts[i] = slices.split(delim).toString();
    }
    _words = parts;

  }

  function getNumBetsForWord(string word) public view returns (uint) {
    return _bets[keccak256(abi.encodePacked(word))].bets.length;
  }

  function getNumBets() public view returns (uint) {
    uint num = 0;
    for (uint i = 0; i < _words.length; i++) {
      num += _bets[keccak256(abi.encodePacked(_words[i]))].bets.length;
    }
    return num;
  }

  function getBetsTotalForWord(string word) public view returns (uint) {
    return _bets[keccak256(abi.encodePacked(word))].total;
  }

  function getBet(string word, uint i) public view returns (address, uint, uint) {
    Bet memory bet = _bets[keccak256(abi.encodePacked(word))].bets[i];

    return (bet.account, bet.stake, bet.time);
  }

  function getWinningBetsTotal(string text, uint time) public view returns (uint) {
    string memory lowerText = StringUtils.toLower(text);

    return getWinningBets(lowerText, time).total;
  }

  function getWinningBets(string text, uint time) private view returns (GetWinningBetsResult) {
    strings.slice memory textSlice = text.toSlice();
    uint total;
    GetWinningBetsResult memory result;
    result.words = new string[](_words.length);
    uint numWords = 0;
    for (uint i = 0; i < _words.length; i++) {
      strings.slice memory wordSlice = _words[i].toSlice();
      if (textSlice.contains(wordSlice)) {
        Bets storage bets = _bets[keccak256(abi.encodePacked(_words[i]))];
        total = total.add(bets.total);
        uint j = bets.bets.length;
        while (0 < j && time <= bets.bets[j-1].time) {
          total = total.sub(bets.bets[j-1].stake);
          j = j-1;
        }

        result.words[numWords++] = _words[i];
      }
    }
    result.total = total;
    return result;
  }

  function getTotalBets(uint time) public view returns (uint) {
    uint total = 0;

    for (uint i = 0; i < _words.length; i++) {
      Bets storage bets = _bets[keccak256(abi.encodePacked(_words[i]))];
      uint j = 0;
      if (bets.bets.length != 0) {
        while ((j < bets.bets.length) && (time > bets.bets[j].time)) {
          total = total.add(bets.bets[j].stake);
          j = j+1;
        }
      }
    }

    return total;
  }

  function getMinBet() public returns (uint) {
    return MIN_BET;
  }

  function getNumWords() public returns (uint) {
    return _words.length;
  }

  function setMaxNumBets(uint num) public onlyOwner {
    _maxNumBets = num;
  }

  function setFeeder(address feeder) public onlyOwner {
    _feeder = feeder;
  }

  function setBankroll(address target) public onlyOwner {
    _bankroll = IBankroll(target);
  }

  function placeBet (string word) public payable onlyIfActive {
    require(msg.value >= MIN_BET);

    uint found = 0;
    for (uint i = 0; i < _words.length; i++) {
      if (StringUtils.stringsEqual(_words[i], word)) {
        found = 1;
      }
    }
    if (found == 0) { revert(); }

    assert(getNumBets() < _maxNumBets);

    Bets storage bets = _bets[keccak256(abi.encodePacked(word))];
    bets.bets.push(Bet(msg.sender, msg.value, now.add(BET_DELAY)));
    bets.total = bets.total.add(msg.value);
    _betsTotal = _betsTotal.add(msg.value);

    emit PlacedBet(msg.sender, word, msg.value, now);

  }

  function process(uint id, string text, uint time) public onlyFeeder {
    require(!_processed[id]);
    _processed[id] = true;
    _lastId = id;

    string memory lowerText = StringUtils.toLower(text);

    GetWinningBetsResult memory winningBets = getWinningBets(lowerText, time);
    if (winningBets.total > 0) {
      settleBets(lowerText, time);
      _lastWinningId = id;
      _lastWinningBlock = block.number;

      emit WinningWords(id, time, StringUtils.strArrayConcat(winningBets.words), text);

    } else {
      emit WinningWords(id, time, "", text);

    }
  }

  function settleBets(string text, uint time) internal {
    uint betsTotal = getTotalBets(time);
    _betsTotal = 0;

    uint total = betsTotal.mul(100).sub(betsTotal.mul(COMISSION_PERCENTAGE)).div(100);
    GetWinningBetsResult memory winningBets = getWinningBets(text, time);
    uint shares;

    strings.slice memory textSlice = text.toSlice();
    for (uint i = 0; i < _words.length; i++) {
      string memory word = _words[i];
      bytes32 wordHash = keccak256(abi.encodePacked(word));
      strings.slice memory wordSlice = word.toSlice();

      if (textSlice.contains(wordSlice)) {
        shares = shares.add(settleBetsForWord(wordHash, total, winningBets.total, time));
      } else {
        delete _bets[wordHash];
      }
    }

    if (betsTotal >= shares) {
       _balances[_owner] += betsTotal - shares;
    } else {
      revert();
    }

    if (_bankroll != address(0)) {
      uint amount = _balances[_bankroll];
      if (amount > 0) {
        _balances[_bankroll] = 0;
        address(_bankroll).transfer(amount);
      }

      _bankroll.placeBets();
    }

  }

  function settleBetsForWord(bytes32 wordHash, uint total, uint winnigBetsTotal, uint time) internal returns (uint) {
    Bets storage betsForWord = _bets[wordHash];
    uint shares;
    for (uint i = 0; i < betsForWord.bets.length && betsForWord.bets[i].time < time; i++) {
      Bet storage bet = betsForWord.bets[i];
      uint share = total.mul(bet.stake).div(winnigBetsTotal);
      _balances[bet.account] = _balances[bet.account].add(share);
      shares = shares.add(share);
      updateTop10(bet.account, share);

    }
    uint offset = i;
    Bet[] memory remainingBets = new Bet[](betsForWord.bets.length - offset);
    for (i = 0; i < betsForWord.bets.length - offset; i++) {
      remainingBets[i] = betsForWord.bets[i + offset];
    }

    delete _bets[wordHash];

    for (i = 0; i < remainingBets.length; i++) {
      _bets[wordHash].bets.push(remainingBets[i]);
      _bets[wordHash].total = _bets[wordHash].total.add(remainingBets[i].stake);
      _betsTotal = _betsTotal.add(remainingBets[i].stake);
    }

    return shares;
  }

  function updateTop10(address account, uint payout) internal {
    uint minIndex;
    uint maxPayout;

    if (_top10.length < 10) {
      _top10.push(Payout(account, payout));
      _top10Length = _top10.length;
      return;
    }

    for (uint i = 0; i < _top10.length; i++) {
      // _top10.length == 10, hence _top10[i] is defined
      uint p = _top10[i].payout;

      if (p < _top10[minIndex].payout) {
        minIndex = i;
      }
      if (p > maxPayout) {
        maxPayout = p;
      }
    }

    if (payout > maxPayout) {
      _top10[minIndex] = Payout(account, payout);
    }
  }

  function withdraw() public {
    uint amount = _balances[msg.sender];
    if (amount > 0) {
      _balances[msg.sender] = 0;
      msg.sender.transfer(amount);
    }
  }

  function placeBetOnIndex(uint i) public payable {
    placeBet(_words[i]);
  }

  function retire() public onlyOwner {
    bool canceled = address(this).call(bytes4(keccak256("cancelBets()")));
    emit Retired(canceled);
    _retirementTime = now;
  }

  function cancelBets() external onlySelf {
    for (uint i = 0; i < _words.length; i++) {
      bytes32 wordHash = keccak256(abi.encodePacked(_words[i]));
      for (uint j = 0; j < _bets[wordHash].bets.length; j++) {
        Bet storage bet = _bets[wordHash].bets[j];
        _balances[bet.account] = _balances[bet.account].add(bet.stake);
      }
      delete _bets[wordHash];
    }
    _betsTotal = 0;
  }

  function kill() public onlyOwner {
    if (now >= _retirementTime.add(RETIREMENT_DURATION)) {
      selfdestruct(_owner);
    }
  }

}
