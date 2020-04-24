/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity ^0.5.0;

contract titleDeeds{

    //the basic user ID
    struct UserInfo {
         string name;
         address userAddress;
         string IDhash;
    }
    //storee of all users
    UserInfo[] public users;

    //information of the registred property
    struct propertyIdentifier {
        string erfNumber;
        string geoloc;
    }
    //store of all the properties
    propertyIdentifier[] publicProperties;

    //mapping of users and properties
    mapping(address=> uint256) addressToUser;
    mapping(address=> uint256) addressToProperty;

    //the ability to register a user
    function registerUser(string memory _name, string memory _IDhash) public {
        uint256 _id = users.push(UserInfo(_name, msg.sender, _IDhash)) - 1;
        addressToUser[msg.sender] = _id;
    }
    //ability to register a property
    function registerProperty (string memory _erfNumber, string memory _geoloc) public {
       // require(msg.sender==users[_ownerIDnumber].userAddress);
        uint _id = publicProperties.push(propertyIdentifier(_erfNumber, _geoloc));
        addressToProperty[msg.sender] = _id;

    }
    //ability to get a property given your address
    function getProperty () public view returns (string memory, string memory) {
        uint256 propNum = addressToProperty[msg.sender]-1;
        return(publicProperties[propNum].erfNumber, publicProperties[propNum].geoloc);
    }
     //ability to get a user given your address
     function getUser () public view returns (string memory, string memory) {
        uint256 propNum = addressToUser[msg.sender]-1;
        return(users[propNum].name, users[propNum].IDhash);
    }
}
