/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.4;
library AddressLib {
    function toBytes32(address addr) internal pure returns(bytes32) {
        return bytes32(uint(uint160(addr)));
    }
}
library Bytes32Lib {
    function toAddress(bytes32 source) internal pure returns(address) {
        return address(uint160(uint(source)));
    }
    function toString(bytes32 source) internal pure returns(string memory) {
        bytes memory b = new bytes(32);
        for (uint i = 0; i < 32; i++) b[i] = source[i];
        return string(b);
    }
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) return 0;
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
library AccountLib {
    using SafeMath for uint256;
    using AddressLib for address;
    struct AccountInfo {
        uint256 available;
        mapping(bytes32 => uint256) authorized;
    }
    struct AccountList {
        mapping(bytes32 => AccountInfo) balances;
    }
    function has(AccountList storage list, address account) internal view returns(uint256) {
        return list.balances[account.toBytes32()].available;
    }
    function has(AccountList storage list, address account, address dealer) internal view returns(uint256) {
        return list.balances[account.toBytes32()].authorized[dealer.toBytes32()];
    }
    function move(AccountList storage list, address from, address to, uint256 value) internal {
        if (value > has(list, from)) value = has(list, from);
        list.balances[from.toBytes32()].available = list.balances[from.toBytes32()].available.sub(value);
        list.balances[to.toBytes32()].available = list.balances[to.toBytes32()].available.add(value);
    }
    function deal(AccountList storage list, address account, address dealer, uint256 value) internal {
        if (value > has(list, account)) value = has(list, account);
        list.balances[account.toBytes32()].authorized[dealer.toBytes32()] = value;
    }
    function move(AccountList storage list, address dealer, address from, address to, uint256 value) internal {
        if (value > has(list, from, dealer)) value = has(list, from, dealer);
        if (value > has(list, from)) value = has(list, from);
        move(list, from, to, value);
        list.balances[from.toBytes32()].authorized[dealer.toBytes32()] = list.balances[from.toBytes32()].authorized[dealer.toBytes32()].sub(value);
        if (has(list, from, dealer) > has(list, from)) {
            list.balances[from.toBytes32()].authorized[dealer.toBytes32()] = has(list, from);
        }
    }
    function release(AccountList storage list, address account, uint256 value) internal {
        list.balances[account.toBytes32()].available = list.balances[account.toBytes32()].available.add(value);
    }
    function revoke(AccountList storage list, address account, uint256 value) internal {
        if (value > has(list, account)) value = has(list, account);
        list.balances[account.toBytes32()].available = list.balances[account.toBytes32()].available.sub(value);
    }
}
contract Accountable {
    using AccountLib for AccountLib.AccountList;
    event Approval(address indexed account, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    AccountLib.AccountList _accounts;
    function approve(address spender, uint256 value) public returns(bool) {
        require(spender != address(0));
        _accounts.deal(msg.sender, spender, value);
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint256 value) public returns(bool) {
        require(to != address(0));
        _accounts.move(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(from != address(0) && address(0) != to);
        _accounts.move(msg.sender, from, to, value);
        emit Transfer(from, to, value);
        return true;
    }
    function balanceOf(address account) public view returns(uint256) {
        return _accounts.has(account);
    }
    function allowance(address account, address spender) public view returns(uint256) {
        return _accounts.has(account, spender);
    }
}
contract Metadata {
    using Bytes32Lib for bytes32;
    bytes32 _owner;
    bytes32 _name;
    bytes32 _symbol;
    uint8 _decimals;
    uint256 _current;
    function totalSupply() public view returns(uint256) {
        return _current;
    }
    function owner() public view returns(address) {
        return _owner.toAddress();
    }
    function name() public view returns(string memory) {
        return _name.toString();
    }
    function symbol() public view returns(string memory) {
        return _symbol.toString();
    }
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}
contract Mintable is Accountable, Metadata {
    using SafeMath for uint256;
    function mint() public payable returns(bool) {
        require(msg.value > 0);
        _accounts.release(msg.sender, msg.value);
        _current = _current.add(msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
        return true;
    }
    function burn(uint256 value) public returns(bool) {
        if (value > balanceOf(msg.sender)) value = balanceOf(msg.sender);
        msg.sender.transfer(value);
        _accounts.revoke(msg.sender, value);
        _current = _current.sub(value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }
}
contract Token is Mintable {
    using AddressLib for address;
    constructor (address tokenIssuer, bytes32 tokenName, bytes32 tokenSymbol) public {
        _owner = tokenIssuer.toBytes32();
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
        emit Transfer(msg.sender, address(0), _current);
    }
}
