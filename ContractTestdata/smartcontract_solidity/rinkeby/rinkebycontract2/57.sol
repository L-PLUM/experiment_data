/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.5.4;
	contract HashLock {
	    bytes32 public constant hashLock = bytes32(0xA90F518AAE295D8CB86F4E63B460357BD499E5EDF3430AD5DE1C2D46FD1C0BB6);
	    function () external payable {}
	    function claim(string memory _WhatIsTheMagicKey) public {
	        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
	        selfdestruct(msg.sender);
	    }
	}
