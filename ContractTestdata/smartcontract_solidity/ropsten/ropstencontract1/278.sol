/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.0;

contract Test
{
	string a;
	uint b;
		
	mapping(address => uint256) public balances;
		
	event testLog(string param, uint value);
	event buytLog(address addr, uint value);

	constructor() public
	{
		a = "hello";
		b = 1000;
		
		emit testLog(a,b);
	}

	function buy() public payable
	{
		emit buytLog(msg.sender,msg.value);
		balances[msg.sender] += msg.value;
	}
	
    function set1(string memory param, uint value) public
	{
		require(value>=1000, "ne menee 1000");

		a = param;
		b = value;
		
		emit testLog(a,b);
	}
	
	function set2(string memory param, uint value) public
	{
		require(value<=4000, "ne bolee 4000");

		a = param;
		b = value;
		
		emit testLog(a,b);
	}
	
	function set3(string memory param, uint value) public
	{
		require(value!=500);

		a = param;
		b = value;
		
		emit testLog(a,b);
	}
	
	function get() public view returns (string memory param, uint value)
	{
		param = a;
		value = b;
	}
	
}
