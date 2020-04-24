/**
 *Submitted for verification at Etherscan.io on 2018-12-17
*/

pragma solidity ^0.4.25;
contract IOU {
    string public message;
    event IOULog(bytes32  data, uint blockNumber);
    constructor()public {

    }
    function createIOU(bytes32 IOUMessage)  public {
        emit IOULog(IOUMessage,block.number);
    }
}
