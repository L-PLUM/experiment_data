pragma solidity ^0.5.7;

import './ERC20.sol';
import './ERC20Detailed.sol';



contract ERC20Standard is ERC20, ERC20Detailed{

    constructor(string memory name,string memory symbol,uint8 decimals,uint totalSupply) ERC20Detailed(name, symbol, decimals) public{
        _mint(msg.sender, totalSupply);
	}
    
}
