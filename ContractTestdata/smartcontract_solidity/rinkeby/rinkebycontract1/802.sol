/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.24;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);    
}

contract TokenSale {
    IERC20Token public tokenContract;  
    uint256 public price;              
    address owner;
    uint256 public tokensSold;
    bool public saleEnd;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
        saleEnd = false;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(saleEnd == false);
        require(msg.value == _numberOfTokens * price);
        require(tokenContract.balanceOf(this) >= _numberOfTokens);

        emit Sold(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;

        require(tokenContract.transfer(msg.sender, _numberOfTokens));
    }

    function endSale() public {
        require(msg.sender == owner);
        require(tokenContract.transfer(owner, tokenContract.balanceOf(this)));
        owner.transfer(address(this).balance);
        saleEnd = true;
    }
}
