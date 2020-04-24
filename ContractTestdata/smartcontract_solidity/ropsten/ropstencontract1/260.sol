/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.0;

 contract MyDateStorage{
    uint numberofdate=1;
    function setMyNo(uint x) public{
    numberofdate = x;
        }
    function getMyNo() public view returns(uint){
    return numberofdate;
    }
}
