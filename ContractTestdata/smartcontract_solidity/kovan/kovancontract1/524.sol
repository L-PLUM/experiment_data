/**
 *Submitted for verification at Etherscan.io on 2019-01-21
*/

pragma solidity 0.5.0;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
 constructor() public {
    owner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title EscrowVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if whitelist fails,
 * and forwarding it if whitelist is successful.
 */
contract EscrowVault {
 enum State { Active, Refunding, Success, Closed }

  State public state;

  using SafeMath for uint256;
  
  struct BackerState{
      uint256 depositedAmount;
      uint256 votingPercentage;
      bool votingStatus;
      uint256 amountUSD;
      uint256 votingPercentageUSD;
      bool votingStatusUSD;
  }
  
  mapping (address => BackerState) public backerState;
  
  mapping (address => uint256) public votingPercentagePerBacker;

  address payable owner;
  
  uint256 public votingPercentage;
  uint256 public dayscalculation;
  uint256 public voteAcceptingPercentage =100;
  uint256 public voteAcceptingPercentageUSD =100;
 
  uint256 public projectBalance;
  
  uint256 public time = block.timestamp;
  
  uint256 public fee;


  uint256 public closingTime;
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event paid(address indexed beneficiary, uint256 weiAmount);
  address payable founder;
  address[] public payees;
  address[] public votingAccept;
  address[] public votingDecline;
  uint256 constant DECIMAL_FACTORS=10**18;
  uint256 public endtime;
  uint256 public requestAmount;
  address public maxPayee;
  uint256 public backersCount;
  uint256 public refundingCount;
  uint256 public amountTransfer;
  uint256 public raisedAmount;
  
  uint256 public raisedUSD;
  
  //just testing
  uint256 public depositamount;
  
 constructor(uint256 _closingtime, address payable _founder,address payable _owner, uint256 _votingPercentage) public{
    state = State.Active;
    closingTime=_closingtime;
    dayscalculation = closingTime.add(12 weeks);
    founder=_founder;
    owner=_owner;
    votingPercentage=_votingPercentage;
 }

  function () external payable {
      deposit(msg.sender);
  }
  
  function deposit(address _beneficiary) public payable{
          require(state == State.Active);
          uint256 weiAmount=msg.value;
          uint256 value=1;
          BackerState storage contribState = backerState[msg.sender];
            if(contribState.depositedAmount == 0){
                payees.push(msg.sender);
               backersCount = backersCount.add(value);
          }
          contribState.votingStatus=true;
          contribState.depositedAmount = contribState.depositedAmount.add(weiAmount);
          projectBalance = projectBalance.add(weiAmount);
          raisedAmount = raisedAmount.add(weiAmount);

          emit paid(_beneficiary,weiAmount);
  }
  
  function depositWithUSD(address _backer, uint256 _amount) public {
        require(state == State.Active);
        BackerState storage contribState = backerState[_backer];
         if(contribState.amountUSD == 0){
                payees.push(_backer);
              // backersCount = backersCount.add(value);
          }
          contribState.votingStatusUSD=true;
          contribState.amountUSD = contribState.amountUSD.add(_amount);
          raisedAmount = raisedAmount.add(_amount);
          raisedUSD = raisedUSD.add(_amount);

  }
  
  function founderRequest(uint256 _endtime,uint256 _amount) public onlyFounder{
    // require(_endtime>block.timestamp);
      require(_amount>0);
    //  require(address(this).balance>=_amount);
      endtime=_endtime;
      requestAmount=_amount;
      
      for(uint i=0;i<payees.length;i++){
           BackerState storage contribState = backerState[payees[i]];
           uint256 depositedValue=contribState.depositedAmount;
           uint256 amountUSD=contribState.amountUSD;

           if(depositedValue > 0){
              contribState.votingPercentage = uint256(SafeMath.mul(SafeMath.div(depositedValue, raisedAmount), 100));
           }
           if(amountUSD > 0){
              contribState.votingPercentageUSD = uint256(SafeMath.mul(SafeMath.div(amountUSD, raisedUSD), 100));
           }
           
         }
      
  }
  
  function votingAccepting(address _backer) public{
     // require(endtime>=block.timestamp);
      require(requestAmount>0);
      BackerState storage contribState = backerState[_backer];
      if(contribState.amountUSD > 0){
           require(contribState.votingStatusUSD != false);
      //require(voting[msg.sender]!=false);
       uint256 depositedValue = contribState.amountUSD;
       assert(depositedValue>0);
       contribState.votingStatusUSD = true;
       votingAccept.push(_backer);
      }
       if(contribState.depositedAmount > 0){
           require(contribState.votingStatus != false);
      //require(voting[msg.sender]!=false);
       uint256 depositedValue = contribState.depositedAmount;
       assert(depositedValue>0);
       contribState.votingStatus = true;
       votingAccept.push(_backer);
       }
      
  }
  
   function votingDeclining(address _backer) public{
     // require(endtime>=block.timestamp);
      require(requestAmount>0);
      BackerState storage contribState = backerState[_backer];
      
      if(contribState.amountUSD > 0){
           require(contribState.votingStatusUSD != true);
      //require(voting[msg.sender]!=false);
       uint256 depositedValue = contribState.amountUSD;
       assert(depositedValue>0);
       contribState.votingStatusUSD = false;
       votingDecline.push(_backer);
       uint256 votePercentageBacker = contribState.votingPercentageUSD;
       voteAcceptingPercentage = voteAcceptingPercentage.sub(votePercentageBacker);
      }
      if(contribState.depositedAmount > 0){
          require(contribState.votingStatus==true);
    //   require(voting[msg.sender]==true);
       uint256 depositedValue = contribState.depositedAmount;
       assert(depositedValue>0);
       contribState.votingStatus = false;
       votingDecline.push(_backer);
       uint256 votePercentageBacker = contribState.votingPercentage;
       voteAcceptingPercentage = voteAcceptingPercentage.sub(votePercentageBacker);
      }
      
   }
  
  function enableRelease() public {
    // require(endtime<=block.timestamp);
      fee = uint256(SafeMath.div(SafeMath.mul(2, 95), 100));
      if(projectBalance > 0){
          projectBalance = projectBalance.sub(fee);
          owner.transfer(fee); 
      }
      uint256 maxAmount=0;
      uint256 maxUSD=0;
      for(uint i=0;i<payees.length;i++){
           BackerState storage contribState = backerState[payees[i]];
            uint256 depositedValue=contribState.depositedAmount;
            uint256 depositUSD=contribState.amountUSD;
            if(maxAmount<=depositedValue){
                maxPayee=payees[i];
                maxAmount=depositedValue;
            }
              if(maxUSD<=depositUSD){
                maxPayee=payees[i];
                maxUSD=depositUSD;
            }
         }
         
         if(voteAcceptingPercentage > votingPercentage || backerState[maxPayee].votingStatus==true){
             state = State.Success;
         }
         
         if(votingAccept.length==0 || endtime >= block.timestamp){
             state = State.Success;
         }
         
          if(voteAcceptingPercentage < votingPercentage || backerState[maxPayee].votingStatus==false){
             state = State.Refunding;
              delete votingAccept;
              delete votingDecline;
         }
             
         }
         
    function enableReleaseFor90Days() public {
        require(address(this).balance > 0);
    // require(dayscalculation<=block.timestamp);
      owner.transfer(address(this).balance);
      state = State.Closed;
     }
  
    /**
   * @dev Withdraws the beneficiary's funds.
   */
  function beneficiaryWithdraw() public onlyFounder{
    require(founder==msg.sender);
    require(state == State.Success);
    founder.transfer(address(this).balance);
    projectBalance = projectBalance.sub(requestAmount);
    requestAmount = 0;
    state = State.Closed;
    
    }

  function refund() public    {
    require(projectBalance>=0);
    require(state == State.Refunding);
    BackerState storage contribState = backerState[msg.sender];
    uint256 value=1;
    uint256 depositedValue = contribState.depositedAmount;
    amountTransfer = uint256(SafeMath.div(SafeMath.mul(address(this).balance, contribState.votingPercentage), 100));
    assert(depositedValue>0);
   // assert(address(this).balance >= depositedValue);
    msg.sender.transfer(amountTransfer);
    contribState.votingPercentage = 0;
    projectBalance = projectBalance.sub(amountTransfer);
    emit Refunded(msg.sender, depositedValue);
    contribState.depositedAmount = depositedValue.sub(depositedValue);
    refundingCount = refundingCount.add(value);
     if(refundingCount == backersCount) {
          state = State.Closed;
      }
  }
  
  function setFounder(address payable _founder) public {
        founder = _founder;
  }
  
  /**
   * @dev Throws if called by any account other than the admin.
   */
  modifier onlyFounder() {
    require(msg.sender == founder);
    _;
  }
  
  /**
   * @dev Reverts if not in closingTime time range.
   */
  modifier hasClosed {
    // solium-disable-next-line security/no-block-members
    require( closingTime <= block.timestamp);
    _;
  }
  

// just for testing
function payout() public {
    require(address(this).balance > 0);
    owner.transfer(address(this).balance);
}

}

contract Charity   {
    EscrowVault public wallet;
    address payable owner;
    address payable founder;
    
   // EscrowVault escrowVault;
    
    constructor() public{
        owner=msg.sender;
    }
    
    function generateWallet(uint256 _closingtime, uint256 _votingPercentage) public{
        founder = msg.sender;
    wallet = new EscrowVault(_closingtime,founder,owner, _votingPercentage);
  //  wallet = escrowVault;
    }
    
}
