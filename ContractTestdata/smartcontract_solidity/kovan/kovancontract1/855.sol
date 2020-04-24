/**
 *Submitted for verification at Etherscan.io on 2018-12-24
*/

pragma solidity >=0.4.0 <0.6.0;

contract NetMonitor {
    
    address public owner;
    
    // true means UP, false means DOWN
    bool public previous_status;
    bool public current_status;
    
    event LogPreviousStatus(bool status);
    event LogCurrentStatus(bool status);
    event LogWentUp(uint256 timestamp);
    event LogWentDown(uint256 timestamp);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner is allowed to do this");
        _;
    }

    function update(bool _current_status) onlyOwner public {
        previous_status = current_status;
        current_status = _current_status;
        
        emit LogPreviousStatus(previous_status);
        emit LogCurrentStatus(current_status);

        if (!previous_status && current_status) {
            emit LogWentUp(now);
        }

        if (previous_status && !current_status) {
            emit LogWentDown(now);
        }
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
}
