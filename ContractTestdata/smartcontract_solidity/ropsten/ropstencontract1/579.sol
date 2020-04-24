/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.4.16;

contract testContracts {

    uint value;
    function testContract(uint _p) {
        value = _p;
    }

    function setP(uint _n) payable {
        value = _n;
    }

    function setNP(uint _n) {
        value = _n;
    }

    function get () constant returns (uint) {
        return value;
    }
}
