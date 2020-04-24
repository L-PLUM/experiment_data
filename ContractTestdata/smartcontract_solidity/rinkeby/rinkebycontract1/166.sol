/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.1;

contract landOwnership{
    
    struct Personal{
    string Person;
    address a;
    }
    Personal[] personal;
    constructor(string memory _Person)public{
        personal.push(Personal(_Person,msg.sender));
    }
   
    mapping(address=>string[]) personAddress;
    function setPerson(string memory _Person)public{
        personal.push(Personal(_Person,msg.sender));
    }
    function getPerson(uint id)public view returns(string memory,address){
        return (personal[id].Person,personal[id].a);
    }
    modifier matchLandPrice() {
        require(msg.value == 0.1 ether);
        _;
    }
    function transferOwnership(uint id)public matchLandPrice payable {
        personal[id].a=personal[0].a;
        personal[0].a=0x0000000000000000000000000000000000000000;
    }
}
