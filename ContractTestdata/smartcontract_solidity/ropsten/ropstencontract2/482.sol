/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.5.0;

contract notluck {
    address payable public owner;
    //Games.deployed().then(function(i) {app=i})
    constructor() public {
        owner = msg.sender;
        createGame(10000000000000000, 2, 2, "PvP 2 Players Ghost Runner", 100, true, true);
        createGame(25000000000000000, 1, 2, "2 Players Ghost Runner", 100, true, false);
        createGame(23000000000000000, 2, 2, "PvP 2 Players Ghost Runner", 100, true, true);
        createGame(100000000000000000, 2, 2, "PvP 2 Players Ghost Runner", 100, true, true);
        createGame(10000000000000000, 1, 3, "3 Players Ghost Runner", 100, true, false);
        createGame(10000000000000000, 1, 6, "6 Players Ghost Runner", 60, true, false);
    }


    modifier onlyOwner{
      require(
          msg.sender == owner,
          "Only owner can call this function."
      );
      _;
    }

    struct Player {
        uint index;
        address pAddress;
        uint buyinWithRake;
        uint position;
        uint score;
        uint winnings;
        bool paid;
        bool finished;
        bool created;
    }

    struct Game {
        uint gameID;
        string name;
        bool created;
        bool pvp;
        mapping(address => Player) players;
        uint playersAmount;
        uint prizePercentageDistribution;
        address[] playersAddresses;
        uint playersAddressesLength;
        uint playersConfirmedLength;
        uint buyin;
        uint rake;
        uint prizePool;
        bool finished;
        bool recreate;
    }

    mapping(uint => Game) public games;
    uint[] public gamesID;
    uint public gamesIDLength = 0;
    uint public contractBalance;
    uint public denominatorFee = 25; //4%

    // Event which would be emmitted once winner is found.
    event CreateGame(uint id, uint buyin, uint gameID, uint playersAmount, string name, bool pvp);
    event JoinGame(uint id, address player, uint buyinWithRake, uint playersConfirmedLength);
    event UpdateScore(uint id, address player, uint score);
    event GameWithdraw(uint id, address player);
    event PayPlayer(uint id, address player, uint winnings, uint position);
    event EndGame(uint id);

    function createGame(uint _buyin,
    uint _gameID,
    uint _playersAmount,
    string memory _name,
    uint _prizePercentageDistribution,
    bool _pvp,
    bool _recreate) public onlyOwner{
        require(!games[gamesIDLength].created, "Game already created");

        games[gamesIDLength].buyin = _buyin;
        games[gamesIDLength].rake = _buyin / denominatorFee;
        games[gamesIDLength].name = _name;
        games[gamesIDLength].prizePercentageDistribution = _prizePercentageDistribution;
        games[gamesIDLength].gameID = _gameID;
        games[gamesIDLength].playersAmount = _playersAmount;
        games[gamesIDLength].created = true;
        games[gamesIDLength].pvp = _pvp;
        games[gamesIDLength].recreate = _recreate;
        gamesID.push(gamesIDLength);
        emit CreateGame(gamesIDLength, _buyin, _gameID, _playersAmount, _name, _pvp);
        gamesIDLength = gamesIDLength + 1;

    }

    function joinGame(uint _id) public payable {
        require(games[_id].created, "Game does not exist");
        require(games[_id].playersConfirmedLength < games[_id].playersAmount, "Players pool already filled");
        require(msg.value == games[_id].buyin + games[_id].rake, "Amount sent not equal to buy in");
        require(!games[_id].players[msg.sender].paid, "player already paid");
        require(!games[_id].finished, "Game is finished");
        uint _rake = msg.value - games[_id].buyin;
        uint buyinWithRake = msg.value - _rake;
        games[_id].prizePool += buyinWithRake;
        contractBalance += _rake;

        if(!games[_id].players[msg.sender].created){
            games[_id].playersAddresses.push(msg.sender);
            games[_id].playersAddressesLength = games[_id].playersAddresses.length;
        }

        games[_id].players[msg.sender] = Player(games[_id].playersAddressesLength, msg.sender, buyinWithRake, 0, 0, 0, true, false, true);
        games[_id].playersConfirmedLength++;
        emit JoinGame(_id, msg.sender, buyinWithRake, games[_id].playersConfirmedLength);
    }

    function updateScore(uint _id, address player, uint score) public onlyOwner{
        require(games[_id].created, "Game does not exist");
        require(games[_id].players[player].paid, "Player didnt pay");
        require(!games[_id].players[player].finished, "Player already finished");
        require(!games[_id].finished, "Game is finished");
        games[_id].players[player].finished = true;
        games[_id].players[player].score = score;
        emit UpdateScore(_id, player, score);
    }

    function payPlayer(uint _id, address payable player, uint position, uint prize, bool closeGame) public onlyOwner{
        require(games[_id].created, "Game does not exist");
        require(games[_id].players[player].paid, "Player didnt pay");
        require(games[_id].players[player].finished || games[_id].pvp, "Player didnt finish yet");
        require(games[_id].players[player].position == 0, "Player position already set");
        require(!games[_id].finished, "Game is finished");
        games[_id].players[player].winnings = prize;
        games[_id].players[player].position = position;
        player.transfer(prize);
        games[_id].prizePool -= prize;
        emit PayPlayer(_id, player, prize, position);

        if(closeGame){
            games[_id].finished = true;
            contractBalance += games[_id].prizePool;
            games[_id].prizePool = 0;
            emit EndGame(_id);
        }
    }

    function withdraw(uint _id, address payable pAddress) public onlyOwner{
        require(games[_id].created, "Game has not been created");
        require(!games[_id].finished, "Game has finished");
        require(games[_id].players[pAddress].paid, "Player address doesn't match any player in game");
        require(!games[_id].players[pAddress].finished, "Player already played");
        pAddress.transfer(games[_id].players[pAddress].buyinWithRake);
        games[_id].prizePool -= games[_id].players[pAddress].buyinWithRake;
        games[_id].players[pAddress].paid = false;
        games[_id].playersConfirmedLength--;

        emit GameWithdraw(_id, pAddress);
    }

    function withdrawContractBalance(address payable _address) public onlyOwner{
        require(contractBalance > 0, "Contract balance must be greater than 0");
        _address.transfer(contractBalance);
    }

    function getPlayer(uint _id, uint pID) public view  returns(address, uint, uint, uint, uint, bool, bool){
        require(games[_id].created, "Game has not been created");
        require(games[_id].players[games[_id].playersAddresses[pID]].created, "Player does not exit");

        address pAdress = games[_id].playersAddresses[pID];
        Player memory player = games[_id].players[pAdress];
        return (pAdress, player.buyinWithRake, player.position, player.score, player.winnings, player.paid, player.finished);
    }
}
