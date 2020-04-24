/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.4;
contract HashLock {
bytes32 public constant hashLock = bytes32(0xA2C41B64DA631268128775DCDC05DD4995F56B9E6E962FDAACEC2F33C1CF0526);
    function () payable external{}
    function claim(string memory _WhatIsTheMagicKey) public {
        require(sha256(abi.encodePacked(_WhatIsTheMagicKey)) == hashLock);
        selfdestruct(msg.sender);
    }
}
