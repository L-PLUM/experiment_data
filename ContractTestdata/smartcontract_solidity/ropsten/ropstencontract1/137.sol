/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.0;
contract ERC20{
    function totalSupply() public view returns (uint256);
    function transfer(address _destination,uint256 _shareValue) public  returns (bool);
    function balanceOf(address _who) public view returns(uint256);
    }

contract CryptoContract is ERC20 {
    
    mapping(address => uint256)public balance;
    
    uint256 totalTokens;
    string public name;
    string public symbol;
    uint8 public decimal;
    
    constructor() public{
        totalTokens = 100000 * 10**18;
        balance[tx.origin] = totalTokens;
        name="anonymous";
        symbol="anonymous";
        decimal=18;
    }
    
    function transfer(address _destination , uint256 value) public returns (bool){
        require(balance[msg.sender]>=value);
        balance[msg.sender]=balance[msg.sender]-value;
        balance[_destination]=balance[_destination]+value;
        return true;
    }
    function totalSupply() public constant returns (uint256){
        return totalTokens;
    }
    function balanceOf(address _destination)public constant returns (uint256){
        return (balance[_destination]);
    }
    
    
}
