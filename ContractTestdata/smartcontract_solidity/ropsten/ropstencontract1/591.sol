/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

//pragma solidity ^0.4.25;
pragma solidity ^0.5.0;

contract TestA
{
	uint a;
	uint b;

	constructor() public
	{
		a = 100;
		b = 200;
	}

    function setNum(uint num1, uint num2) public
	{
		a = num1;
		b = num2;
	}
	
	function getA() public view returns (uint value)
	{
		value = a;
	}
	
	function getB() public view returns (uint value)
	{
		value = b;
	}
	
}
