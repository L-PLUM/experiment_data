/**
 *Submitted for verification at Etherscan.io on 2019-02-06
*/

pragma solidity ^0.5.3;
contract IERC20 {
    function balanceOf(address who) public view returns(uint);
    function transfer(address to, uint value) public returns(bool);
}
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed _newOwener, address indexed _previousOwner);
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner returns(bool) {
        require(newOwner != address(0) && address(this) != newOwner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
        return true;
    }
    function anyERC20Transfer(address token, uint value) public onlyOwner returns(bool) {
        return IERC20(token).transfer(owner, value);
    }
}
contract Reserve is Ownable, IERC20 {
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    string public name;
    string public symbol;
    uint8 public decimals;
    event Approval(address indexed _owner, address indexed _spender, uint value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    constructor() public {
        owner = msg.sender;
        name = "Ethereum Reserve Assets";
        symbol = "ERA";
        decimals = 18;
        balances[owner] = 0;
        emit OwnershipTransferred(msg.sender, address(0));
        emit Transfer(address(0), msg.sender, 0);
    }
    function balanceOf(address tokenOwner) public view returns(uint) {
        return balances[tokenOwner];
    }
    function totalSupply() public view returns(uint) {
        return address(this).balance;
    }
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[spender][tokenOwner];
    }
    function reserve() public payable returns(bool) {
        require(msg.value > 0);
        balances[msg.sender] += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
        return true;
    }
    function withdraw(uint value) public returns(bool) {
        require(value > 0 && value <= balances[msg.sender]);
        msg.sender.transfer(value);
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
        return true;
    }
    function approve(address spender, uint value) public returns(bool) {
        require(spender != address(0) && address(this) != spender);
        require(value > 0 && value <= balances[msg.sender]);
        allowed[spender][msg.sender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint value) public returns(bool) {
        require(value > 0 && value <= balances[msg.sender]);
        require(to != address(0) && address(this) != to);
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(value <= allowed[msg.sender][from] && value <= balances[from]);
        require(to != address(0) && address(this) != to);
        if (value > 0) {
            balances[from] -= value;
            balances[to] += value;
            allowed[msg.sender][from] -= value;
        }
        emit Transfer(from, to, value);
        return true;
    }
    function increaseApproval(address spender, uint value) public returns(bool) {
        require(allowed[spender][msg.sender] < balances[msg.sender]);
        uint approvable = balances[msg.sender] - allowed[spender][msg.sender];
        if (value > approvable) revert();
        allowed[spender][msg.sender] += value;
        emit Approval(msg.sender, spender, allowed[spender][msg.sender]);
        return true;
    }
    function decreaseApproval(address spender, uint value) public returns(bool) {
        require(allowed[spender][msg.sender] >= value);
        allowed[spender][msg.sender] -= value;
        emit Approval(msg.sender, spender, allowed[spender][msg.sender]);
        return true;
    }
    function () external payable {
        if (msg.value > 0) reserve();
    }
}
