/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.4.21;

contract Oya {
    
    mapping(address => uint256) leftShares;
    mapping(address => uint256) rightShares;
    
    address[] participants;
    
    uint256 totalLeft;
    uint256 totalRight;
    uint256 minEther = 100 wei;
    uint256 fee = 1000; //.1%
    uint currentParticipant = 0;
    
    uint timeout;
    
    address owner;
    
    constructor () public {
        owner = msg.sender;
        reset();
    }
    
    function test() public {
        totalRight = totalRight;
    }
    
    function reset() private {
        currentParticipant = 0;
        participants.length = 0;
        totalRight = 0;
        totalLeft = 0;
        timeout = now + 24 hours;//change this to blocks to make it more predictable?
    }
    
    function payout () public {//is 50 rounds small enough?
        require (now > timeout); //uncomment
        
        uint256 totalWinner;
        uint256 totalLoser;
        
        if (totalLeft > totalRight) {
            totalWinner = totalLeft;
            totalLoser = totalRight;
        } else if (totalRight > totalLeft) {
            totalWinner = totalRight;
            totalLoser = totalLeft;
        } else {
            //if tie, extend the game
            timeout += 1 hours;
            return;
        }
        
        //Gotta do this in rounds of 50 so contract doesn't run out of gas
        uint256 end = currentParticipant + 50;
        
        for (; currentParticipant < end; currentParticipant++) {
            
            if (currentParticipant == participants.length) {
                if (owner.send(address(this).balance)) {
                    reset();
                    return;
                }
            }

            address player = participants[currentParticipant];

            uint256 winnerShares;
            if (totalLeft > totalRight) {
                winnerShares = leftShares[player];
            } else if (totalRight > totalLeft) {
                winnerShares = rightShares[player];
            }
            
            uint256 winnings = winnerShares*totalLoser/totalWinner;
            winnings -= (winnings/fee); //fee
            //player recieves orginal shares + proportion of loser shares minus fee
            winnings += winnerShares;
            
            leftShares[player] = 0;
            rightShares[player] = 0;
            delete participants[currentParticipant];
            
            if (winnings > 0) {
                player.send(winnings);
            }
        }
    }
    
    function addTime (uint amt) private {
        if (totalLeft + totalRight == 0) {
            return;
        }
        
        uint time = amt*120/(totalLeft+totalRight);
        timeout += time * 60;
        
        if (timeout > now + 24 hours) {
            timeout = now + 24 hours;
        }
    }
    
    function voteLeft () public payable {
        require (msg.value > minEther);
        require (now < timeout);
        
        if (leftShares[msg.sender] == 0 && rightShares[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        
        addTime(msg.value);
        
        totalLeft += msg.value;
        leftShares[msg.sender] += msg.value;
    }
    
    function voteRight () public payable {
        require (msg.value > minEther);
        require (now < timeout);
        
        if (leftShares[msg.sender] == 0 && rightShares[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        
        addTime(msg.value);
        
        totalRight += msg.value;
        rightShares[msg.sender] += msg.value;
    }
    
    function getLeft() public constant returns (uint256) {
        return totalLeft;
    }
    
    function getRight() public constant returns (uint256) {
        return totalRight;
    }
    
    function getTime() public constant returns (uint256) {
        return timeout-now;
    }
    
    // function () payable {
    //     msg.sender.send(msg.value);
    // }
    
    
}
