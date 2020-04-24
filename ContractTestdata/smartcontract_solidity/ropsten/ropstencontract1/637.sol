/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;

contract DataTransaction {
    
    struct Transaction {
         uint timestamp;
         string latitude;
         string longitude;
         address useraddress;
         address walletaddress;
         uint256 tokenssent;
         uint256 tokenfees;
         address sender;
   
     }

     mapping (bytes32 => Transaction) public transactions;
     bytes32[] transactionIds;
     
      function getTransactionByUUId(bytes32 uuid) public view returns (uint timestamp,string latitude,string longitude,address useraddress,address walletaddress,uint tokenssent,uint tokenfees) {
            
            return(transactions[uuid].timestamp,transactions[uuid].latitude,transactions[uuid].longitude,transactions[uuid].useraddress,transactions[uuid].walletaddress,transactions[uuid].tokenssent,transactions[uuid].tokenfees);
          
    }
     

     function createTransaction(bytes32 transactionID,uint timestamp,string latitude,string longitude,address useraddress,address walletaddress,uint tokenssent,uint256 tokenfees) public returns(bool success) {
         transactions[transactionID].timestamp =timestamp;
         transactions[transactionID].latitude=latitude;
         transactions[transactionID].longitude=longitude;
         transactions[transactionID].useraddress=useraddress;
         transactions[transactionID].walletaddress=walletaddress;
         transactions[transactionID].tokenssent=tokenssent;
         transactions[transactionID].tokenfees=tokenfees;
         transactions[transactionID].sender=msg.sender;
         transactionIds.push(transactionID);
         return true;
     }
}
