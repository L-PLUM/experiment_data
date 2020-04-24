/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.3;

contract RNG {
    //uint public nonce;
    struct History{
        uint time;
        uint result;
        address sender;
    }
    History[] public history;
    event Result(uint time, uint result, address sender);
    
    function ByteToInt(bytes32 _number) public pure returns(uint num) {
      return uint(_number);
  }
    
    function GetResult(uint nonce) public returns(uint num){
        bytes32 lottery = keccak256(abi.encodePacked(msg.sender, nonce, blockhash(block.number - 1)));
        uint res = ByteToInt(lottery) % 100001;
        history.push(History(now, res, msg.sender));
        emit Result(now, res, msg.sender);
        return res;
    }

}
