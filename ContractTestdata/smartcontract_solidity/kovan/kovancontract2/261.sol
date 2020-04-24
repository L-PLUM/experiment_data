/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity ^0.5.8;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/*
The MIT License (MIT)

Copyright (c) 2016-2019 zOS Global Limited

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
*/

// This token is a copy of the TrustlinesNetworkToken as of commit 0651fb21bc35380a551988a8dc9fedd763abb253.
// The burn and transfer functions have been modified for test purpose.
// It is used for testing the MerkleDrop contract.
// The MerkleDrop contract is able to drop any ERC20 token however.

// This contract should not be deployed

contract DroppedToken {

    using SafeMath for uint256;

    uint constant MAX_UINT = 2**256 - 1;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool private burnLoopFlag;

    MerkleDrop public merkleDrop;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (string memory name, string memory symbol, uint8 decimals, address preMintAddress, uint256 preMintAmount) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        _mint(preMintAddress, preMintAmount);
    }

    function storeAddressOfMerkleDrop(address _merkleDrop) public {
        merkleDrop = MerkleDrop(_merkleDrop);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        // We call merkleDrop.burnUnusableTokens() here as a test to see if it will burn too many tokens if we call it before updating the balances.
        merkleDrop.burnUnusableTokens();
        _transfer(msg.sender, recipient, amount);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(value == 0 || _allowances[msg.sender][spender] == 0, "ERC20: approve only to or from 0 value");
        _approve(msg.sender, spender, value);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint allowance = _allowances[sender][msg.sender];
        uint updatedAllowance = allowance.sub(amount);
        if (allowance < MAX_UINT) {
            _approve(sender, msg.sender, updatedAllowance);
        }
    }

    function burn(uint256 amount) public {
        // We call merkleDrop.burnUnusableTokens() here as a test to see if it will burn too many tokens if we re-enter it.
        // We use the burnLoopFlag to prevent an infinite loop of calls, knowing MerkleDrop.sol calls the burn function again.
        if (! burnLoopFlag) {
            burnLoopFlag = true;
            merkleDrop.burnUnusableTokens();
        }
        _burn(msg.sender, amount);
        burnLoopFlag = false;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}

/*
The MIT License (MIT)

Copyright (c) 2016-2019 zOS Global Limited

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
*/


contract MerkleDrop {

    bytes32 public root;
    DroppedToken public droppedToken;
    uint public decayStartTime;
    uint public decayDurationInSeconds;

    uint public initialBalance;
    uint public remainingValue;  // The total not decayed not withdrawn entitlements
    uint public spentTokens;  // The total tokens spent by the contract, burnt or withdrawn

    mapping (address => bool) public withdrawn;

    event Withdraw(address recipient, uint value);
    event Burn(uint value);

    constructor(DroppedToken _droppedToken, uint _initialBalance, bytes32 _root, uint _decayStartTime, uint _decayDurationInSeconds) public {
        droppedToken = _droppedToken;
        initialBalance = _initialBalance;
        remainingValue = _initialBalance;
        root = _root;
        decayStartTime = _decayStartTime;
        decayDurationInSeconds = _decayDurationInSeconds;
    }

    function withdraw(uint value, bytes32[] memory proof) public {
        withdrawFor(msg.sender, value, proof);
    }

    function withdrawFor(address recipient, uint value, bytes32[] memory proof) public {
        require(verifyEntitled(recipient, value, proof), "The proof could not be verified.");
        require(! withdrawn[recipient], "The recipient has already withdrawn its entitled token.");

        burnUnusableTokens();

        uint valueToSend = decayedEntitlementAtTime(value, now);
        assert(valueToSend <= value);
        require(droppedToken.balanceOf(address(this)) >= valueToSend, "The MerkleDrop does not have tokens to drop yet / anymore.");
        require(valueToSend != 0, "The decayed entitled value is now null.");

        withdrawn[recipient] = true;
        remainingValue -= value;
        spentTokens += valueToSend;

        droppedToken.transfer(recipient, valueToSend);
        emit Withdraw(recipient, value);
    }

    function verifyEntitled(address recipient, uint value, bytes32[] memory proof) public view returns (bool) {
        // We need to pack pack the 20 bytes address to the 32 bytes value
        // to match with the proof made with the python merkle-drop package
        bytes32 leaf = keccak256(abi.encodePacked(recipient, value));
        return verifyProof(leaf, proof);
    }

    function decayedEntitlementAtTime(uint value, uint time) public view returns (uint) {
        if (time <= decayStartTime) {
            return value;
        } else if (time >= decayStartTime + decayDurationInSeconds) {
            return 0;
        } else {
            uint timeDecayed = time - decayStartTime;
            uint valueDecay = decay(value, timeDecayed, decayDurationInSeconds);
            assert(valueDecay <= value);
            return value - valueDecay;
        }
    }

    function burnUnusableTokens() public {
        if (now <= decayStartTime) {
            return;
        }

        // The amount of tokens that should be held within the contract after burning
        uint targetBalance = decayedEntitlementAtTime(remainingValue, now);

        // toBurn = (initial balance - target balance) - what we already removed from initial balance
        uint currentBalance = initialBalance - spentTokens;
        assert(targetBalance <= currentBalance);
        uint toBurn = currentBalance - targetBalance;

        spentTokens += toBurn;
        burn(toBurn);
    }

    function deleteContract() public {
        require(now >= decayStartTime + decayDurationInSeconds, "The storage cannot be deleted before the end of the merkle drop.");
        burnUnusableTokens();

        selfdestruct(address(0));
    }

    function verifyProof(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        bytes32 currentHash = leaf;

        for (uint i = 0; i < proof.length; i += 1) {
            currentHash = parentHash(currentHash, proof[i]);
        }

        return currentHash == root;
    }

    function parentHash(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        if (a < b) {
            return keccak256(abi.encode(a, b));
        } else {
            return keccak256(abi.encode(b, a));
        }
    }

    function burn(uint value) internal {
        if (value == 0) {
            return;
        }
        emit Burn(value);
        droppedToken.burn(value);
    }

    function decay(uint value, uint timeToDecay, uint totalDecayTime) internal pure returns (uint) {
        uint decay = value*timeToDecay/totalDecayTime;
        return decay >= value ? value : decay;
    }
}
