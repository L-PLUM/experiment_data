/**
 *Submitted for verification at Etherscan.io on 2019-07-11
*/

pragma solidity ^0.5.0;

contract PropertyRegistryContract {

    event NewPropertyRegistered(uint indexed propertyId, string indexed propertyAddress);

    event PropertyInitialOwnerWasSet(uint indexed propertyId, address indexed propertyOwner);

    event PropertyOwnershipTransferred(
        uint indexed propertyId,
        address indexed previousPropertyOwner,
        address indexed newPropertyOwner);


    struct PropertyDetails {
        uint propertyId;
        string propertyAddress;
        address propertyOwner;
    }


    address public contractOwner;

    PropertyDetails[] public properties;


    constructor() public {
        contractOwner = msg.sender;
    }


    function RegisterNewProperty(string memory propertyAddress) public {

        // This function can ONLY be used by the owner of the contract.
        require(msg.sender == contractOwner);

        // Assign the property id as an index in the array of properties for easy mapping.
        uint propertyId = properties.length;

        // Initialise a new Property instance.
        PropertyDetails memory newProperty = PropertyDetails(propertyId, propertyAddress, address(0));

        // Add the new property to the array of properties.
        properties.push(newProperty);

        // Emmit the new property added event for logging.
        emit NewPropertyRegistered(propertyId, propertyAddress);
    }


    function setInitialPropertyOwner(uint propertyId, address initialPropertyOwner) public {

        // This function can ONLY be used by the owner of the contract.
        require(msg.sender == contractOwner);

        // This function can be called ONLY if the property hasn't had an owner yet.
        require(properties[propertyId].propertyOwner == address(0));

        // Set the initial property owner.
        properties[propertyId].propertyOwner = initialPropertyOwner;

        // Emit the property ownership set event for logging.
        emit PropertyInitialOwnerWasSet(propertyId, initialPropertyOwner);
    }


    function transferPropertyOwnership(uint propertyId, address newPropertyOwner) public {

        // This function can ONLY be used by the current property owner.
        require(properties[propertyId].propertyOwner == msg.sender);

        // Set the new owner.
        properties[propertyId].propertyOwner = newPropertyOwner;

        // Emmit the property ownership transferred event for logging.
        emit PropertyOwnershipTransferred(propertyId, msg.sender, newPropertyOwner);
    }
}
