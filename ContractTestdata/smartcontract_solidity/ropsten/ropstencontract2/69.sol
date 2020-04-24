/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity >= 0.5.0 < 0.6.0;

contract SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ballot is SafeMath {
    
    struct Bet {
        address payable backer;
        address payable layer;
        uint game_prediction;        //1-home win, 2- away win, 3 - draw
        uint odd;                   //multiplied by 10 (odd => 2.6      send =>26 )
        uint layer_stake;
        uint backer_stake;
        uint game_id;
        uint bet_id;
        uint game_Result;         //1-home win, 2- away win, 3 - draw
        bytes32 names;
    }
    
    struct User {
       uint[] user_bets;
    }

    uint[] open_bets;    //bets that are created without bet_against
    uint[] closed_bets;  //bets that have been bet_against but not yet finished
    
    address public owner;
    uint256  betid;
    uint public houseEdge;
    mapping(address => User) users;
    mapping(uint => Bet) bets;
    
    event GameFinish(address backer, address layer, uint game_prediction, uint game_Result);
    
    constructor() public {
        owner = msg.sender;
        betid = 1;
        houseEdge = 98; //2% commission
    }
    
    function create_bet(address payable _layer, uint _prediction, uint _odds, uint _game_id, bytes32 _names) public payable returns (uint) {
        require(_layer != address(0));
        require(_odds < 260 && _odds > 10);
        require(msg.value > 0);
        uint queryId = betid;
        betid++;
        bets[queryId] = Bet(address(0), _layer, _prediction, _odds, msg.value, 0, _game_id, queryId, 0 , _names);
        open_bets.push(queryId);
         return queryId;
    }
    
    function bet_against(address payable _backer, uint _bet_id) public payable  {
        require(_bet_id != 0);
        require(_backer != address(0));
        require(msg.value > 0);
        bets[_bet_id].backer = _backer;
        bets[_bet_id].backer_stake = msg.value;
        removefromopenbets(_bet_id);
        closed_bets.push(_bet_id);
    }
    
      
    function trigger_final(uint _bet_id, uint result) public payable onlyOwner () {
        bets[_bet_id].game_Result = result;
        emit GameFinish(bets[_bet_id].backer, bets[_bet_id].layer, bets[_bet_id].game_prediction, bets[_bet_id].game_Result);
        
        if(result != bets[_bet_id].game_prediction) {
            //layer lost
            uint backerstk = ((bets[_bet_id].backer_stake * bets[_bet_id].odd / 10) * houseEdge) / 100;   //2% house feed
            uint amtToSend = bets[_bet_id].layer_stake - backerstk;
            bets[_bet_id].layer.transfer(amtToSend);
            bets[_bet_id].backer.transfer(backerstk);
            
        } else {
            //layer won
            uint backerstk = ((bets[_bet_id].backer_stake) * houseEdge) / 100;   //2% house feed
            bets[_bet_id].layer.transfer(backerstk);
        }
    }
	
	function close_openbet(uint _bet_id) public payable onlyOwner () {
		//emit event!!
		
		for (uint i=0; i< open_bets.length; i++) {
            if(open_bets[i] == _bet_id){
				uint amtToSend = bets[_bet_id].layer_stake;
				bets[_bet_id].layer.transfer(amtToSend);
                open_bets[i] = open_bets[open_bets.length-1];
                open_bets.length--;
                return;
            }
        }
		return;
    }
    
   function removefromopenbets(uint _assetToDelete) internal  {
        for (uint i=0; i< open_bets.length; i++) {
            if(open_bets[i] == _assetToDelete){
                open_bets[i] = open_bets[open_bets.length-1];
                open_bets.length--;
                return;
            }
        }
		return;
    }

     function withdrawBalance(uint amount) public payable onlyOwner {
        require(msg.sender != address(0));
        uint balance = sub(address(this).balance, amount);
        msg.sender.transfer(balance);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
  
    function getbalance() public view returns (uint) {
        return address(this).balance;
    }
    function getopenbets() public view returns (uint[] memory) {
        return open_bets;
    }
    function getclosedbets() public view returns (uint[] memory) {
        return closed_bets;
    }

    function getBet(uint _id) public view returns (address, address, bytes32,  uint, uint, uint, uint, uint, uint) {
        Bet memory _bet = bets[_id];
        return (_bet.backer, _bet.layer, _bet.names, _bet.odd,  _bet.backer_stake,  _bet.layer_stake,  _bet.game_prediction,  _bet.game_Result,  _bet.game_id);
    }    
    
     function setHouseEdge(uint value) public onlyOwner {
            houseEdge = value;
    }
}
