/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.5.1;

contract TotalSupplyHidden {
    
    address private owner;
    uint private totalSupply;
    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    constructor(address _owner) public {
        owner = _owner;
        totalSupply = 1000000;
    }
    
    function GetTotalSUpply() public view onlyOwner returns (uint) {
        return totalSupply;
    }
}
