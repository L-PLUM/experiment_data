/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.0;



contract testmap {

    uint[5] public b; 
    uint public bigN;
    int256 public iint256;
  function a( uint[5] memory _b) public {
      b = _b;
  }

    function d(uint[] memory _e) public {
        b[1] = _e[1];
    }


    function bignumberOne(uint _bigN) public {
        bigN = _bigN;
    }
    
        function bignumberOne256(uint256 _bigN) public {
        bigN = _bigN;
    }
    
        function bignumberOne256(int256 _bigN) public {
        iint256 = _bigN;
    }

}
