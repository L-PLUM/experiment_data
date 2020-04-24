/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.5.2;

contract AddressSetHaver {
  uint[] public testList = [1,2,3,4,5,6];

  
  function foo() public returns(bool) { 
      require(1 == 2, "awww noooo");
      return true;
  } 
  
  function yee(uint [] memory bacon) public returns(bool[] memory) {
      bool[] memory copy = new bool[](bacon.length);
      copy[bacon.length -1] = true;
      return copy;
  }

  function add(uint element) public returns (uint) {
    if ( contains(element) ) {
      return testList.length;
    } else {
      return testList.push(element);
    }
  }

  function contains(uint element) public view returns (bool) {
    uint len = testList.length;
    for(uint i = 0; i < len; i++) {
      if(testList[i] == element) {
        return true;
      }
    }
    return false;
  }

  function length() public view returns (uint) {
    return testList.length;
  }
}
