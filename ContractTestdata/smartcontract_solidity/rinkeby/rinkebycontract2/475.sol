/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity ^0.4.12;

contract Test1 {
    
    address Sender1 = 0xe2eeaACfC6A5488aAcFB2131108AE7b59026Fe4b;
    address Sender2 = 0x07EC09F7fd204A835CAE76dc224242451C7aC1DC;
    address Sender3 = 0x22a9304E395f0657cFEC6d5E7A95C24702EED158;
            
    function transfer() public {
        uint256 current_balance = address(this).balance;
        Sender1.transfer(current_balance/4);
        Sender2.transfer(current_balance/4);
        Sender3.transfer(current_balance/4);
    }
            
    function() payable { }
}
