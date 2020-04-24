/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.24;

contract NBAX {
    using SafeMath for *;
    string public name = "NBAX";
    string public symbol = "nba";
    
    mapping(address => bool) public admins;
    bool public activated = false;

    uint unreachable;
    uint minBetPrice = 0.05 ether;
    uint public bettimes;// 总投注次数
    uint public gamespot; // 总流水
    uint public reachablepot; // 
    address airpot;
    uint withdrawdelay;

    mapping(uint => game) public games; // 比赛列表
    mapping(uint => gamedetail) public gamedetails;
    mapping(uint => mapping(address => mapping(uint => uint))) public gameplayerbet; // 某场比赛 某个人 在某个队 投注了多少
    mapping(address => mapping(uint => bool)) public resolved; // 某人 某场比赛是否已经提款
    mapping(address => uint[]) public playergames; // 某人投注过的比赛
    mapping(address => uint) public playergametimes; // 某人 已经投注的数量
    uint[] public gameids;
    uint gameidfrom;
    uint gameidto;

    struct gamedetail {
        uint id;
        bool aired;
        uint balance;
        address[] team1players;
        address[] team2players;
        address firstplayer; // 第一个投注的人
        address lastplayer;// 最后一个投注的人
        uint firstplayerTeam;// 第一个投注的人 投注的队
        uint lastplayerTeam;
    }
    struct game {
        uint id;// 比赛编号
        uint timestamp;// 开始时间
        uint teampot1;// 主队 投注池
        uint teampot2;// 客队 投注池
        
        uint playerNum1;// 主队 投注人数
        uint playerNum2;// 客队 投注人数

        uint team1;// 主队
        uint team2;// 客队
        uint winner;// 
        uint team1point; // 主队最终分数
        uint team2point;// 客队最终分数
        uint8 status; // 状态 0 1 2

        uint winpot;
        uint bettimes;
    }

    constructor()
    public
    {
        admins[msg.sender] = true;
        withdrawdelay = 2 hours;
    }

    function setting(address _addr, uint from , uint to, uint delay)
    onlyOwner()
    public
    {
        if (_addr != address(0x0)){
            airpot = _addr;
        }
        
        require(from < to,"invalid");
        if (from != 0){
            gameidfrom = from;
        }
        if (to != 0) {
            gameidto = to;
        }
        if (delay > 0) {
            withdrawdelay = delay;
        }
    }

    function airpotSuprise(uint id, uint max)
    onlyOwner()
    public
    payable
    {
        uint random = airdrop(max);
        if (games[id].playerNum1 > random) {
            gamedetails[id].team1players[random].transfer(msg.value);
        }else{
            gamedetails[id].team2players[random - games[id].playerNum1].transfer(msg.value);
        }
    }

    function airdrop(uint max)
    private 
    view 
    returns(uint)
    {
        uint seed = uint(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));
        uint randomnum = (seed - ((seed / max) * max));
        return (randomnum);
    }

    function getSetting()
    onlyOwner()
    public
    view
    returns(address,uint,uint,uint)
    {
        return (airpot,gameidfrom,gameidto, withdrawdelay);
    }

    function setAdmin(address _addr)
    public
    payable
    {
        require(admins[msg.sender] == true,"not administrator");
        admins[_addr] = true;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        require(_addr == tx.origin);
        
        uint _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry human only");
        _;
    }
    
    modifier onlyOwner() {
        require(admins[msg.sender], "admin only");
        _;
    }
    
    function()
    public
    payable
    {
        unreachable += msg.value;
    }

    function getPlayersByGameID(uint id, uint8 team) constant public returns (address[]) {
        if (team == 1){
            return gamedetails[id].team1players;
        }
        return gamedetails[id].team2players;
    }

    function setGame(uint id, uint team1, uint team2, uint timestop)
    onlyOwner()
    public
    {
        require(team1 != team2,"invalid");
        require(games[id].status == 0,"invalid");
        gameids.push(id);
        games[id].id = id;
        gamedetails[id].id = id;
        games[id].team1 = team1;
        games[id].team2 = team2;
        games[id].timestamp = timestop;
        games[id].status = 1;
    }

    function getOwnBet(uint id)
    isHuman()
    public
    view
    returns(uint,uint)
    {
        return (gameplayerbet[id][msg.sender][1],gameplayerbet[id][msg.sender][2]);
    }

    function isFirstPlayerWin(uint id)
    public
    view
    returns(bool){
        return (gamedetails[id].firstplayerTeam == games[id].winner);
    }

    function isLastPlayerWin(uint id)
    public
    view
    returns(bool){
        return (gamedetails[id].lastplayerTeam == games[id].winner);
    }

    function getAirPotByID(uint id)
    public view
    returns(uint){
        uint air;
        if (isLastPlayerWin(id) == false) {
            air += games[id].winpot * 5 / 100;
        }

        if (isFirstPlayerWin(id) == false) {
            air += games[id].winpot * 5 / 100;
        }
        return (air);
    }

    function getWinByGame(uint id)
    isHuman()
    public
    view
    returns(uint)
    {
        require(gameplayerbet[id][msg.sender][1] > 0 || gameplayerbet[id][msg.sender][2] > 0);
        require(games[id].status == 2);

        uint win = 0;
        if (games[id].winner == games[id].team1) {
            if (gameplayerbet[id][msg.sender][1] > 0){
                win += gameplayerbet[id][msg.sender][1];

                win += (gameplayerbet[id][msg.sender][1] / games[id].teampot1) * games[id].teampot2 * 9 / 10;

                if (isLastPlayerWin(id) && gamedetails[id].lastplayer == msg.sender) {
                    win += games[id].teampot2 * 5 / 100;
                }

                if (isFirstPlayerWin(id) && gamedetails[id].firstplayer == msg.sender) {
                    win += games[id].teampot2 * 5 / 100;
                }
            }
        }

        if (games[id].winner == games[id].team2) {
            if (gameplayerbet[id][msg.sender][2] > 0){
                win += gameplayerbet[id][msg.sender][2];

                win += (gameplayerbet[id][msg.sender][2] / games[id].teampot2) * games[id].teampot1 * 9 / 10;

                if (isLastPlayerWin(id) && gamedetails[id].lastplayer == msg.sender) {
                    win += games[id].teampot1 * 5 / 100;
                }

                if (isFirstPlayerWin(id) && gamedetails[id].firstplayer == msg.sender) {
                    win += games[id].teampot1 * 5 / 100;
                }
            }
        }

        return (win);
    }

    function subit(uint a, uint b)
    private
    pure
    returns(uint){
        if (a <= b) {
            return 0;
        }
        return (a - b);
    }

    event withdrawhistorylog(address indexed player, uint time, uint win, bool isforce, bool isless);
    function withdraw(uint id, bool force)
    isHuman()
    public
    {
        require(resolved[msg.sender][id] == false,"");
        require(now > games[id].timestamp + withdrawdelay);
        require(gamedetails[id].balance > 0 ,"invalid");
        uint win = getWinByGame(id);
        uint balance = address(this).balance;

        if (balance >= win){
            msg.sender.transfer(win);
            resolved[msg.sender][id] = true;
            emit withdrawhistorylog(msg.sender,now,win,force,false);
            gamedetails[id].balance = subit(gamedetails[id].balance,win);
        }else if (force == true){
            msg.sender.transfer(balance);
            resolved[msg.sender][id] = true;
            emit withdrawhistorylog(msg.sender,now,win,force,true);
            gamedetails[id].balance = subit(balance,win);
        }
        
        if (gamedetails[id].aired == false){
             uint thisairpot = getAirPotByID(id);
             if (thisairpot > 0){
                 airpot.transfer(thisairpot);
             }
             gamedetails[id].aired = true;
        }
    }

    function withdrawovertime(uint id)
    onlyOwner()
    public
    {
        require(now > games[id].timestamp + 30 days,"invalid");
        require(gamedetails[id].balance > 0,"invalid");
        unreachable += gamedetails[id].balance;
        gamedetails[id].balance = 0;
    }

    function withdrawUnreachable()
    onlyOwner()
    public
    {
        require(unreachable > 0,"invalid");
        if (address(this).balance < unreachable){
            unreachable = address(this).balance;
        }
        msg.sender.transfer(unreachable);

        unreachable = 0;
    }

    function openGame(uint id, uint winner, uint team1point , uint team2point)
    onlyOwner()
    public
    {
        // require(games[id].status == 1,"invalid");
        // require(games[id].timestamp > now - 5 minutes);
        if (team1point > team2point){
            require(winner == games[id].team1,"invalid");
        }else{
            require(winner == games[id].team2,"invalid");
        }
        games[id].winner = winner;
        games[id].team1point = team1point;
        games[id].team2point = team2point;
        games[id].status = 2;

        games[id].winpot = games[id].teampot1;
        if (winner == games[id].team2){
            games[id].winpot = games[id].teampot2;
        }
    }

    function betGame(uint id, uint team)
    isHuman()
    public
    payable
    {
        require(id >= gameidfrom && id <= gameidto,"invalid");
        require(msg.value >= minBetPrice, "invalid");
        require(games[id].status == 1,"invalid");
        require(now <= games[id].timestamp,"invalid");
        bettimes++;
        games[id].bettimes++;
        if (gameplayerbet[id][msg.sender][1] == 0 && gameplayerbet[id][msg.sender][2] == 0){
            playergametimes[msg.sender] ++;
        }

        if (gamedetails[id].firstplayer == address(0x0)) {
            // firstplayer !
            gamedetails[id].firstplayer = msg.sender;
            gamedetails[id].firstplayerTeam = team;
        }

        // lastplayer
        gamedetails[id].lastplayer = msg.sender;
        gamedetails[id].lastplayerTeam = team;

        playergames[msg.sender].push(id);
        if (team == games[id].team1){
            games[id].teampot1 += msg.value;
            if (gameplayerbet[id][msg.sender][1] == 0){
                games[id].playerNum1 += 1;
                gamedetails[id].team1players.push(msg.sender);
            }
            gameplayerbet[id][msg.sender][1] += msg.value;
            
        }else if (team == games[id].team2){
            games[id].teampot2 += msg.value;
            if (gameplayerbet[id][msg.sender][2] == 0){
                games[id].playerNum2 += 1;
                gamedetails[id].team2players.push(msg.sender);
            }
            gameplayerbet[id][msg.sender][2] += msg.value;
        }

        gamespot += msg.value;
        gamedetails[id].balance += msg.value;
    }
}

library SafeMath {
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint a, uint b)
        internal
        pure
        returns (uint c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
}
