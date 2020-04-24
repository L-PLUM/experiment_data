/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.0;
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
contract LockableToken is Ownable {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool);
    function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool);
    function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public payable returns (bool);
}

contract Token is Ownable{
	LockableToken public token;
	uint256 public tokenToWeiRatio = 10000;

	event TokenAddressChange(address token);

	function changeTokenAddress(address _token) onlyOwner public {
	    require(_token != address(0), "Token address cannot be null-address");
	    token = LockableToken(_token);
	    emit TokenAddressChange(_token);
	}

	function daoTokenBalance() public view returns (uint256) {
	    return token.balanceOf(address(this));
	}
	function buyTokensThrow(address _buyer, uint256 _wei) external {

	    uint256 tokens = _wei * tokenToWeiRatio;
	    require(daoTokenBalance() >= tokens, "DAO must have enough tokens for sale");
	    token.transfer(_buyer, tokens);
	}
}
