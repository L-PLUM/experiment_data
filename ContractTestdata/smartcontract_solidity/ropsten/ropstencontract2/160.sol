/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.5.10;

contract Trusti {
    struct Asset {
    string datahash;
    string signee;
    address manufacturer;
    bool initialized;    
         }
         
    struct tracking {
    address location;
    string datahash;
          }
    mapping(string => tracking) locations;
    mapping(string  => Asset) private assetStore;

      event AssetCreate(address manufacturer, string datahash, address location);
      event AssetTransfer(address from, address to, string datahash);

      function createAsset(string memory datahash, string memory signee) public {
      require(!assetStore[datahash].initialized, "Asset With This DATAHASH Already Exists");
 
      assetStore[datahash] = Asset(signee, datahash, msg.sender,true);
      locations[datahash] = tracking(msg.sender, datahash);
      emit AssetCreate(msg.sender, datahash, msg.sender);
                }
                
       function transferAsset(address to, string memory datahash) public {
         require(locations[datahash].location==msg.sender, "You are Not Authorized to Transfer This Asset");
         
        locations[datahash]= tracking(to, datahash);
        emit AssetTransfer(msg.sender, to, datahash);
               }
               
          function getAssetDetails(string memory datahash)public view returns (string memory,string memory,address) {
 
               return (assetStore[datahash].signee, assetStore[datahash].datahash, assetStore[datahash].manufacturer);
                   }
          function getAssetLocation(string memory datahash)public view returns (address) {
 
            return (locations[datahash].location);
                  }

         
       }
