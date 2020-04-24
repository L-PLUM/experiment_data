/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.10;

contract Deroulette
{
    struct Bet
    {
        uint256 block;
        uint256 number;
        uint256 amount;
    }
    
    mapping (address => Bet) public last;
    
    function() external payable
    {
        require(msg.data.length > 0);
        
        uint256 number = uint8(msg.data[0]);
        require(1 <= number && number <= 36);
        
        Bet storage bet = last[msg.sender];
        
        if(bet.amount > 0)
        {
            uint256 random_basis = uint256(blockhash(bet.number));
            uint256 random = random_basis % 37;
            if(random == bet.number)
            {
                msg.sender.transfer(bet.amount*36);
            }
        }
        
        bet.block = block.number;
        bet.number = number;
        bet.amount = msg.value;
    }
    
    function get_block_hash(uint256 number) public view returns (bytes32)
    {
        return blockhash(number);
    }
}
