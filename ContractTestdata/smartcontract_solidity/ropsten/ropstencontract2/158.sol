/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.4.25;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

contract attack_kaleidoscope {
    using SafeMath for *;
    string hint = "まんげきょう";
    string author = "luobobo";
    string references = "https://blog.peckshield.com/";
    
    uint256 roundStart;
    mapping (address => uint256) public balances;
    mapping (address => uint256) public ticket;
    mapping (address => uint256) public transferNum;
    
    mapping (address => uint256) public game1;
    mapping (address => uint256) public game2;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Score(address indexed _player, uint256 _score, string _game);
    event Announcement(string team, uint256 _score);
    
    constructor () payable{
        require(msg.value >= 1 ether);
        roundStart = now;
    }
    
    function scoreOf() public view returns(uint){
        return game1[msg.sender] + game2[msg.sender];
    }
    
    function welcome() public returns(string){
        balances[msg.sender] = 1;
        transferNum[msg.sender] = 0;
        return "let's begin!";
    }
    
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(transferNum[msg.sender] < 10);
        transferNum[msg.sender] = transferNum[msg.sender].add(1);
        return _transfer(msg.sender, _to, _value);     
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));
        uint256 oldFromVal = balances[_from];
        require(_value > 0 && oldFromVal >= _value);
        uint256 oldToVal = balances[_to];
        uint256 newToVal = oldToVal + _value;
        require(newToVal > oldToVal);
        uint256 newFromVal = oldFromVal - _value;
        balances[_from] = newFromVal;
        balances[_to] = newToVal;

        assert((oldFromVal + oldToVal) == (newFromVal + newToVal));
        emit Transfer(_from, _to, _value);

        return true;
    }
    
    // uint256 to bytes32
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    function buyTicket() 
        public 
    {
        require(balances[msg.sender] >= 1024);
        balances[msg.sender] = balances[msg.sender].sub(1024);
        ticket[msg.sender] = ticket[msg.sender].add(10);
    }
    
    function Game1() 
        public
    {
        require(ticket[msg.sender] >= 1);
        require(game1[msg.sender] <= 40);
        ticket[msg.sender] = ticket[msg.sender].sub(1);
        uint256 seed = block.timestamp;
        uint256 a = uint(sha256(toBytes(block.difficulty + seed))) % 1000;
        
        if (a < 10){
            msg.sender.transfer(0.001 ether);
            game1[msg.sender] += 1;
            emit Score(msg.sender, game1[msg.sender], "game1");
        }
        
    }

    function Game2() 
        public
    {
        require(ticket[msg.sender] >= 1);
        require(game2[msg.sender] <= 60);
        ticket[msg.sender] = ticket[msg.sender].sub(1);
        uint256 seed = block.timestamp + uint(msg.sender);
        uint256 a = uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % 1000;
        
        if (a < 20){
            game2[msg.sender] += 1;
            emit Score(msg.sender, game2[msg.sender], "game2");
        }
        
    }
    
    function announce(string _team)
        public
    {
        require(now - roundStart > 2 hours);
        emit Announcement(_team, scoreOf());
    }
    
}
