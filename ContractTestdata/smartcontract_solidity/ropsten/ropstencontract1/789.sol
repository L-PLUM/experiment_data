/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.0;



contract testmap {

    uint[5] public b; 
  function a( uint[5] memory _b) public {
      b = _b;
  }

    function d(uint[] memory _e) public {
        b[1] = _e[1];
    }


}
