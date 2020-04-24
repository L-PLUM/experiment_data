/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.0;

// THIS IS FOR TOKEN TESTING PURPOSE
// Replaced name, symbol for test purposes
// ----------------------------------------------------------------------------
// 'OKT' 'OK Token' token contract
// 
// Deployed to : 0x1382ed5aA260a43aC7682e91d9E095dc4f352e04
// Symbol      : OKT
// Name        : OK Token
// Total supply: 1,000,000.000000000000000000
// Decimals    : 18
//
// 
// Code by moog
// Original by: (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------

// -- Safe Math Library (from OpenZeppelin Library) --

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// -- ERC Token Standard #20 Interface --
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// -- Contract function to receive approval and execute function in one call --
// from BokkyPooBah 

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// -- Contract owner and transfer ownership --

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// -- ERC20 Token /w fixed supply --

contract OKToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // -- constructor --
    constructor() public {
        symbol = "OKT";
        name = "OK Token";
        decimals = 18;
        _totalSupply = 1000000 * 10**uint(decimals);
        balances[0x1382ed5aA260a43aC7682e91d9E095dc4f352e04] = _totalSupply;
        emit Transfer(address(0), 0x1382ed5aA260a43aC7682e91d9E095dc4f352e04, _totalSupply);
    }


    // -- total supply --
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // -- token balance for token owner --
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // -- transfer balance from token owner's account to `to` account --
    // -> Owner's account must have sufficient balance to transfer
    // -> 0 value transfers are allowed
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // -- token owner can approve for `spender` to transferFrom(...) `tokens from the token owner's account -- 
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    
    // > recommends that there are no checks for the approval double-spend attack
    // > as this should be implemented in user interfaces
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // -- Transfer `tokens` from the `from` account to the `to` account -- 
    
    // > The calling account must already have sufficient tokens approve(...)-d
    // > for spending from the `from` account and
    
    // -> From account must have sufficient balance to transfer
    // -> Spender must have sufficient allowance to transfer
    // -> 0 value transfers are allowed
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // -- Returns the amount of tokens approved by the owner that can be transferred to the spender's account -- 
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // -- Token owner can approve for `spender` to transferFrom(...) `tokens` from the token owner's account --
    // The `spender` contract function `receiveApproval(...)` is then executed
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
