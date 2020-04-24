/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity >=0.4.0 <0.7.0;
contract SimpleStorage {
    uint storedData;
    uint storedData2;

    function set(uint x,uint y) public {
        storedData = x;
        storedData2=y;
    }

    function get() public view returns (uint,uint) {
        return (storedData,storedData2);
    }
}
