/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity >=0.4.22 <0.6.0;

contract Coin{
  mapping (address => uint256) public balanceOf;
  function transfer(address to, uint value) public returns (bool);
}

contract DappToken {
    address public owner;
    uint256 public buyPrice;
    string public detail;
    address public tokenAddress;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
    event BuyToken(address target, uint256 value, uint256 amount);

    function setPrices(uint256 _newBuyPrice) onlyOwner public {
        buyPrice = _newBuyPrice;
    }

    function settingDetail(string memory _tokenDetail) onlyOwner public {
        detail = _tokenDetail;
    }
    
    function withdraw() onlyOwner public {
        Coin token = Coin(tokenAddress);
        require(token.transfer(msg.sender, token.balanceOf(address(this))));
    }
    
    function buy() payable public {
        uint256 amount = msg.value / buyPrice;
        Coin token = Coin(tokenAddress);
        require(token.balanceOf(address(this)) >= amount);
        require(token.transfer(msg.sender, amount));
        emit BuyToken(msg.sender, msg.value, amount);
    }
}
