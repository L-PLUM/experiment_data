/**
 *Submitted for verification at Etherscan.io on 2019-01-21
*/

pragma solidity ^0.4.25;

contract SmartSnake{
    
    using SafeMath for uint;
    
    using Address for *;
    using Zero for *; 
    
    uint startTime = 1547631369;

    uint constant public MAX_INVESTMENT = 10 ether;
    uint constant public MIN_INVESTMENT = 0.1 ether;
    
    uint constant public MIN_TRANSACTION = 0.001 ether;
    
    uint constant public INVESTOR_PERCENT = 2;
    uint constant public INVESTORS_TO_PAY = 40;
    uint constant public REFERAL_PERCENT = 20;

    address constant private PROMO = 0xf7EE772303eb576D1aa3d17D5454f79a69F80bEf;
    
    //tmp
    uint public investorsCount = 0;
    uint public depositsCount = 0;
    
    uint public prize = 0;
    
    address public lastFamousInvestor;
    
    int public stage = 0; //Number of contract runs
    
    struct Deposit {
        address depositor_address; //The depositor address
        uint deposit;   //The deposit amount
        uint profit;    //накапало процентов 
        address referal;   //Referal address
        uint time; //Timestamp 
        uint payed_out; //Выплачено
    }
    
    struct Investor {
        uint deposits_count;
        uint deposits_amount;
        uint referal_investments;
        uint referals_count;
        uint payed_out;
        uint balance;
    }

    address[] public InvestorAddresses;
    
    //for bonuses
    uint public bestInvestorAmount = 0;
    address public bestInvestorAddress;
    
    uint public lastGoodInvestorAmount = 0;
    address public lastGoodInvestorAddress;
    
    //для остатков
    address public lastInvestorAddress;
    uint public lastInvestorTime;
    

    mapping (address => Investor) public investorsStorage;
    Deposit[] public depositsStorage;
    

  event LogMessage(uint message);
  event LogNextWave(uint when);


  modifier adminOnly() {
    require(msg.sender == PROMO, "only admin allowed");
    _;
  }
    
    function () public payable {
           
       // require(tx.gasprice <= 50000000000 wei, "Gas price is too high!");
        require(now > startTime, "We will start later");
        
        if(msg.value > 0){
            pay(msg.data.toAddress());
        }else if(msg.value == 0){
            withdraw();
        }
    }

    function pay(address referrerAddr) public payable{
          
          uint investment = msg.value;
          
          require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
          require(msg.value <= MAX_INVESTMENT, "The investment is too much!"); //Do not allow too big investments
          require(msg.value >= MIN_INVESTMENT, "The investment is too small!"); //Do not allow too small investments

          addDeposit(msg.sender, investment, referrerAddr);
          uint referalAmount = REFERAL_PERCENT.mul(investment).div(100);
          
          if(referrerAddr.notZero() && isReferal(referrerAddr) && referrerAddr!=msg.sender){
              referrerAddr.transfer(referalAmount);
              investorsStorage[referrerAddr].referal_investments = investorsStorage[referrerAddr].referal_investments.add(referalAmount);
          }
          else{
             PROMO.transfer(referalAmount);
          }
           
         
            
        refreshPrizeInfo();  
        
        investment = investment.sub(referalAmount);
          
        uint onePortion = investment.div(INVESTORS_TO_PAY);
     
          
        // меньше 40 инвесторов - всем розсылаем профит
        if(depositsCount < INVESTORS_TO_PAY){
              //todo проблема зміни депозітКаунта в функції аддПрофит
            for(uint i=0; i<depositsCount; i++){
              if(depositsStorage[i].profit == depositsStorage[i].deposit.mul(2)){
                continue;
              }
              depositsStorage[i].profit+=onePortion;
              //addProfitToInvestor(i, onePortion);
              investment = investment.sub(onePortion);
            }
            
            //все что осталось - в приз
            prize = prize.add(investment); 
        }
        else{
            // // first 20
            //  uint realCounter = 1;
            //  for(i=0; i<depositsCount; i++){
            //     if(realCounter > 20){
            //          break;
            //     }
            //     if(depositsStorage[i].expect.isZero()){
            //         continue;
            //     }
                
            //     addProfitToInvestor(i, onePortion);
            //     investment = investment.sub(onePortion);
            //     realCounter = realCounter.add(1);
            // }
            
            // //last 20
            //  realCounter = 1;
            //  for(i=depositsCount; i>0; i--){
            //     if(realCounter > 20){
            //          break;
            //     }
            //     if(depositsStorage[i].expect.isZero()){
            //         continue;
            //     }
                
            //     addProfitToInvestor(i, onePortion);
            //     investment = investment.sub(onePortion);
            //     realCounter = realCounter.add(1);
            // }
        }
    }
    
    function refreshPrizeInfo() private {
         //for last
          if(msg.value > 1 ether){
            lastGoodInvestorAmount = msg.value;
            lastGoodInvestorAddress = msg.sender;
          }
          
          //for best 
          if(msg.value > bestInvestorAmount){
              bestInvestorAmount = msg.value;
              bestInvestorAddress = msg.sender;
          }
    }
    
    
 
    
    // Начисляем одному депозитору часть от дохода по позиции в очереди
    // function addProfitToInvestor(uint iteration, uint profit) private{
        
    //     Deposit storage oneDeposit = depositsStorage[iteration];
         
    //     if(oneDeposit.expect < profit){
    //         investorsStorage[oneDeposit.depositor_address].balance = investorsStorage[oneDeposit.depositor_address].balance.add(oneDeposit.expect);
    //         prize = prize.add(profit.sub(oneDeposit.expect));
    //         oneDeposit.expect = 0;
    //         //depositsCount.sub(1);
    //     }
    //     else{
    //         oneDeposit.expect = oneDeposit.expect.sub(profit);
    //         investorsStorage[oneDeposit.depositor_address].balance = investorsStorage[oneDeposit.depositor_address].balance.add(profit);
    //     }
    // }
    
    //роздача слонов каждую неделю
    function sendBonuses() private{
        uint partOfBonuces = prize.div(5);
        
        //#1 to last investor
        if(lastGoodInvestorAmount > 0){
            lastGoodInvestorAddress.transfer(partOfBonuces);
            prize = prize.sub(partOfBonuces);
        }
        
        //#2 to best investor
        if(bestInvestorAmount > 0){
            bestInvestorAddress.transfer(partOfBonuces);
            prize = prize.sub(partOfBonuces);
        }
        //#3 to top referals
        prizeForTopReferals(partOfBonuces);
        
        //#4 rand
        if(depositsCount>0){
            uint lucky = rand(depositsCount, partOfBonuces);
            depositsStorage[lucky].depositor_address.transfer(partOfBonuces);
            prize = prize.sub(partOfBonuces);
        }
        
        //#5 to admin
        PROMO.transfer(partOfBonuces);
        prize = prize.sub(partOfBonuces);
    }
    

    function prizeForTopReferals(uint amount) private{
        PROMO.transfer(amount);
    }
    
    function reset() adminOnly public{
        depositsCount=0;
        uint totalCount = depositsStorage.length;
        for(uint i=0; i<totalCount; i++){
           delete(depositsStorage[i]);
        }
        startTime  = now + 3 days;
    }

    function addDeposit(address investor_address, uint deposit, address referrerAddr) private{
        depositsCount++;
       // uint expect = deposit.mul(2);
        //newInvestor(depositor, deposit, referrerAddr);
        depositsStorage.push(Deposit(investor_address, deposit, uint(0), referrerAddr, uint128(now), uint(0)));
    }
    
   function newInvestor(address addr, uint deposit, address referrerAddr) private returns (bool) {
      Investor storage inv = investorsStorage[addr];
      
    if (investorsStorage[referrerAddr].deposits_amount > 0) {
       investorsStorage[referrerAddr].referals_count++;
    }
     inv.deposits_amount = inv.deposits_amount.add(deposit);
     inv.deposits_count++;
     investorsCount++;
      return true;
   }

    function isReferal(address referrerAddr) public view returns (bool) {
       return investorsStorage[referrerAddr].deposits_amount > 0;
    }
    
    function addReferal(address referrerAddr) private{
        investorsStorage[referrerAddr].referals_count++;
    }

    function withdraw() public {
       Investor storage inv = investorsStorage[msg.sender];
       if(inv.balance > 0){
           msg.sender.transfer(inv.balance);
           inv.payed_out = inv.payed_out.add(inv.balance);
           inv.balance=0;
       }
    }
   
    function getStage() private view returns (int) {
        return int(now - 17 hours) / 1 days - 17844; //Start is 09/11/2018 20:00 GMT+3
    }
   
    function getCurrentStageByTime() public view returns (int) {
        return int(now - 17 hours) / 1 days - 17844; //Start is 09/11/2018 20:00 GMT+3
    }
    
    function getDepositsCount() public view returns (uint) {
        return depositsCount;
    }
    
    function getDepositInfo(uint position) public view returns(address depositor_address, uint deposit, uint profit, address referal, uint time, uint payed_out){
        depositor_address = depositsStorage[position].depositor_address;
        deposit = depositsStorage[position].deposit;
        profit = depositsStorage[position].profit; // доступно для вывода
        referal = depositsStorage[position].referal;
        time = depositsStorage[position].time;
        payed_out = depositsStorage[position].payed_out;
            }
    
    
        //Get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=0; i<depositsCount; ++i){
            if(depositsStorage[i].depositor_address == depositor)
                c++;
        }
        return c;
    }
   
    function getShortInvestorInfo(address addr) public view returns(uint deposits_amount, uint deposits_count, uint referals_count, uint payed_out, uint balance) {
        deposits_amount = investorsStorage[addr].deposits_amount;
        deposits_count = investorsStorage[addr].deposits_count;
       
        referals_count = investorsStorage[addr].referal_investments;
        payed_out = investorsStorage[addr].payed_out;
        balance = investorsStorage[addr].balance;
    }
   
   
    function balanceETH() public view returns(uint) {
      return address(this).balance;
    }
    
    function testRand(uint salt) public view returns(uint) {
      return rand(10, salt);
    }
    
    /*
     * @todo refactor this code
     */
    function rand(uint max, uint salt) constant private returns (uint256 result){
      uint256 factor = salt * 100 / max;
      uint256 lastBlockNumber = block.number - 1;
      uint256 hashVal = uint256(blockhash(lastBlockNumber));
      return uint256((uint256(hashVal) / factor)) % max;
    }
}


library Math {
  function min(uint a, uint b) internal pure returns(uint) {
    if (a > b) {
      return b;
    }
    return a;
  }
}


library Zero {
  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }

  function requireNotZero(uint val) internal pure {
    require(val != 0, "require not zero value");
  }

  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }

  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }

  function isZero(uint a) internal pure returns(bool) {
    return a == 0;
  }

  function notZero(uint a) internal pure returns(bool) {
    return a != 0;
  }
}



library Address {
  function toAddress(bytes source) internal pure returns(address addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }

  function isNotContract(address addr) internal view returns(bool) {
    uint length;
    assembly { length := extcodesize(addr) }
    return length == 0;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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
