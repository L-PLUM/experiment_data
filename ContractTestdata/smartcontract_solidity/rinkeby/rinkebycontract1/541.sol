/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity >0.4.23 <0.6.0;

contract BillOfSale {
	address public seller;
	address public buyer;
	string public descr;
	uint public price;
    
	constructor(string _descr, uint _price,
    	address _seller, address _buyer) public {
    	descr = _descr;
    	price = _price;
    	seller = _seller;
    	buyer = _buyer;
	}
    
	function confirmPurchase() public payable {
    	require(msg.sender == buyer, "only buyer can fund price");
    	require(price == msg.value);
	}
    
	function confirmReceipt() public {
    	require(msg.sender == buyer, "only buyer can confirm");
    	seller.transfer(address(this).balance);
	}
}
