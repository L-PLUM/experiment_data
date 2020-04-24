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

    //会员数据结构
   struct BebUser {
        address customerAddr;//会员address
        uint256 amount; //存款金额 
        uint256 bebtime;//存款时间
        uint256 interest;//利息
    }
    uint256 Bebamount;//BEB未发行数量
    uint256 bebTotalAmount;//BEB总量
    uint256 sumAmount = 0;//会员的总量 
    uint256 OneMinuteBEB;//初始化1分钟产生BEB数量
    tokenTransfer public bebTokenTransfer; //代币 
    uint8 decimals = 18;
    uint256 OneMinute=1 minutes; //1分钟
    //会员 结构 
    mapping(address=>BebUser)public BebUsers;
    address[] BebUserArray;//存款的地址数组
    //事件
    event messageBetsGame(address sender,bool isScuccess,string message);
    //BEB的合约地址 
    function BebPos(address _tokenAddress,uint256 _Bebamount,uint256 _bebTotalAmount,uint256 _OneMinuteBEB){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         Bebamount=_Bebamount;//初始设定为发行数量
         bebTotalAmount=_bebTotalAmount;//初始设定总量==
         OneMinuteBEB=_OneMinuteBEB;//初始化1分钟产生BEB数量 
         BebUserArray.push(_tokenAddress);
     }
         //存入 BEB
    function BebDeposit(uint256 _value) public{
        //判断会员存款金额是否等于0
       if(BebUsers[msg.sender].amount == 0){
           //判断未发行数量是否大于20个BEB
           if(Bebamount > OneMinuteBEB){
           bebTokenTransfer.transferFrom(msg.sender,address(this),_value);//存入BEB
           BebUsers[msg.sender].customerAddr=msg.sender;
           BebUsers[msg.sender].amount=_value;
           BebUsers[msg.sender].bebtime=now;
           sumAmount+=_value;//总存款增加
           //加入存款数组地址
           addToAddress(msg.sender);//加入存款数组地址
           messageBetsGame(msg.sender, true,"转入成功");
            return;   
           }
           else{
            messageBetsGame(msg.sender, true,"转入失败,BEB总量已经全部发行完毕");
            return;   
           }
       }else{
            messageBetsGame(msg.sender, true,"转入失败,请先取出合约中的余额");
            return;
       }
    }
        //加入存款地址
    function addToAddress(address _miner) internal{
             bool hasAdd=false;
        for(uint i=0;i<BebUserArray.length;i++){
            //判断数组中是否存在
            if(BebUserArray[i]==_miner){
                hasAdd=true;
                break;
            }
        }
        //不存在则加入地址
        if(!hasAdd){
        BebUserArray.push(_miner);
        }
    }
    //取款
    function redemption() public {
        address _address = msg.sender;
        BebUser memory user = BebUsers[_address];
       assert(user.amount > 0);
        //判断未发行数量是否大于20个BEB
        if(Bebamount > OneMinuteBEB){
            uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
            uint256 B=bebTotalAmount-Bebamount;//计算出已流通数量
            uint256 C=user.amount*A/B;//存款*A/已流通数量
            Bebamount-=C;//从发行总量当中减少
            sumAmount-=user.amount;
            bebTokenTransfer.transfer(msg.sender,C+user.amount+user.interest);//转账给会员 + 会员本金+当前利息 
           //更新数据 
            BebUsers[_address].amount=0;//会员存款0
            BebUsers[_address].bebtime=0;//会员存款时间0
            BebUsers[_address].interest=0;//利息归0
            messageBetsGame(_address, true,"本金和利息成功取款");
            return;
        }
        else{
            uint256 AAA=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
            uint256 BBB=bebTotalAmount-Bebamount;//计算出已流通数量
            uint256 CCC=user.amount*A/B;//存款*A/已流通数量
            Bebamount-=CCC;//从发行总量当中减少
            sumAmount-=user.amount;
            bebTokenTransfer.transfer(msg.sender,user.amount+user.interest);//转账给会员 + 会员本金 
           //更新数据 
            BebUsers[_address].amount=0;//会员存款0
            BebUsers[_address].bebtime=0;//会员存款时间0
            BebUsers[_address].interest=0;//利息归0
            messageBetsGame(_address, true,"BEB总量已经发行完毕，取回本金");
            return;  
        }
            
       
    }
    //定期向所有存款账户发放利息
    function sendInterest() onlyOwner public{
        //历遍所有区块链钱包存款账户
       for(uint w=0;w<BebUserArray.length; w++) {
        uint256 _amuont=BebUsers[BebUserArray[w]].amount;//个人存款金额
        //金额大于0，开始计算利息
        if(_amuont > 0){
           uint256 _time=BebUsers[BebUserArray[w]].bebtime;//存款时间
           uint256 AA=(now-_time)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
           uint256 BB=bebTotalAmount-Bebamount;//计算出已流通数量
           uint256 CC=_amuont*AA/BB;//存款*AA/已流通数量
           //判断未发行数量是否大于20BEB
           if(Bebamount > OneMinuteBEB){
              Bebamount-=CC; 
             BebUsers[BebUserArray[w]].interest+=CC;//向账户增加利息
             BebUsers[BebUserArray[w]].bebtime=now;//重置存款时间为现在
           }
        }
       }
    }
     //查询合约代币余额 
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
    //查询会员存款总量 
    function getSumAmount() public view returns(uint256){
        return sumAmount;
    }
    //查询未发行总量
    function getBebAmount() public view returns(uint256){
        return Bebamount;
    }
    //查询已流通总量
    function getBebAmountzl() public view returns(uint256){
        uint256 _sumAmount=bebTotalAmount-Bebamount;
        return _sumAmount;
    }
    //查询会员存款信息 
    function getUserInfo(address _form) public view returns(address,uint256,uint256,uint256){
        BebUser memory user = BebUsers[_form];
        //返回地址，个人存款金额，存款时间，利息收益
        return (user.customerAddr,user.amount,user.bebtime,user.interest);
    }
    function getLength() public view returns(uint256){
        return (BebUserArray.length);
    }
    //查询实时收益 
     function getUserProfit() public view returns(address ,uint256,uint256,uint256){
       address _address = msg.sender;
       BebUser memory user = BebUsers[_address];
       assert(user.amount > 0);
       uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
       uint256 B=bebTotalAmount-Bebamount;//计算出已流通数量
       uint256 C=user.amount*A/B;//存款/已流通数量*A
        return (_address,user.amount,C,user.interest);
    }
    function A() public view returns(address ,uint256,uint256){
         address _address = msg.sender;
        BebUser memory user = BebUsers[_address];
       assert(user.amount > 0);
       uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
        return (_address,user.amount,A);
    }
    function B() public view returns(address ,uint256,uint256){
         address _address = msg.sender;
        BebUser memory user = BebUsers[_address];
       assert(user.amount > 0);
       uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
       uint256 B=bebTotalAmount-Bebamount;//计算出已流通数量
       sumAmount-=user.amount;
        return (_address,user.amount,B);
    }
     function C() public view returns(address ,uint256,uint256){
         address _address = msg.sender;
        BebUser memory user = BebUsers[_address];
       //assert(user.amount > 0);
       uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;//现在时间-存款时间/60秒*每分钟生产20BEB
       uint256 B=bebTotalAmount-Bebamount;//计算出已流通数量
       uint256 C =user.amount*A/B; //存款/已流通数量*A
        return (_address,user.amount,C);
    }
}
