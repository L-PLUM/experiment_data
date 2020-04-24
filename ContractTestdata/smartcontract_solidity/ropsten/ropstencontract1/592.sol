/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

//pragma solidity ^0.4.25;
pragma solidity ^0.5.0;

/*
ropsten TestA
0xB7C926E0FA0932BbeBb96A08af3d14972009D643

TestB
0x8c55F45Db435df36Db982a54788FCc5889d5B025
*/

contract TestA
{
	function getA() public view returns (uint);
	function getB() public view returns (uint);
}

contract TestB
{
	string a;
	string b;

	constructor() public
	{
		a = "hello";
		b = "hi";
	}

    function setStr(string memory str1, string memory str2) public
	{
		a = str1;
		b = str2;
	}
	
	function getStrs() public view returns (string memory str1, string memory str2)
	{
		str1 = a;
		str2 = b;
	}
	
	function getNums(address addr) public view returns (uint num1,uint num2)
	{
		TestA testa = TestA(addr);
		num1 = testa.getA();
		num2 = testa.getB();
	}
	
}
