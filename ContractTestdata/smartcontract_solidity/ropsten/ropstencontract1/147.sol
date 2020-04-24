/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.0;

// File: contracts/SimpleStorage.sol

contract SimpleStorage {

  mapping (address => string) ipfsHash;

  function set(string memory _hash) public {
    ipfsHash[msg.sender] = _hash;
  }

  function get(address _user) public view returns (string memory) {
    return ipfsHash[_user];
  }

}
