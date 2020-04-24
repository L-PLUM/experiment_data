/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address internal _owner;
  
  
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
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
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract ETHSurge is Ownable{
    using SafeMath for uint256;
    
    mapping (address => uint256) public investedETH;
    mapping (address => uint256) public lastInvest;
    
    mapping (address => uint256) public affiliateCommision;
    
    address public promoter1 = address(0x0000000000000000);
    address public promoter2 = address(0x0000000000000000000);
    address public fund_account = address(0x00000000000000000000000000);
    address public lastPotWinner;
    
    uint256 public pot = 0;
    
    event PotWinner(address indexed beneficiary, uint256 amount );
    
    //sequential deposit tracker variables
    mapping(address => uint256[]) public userSequentialDeposits;
    mapping(address => uint256[]) public userSequentialDepositDates;
    mapping(address => uint256) public userSequentialProfit;
  
   
    constructor () public {
        _owner = address(0x000000000000000000000000000);
    }
    
    
    function processDoubleDeposit() internal returns(bool){
        
        //checking for any subsequent profit doubled issue
        uint256 totalNoOfDeposits = userSequentialDeposits[msg.sender].length;
        for(uint256 i=0; i < totalNoOfDeposits; i++ ){
            
            uint256 sequentialProfit = getProfitCustom(userSequentialDeposits[msg.sender][i], userSequentialDepositDates[msg.sender][i]);
            
            if( sequentialProfit >= userSequentialDeposits[msg.sender][i] && userSequentialDeposits[msg.sender][i] > 0 ){
            
                //profit is tracked in specific mapping as that we need to give to users
                userSequentialProfit[msg.sender] = userSequentialDeposits[msg.sender][i];
            
                //deposit is being reset
                if(investedETH[msg.sender] > userSequentialDeposits[msg.sender][i]){
                    investedETH[msg.sender] = investedETH[msg.sender].sub(userSequentialDeposits[msg.sender][i]);
                }
                else{
                    investedETH[msg.sender]=0;
                }
                
                //resetting entry from userSequentialDeposits
                userSequentialDeposits[msg.sender][i] = 0;
                
                //resetting entry from userSequentialDepositDates
                userSequentialDepositDates[msg.sender][i] = 0;
                
            }
        }
        
        return true;
    }
    

    function investETH(address referral) public payable {
        
        require(msg.value >= 0.5 ether);
    
        
        /* No need to withdraw profit as every deposits are tracked separetely
        uint256 profit = getProfit(msg.sender);
        if(profit > 0){
            
            lastInvest[msg.sender] = now;
            msg.sender.transfer(profit);
        }
        */
        
        
        //checking and processing DoubleDeposit
        processDoubleDeposit();
        
        
        amount = msg.value;
        uint256 commision = SafeMath.div(amount, 20);

        uint256 commision1 = amount.mul(3).div(100);
        uint256 commision2 = amount.mul(2).div(100);
        uint256 _pot = amount.mul(15).div(100);
        uint256 amount = amount.sub(commision1).sub(commision2).sub(_pot);
        pot = pot.add(_pot);
        
        promoter1.transfer(commision1);
        promoter2.transfer(commision2);
        
        if(referral != msg.sender && referral != 0x1 && referral != promoter1 && referral != promoter2){
            affiliateCommision[referral] = SafeMath.add(affiliateCommision[referral], commision);
        }
        
        affiliateCommision[promoter1] = SafeMath.add(affiliateCommision[promoter1], commision);
        affiliateCommision[promoter2] = SafeMath.add(affiliateCommision[promoter2], commision);
        
        investedETH[msg.sender] = investedETH[msg.sender].add(amount);
        lastInvest[msg.sender] = now;
        userSequentialDeposits[msg.sender].push(amount);
        userSequentialDepositDates[msg.sender].push(now);
        
        bool potWinner = random();
        if(potWinner){
            uint256 winningReward = pot.mul(70).div(100);
            uint256 dev = pot.mul(20).div(100);
            pot = pot.sub(winningReward).sub(dev);
            msg.sender.transfer(winningReward);
            fund_account.transfer(winningReward);
            lastPotWinner = msg.sender;
            emit PotWinner(msg.sender, winningReward);
        }
    }
    
    /*
    function divestETH() public {
        
        //checking and processing DoubleDeposit
        processDoubleDeposit();
        
        uint256 profit = getProfit(msg.sender);
        lastInvest[msg.sender] = now;
        
        //50% fee on taking capital out
        uint256 capital = investedETH[msg.sender];
        uint256 fee = SafeMath.div(capital, 2);
        capital = SafeMath.sub(capital, fee);
        
        uint256 total = SafeMath.add(capital, profit);
        require(total > 0);
        investedETH[msg.sender] = 0;
        
        //resetting sequential deposit variables
        delete userSequentialDeposits[msg.sender];
        delete userSequentialDepositDates[msg.sender];
        userSequentialProfit[msg.sender] = 0;
        
        msg.sender.transfer(total);
    }
    
    */
    
    function withdraw() public{
        
        //checking and processing DoubleDeposit
        processDoubleDeposit();
        
        uint256 profit = getProfit(msg.sender);
        require(profit > 0);
        lastInvest[msg.sender] = now;
        
        //resetting userSequentialProfit variable
        userSequentialProfit[msg.sender] = 0;
        
        msg.sender.transfer(profit);
    }
    
    function getProfitFromSender() public view returns(uint256){
        return getProfit(msg.sender);
    }
    
    function getTotalNumberOfDeposits(address _user) public view returns(uint256){
        return userSequentialDeposits[_user].length;
    }

    function getProfit(address customer) public view returns(uint256){
        
        uint256 totalNoOfDeposits = userSequentialDeposits[customer].length;
        uint256 totalProfit;
        for(uint256 i=0; i < totalNoOfDeposits; i++ ){
            uint256 sequentialProfit = getProfitCustom(userSequentialDeposits[customer][i], userSequentialDepositDates[msg.sender][i] );
            if(sequentialProfit > userSequentialDeposits[customer][i]){
                totalProfit += userSequentialDeposits[customer][i];
            }
            else{
                totalProfit += sequentialProfit;
            }
            
        }
        
        return totalProfit;
    }
    
    function getProfitCustom(uint256 investedETH_, uint256 lastInvestTime_) public view returns(uint256){
        uint256 secondsPassed = SafeMath.sub(now, lastInvestTime_);
        uint256 profit = SafeMath.div(SafeMath.mul(secondsPassed, investedETH_), 100);
        uint256 bonus = getBonus();
        if(bonus == 0){
            //adding sequentialProfit if available. This happens when we reset deposit when it becomes 200%
            return profit + userSequentialProfit[msg.sender];
        }
        //adding sequentialProfit here as well if application
        return (SafeMath.add(profit, SafeMath.div(SafeMath.mul(profit, bonus), 100))) + userSequentialProfit[msg.sender];

    }
    
    function getBonus() public view returns(uint256){
        uint256 invested = getInvested();
        if(invested >= 0.1 ether && 4 ether >= invested){
            return 0;
        }else if(invested >= 4.01 ether && 7 ether >= invested){
            return 20;
        }else if(invested >= 7.01 ether && 10 ether >= invested){
            return 40;
        }else if(invested >= 10.01 ether && 15 ether >= invested){
            return 60;
        }else if(invested >= 15.01 ether){
            return 99;
        }
    }
    
    function reinvestProfit() public {
        
        //checking and processing DoubleDeposit
        processDoubleDeposit();
        
        uint256 profit = getProfit(msg.sender);
        require(profit > 0);
        lastInvest[msg.sender] = now;
        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], profit);
        
        //resetting userSequentialProfit variable
        userSequentialProfit[msg.sender] = 0;
    }
    
    function getAffiliateCommision() public view returns(uint256){
        return affiliateCommision[msg.sender];
    }
    
    function withdrawAffiliateCommision() public {
        require(affiliateCommision[msg.sender] > 0);
        uint256 commision = affiliateCommision[msg.sender];
        affiliateCommision[msg.sender] = 0;
        msg.sender.transfer(commision);
    }
    
    function getInvested() public view returns(uint256){
        return investedETH[msg.sender];
    }
    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
    }
    
    function updatePromoter1(address _address) external onlyOwner {
        require(_address != address(0x0));
        promoter1 = _address;
    }
    
    function updatePromoter2(address _address) external onlyOwner {
        require(_address != address(0x0));
        promoter2 = _address;
    }
    
    function updateDev(address _address) external onlyOwner {
        require(_address != address(0x0));
        fund_account = _address;
    }
    
    function random() internal view returns (bool) {
        uint maxRange = 2**(8* 7);
        for(uint8 a = 0 ; a < 8; a++){
            uint randomNumber = uint( keccak256(abi.encodePacked(msg.sender,blockhash(block.number), block.timestamp )) ) % maxRange;
            if ((randomNumber % 13) % 19 == 0){
                return true;
                break;
            }
        }
        return false;    
    } 
}

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
