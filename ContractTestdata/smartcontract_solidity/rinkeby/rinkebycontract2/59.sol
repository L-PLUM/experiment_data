/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.5.4;
	contract HashLock {
	    bytes32 public constant hashLock = bytes32(0xE6EAB08A7A4C1BE0D615002A85DAE09793BCF240BC315331525916091028FF01);
	    function () external payable {}
	    function claim(string memory _WhatIsTheMagicKey) public {
	        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
	        selfdestruct(msg.sender);
	    }
	}
