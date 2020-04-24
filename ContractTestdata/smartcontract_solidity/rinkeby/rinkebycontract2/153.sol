/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity 0.5.3; 

contract Bereitstellen { 
    string public color; 

    event MessageChanged(address by, string name); 

    function setMessage(string memory _yourMessage) public { 
        color = _yourMessage; 
        emit MessageChanged(msg.sender, _yourMessage);
    }
}
