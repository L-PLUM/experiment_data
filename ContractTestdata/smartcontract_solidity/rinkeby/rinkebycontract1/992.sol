/**
 *Submitted for verification at Etherscan.io on 2019-01-31
*/

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable _owner;
    address payable _creator; 

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        _creator = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return (msg.sender == _owner) || (msg.sender == _creator);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}

contract Recoverable is Ownable {
    
    function recover() external onlyOwner {
        address myAddress = address(this);
        _owner.transfer(myAddress.balance);
    }
}

contract Commented is Ownable{
    string public comment;

    function setName(string memory newName) public onlyOwner {
        comment = newName;
    }
    
}

contract Events {
    enum Way { Send, Call, Transfer }
    event BeforeDeliveredOrAttempted(address destination, uint amount, Way way);
    event AfterDeliveredAttempted(address destination, uint amount, Way way);
}

contract doesTransfers is Ownable, Events {
    address payable [5] public transReceivers = [address(0x0),address(0x0),address(0x0),address(0x0),address(0x0)];
    uint public valueForTransfers = 1;
    
    bool public transferON = false;
    
    function setCallFalse() public onlyOwner {
        transferON = false;
    }
    function setCallTrue() public onlyOwner {
        transferON = true;
    }
    
    function setTransferAddress(uint8 n, address payable x) public onlyOwner {
        require(n<5);
        transReceivers[n] = x;
    }
    function delTransferAddress(uint8 n) public onlyOwner {
        transReceivers[n] = address(0x0);
    }
    function setValueToTransfer(uint newValue) public onlyOwner {
        valueForTransfers = newValue;
    }
    
    function sendTransfers() public {
        if(transferON == true) {
        for(uint8 x = 0; x < 5; x++) {
            if(transReceivers[x] != address(0x0)) {
                // send given amount of Wei to Address, reverts on failure, forwards 2300 gas stipend, not adjustable
                emit BeforeDeliveredOrAttempted(transReceivers[x], valueForTransfers, Way.Transfer);
                transReceivers[x].transfer(valueForTransfers);
                emit AfterDeliveredAttempted(transReceivers[x], valueForTransfers, Way.Transfer);
            }
        }
        }
    }
}

contract doesSending is Ownable, Events {
    address payable [5] public sendReceivers = [address(0x0),address(0x0),address(0x0),address(0x0),address(0x0)];
    uint public valueForSending = 7;
    
    bool public sendON = false;
    
    function setCallFalse() public onlyOwner {
        sendON = false;
    }
    function setCallTrue() public onlyOwner {
        sendON = true;
    }
    
    function setSendAddress(uint8 n, address payable x) public onlyOwner {
        require(n<5);
        sendReceivers[n] = x;
    }
    function delSendAddress(uint8 n) public onlyOwner {
        sendReceivers[n] = address(0x0);
    }
    function setValueToSend(uint newValue) public onlyOwner {
        valueForSending = newValue;
    }
    
    function sendSending() public {
        if(sendON == true) {
            for(uint8 x = 0; x < 5; x++) {
                if(sendReceivers[x] != address(0x0)) {
                    emit BeforeDeliveredOrAttempted(sendReceivers[x], valueForSending, Way.Send);
                    sendReceivers[x].send(valueForSending);
                    emit AfterDeliveredAttempted(sendReceivers[x], valueForSending, Way.Send);
                }
            }
        }
    }
}

contract doesCall is Ownable, Events {
    address payable [5] public callReceivers = [address(0x0),address(0x0),address(0x0),address(0x0),address(0x0)];
    uint public valueForCall = 7;
    bool public callOn = false;
    
    function setCallFalse() public onlyOwner {
        callOn = false;
    }
    function setCallTrue() public onlyOwner {
        callOn = true;
    }
    function setCallAddress(uint8 n, address payable x) public onlyOwner {
        require(n<5);
        callReceivers[n] = x;
    }
    function delCallAddress(uint8 n) public onlyOwner {
        callReceivers[n] = address(0x0);
    }
    function setValueToCall(uint newValue) public onlyOwner {
        valueForCall = newValue;
    }
    
    function sendCall() public {
        if(callOn == true) {
            for(uint8 x = 0; x < 5; x++) {
                if(callReceivers[x] != address(0x0)) {
                    emit BeforeDeliveredOrAttempted(callReceivers[x], valueForCall, Way.Call);
                    callReceivers[x].call.value(valueForCall)("");
                    emit AfterDeliveredAttempted(callReceivers[x], valueForCall, Way.Call);
                }
            }
        } 
    }
}

contract MoneyDistributor3 is Ownable, Recoverable, Commented, doesSending, doesTransfers, doesCall {
    event ReceivedMoney(address fromWhom, uint amount);
    function receive() payable external {
        emit ReceivedMoney(msg.sender, msg.value);
    }
    
    function() payable external {
        sendTransfers();
        sendCall();
        sendSending();
    }
    
  
}
