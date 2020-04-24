/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.4.23;

contract Purchase {
    uint public value;
    address public seller;
    address public buyer;
    enum State { Available, Locked, Inactive }
    State public state;

    // Ensure that msg.value is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.
    constructor() public payable {  //建構子 程式開始的佈建
        seller = msg.sender;
        value = msg.value;
    }
    modifier onlyBuyer() {
        require(
            msg.sender == buyer,
            "Only buyer can call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();


    /// Confirm the purchase as buyer.
    /// Transaction has to include 2 * value ether.
    /// The ether will be locked until confirmReceived
    /// is called.

    event LogPurchase(address selleradd, address seller, uint value);
    function Pay(address _selleradd)public payable{
        _selleradd.transfer(msg.value);
        emit LogPurchase(_selleradd, msg.sender, msg.value);
    }
    
    
    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
}
