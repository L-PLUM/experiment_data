/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity 0.4.24;

contract AddInteger{

 uint256 storageVariable;
 
 function addition(uint a, uint b) external
  {
    
    storageVariable = a+b;
  } 
  
  function getStorageVariable()external view returns(uint256)
  {
      return storageVariable;
  }
  
}
