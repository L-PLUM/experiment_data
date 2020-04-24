/**
 *Submitted for verification at Etherscan.io on 2019-07-08
*/

pragma solidity ^0.4.23;

contract CuteCoinPriceOracle {

    mapping (address => bool) admins;

    // How much Tokens you get for 1 ETH, multiplied by 10^18
    uint256 public ETHPrice;

    event PriceChanged(uint256 newPrice);

    constructor() public {
        admins[msg.sender] = true;
    }

    function updatePrice(uint256 _newPrice) external {
        require(_newPrice > 0);
        require(admins[msg.sender] == true);
        ETHPrice = _newPrice;
        emit PriceChanged(_newPrice);
    }

    function setAdmin(address _newAdmin, bool _value) external {
        require(admins[msg.sender] == true);
        admins[_newAdmin] = _value;
    }
}
