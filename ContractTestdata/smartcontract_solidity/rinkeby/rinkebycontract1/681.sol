/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity >=0.4.0 <0.6.0;

contract HireGoListings {

    struct HireGoListing {
        address user;
        address appOwner;
    }

    mapping(bytes32 => HireGoListing) public listings;

    function addListing(bytes32 _ipfs, address _thirdPartyOwner) public {
        HireGoListing memory listing = HireGoListing({user:msg.sender, appOwner:_thirdPartyOwner});
        listings[_ipfs] = listing;
    }

    function adminDelete(bytes32 _ipfs) public {
        require(listings[_ipfs].user == msg.sender);
        delete listings[_ipfs];
    }

    function deleteListing(bytes32 _ipfs) public {
        require(listings[_ipfs].appOwner == msg.sender);
        delete listings[_ipfs];
    }
}
