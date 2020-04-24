/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity 0.5.1;


// rock paper scissors

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "");
        owner = newOwner;
    }

}

contract Game is Ownable {
    
    struct Player {
        address addr;
        bytes32 betHash;
        bool confirm;
        uint bet;
    }

    struct Round {
        uint numPlayers;
        mapping (uint => Player) players;
    }

    uint public numRounds;
    mapping (uint => Round) public rounds;

    function newRound() public onlyOwner returns (uint) {
        uint roundID = numRounds++;
        rounds[roundID] = Round(0);
        return roundID;
    }

    function setBet(bytes32 _betHash) public returns (uint) {
        require(rounds[numRounds].numPlayers < 2, "");
        
        Round storage c = rounds[numRounds];
        
        uint playerNum = c.numPlayers;
        c.players[playerNum] = Player({addr: msg.sender, betHash: _betHash, confirm: false, bet: 0});
        c.numPlayers++;
        
        return playerNum;
    }

    function confirmBet(uint256 _roundID, uint256 _playerNum, uint256 _hand, uint256 _secretKey) public {
        require(_roundID < numRounds);
        require(rounds[_roundID].players[_playerNum].betHash == betToBytes32(_hand, _secretKey));
        require(_hand <= 2); // rock is 0, scissors is 1, paper is 2
        
        rounds[_roundID].players[_playerNum].confirm = true;
        rounds[_roundID].players[_playerNum].bet = _hand;
    }
    
    function getWinner(uint256 _roundID) public view returns (address) {
        require(rounds[_roundID].players[0].confirm, "");
        require(rounds[_roundID].players[1].confirm, "");
        
        uint bet1 = rounds[_roundID].players[0].bet;
        uint bet2 = rounds[_roundID].players[1].bet;
        
        uint numWinner = checkWinner(bet1, bet2);
        
        require(numWinner != 2, "draw");
        
        return rounds[_roundID].players[numWinner].addr;
    }
    
    function betToBytes32(uint256 _hand, uint256 _secretKey) public pure returns (bytes32) {
        require(_hand <= 2); // rock is 0, scissors is 1, paper is 2

        return keccak256(abi.encodePacked(_hand, _secretKey));
    }
    
    function checkWinner(uint256 _bet1, uint256 _bet2) public pure returns (uint) {
        // rock is 0, scissors is 1, paper is 2
        if (_bet1 == _bet2) {
            return 0;
        }
        
        if (
            ((_bet1 == 0) && (_bet2 == 1))
            || ((_bet1 == 1) && (_bet2 == 2))
            || ((_bet1 == 2) && (_bet2 == 0))
        ) {
            return 0;
        } else {
            return 1;
        }
        
    }
    
}
