/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.5.4;
	contract HashLock {
	    bytes32 public constant hashLock = bytes32(0xCE8CF2B15E7CAC6D5EF34E9BD3EFEAECA8ABB776059AD805274DEBC3AA58E290); //key
	    function () external payable {} //defaultFunction
	    function claim(string memory _WhatIsTheMagicKey) public {
	        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
	        selfdestruct(msg.sender);
	    }
	    
	}
