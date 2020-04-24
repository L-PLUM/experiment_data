/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.5.0;


contract Testcontr {
	event Output(string indexed msg);
	
	
    constructor() public {
	emit Output("hello");
	}
}
