/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.5.1;

contract Jude {
    address canDo;
    
    uint private a;
    
    modifier onlyCanDo() {
    require(msg.sender == canDo);
    _;
  }
    
    constructor(address _canDo) public {
        canDo = _canDo;
        a = 5;
    }
    
    function GetAll() public view onlyCanDo returns (uint) {
        return a;
    }
}
