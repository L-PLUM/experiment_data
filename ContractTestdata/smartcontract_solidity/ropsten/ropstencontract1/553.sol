/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.0;



 contract SimpleStorage{
    uint storeddata;
    function set(uint x) public{
    storeddata = x;
        }
    function get() public view returns(uint){
    return storeddata;
    }
}
