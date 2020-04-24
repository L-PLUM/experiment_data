/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity >=0.4.22 <0.6.0;

contract Send {
    address private _owner;
    struct recipient {
       string mess;
       address ad;
    }
    function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }
   function owner() public view returns(address) {
    return _owner;
  }
    modifier onlyOwner() {
    require(isOwner());
    _;
  }
    mapping(address => recipient) recipients;
  
    function message(string memory m, address a) public onlyOwner {
        recipient memory r;
        r.mess = m;
        r.ad = a;
        
    }
}
