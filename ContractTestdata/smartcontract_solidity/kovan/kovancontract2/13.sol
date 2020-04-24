/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity 0.5.10;


contract ERC20 {
    uint256 public totalSupply;
    mapping (address => uint256) private balances;
    
    constructor(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }   
    
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }
    
    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "ERROR_NO_TOKEN");
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}
