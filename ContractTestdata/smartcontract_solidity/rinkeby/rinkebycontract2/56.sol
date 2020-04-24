/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.5.4;
	contract HashLock {
	    bytes32 public constant hashLock = bytes32(0xF9559FC556D986A30F5F6A3684DE7D649B23A3D38AEF72C975E990964D536D8D);
	    function () external payable {}
	    function claim(string memory _WhatIsTheMagicKey) public {
	        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
	        selfdestruct(msg.sender);
	        // send back all the thing to sender
	    }
	}
