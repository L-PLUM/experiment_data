/**
 *Submitted for verification at Etherscan.io on 2019-04-07
*/


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
pragma solidity ^0.5.2;

/// @title Abstract token contract - Functions to be implemented by token contracts
contract Token {
    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    function balanceOf(address owner) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function totalSupply() public view returns (uint);
}

// File: @gnosis.pm/util-contracts/contracts/Math.sol

/// @title Math library - Allows calculation of logarithmic and exponential functions
/// @author Alan Lu - <[email protected]>
/// @author Stefan George - <[email protected]>
library GnosisMath {
    /*
     *  Constants
     */
    // This is equal to 1 in our calculations
    uint public constant ONE = 0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    function max(int[] memory nums) public pure returns (int maxNum) {
        require(nums.length > 0);
        maxNum = -2 ** 255;
        for (uint i = 0; i < nums.length; i++) if (nums[i] > maxNum) maxNum = nums[i];
    }

    function safeToAdd(uint a, uint b) internal pure returns (bool) {
        return a + b >= a;
    }

    
    function safeToSub(uint a, uint b) internal pure returns (bool) {
        return a >= b;
    }

    
    function safeToMul(uint a, uint b) internal pure returns (bool) {
        return b == 0 || a * b / b == a;
    }

    /// @dev Returns sum if no overflow occurred
    /// @param a First addend
    /// @param b Second addend
    /// @return Sum
    function add(uint a, uint b) internal pure returns (uint) {
        require(safeToAdd(a, b));
        return a + b;
    }

    /// @dev Returns difference if no overflow occurred
    /// @param a Minuend
    /// @param b Subtrahend
    /// @return Difference
    function sub(uint a, uint b) internal pure returns (uint) {
        require(safeToSub(a, b));
        return a - b;
    }

    /// @dev Returns product if no overflow occurred
    /// @param a First factor
    /// @param b Second factor
    /// @return Product
    function mul(uint a, uint b) internal pure returns (uint) {
        require(safeToMul(a, b));
        return a * b;
    }

    /// @dev Returns whether an add operation causes an overflow
    /// @param a First addend
    /// @param b Second addend
    /// @return Did no overflow occur?
    function safeToAdd(int a, int b) internal pure returns (bool) {
        return (b >= 0 && a + b >= a) || (b < 0 && a + b < a);
    }

    /// @dev Returns whether a subtraction operation causes an underflow
    /// @param a Minuend
    /// @param b Subtrahend
    /// @return Did no underflow occur?
    function safeToSub(int a, int b) internal pure returns (bool) {
        return (b >= 0 && a - b <= a) || (b < 0 && a - b > a);
    }

    /// @dev Returns whether a multiply operation causes an overflow
    /// @param a First factor
    /// @param b Second factor
    /// @return Did no overflow occur?
    function safeToMul(int a, int b) internal pure returns (bool) {
        return (b == 0) || (a * b / b == a);
    }

    /// @dev Returns sum if no overflow occurred
    /// @param a First addend
    /// @param b Second addend
    /// @return Sum
    function add(int a, int b) internal pure returns (int) {
        require(safeToAdd(a, b));
        return a + b;
    }

    /// @dev Returns difference if no overflow occurred
    /// @param a Minuend
    /// @param b Subtrahend
    /// @return Difference
    function sub(int a, int b) internal pure returns (int) {
        require(safeToSub(a, b));
        return a - b;
    }

    /// @dev Returns product if no overflow occurred
    /// @param a First factor
    /// @param b Second factor
    /// @return Product
    function mul(int a, int b) internal pure returns (int) {
        require(safeToMul(a, b));
        return a * b;
    }
}

// File: @gnosis.pm/util-contracts/contracts/GnosisStandardToken.sol

/**
 * Deprecated: Use Open Zeppeling one instead
 */
contract StandardTokenData {
    /*
     *  Storage
     */
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    uint totalTokens;
}

/**
 * Deprecated: Use Open Zeppeling one instead
 */
/// @title Standard token contract with overflow protection
contract GnosisStandardToken is Token, StandardTokenData {
    using GnosisMath for *;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
    function transfer(address to, uint value) public returns (bool) {
        if (!balances[msg.sender].safeToSub(value) || !balances[to].safeToAdd(value)) {
            return false;
        }

        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success
    /// @param from Address from where tokens are withdrawn
    /// @param to Address to where tokens are sent
    /// @param value Number of tokens to transfer
    /// @return Was transfer successful?
    function transferFrom(address from, address to, uint value) public returns (bool) {
        if (!balances[from].safeToSub(value) || !allowances[from][msg.sender].safeToSub(
            value
        ) || !balances[to].safeToAdd(value)) {
            return false;
        }
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param spender Address of allowed account
    /// @param value Number of approved tokens
    /// @return Was approval successful?
    function approve(address spender, uint value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address
    /// @param owner Address of token owner
    /// @param spender Address of token spender
    /// @return Remaining allowance for spender
    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    /// @dev Returns number of tokens owned by given address
    /// @param owner Address of token owner
    /// @return Balance of owner
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    /// @dev Returns total supply of tokens
    /// @return Total supply
    function totalSupply() public view returns (uint) {
        return totalTokens;
    }
}

