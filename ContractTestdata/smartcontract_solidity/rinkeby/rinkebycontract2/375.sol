/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

pragma solidity ^0.5.8;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract SmartJackPot is Ownable {
    using SafeMath for uint256;
    
    enum RoundState {started, spinning, finished}

    event MakeNewBet(address indexed betAddress, uint betNum, uint betTime, uint roundId);

    event StopRound(address indexed to, uint numberRound, uint winNum, uint jackPotSumm);

    struct Bet {
        address payable betAddress;
        uint betNum;
        uint betTime;
        uint win;    // статус выйграл или нет
    }

    struct Round {
        bool isDone;
        RoundState state;
        uint winNum;
        uint lastBet;
    }

    mapping(uint => Round) public roundsHistory;
    
    mapping(address => uint[]) public betsUser;

    uint public lastRound;
    
    uint numbersCount = 99;
    
    uint public jackPot;
    
    uint public betAmount = 1 ether;
    
    uint public percentDev = 10;
    
    Bet[] public bets;
    
    uint[] betsNum = new uint[](numbersCount);

    function () external payable {
        makeBet();
    }
   
    function setRoundState(uint _roundId) public onlyOwner{
        require(bets.length > 0);
        Round storage round = roundsHistory[_roundId]; 
        round.state = RoundState.spinning;
    }
   
    function makeBet() internal {
       require(msg.value == betAmount);
       require(msg.data.length >= 32);
       Round storage round = roundsHistory[lastRound.add(1)];
       require(uint(round.state) == 0);
       uint betNum = bytesToUint(msg.data, 0);
       Bet memory newBet = Bet(msg.sender, betNum, now, 0);
       bets.push(newBet);
       betsUser[msg.sender].push(betNum);
       betsNum[betNum] =  betsNum[betNum] + 1;
       jackPot = jackPot.add(msg.value.mul(90).div(100));
       owner.transfer(msg.value.mul(percentDev).div(100));
       emit MakeNewBet(msg.sender, betNum, now, lastRound);
   }
   
    function stopRound(uint _roundId) public onlyOwner{
        Round storage round = roundsHistory[_roundId];
        require(!round.isDone);
        require(bets.length > 0);
        round.isDone = true;
        uint winNum = random(numbersCount);
        round.winNum = winNum;
        round.lastBet = bets.length;
        round.state = RoundState.finished;
        lastRound = _roundId;
        getWinAddress(winNum, 70);
        getWinAddress(winNum, 30);
        emit StopRound(msg.sender, _roundId, winNum, address(this).balance);
    }

    function getWinAddress(uint _winNum, uint _percentWin) internal {
        if(betsNum[_winNum] != 0 && _percentWin == 70){
            uint winSumm = address(this).balance.mul(_percentWin).div(100).div(betsNum[_winNum]);
        
            uint i = 0;
            while(i < bets.length){
                if(bets[i].betNum == _winNum){
                    bets[i].betAddress.send(winSumm);
                }
    
                i++;
            } 
            
        } 
        uint winNum_1_bol;
        uint winNum_1_men;
        if(_winNum == numbersCount){
            winNum_1_bol = 0;
            winNum_1_men = _winNum.sub(1);
        } else if(_winNum == 0){
            winNum_1_bol = _winNum.add(1);
            winNum_1_men = numbersCount;
        } else {
            winNum_1_bol = _winNum.add(1);
            winNum_1_men = _winNum.sub(1);
        }
        uint summ = betsNum[winNum_1_bol].add(betsNum[winNum_1_men]);
        if(betsNum[winNum_1_bol] != 0 && _percentWin == 30){
            
            uint winSumm_2 = address(this).balance.mul(_percentWin).div(100).div(summ);
            
            uint i = 0;
            while(i < bets.length){
                if(bets[i].betNum == winNum_1_bol){
                    bets[i].betAddress.send(winSumm_2);
                }
    
                i++;
            } 
        }
        if(betsNum[winNum_1_men] != 0 && _percentWin == 30){
            uint winSumm_3 = address(this).balance.mul(_percentWin).div(100).div(summ);
        
            uint i = 0;
            while(i < bets.length){
                if(bets[i].betNum == winNum_1_men){
                    bets[i].betAddress.send(winSumm_3);
                }
    
                i++;
            } 
        }
        clearArr();
        bets.length = 0;
    }
    
    function bytesToUint(bytes memory _bs, uint _start) internal pure returns (uint) {
        require(_bs.length >= _start + 32);
        uint x;
        assembly {
            x := mload(add(_bs, add(0x20, _start)))
        }
        return x;
    }
    
    function clearArr() internal {
        for(uint i = 0; i < betsNum.length; i++){
            betsNum[i] = 0;
        }
    }
    
    function random(uint _numbersCount) internal returns (uint) {
        uint _seed = _numbersCount;
        uint blockNumber = block.number;
        bytes32 blockHashPrevious = blockhash(blockNumber - 1);
        bytes32 _seed0 = keccak256(abi.encodePacked(blockHashPrevious, _numbersCount));
        bytes32 _seed1 = keccak256(abi.encodePacked(_seed0, block.timestamp));
        _seed = uint(_seed1);
        return _seed % _numbersCount;
    }
    
    function getBetsUser(address _betAddress) public view returns(uint[] memory){
        return betsUser[_betAddress];
    }
    
    function toBytes(uint256 x) public pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }

}
