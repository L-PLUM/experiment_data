/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.18;

contract TakeSeatEvents {
	// 
	event BuyTicket (
        address indexed plyr
    );
	//
	event Withdraw (
        address indexed plyr,
		uint256 indexed value,
		uint256 indexed num
    );
}

contract TakeSeat is TakeSeatEvents {
	uint256 constant private BuyValue = 1000000000000000000;
	address private admin_;
	uint256 private closed_;

	constructor() public {
		admin_ = msg.sender;
		closed_ = 0;
	}
	
	modifier notClosed() {
        require(closed_ == 0, "not closed"); 
        _;
    }
	
	modifier olnyAdmin() {
        require(msg.sender == admin_, "only for admin"); 
        _;
    }
	
	modifier checkBuyValue(uint256 value) {
        require(value == BuyValue, "please use right buy value"); 
        _;
    }
	
	modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
	
	function buyTicket() isHuman() checkBuyValue(msg.value) notClosed() public payable {
		emit TakeSeatEvents.BuyTicket(msg.sender);
	}
	
	function withdraw(address addr, uint256 value, uint256 num) olnyAdmin() public {
		addr.transfer(value);
		emit TakeSeatEvents.Withdraw(addr, value, num);
	}
	
	function isClosed() view public returns(uint256 c) {
	    return (closed_);
	}
	
	function close() olnyAdmin() public {
		closed_ = 1;
	}
}
