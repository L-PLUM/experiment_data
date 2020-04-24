/**
 *Submitted for verification at Etherscan.io on 2019-08-11
*/

pragma solidity^0.4.20;  
//实例化代币
interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}

contract Ownable {
  address public owner;
  bool lock = false;
 
 
    /**
     * 初台化构造函数
     */
    function Ownable () public {
        owner = msg.sender;
    }
 
    /**
     * 判断当前合约调用者是否是合约的所有者
     */
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * 合约的所有者指派一个新的管理员
     * @param  newOwner address 新的管理员帐户地址
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

contract BebPos is Ownable{
tokenTransfer public bebTokenTransfer; //代币 
    uint8 decimals = 18;
    //会员数据结构
   struct BebUser {
        address customerAddr;//会员address
        uint256 amount; //存款金额 
        uint256 bebtime;//存款时间
        uint256 interest;//利息
    }
    //ETH挖矿
    struct miner{
        uint256 mining;//挖矿投资金额
        uint256 _mining;//矿机折旧
        uint256 lastDate;//结算日期
        uint256 ethbomus;//收益
        uint256 amountTotal;//累计挖矿
        uint256 bebToEthTime;
        
    }
    mapping(address=>miner)public miners;//映射挖矿结构
    address[]public minersArray;//可能的矿机地址
    //以下为挖矿部分函数
    uint256 ethExchuangeRate=20000*(10**uint256(decimals));//汇率
    uint256 bounstotal;//累计挖矿金额
    uint16 depreciationRate=3;//折旧衰减
    uint256 depreciationTime= 60;//衰减时间
    uint256 SellBeb=1000*(10**uint256(decimals));//默认每次卖出1000BEB
    uint256 BuyBeb=100000*(10**uint256(decimals));//默认每次买入100000BEB
    //事件通知
    event bomus(address to,uint256 amountBouns);
    function BebTomining(address addr,uint256 _value)public{
        require(_value>0);
        bebTokenTransfer.transferFrom(msg.sender,address(this),_value);//存入BEB
        miners[msg.sender].mining+=_value;
        miners[msg.sender]._mining+=_value;
        if(miners[msg.sender].lastDate==0){
        miners[msg.sender].lastDate=now;
        }
        addTominersArray(msg.sender);
    }
    function addTominersArray(address _Miner)internal{
        bool HasAdd=false;
        for(uint i=0;i<minersArray.length;i++){
            if(minersArray[i]==_Miner){
                HasAdd=true;
                break;
            }
        }
        if(!HasAdd){
            minersArray.push(_Miner);
        }
        
    }
    //自由结算
    function freeSettlement()public{
        miner storage user=miners[msg.sender];
        uint256 amuont=user._mining;
        uint256 _ethbomus=user.ethbomus;
        uint256 _lastDate=user.lastDate;
        uint256 _ethbos=0;

            uint256 depreciation=(now-_lastDate)/depreciationTime;
            for(uint m=0;m<depreciation;m++){
             amuont=amuont*(1000-depreciationRate)/1000;
             uint256 Bebday=(amuont+amuont*50/100)/365/ethExchuangeRate;
             _ethbos+=Bebday;
            }
            user.lastDate=now;
            user.ethbomus+=_ethbos;
            user.amountTotal+=_ethbos;
        
    }
    //取款
    function Withdrawal()public{
        miner storage user=miners[msg.sender];
        require(user.ethbomus>0,"Mining amount 0");
            uint256 ethbeb=user.ethbomus;
        user.ethbomus=0;        
        msg.sender.transfer(ethbeb/ethExchuangeRate);

    }
    //查询
    function querYrevenue()public view returns(uint256,uint256,uint256,uint256){
        miner storage user=miners[msg.sender];
        return (user.lastDate,user._mining,user.ethbomus/ethExchuangeRate,user.amountTotal);
        
    }
    function sendEth()payable onlyOwner{
        
    }
  //在合约用BEB兑换ETH。每天兑换只能兑换一次
    function sellBeb(uint256 _sellbeb)public {
        miner storage user=miners[msg.sender];
        require(now>_time);
       if(user.bebToEthTime==0){
         user.bebToEthTime=now;
         require(_sellbeb>0,"The exchange amount must be greater than 0");
         require(_sellbeb<SellBeb,"More than the daily redemption limit");
         bebTokenTransfer.transferFrom(msg.sender,address(this),_sellbeb);//会员BEB转入合约
         msg.sender.transfer(_sellbeb/ethExchuangeRate);
        }
         uint256 _time = user.bebToEthTime+86400;
         require(now>_time,"Insufficient exchange interval");
         require(_sellbeb>0,"The exchange amount must be greater than 0");
         require(_sellbeb<SellBeb,"More than the daily redemption limit");
         bebTokenTransfer.transferFrom(msg.sender,address(this),_sellbeb);//会员BEB转入合约
         msg.sender.transfer(_sellbeb/ethExchuangeRate);
    }
    //在合约用ETH购买BEB
    function buyBeb() payable public {
        uint amount = msg.value;
        //合约余额充足
        uint256 _amuontbeb=getTokenBalance();//算出合约可供兑换的BEB数量
        require(_amuontbeb>amount*ethExchuangeRate);//可供兑换的BEB不得小于购买数量
        bebTokenTransfer.transfer(msg.sender,amount*ethExchuangeRate);//转账给会员BEB  
    }
    //限制每次出售或购买BEB上限和汇率
    function setSellOrBuyBeb(uint256 _sellbeb,uint256 _buybeb,uint256 _ethExchuangeRate) public {
           SellBeb=_sellbeb;//每次卖出数量
           BuyBeb=_buybeb;//每次买入数量
           ethExchuangeRate=_ethExchuangeRate;//ETH和BEB的汇率
    }
    //事件
    event messageBetsGame(address sender,bool isScuccess,string message);
    //BEB的合约地址 
    function BebPos(address _tokenAddress){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
     }
     //查询合约代币余额 
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
   
}
