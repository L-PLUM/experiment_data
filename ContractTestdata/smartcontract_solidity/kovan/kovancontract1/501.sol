/**
 *Submitted for verification at Etherscan.io on 2019-01-22
*/

pragma solidity ^0.4.24;

contract LNS {    
    
   mapping (bytes32 => address) addresses;

   mapping (address => string) names;    function setName(string _name) public{

       //hash the name;

       bytes32 nameHash = keccak256(abi.encodePacked(_name));

       //check if name is not in use

       require(addresses[nameHash] == address(0x0), "Name is already claimed.");        //check if there was a previous name for this address

       bytes memory emptyStringTest = bytes(names[msg.sender]);

       if (emptyStringTest.length != 0) {

           //reset previous name

           addresses[keccak256(abi.encodePacked(names[msg.sender]))] = address(0x0);

       }        //set the name

       addresses[nameHash] = msg.sender;

       names[msg.sender] = _name;    }    function resolveAddressByName(string _name) external view returns (address){

       return addresses[keccak256(abi.encodePacked(_name))];

   }    function resolveNameByAddress(address _address) external view returns(string){

       return names[_address];

}
    
}
