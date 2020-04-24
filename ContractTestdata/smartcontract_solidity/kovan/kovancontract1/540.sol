/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.5.0;



contract testmap {

    mapping(address => bool) public i;

    constructor() public {
        i[msg.sender] = true;
        i[0x7218522a731eC98311f1702C23BCa45EC21152cB] = false;
}



}
