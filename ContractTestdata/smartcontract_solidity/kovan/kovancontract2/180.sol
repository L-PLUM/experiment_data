/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^0.5.10;

contract Token {
    function transferFrom(address src, address dst, uint wad) public;
}

contract BandL {
    
    function() external payable {
        
    }
    
    struct lenderOffer {
        uint lBalance;
        uint lInterestRate;
        uint lOfferId;
    }
    
    lenderOffer[] public lendingList;
    
    
    mapping (address => lenderOffer) lOffer;
    
    mapping (address => uint[]) lOffersBy;
    
    function createLendOffer (uint _interestRate) public payable {
        uint _offerId = lendingList.length;
        lOffersBy[msg.sender].push(uint(_offerId));
        lOffer[msg.sender] = lenderOffer(msg.value, _interestRate, _offerId);
        lendingList.push(lenderOffer(msg.value, _interestRate, _offerId));
        
    }
    
    function offersByAddress (address _address) public view returns(uint[] memory) {
        return lOffersBy[_address];
    }
    
    function borrowFrom (uint _offerId, uint _amount) public payable {
        require(msg.value == 2 * _amount);
        msg.sender.transfer(_amount);
        lendingList[_offerId].lBalance = lendingList[_offerId].lBalance - _amount;
    }
    
    function checkBalance (address _address) public view returns(uint) {
        return _address.balance;
        
    }
    
    function transferFrom (address _contractAddress, address _from, address _to, uint _amount) public {
        Token myToken = Token(_contractAddress);
        myToken.transferFrom(_from, _to, _amount);
    }
    
}
