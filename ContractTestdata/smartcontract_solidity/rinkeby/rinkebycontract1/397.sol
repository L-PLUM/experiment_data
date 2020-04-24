/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity >=0.5.4 <0.6.0;

contract GenerateEvent {
    event MessageSend(bytes ipfsAddress, address to);

    function sendMessage(bytes calldata ipfsAddress, address to) external {
        emit MessageSend(ipfsAddress, to);
    }
}
