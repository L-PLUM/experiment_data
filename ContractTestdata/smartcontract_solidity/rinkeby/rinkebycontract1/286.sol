/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.4;

contract HashLock {
bytes32 public constant hashLock = bytes32(0x1F49287EF2EBA37B8E67F63905431CCEED3AA95A78904B1C4AEA9FD61A07FA70);
    function () payable external{}
    function claim(string memory _WhatIsTheMagicKey) public {
        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
        selfdestruct(msg.sender);
    }
}
