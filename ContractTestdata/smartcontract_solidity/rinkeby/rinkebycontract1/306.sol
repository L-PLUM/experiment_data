/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.4.23;
contract Lottery{
    address  public manager; //address of lottery manager who will trigger the function in contract which will pick a winner
    address[]  public players;   //making a dynamic array for address of players
    address public lastWinner;

    constructor()  public {  
        manager=msg.sender ; //manager address will be the one who is deploying this smart contract
    }
    
    function enter() public payable{   //when a person wants to participate in lottery he do so by sending some amount of ether 
        require(msg.value > 0.01 ether);    //without sending ether more than 0.01 a person cant enter lottery        
        players.push(msg.sender);   //adding eligible player to lottery
    }
    
    function random() public view returns (uint)    //there is no way to generate a random number in solidity thus we are doing so by pseudo random generator
    {
       return uint(keccak256(block.difficulty,now,players)); //hash thes data(block difficulty ,timestamp and address of all players) by sha3 to generate a random number
    }
    
    modifier checkManager()
    {
        require(msg.sender==manager);
        _;
    }

    function pickWinner() public checkManager   
    {
        uint index=random() % players.length; 
        lastWinner= players[index];     //address of the winner
        players[index].transfer(address(this).balance); //transfer all money to the winner
        players=new address[](0);   //emptying the players array & reseting for next round
    }
    
    function getPlayers() public view returns(address[])
    {
        return players;
    }
}
