/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.0;

contract Atom {
    
    uint deaDline;
    bytes20 iMage;
    address Buyer;
    address Seller;
    event Atomo(address);
    
    function Atom(address _buyer, bytes20 _image, uint _window) payable {
        
        deaDline = now + _window;
        Buyer = _buyer;
        Seller = msg.sender;
        iMage = _image;
        Atomo(address(this));
    }
    
    function Burn() public returns(bool) {
        require (msg.sender == Seller);
        require (now > deaDline);
        return true;
        selfdestruct(msg.sender);
    }
    function Claim(bytes _pre) public returns(bool) {
        require (msg.sender == Buyer);
        require (iMage == sha256(_pre));
        return true;
        selfdestruct(msg.sender);

    }
}

contract SwapGen {
    
    Atom _swap;
    
    function Ofertar(address _buyer, bytes20 _image, uint _window) public payable {
        
        // _swap = new Atom(_buyer, _image, _window);
        // address(_swap).transfer(msg.value);
        _swap = (new Atom).value(msg.value)(_buyer, _image, _window);

    }
    
    
}
