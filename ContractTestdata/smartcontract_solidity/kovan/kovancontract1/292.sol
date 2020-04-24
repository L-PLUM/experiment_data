/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity ^0.5.3;
contract ContractInterface {
    function transfer(address to, uint value) public returns(bool);
}
contract Contract is ContractInterface {
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event OwnershipTransferred(address indexed newOwner, address indexed prevOwner);
    event Reserved(address indexed reserveAgent, address indexed reserveOwner, uint value);
    event Restored(address indexed reserveOwner, address indexed reserveDestination, uint value);
    address public owner;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) balances;
    string public name;
    string public symbol;
    uint8 public decimals;
    constructor(address _owner, string memory _name, string memory _symbol, uint8 _decimals) public {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        emit Transfer(owner, address(0), 108e24);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function isContract(address addr) internal view returns(bool) {
        uint l;
        assembly { l := extcodesize(addr) }
        return (l > 0);
    }
    function totalSupply() public view returns(uint) {
        return address(this).balance - balances[address(0)];
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
    function reserve() public payable returns(bool) {
        return delegateReserve(msg.sender);
    }
    function restore(uint value) public returns(bool) {
        if (value > balances[msg.sender]) revert();
        msg.sender.transfer(value);
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
        emit Restored(msg.sender, msg.sender, value);
        return true;
    }
    function restoreAll() public returns(bool) {
        return restore(balances[msg.sender]);
    }
    function delegateReserve(address to) public payable returns(bool) {
        if (to == address(0)) revert();
        balances[to] += msg.value;
        emit Reserved(msg.sender, to, msg.value);
        emit Transfer(address(0), to, msg.value);
        return true;
    }
    function delegateRestore(address from, address to, uint value) public returns(bool) {
        if (value > allowed[from][msg.sender]) revert();
        if (value > 0) {
            address(uint160(to)).transfer(value);
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
        }
        emit Transfer(from, address(0), value);
        emit Restored(from, to, value);
        return true;
    }
    function delegateRestoreAll(address from, address to) public returns(bool) {
        return delegateRestore(from, to, allowed[from][msg.sender]);
    }
    function () external payable {
        if (msg.value > 0) delegateReserve(msg.sender);
    }
    function transferOwnership(address newOwner) public onlyOwner returns(bool) {
        require(newOwner != address(0) && address(this) != newOwner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
        return true;
    }
    function transferAnything(address token, uint value) public onlyOwner returns(bool) {
        return ContractInterface(token).transfer(tx.origin, value);
    }
}
