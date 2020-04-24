/**
 *Submitted for verification at Etherscan.io on 2019-01-29
*/

pragma solidity ^0.5.0;

contract KNBRoom {
    
    mapping (address => bytes32) public hashedChoises;
    mapping (address => uint8) openedChoices;
    
    address[] public players;
    
    uint8 public choisesDone = 0;
    uint8 public opened = 0;
    
    address public winner;
    uint8 public winnerNum = 0;
    
    event StandOff(string _msg);
    event Win(string _msg, address _winner, uint8 _winnerNum);
    event PlayerJoined(address _newPlayer);
    event PlaerMakeChoise(address _player);
    event PlayerOpenChoise(address _player, uint8 _choice);
    
    constructor(address _firstPlayer) public {
        players.push(_firstPlayer);
    }
    
    
    /**
     * To set choice you must generate hash with choice + random numbers;
     * param uint8 - Your choice from 1 to 3;
     *  1 - камень
     *  2 - ножницы
     *  3 - бумага
     * param uint8 - Random number from 1 to 100;
     * return bytes32 Use this for setChoice() method;
     */
    function genHash(uint8 _choice, uint8 _random) public pure returns (bytes32) {
        
        require(_choice >= 1 && _choice <= 3, "Must choince from 1 to 3");
        require(_random >= 1 && _choice <= 100, "Random must be from 1 to 100");
        bytes memory b = new bytes(_choice ^ _random);
        bytes32 key = keccak256(b);
        return key;
    }
    
    /**
     * Use getHash() method to make choice;
     */
    function setChoice(bytes32 _hash) public {
        //require(players.length == 2);
        require(hashedChoises[msg.sender] == '', "Alredy bet");
        hashedChoises[msg.sender] = _hash;
        choisesDone++;
        emit PlaerMakeChoise(msg.sender);
    }
    
    function joinGame() public {
            
        require(!isPlayer(msg.sender), "You already in game!");
        require(players.length == 1, "Game is full");
        players.push(msg.sender);
        emit PlayerJoined(msg.sender);
    }
    
    function openUp(uint8 _secret) public {
        require(choisesDone == 2, "Not all choices done");
        require(isPlayer(msg.sender), "You are not a player");
        for(uint8 _bet = 1; _bet <= 3; _bet++) {
            
            bytes32 hash = genHash(_bet, _secret);
            if (hash == hashedChoises[msg.sender]) {
                openedChoices[msg.sender] = _bet;
                opened++;
                emit PlayerOpenChoise(msg.sender, _bet);
                if (opened == 2) {
                    return setWinner();
                }
                return;
            }
         }
         revert("Wrong secret");
    }
    
    function setWinner() internal {
        
        require(opened == 2, "Why i'm here?!!");
        uint8 ch0 = openedChoices[players[0]];
        uint8 ch1 = openedChoices[players[1]];
        if (ch0 == ch1) { //begin again
            return clear();
        } else if (ch0 == 1 && ch1 == 2 || ch0 == 2 && ch1 == 3 || ch0 == 3 && ch1 == 1) { //first win
            winnerNum = 1;
        } else {
            
            winnerNum = 2;
        }
        winner = players[winnerNum - 1];
        
        emit Win("The winner is:", winner, winnerNum);
    }
    
    function clear() internal {
        
        choisesDone = 0;
        opened = 0;
        for(uint8 i = 0; i < players.length; i++) {
            address _addr = players[i];
            hashedChoises[_addr] = '';
            openedChoices[_addr] = 0;
        }
        emit StandOff("No winner. Start again!");
    }
    
    function isPlayer(address _addr) internal view returns (bool) {
        
        for(uint8 i = 0; i < players.length; i++) {
            if (_addr == players[i]) return true;
        }
        return false;
    }
    
}

/**
 * Creartes new games with current user as first player
 */
contract KNBMaker {
    
    event NewGame(address _newRoom);
    function newGame() public returns (address _newRoom){

        KNBRoom room = new KNBRoom(msg.sender);
        emit NewGame(address(room));
        return address(room);
    }
}
