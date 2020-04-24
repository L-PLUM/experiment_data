/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity ^0.5.0;

    ///@title Indeed Contract
    ///@author Chandler De Kock, Iggy Phiri, Juliet Magagula

    ///@notice the start of the contract
    contract IndeedContract{

    ///@notice structure containing the basic information of the property user
    ///@param name the name of the property holder
    ///@param userAddress the address that created the contract
    ///@param IDhash a unquie person identifier, for safety, please hash this number
    struct UserInfo {
            string name;
            address userAddress;
            string IDhash;
        }

    ///@notice store of all users in a public array
    UserInfo[] public users;

    ///@notice information of the registred property
    ///@param erfNumber is the erfNumber the property is registeretd to - set tto zero if the property does nott have an ERF number
    ///@param geoloc is the geocordinates of the property stored as a string
    struct propertyIdentifier {
            string erfNumber;
            string geoloc;
        }

    ///@notice store of all the properties in a public array
    propertyIdentifier[] public publicProperties;

    ///@notice mapping of users and properties - this mapping works by mapping the position the user is in their respective arrays to their address
    mapping(address=> uint256) addressToUser;
    mapping(address=> uint256) addressToProperty;

     ///@notice the ability to register a user
     ///@param _name the name of the property holder
     ///@param _IDhash the hash of a unique identifier for a person (please hash)
     ///@dev Add a new user to the user array given the inputs  and then creates a mapping for the message sender to the position in the user array
    function registerUser(string memory _name, string memory _IDhash) public {
        uint256 _id = users.push(UserInfo(_name, msg.sender, _IDhash)) - 1;
        addressToUser[msg.sender] = _id;
    }

    ///@notice ability to register a property and unquity identify it
    ///@param _erfNumber the property ERF number as a string - set to zero if there is none
    ///@param _geoloc gelolocation of the property stored as a string
    ///@dev Add a new property to the proprty array given the inputs  and then creates a mapping for the message sender to the position in the array
    function registerProperty (string memory _erfNumber, string memory _geoloc) public {
        uint _id = publicProperties.push(propertyIdentifier(_erfNumber, _geoloc)) - 1;
        addressToProperty[msg.sender] = _id;
    }

    ///@notice ability to get a property given your address
    ///@return two strings that identify the senders property - this is the same details as the property struct
    function getProperty () public view returns (string memory, string memory) {
        uint256 propNum = addressToProperty[msg.sender];
        return(publicProperties[propNum].erfNumber, publicProperties[propNum].geoloc);
    }

    ///@notice ability to get a user given your address
    ///@return two strings that identify the senders user details - this is the same details in the user struct
    function getUser () public view returns (string memory, string memory) {
        uint256 propNum = addressToUser[msg.sender];
        return(users[propNum].name, users[propNum].IDhash);
    }
}
