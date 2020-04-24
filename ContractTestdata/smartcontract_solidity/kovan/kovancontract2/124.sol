pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./CrowdsaleCompatible.sol";
import "./EditableToken.sol";
import "./ThirdPartyTransferableToken.sol";

contract ERC20Token is CrowdsaleCompatible, EditableToken, ThirdPartyTransferableToken {
    using SafeMath for uint256;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public
    {
        balanceOf[0xCC8Ec3419B5a273Af965bc144030c026bC4cB4a3] = uint256(888000000000000) * 10**18;
        emit Transfer(address(0x0), 0xCC8Ec3419B5a273Af965bc144030c026bC4cB4a3, balanceOf[0xCC8Ec3419B5a273Af965bc144030c026bC4cB4a3]);

        transferOwnership(0xCC8Ec3419B5a273Af965bc144030c026bC4cB4a3);

        totalSupply = 888000000000000 * 10**18;                  // Update total supply
        name = 'MaharlikaCoin';                                   // Set the name for display purposes
        symbol = 'MHLK';                               // Set the symbol for display purposes
        decimals = 18;                                           // Amount of decimals for display purposes
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () public {
        assert(false);     // Prevents accidental sending of ether
    }
}
