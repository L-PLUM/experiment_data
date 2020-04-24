/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.24;
contract ERC20Interface {
    uint public aa=0;
    mapping (uint=>uint) public test;
    event testt(uint t);
    function balanceOf() public returns (uint) {
        aa++;
        test[aa]=aa;
        emit testt(test[aa]);
    }
    function getOf(uint ina) view public returns (uint) {
        return test[ina];
    }
    
}
