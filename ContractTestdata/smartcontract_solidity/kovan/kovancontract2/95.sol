/**
 *Submitted for verification at Etherscan.io on 2019-08-03
*/

pragma solidity ^0.5.8;

// The ExecutorRegistry is just a quick way for the app to find already active contract for a user needing an executor contract
// The registry requires no admin or maintenance but can be added in the future

contract ExecutorRegistry {
  function onlyDistinctUser(address user) public view returns (bool success) {
    return (user == msg.sender) || (user == tx.origin);
  }

  mapping(address => address) private userToExecutorContractMapping;

  function addOrUpdateExecutorContractRegistry(address user, address executorContract) public returns (bool success) {
      require(onlyDistinctUser(user));
      userToExecutorContractMapping[user] = executorContract;
      return true;
    }

  function removeSpecificUserFromContractRegistry(address user) public returns (bool success) {
      require(onlyDistinctUser(user));
      delete userToExecutorContractMapping[user];
      return true;
  }

  function getExecutorContract(address user) public view returns (address executor) {
      return userToExecutorContractMapping[user];
  }
}
