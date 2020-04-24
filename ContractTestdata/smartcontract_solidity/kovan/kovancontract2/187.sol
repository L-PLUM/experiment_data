/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity >=0.4.0 <0.7.0;
contract thisisContract{
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return (storedData);
    }
}
