/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.5.3;
contract IToken {
    function transfer(address to, uint value) public returns(bool);
}
contract Ownable {
    event OwnershipTransferred(address indexed newOwner, address indexed prevOwner);
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function isContract(address addr) internal view returns(bool) {
        uint l;
        assembly { l := extcodesize(addr) }
        return (l > 0);
    }
    function transferOwnership(address newOwner) public onlyOwner returns(bool) {
        require(newOwner != address(0) && address(this) != newOwner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
        return true;
    }
    function transferAnyToken(address erc20, uint value) public onlyOwner returns(bool) {
        return IToken(erc20).transfer(tx.origin, value);
    }
}
contract Token is Ownable {
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
    string public name;
    string public symbol;
    uint8 public decimals;
    function totalSupply() public view returns(uint) {
        return address(this).balance;
    }
    function balanceOf(address tokenOwner) public view returns(uint) {
        return balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[tokenOwner][spender];
    }
    function approve(address spender, uint value) public returns(bool) {
        if (!isContract(spender)) revert();
        if (value > balances[msg.sender]) revert();
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint value) public returns(bool) {
        if (value > balances[msg.sender]) revert();
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (value > allowed[from][msg.sender]) revert();
        if (value > 0) {
            balances[from] -= value;
            balances[to] += value;
            allowed[from][msg.sender] -= value;
        }
        emit Transfer(from, to, value);
        return true;
    }
}
contract MyToken is Token {
    event Reserved(address indexed reserveOwner, uint value);
    event Restored(address indexed reserveOwner, uint value);
    function reserve() public payable returns(bool) {
        balances[msg.sender] += msg.value;
        emit Reserved(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
        return true;
    }
    function restore(uint value) public returns(bool) {
        if (value > balances[msg.sender]) revert();
        msg.sender.transfer(value);
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
        emit Restored(msg.sender, value);
        return true;
    }
    function restoreAll() public returns(bool) {
        return restore(balances[msg.sender]);
    }
}
contract ReserveCenter is MyToken {
    constructor() public {
        owner = msg.sender;
        name = "Reserve Center Shares";
        symbol = "RCS";
        decimals = 18;
        emit Transfer(msg.sender, address(0), 108e24);
    }
    function () external payable {
        if (msg.value > 0) reserve();
    }
}
