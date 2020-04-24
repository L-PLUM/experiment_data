/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.0;

interface TumblerGameInterface {
    
    function investByToken(uint256 amount) external;

    function investByEth() external payable;

    //从分红池提取收益
    function withdrawFromProfitPool(uint256 roundId) external;

    //从分红池以外的用户收入获取收益
    function withdrawGain() external;

    function queryRoundById(uint256 rid) external view returns(
        uint256 roundId,
        uint256 startTime,
        uint256 endTime,
        uint256 investAmount,
        //奖池金额
        uint256 gainPoolAmount,
        uint256 winnerGainAmount,
        //分红池金额
        uint256 profitPoolAmount,
        address payable recentlyPlayer,
        uint256 keys,
        uint256 users,
        bool hasClosed);

    function queryRoundByIdAndUser(address user, uint256 rid) external view returns(
        uint256 userRoundGain      // 每轮奖励
        ,uint256 userRoundKeys      // 每轮key数
        ,uint256 userRoundAmount     // 每轮投资
        ,uint256 uTotalGain       // 总奖金
        ,uint256 uGainBalance       // 奖金提现余额
        ,uint256 uTotalSeeAmount    // 总见点奖金
        );

    // 由key计算金额
    function calacAmounts(uint256 rid, uint256 ks) view external returns(uint256);

    function queryProfitAmount(address user, uint256 roundId) external view returns(uint256 userAmount);
}

contract TumblerEvents{

    /**
     *用户注册事件
     */
    event onUserRegistry(
        uint256 indexed gameId,
        uint256 indexed userId,
        address addr,
        string name,
        uint256 inviteUserId
    );

    /**
    *投资事件
    **/
    event onInvest(
        uint256 indexed gameId,
        address indexed userAddr,
        uint256 amount,
        uint256 keys
    );


    /**
    *提现事件
    **/
    event onWithdraw(
        uint256 indexed gameId,
        address indexed userAddr,
        // bytes32 name,
        uint256 amount
    );


    /**
    *一轮开始事件
    **/
    event onRoundStart(
        uint256 indexed gameId,
        uint256 indexed roundId,
        uint256 poolAmount
    );

    /**
    *一轮结束事件
    **/
    event onRoundEnd(
        uint256 indexed gameId,
        uint256 indexed roundId,
        address indexed winnerAddr
    );

    /**
    *收益事件
    **/
    event onProfit(
        uint256 indexed gameId,
        uint256 indexed roundId,
        address winnerAddr,
        // bytes32 winnerName,
        uint256 winnerGain,
        uint256 shardingGain,
        uint256 platformGain,
        uint256 adminGain
    );

}

interface UserBookInterface {
    
    function registryUser(uint256 gameId,string calldata userName,uint256 inviteUserId) payable external;

    function queryUserByGameIdAndAddr(uint256 _gameId,address _addr) view external returns(uint256 userId,address addr,string memory userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  );

    function queryUserByGameIdAndUserId(uint256 _gameId,uint256 _userId) view external returns(uint256 userId,address addr,string memory userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  );


}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
  
contract TumblerGame is TumblerGameInterface,TumblerEvents,Ownable{
    using SafeMath for uint256;
    uint256 public gameId;

    //1、eth 2、代币
    uint256 public tokenType;

    //如果是代币那么就有tokenAddress，否则为0x0
    IERC20 public token;

    //全网注册用户
    UserBookInterface public userBook;

    //admin不是owner
    address payable public admin;

    //平台账号
    address payable public platformAddr;

    //见点收益门槛，以key计算？
    uint256 seePointminMinAmount;
    
    //记录玩家总奖金 地址=>收益总额
    mapping(address=>uint256) userTotalGain;
    //记录玩家奖金提现 地址=>提现总额
    mapping(address=>uint256) userTotalGainWithdraw;
    //记录玩家见点奖励 地址=>见点总额
    mapping(address=>uint256) userTotalSeeAmount;
    //记录玩家每轮奖励  地址=>轮次=>收益
    mapping(address=>mapping(uint256=>uint256)) userRoundGain;

    //记录玩家每轮持有的key 地址=>轮次=>key数量
    mapping(address=>mapping(uint256=>uint256)) userRoundKeys;
    // 记录玩家是否已分红提现 地址=>轮次=>
    mapping(address=>mapping(uint256=>bool)) userRoundHasWithdraw;
    // 记录分红池已提现金额 轮次=>金额
    mapping(uint256=>uint256) profitPoolHasWithdrawAmount;

    //记录玩家每轮投资 地址=>轮次=>投资
    mapping(address=>mapping(uint256=>uint256)) userRoundAmount;

    //现在的轮数
    uint256 public nowRoundId=0;

    //game名称
    string public gameName;
    //最小投资金额
    uint256 public limitAmount;
    //每轮持续时间
    uint256 public roundTime= 1 days;
    //每个key增加时间
    uint256 public timePerKey = 13 seconds;

    //----------奖励分配百分比（游戏奖金） start
    //赢家获取奖池比例，百分比
    uint256 public winnerGainPercent;
    //平台获取奖池比例，百分比
    uint256 public platformGainPercent;
    //admin获取奖池比例，百分比
    uint256 public adminGainPercent;
    //流到下一轮奖池比例
    uint256 public nextPoolGainPercent;
    //推荐收益收取层级
    uint256 public userGainLayer;
    
    //每层收取百分比
    uint256[] public layerGainPercents;
    //每层收取百分比总和（见点奖占赢家获奖额的百分比，这部分从奖池出）
    uint256 public totalLayerGainPercents;
    //----------奖励分配百分比 end


    //----------投资分配（互助）start
    //平台分配百分比
    uint256 public platformDistributePercent;
    //admin分配百分比
    uint256 public adminDistributePercent;
    //奖励池分配百分比
    uint256 public gainPoolDistributePercent;
    //分红池分配百分比
    uint256 public profitPoolDistributePercent;



    //每层分配百分比
    uint256[] public layerDistributePercents; 
    //每层分配百分比总和(见点奖占用户投资额的百分比，这部分从用户投资出)
    uint256 public totalLayerDistributePercents;
    //----------投资分配end

    mapping(uint256=>Round) public roundMap;

    struct Round{
        uint256 roundId;
        uint256 startTime;
        uint256 endTime;
        // 总投资
        uint256 investAmount;
        //奖池金额
        uint256 gainPoolAmount;
        //分红池金额
        uint256 profitPoolAmount;
        address payable recentlyPlayer;
        uint256 keys;
        uint256 users;
        bool hasClosed;
    }
    bool public baseInfoInited=false;
    bool public percentageInited=false;

    modifier onlyAdmin(){
        require(msg.sender==admin,"只有admin才有权操作");
        _;
    }
    modifier checkAmountLimit(uint256 amount){
        require(amount>=limitAmount, "小于最小投资额度");
        _;
    }
 
    constructor() 
    public
    {
        
    }

    function initBaseInfo(
                string calldata _gameName,          // game名称
                uint256 _gameId,                    // game ID             #        1
                address payable _platformAddr,      // 平台收钱账号         #     0x5309c8e5c90c6407F79e3cAF9191773761dc399E
                uint256 _tokenType,                 // 1、eth 2、代币               2
                address userBookAddr,               // userBook合约地址     #     0x7AB36C9BF00a5F372F208975D8ba8bE2931BF379
                address _tokenAddress,              // 代币合约地址         #   0x6c84291090787746394Db2200984a8A3a1241B5d
                address payable _admin,             // 代理admin收钱地址          0x83346653e6Cf294815DCA12d763AaB4FB2393370
                uint256 _roundTime,                 // 每轮持续时间         1 days 86400
                uint256 _timePerKey,                // 每个key增加时间      13 seconds
                uint256 _limitAmount,               // 最小投资金额         1000000000000000000 1btmc
                uint256 _seePointminMinAmount       // 见点收益门槛，以key计算 用户上级投资金额达到此值才能分红    3000000000000000000
    ) external onlyOwner{
        require(!baseInfoInited);
        seePointminMinAmount=_seePointminMinAmount;
          gameName=_gameName;
        gameId=_gameId;
        platformAddr=_platformAddr;
        userBook = UserBookInterface(userBookAddr);
        admin = _admin;


        //代理人设置参数 start
        tokenType = _tokenType;
        if(_tokenType==1){
            token = IERC20(0x0);
        }else{
            token = IERC20(_tokenAddress);
        }        
        roundTime=_roundTime;
        timePerKey=_timePerKey;
        limitAmount=_limitAmount;
        baseInfoInited=true;
    }

    function initPercentage(
                uint256 _winnerGainPercent,                     // 赢家获取奖池比例，百分比             40
                uint256 _platformGainPercent,                   // 平台获取奖池比例，百分比         #   5
                uint256 _adminGainPercent,                      // admin获取奖池比例，百分比            10
                uint256 _nextPoolGainPercent,                   // 流到下一轮奖池比例                   35
                uint256 _userGainLayer,                         // 推荐收益收取层级    #                3
                uint256 _totalLayerGainPercents,                // 每层收取百分比总和（见点奖占赢家获奖额的百分比，这部分从奖池出）  10
                uint256[] calldata _layerGainPercents,          // 每层收取百分比                       [5,3,2]
                uint256 _platformDistributePercent,             // 平台分配百分比       #           5
                uint256 _adminDistributePercent,                // admin分配百分比                  5
                uint256 _gainPoolDistributePercent,             // 奖励池分配百分比                 45
                uint256 _profitPoolDistributePercent,           // 分红池分配百分比                 25
                uint256 _totalLayerDistributePercents,          // 每层分配百分比总和(见点奖占用户投资额的百分比，这部分从用户投资出)   10
                uint256[] calldata _layerDistributePercents     // 每层分配百分比                       [5,3,2]
    ) external onlyOwner{
        require(baseInfoInited);
        require(!percentageInited);
        require(_layerGainPercents.length<=10, "奖池分享收益不能超过10层");
        require(_layerDistributePercents.length<=10, "投资分享收益不能超过10层");
     
        //奖池分配百分比正确性判断
        assertGainPercentage(_winnerGainPercent,_platformGainPercent,_adminGainPercent,_nextPoolGainPercent,_totalLayerGainPercents);
        //投资分配百分比正确性判断
        assertInvestPercentage(_platformDistributePercent,_adminDistributePercent,_gainPoolDistributePercent,_profitPoolDistributePercent,_totalLayerDistributePercents);
        winnerGainPercent=_winnerGainPercent;
        platformGainPercent=_platformGainPercent;
        adminGainPercent=_adminGainPercent;
        nextPoolGainPercent=_nextPoolGainPercent;
        userGainLayer=_userGainLayer;
        totalLayerGainPercents=_totalLayerGainPercents;
        layerGainPercents=_layerGainPercents;

        platformDistributePercent=_platformDistributePercent;
        adminDistributePercent=_adminDistributePercent;
        gainPoolDistributePercent=_gainPoolDistributePercent;
        profitPoolDistributePercent=_profitPoolDistributePercent;
        layerDistributePercents=_layerDistributePercents;
        totalLayerDistributePercents=_totalLayerDistributePercents;
        //代理人设置参数 end
        createNewRound(0);
        percentageInited=true;
    }

    function assertGainPercentage(uint256 _winnerGainPercent,
                uint256 _platformGainPercent,
                uint256 _adminGainPercent,
                uint256 _nextPoolGainPercent,
                uint256 _totalLayerGainPercents
                )internal pure{
        uint256 realTotalLayerGainPercents=calacPercentAmount(_winnerGainPercent,_totalLayerGainPercents);
        require(_winnerGainPercent.add(_platformGainPercent).add(_adminGainPercent).add(_nextPoolGainPercent).add(realTotalLayerGainPercents)<=100,"设置每个主体的奖励超过了100%");
    }
   function assertInvestPercentage(
                uint256 _platformDistributePercent,
                uint256 _adminDistributePercent,
                uint256 _gainPoolDistributePercent,
                uint256 _profitPoolDistributePercent,
                uint256 _totalLayerDistributePercents
                )internal pure{
        //平台直接分配+代理商直接分配+奖池+分红池+推荐人直接分配 不能超过100%
        require(_platformDistributePercent.add(_adminDistributePercent).add(_gainPoolDistributePercent).add(_profitPoolDistributePercent).add(_totalLayerDistributePercents)<=100,"设置每个主体的投资分配超过了100%");

    }

    function createNewRound(uint256 initPoolAmount)internal returns(Round storage round){
        nowRoundId++;
        Round memory newRound = Round(nowRoundId,now,now.add(roundTime),0,initPoolAmount,0,admin,0,0,false);
        roundMap[nowRoundId]=newRound;
        //发送一轮开始事件
        emit onRoundStart(gameId,nowRoundId,initPoolAmount);
        return roundMap[nowRoundId];
    }


    function investByToken(uint256 amount) external
        checkAmountLimit(amount)
    {
        require(tokenType==2,"这个服只支持token投资");
        require(token.transferFrom(msg.sender, address(this), amount),"可划转额度不足");
        investCore(amount);
    }

    function investByEth() payable external
        checkAmountLimit(msg.value)
    {
        require(tokenType==1,"这个服只支持eth投资");
        investCore(msg.value);
    }


    function investCore(uint256 amount) internal
    {
        require(!Address.isContract(msg.sender), "只允许人类投资");
        // 判断当前论是否已经结束,如果是，则切换到下一轮
        Round storage currentRound=roundMap[nowRoundId];
        if((currentRound.hasClosed==false)&&(now > currentRound.endTime)){
            currentRound = swapToNextRound(currentRound);
        }
        
        // 记录当前玩家为赢家
        currentRound.recentlyPlayer = msg.sender;
        // 记录当前轮次玩家数
        if(userRoundAmount[msg.sender][nowRoundId]==0){
            currentRound.users++;
        }
        // 记录玩家每轮投资
        userRoundAmount[msg.sender][nowRoundId]=userRoundAmount[msg.sender][nowRoundId].add(amount);
        // 记录到总投资
        currentRound.investAmount=currentRound.investAmount.add(amount);

        // 收益分配(分红)，这里分红池部分没法一个人一个人去分配，所以记录到轮次里面，用户按照keys的占比去提取
        uint256 remainAmount=distributeInvestAmount(amount,currentRound);

        //剩余的投资额归还给自己，并按照这个计算key
        userTotalGain[msg.sender]=userTotalGain[msg.sender].add(remainAmount);
        userRoundGain[msg.sender][nowRoundId]=userRoundGain[msg.sender][nowRoundId].add(remainAmount);
        

        //keys核心算法计算用户应得多少keys
        uint256 userKeys=calacKeys(currentRound,amount);
        //增加轮次总keys
        currentRound.keys=currentRound.keys.add(userKeys);
        //增加用户当前轮的keys
        userRoundKeys[msg.sender][nowRoundId]=userRoundKeys[msg.sender][nowRoundId].add(userKeys);
        //增加轮次结束时间
        uint256 addingTime=userKeys.mul(timePerKey);    

        if(now.add(roundTime)<currentRound.endTime.add(addingTime)){    
            currentRound.endTime=now.add(roundTime);
        }else{
            currentRound.endTime=currentRound.endTime.add(addingTime);
        }

        emit onInvest(gameId,msg.sender,amount,userKeys);
    }

    //TODO: keys核心算法计算用户应得多少keys
    function calacKeys(Round memory currentRound,uint256 amount) pure internal returns(uint256){
        return(keys((currentRound.investAmount).add(amount)).sub(keys(currentRound.investAmount)));
    }

    function keys(uint256 amount) internal pure returns(uint256)
    {
        return ((((((amount).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    // 投资分配，（投资金额，当前轮次）
    function distributeInvestAmount(uint256 amount,Round storage currentRound) internal returns(uint256){
  
        //1、给平台加收入分配奖励(记录总奖励和每轮奖励)
        
        uint256 platFormDistributeAmount=calacPercentAmount(amount,platformDistributePercent);
        userTotalGain[platformAddr]=userTotalGain[platformAddr].add(platFormDistributeAmount);
        userRoundGain[platformAddr][nowRoundId]=userRoundGain[platformAddr][nowRoundId].add(platFormDistributeAmount);

        //2、给代理人加奖励
        
        uint256 adminDistributeAmount=calacPercentAmount(amount,adminDistributePercent);
        userTotalGain[admin]=userTotalGain[admin].add(adminDistributeAmount);
        userRoundGain[admin][nowRoundId]=userRoundGain[admin][nowRoundId].add(adminDistributeAmount);

        //3、给投资人见点奖励
        
        uint256 totalShardingDistributeAmount=calacPercentAmount(amount,totalLayerDistributePercents);
        //从userbook里面获取这个用户的邀请关系
         (
            ,
            ,
            ,
            ,  
            uint256[] memory senderInviteUserIds 
         )
        =userBook.queryUserByGameIdAndAddr(gameId,msg.sender);

        uint256 layer=0;
        uint256 realTotalShardingDistributeAmount=0;
        for(uint256 i=senderInviteUserIds.length-1;i>=0;i--){
            if(layer>=userGainLayer){
                break;
            }
            uint256 partnerId=senderInviteUserIds[i];
            (
                ,
                address partnerAddress,
                ,
                ,  
                 
            )
            =userBook.queryUserByGameIdAndUserId(gameId,partnerId);

            if(userRoundAmount[partnerAddress][nowRoundId]<seePointminMinAmount){
                layer++;
                continue;
            }

            uint256 partnerDistributeAmount=calacPercentAmount(totalShardingDistributeAmount,layerDistributePercents[layer]);

            userTotalGain[partnerAddress]=userTotalGain[partnerAddress].add(partnerDistributeAmount);
            userTotalSeeAmount[partnerAddress]=userTotalSeeAmount[partnerAddress].add(partnerDistributeAmount);
            userRoundGain[partnerAddress][nowRoundId]=userRoundGain[partnerAddress][nowRoundId].add(partnerDistributeAmount);
            realTotalShardingDistributeAmount=realTotalShardingDistributeAmount.add(partnerDistributeAmount);
            layer++;
        }

        //4、按比例投入到分红池，剩余见点奖励也投入到分红池
        uint256 remainShardingDistributeAmount=totalShardingDistributeAmount.sub(realTotalShardingDistributeAmount);

        uint256 profitPoolDistributeAmount=calacPercentAmount(amount,profitPoolDistributePercent);
        currentRound.profitPoolAmount=currentRound.profitPoolAmount.add(profitPoolDistributeAmount).add(remainShardingDistributeAmount);

        //5、按比例投入到奖金池的比例
        
        uint256 gainPoolDistributeAmount=calacPercentAmount(amount,gainPoolDistributePercent);
        currentRound.gainPoolAmount=currentRound.gainPoolAmount.add(gainPoolDistributeAmount);
        
        return calacRemainDistributeInvestAmount(amount,platFormDistributeAmount,adminDistributeAmount,totalShardingDistributeAmount,profitPoolDistributeAmount,gainPoolDistributeAmount);
       
    }

    function calacRemainDistributeInvestAmount(uint256 _amount
        ,uint256 _platFormDistributeAmount
        ,uint256 _adminDistributeAmount
        ,uint256 _totalShardingDistributeAmount
        ,uint256 _profitPoolDistributeAmount
        ,uint256 _gainPoolDistributeAmount
        ) pure internal returns(uint256)
    {
        uint256 sum = _platFormDistributeAmount.add(_adminDistributeAmount).add(_totalShardingDistributeAmount).add(_profitPoolDistributeAmount).add(_gainPoolDistributeAmount);
        return _amount.sub(sum);
    }

    // event onRoundEnd(
    //     uint256 indexed gameId,
    //     uint256 indexed roundId,
    //     address indexed winnerAddr,
    // );

    function swapToNextRound(Round storage currentRound) internal returns(Round storage nextRound){
        currentRound.hasClosed=true;
        //发送一轮结束事件
        emit onRoundEnd(gameId,nowRoundId,currentRound.recentlyPlayer);

        //奖励分配
        uint256 remainAmount=distributionGain(currentRound);

        return createNewRound(remainAmount);
    }

    //奖励分配
    function distributionGain(Round storage currentRound) internal returns(uint256 remainAmount){
        //奖池分配
        //获取奖池总金额
        uint256 poolAmount=currentRound.gainPoolAmount;
        
        //1、给平台加奖励(记录总奖励和每轮奖励)
        
        uint256 platFormGain=calacPercentAmount(poolAmount,platformGainPercent);
        userTotalGain[platformAddr]=userTotalGain[platformAddr].add(platFormGain);
        userRoundGain[platformAddr][nowRoundId]=userRoundGain[platformAddr][nowRoundId].add(platFormGain);

        //2、给代理人加奖励

        uint256 adminGain=calacPercentAmount(poolAmount,adminGainPercent);
        userTotalGain[admin]=userTotalGain[admin].add(adminGain);
        userRoundGain[admin][nowRoundId]=userRoundGain[admin][nowRoundId].add(adminGain);

        //3、给赢家加奖励
        //获取赢家地址
        address payable winnerAddr = currentRound.recentlyPlayer;

        uint256 winnerGain=calacPercentAmount(poolAmount,winnerGainPercent);
        userTotalGain[winnerAddr]=userTotalGain[winnerAddr].add(winnerGain);
        userRoundGain[winnerAddr][nowRoundId]=userRoundGain[winnerAddr][nowRoundId].add(winnerGain);

        //4、给赢家上级加奖励封顶
        
        uint256 shardingLayerGain= calacPercentAmount(winnerGain,totalLayerGainPercents);

        //从userbook里面获取这个用户的邀请关系
         (
            ,
            address winnerAddress,
            ,
            ,  
            uint256[] memory winnerInviteUserIds 
         )
        =userBook.queryUserByGameIdAndAddr(gameId,winnerAddr);

        uint256 realShardingLayerGain=0;
        uint256 layer=0;
        for(uint256 i=winnerInviteUserIds.length-1;i>=0;i--){
            if(layer>=userGainLayer){
                break;
            }            
            uint256 partnerId=winnerInviteUserIds[i];
            (
                ,
                address partnerAddress,
                ,
                ,  
                 
            )
            =userBook.queryUserByGameIdAndUserId(gameId,partnerId);

            if(userRoundAmount[partnerAddress][nowRoundId]<seePointminMinAmount){
                layer++;
                continue;
            }

            uint256 partnerGain=calacPercentAmount(shardingLayerGain,layerGainPercents[layer]);

            userTotalGain[partnerAddress]=userTotalGain[partnerAddress].add(partnerGain);
            userTotalSeeAmount[partnerAddress]=userTotalSeeAmount[partnerAddress].add(partnerGain);
            userRoundGain[partnerAddress][nowRoundId]=userRoundGain[partnerAddress][nowRoundId].add(partnerGain);
            realShardingLayerGain=realShardingLayerGain.add(partnerGain);
            layer++;
        }

        //5、给下一轮的奖励保留
        remainAmount=calacRemainDistributionGainAmount(poolAmount,platFormGain,adminGain,winnerGain,realShardingLayerGain);

        //发送奖励事件
        emit onProfit(gameId,nowRoundId,winnerAddress,winnerGain,realShardingLayerGain,platFormGain,adminGain);        
    }

    function calacRemainDistributionGainAmount(uint256 _poolAmount,uint256 _platFormGain,uint256 _adminGain,uint256 _winnerGain,uint256 _realShardingLayerGain) pure internal returns(uint256){
        return _poolAmount.sub(_platFormGain).sub(_adminGain).sub(_winnerGain).sub(_realShardingLayerGain);
    }

   //TODO:从分红池提取收益
    function withdrawFromProfitPool(uint256 roundId) external{
        require(!Address.isContract(msg.sender), "只允许人类提现");     // 判断是否合约
        // require(roundId>0 && roundId<nowRoundId, "轮次错误");
        // 判断轮次结束
        Round memory round=roundMap[roundId];
        require(round.hasClosed, "轮次未结束");
        uint256 uesrKeys=userRoundKeys[msg.sender][roundId];
        require(!userRoundHasWithdraw[msg.sender][roundId], "已分红提现");
        uint256 hasWithdrawAmount=profitPoolHasWithdrawAmount[roundId];
        require(hasWithdrawAmount<round.profitPoolAmount, "分红池已空");
        // 提现金额计算
        uint256 userAmount=uesrKeys.mul(round.profitPoolAmount).div(round.keys);
        // 提现金额不超过剩余总额   
        if (userAmount + hasWithdrawAmount > round.profitPoolAmount){
            userAmount=round.profitPoolAmount-hasWithdrawAmount;
        }
        // 转账
        if (tokenType==1) {     // eth
            msg.sender.transfer(userAmount);
        } else if (tokenType==2) {      // 代币
            require(token.transfer(msg.sender, userAmount),"可提现额度不足");
        } else {
            require(false,"合约货币类型错误");
        }
        // 提现后相关记录和修改
        userRoundHasWithdraw[msg.sender][roundId]=true;
        profitPoolHasWithdrawAmount[roundId]=profitPoolHasWithdrawAmount[roundId].add(userAmount);

        //发送提现事件
        emit onWithdraw(gameId,msg.sender,userAmount);     
    }

    //TODO:从分红池以外的用户收入获取收益
    function withdrawGain() external{
        require(!Address.isContract(msg.sender), "只允许人类提现");
        uint256 userAmount=userTotalGain[msg.sender]-userTotalGainWithdraw[msg.sender];
        require(userAmount>0, "已非分红提现");
        // 转账
        if (tokenType==1) {     // eth
            msg.sender.transfer(userAmount);
        } else if (tokenType==2) {      // 代币
            require(token.transfer(msg.sender, userAmount),"可提现额度不足");
        } else {
            require(false,"合约货币类型错误");
        }
        // 提现后相关记录和修改
        userTotalGainWithdraw[msg.sender]=userTotalGain[msg.sender];

        //发送提现事件
        emit onWithdraw(gameId,msg.sender,userAmount);          
    }

    // 百分比计算
    function calacPercentAmount(uint256 _amount, uint256 _percent) pure internal  returns(uint256) {
        return _amount.mul(_percent).div(100);
    }

    function transferAdmin(address payable _admin) external
        onlyAdmin
    {
        admin=_admin;
    }

    // 由key计算金额
    function calacAmounts(uint256 rid, uint256 ks) view external returns(uint256){
        Round memory currentRound=roundMap[rid];
        return(amounts((currentRound.keys).add(ks)).sub(amounts(currentRound.keys)));
    }

    function amounts(uint256 ks) internal pure returns(uint256)
    {
        uint256 a=1000000000000000000;
        uint256 b=312500000000000000000000000;
        uint256 c=5624988281256103515625000000000000000000000000000000000000000000;
        uint256 d=74999921875000000000000000000000;
        uint256 e=156250000;
        return (((ks.mul(e)).add(d).sq()).sub(c)).div(a.mul(b));
        //return ((((((amount).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    function queryRoundById(uint256 rid) external view returns(
        uint256 roundId,
        uint256 startTime,
        uint256 endTime,
        uint256 investAmount,
        //奖池金额
        uint256 gainPoolAmount,
        uint256 winnerGainAmount,
        //分红池金额
        uint256 profitPoolAmount,
        address payable recentlyPlayer,
        uint256 keys,
        uint256 users,
        bool hasClosed)
    {
        Round memory r=roundMap[rid];

        roundId=r.roundId;
        startTime=r.startTime;
        endTime=r.endTime;
        investAmount=r.investAmount;
        gainPoolAmount=r.gainPoolAmount;
        profitPoolAmount=r.profitPoolAmount;
        recentlyPlayer=r.recentlyPlayer;
        keys=r.keys;
        users=r.users;
        hasClosed=r.hasClosed;

        winnerGainAmount=calacPercentAmount(gainPoolAmount,winnerGainPercent);
    }

    function queryRoundByIdAndUser(address user, uint256 rid) external view returns(
        uint256 uRoundGain      // 每轮奖励
        ,uint256 uRoundKeys      // 每轮key数
        ,uint256 uRoundAmount     // 每轮投资
        ,uint256 uTotalGain       // 总奖金
        ,uint256 uGainBalance       // 奖金提现余额
        ,uint256 uTotalSeeAmount    // 总见点奖金
        )
    {
        uRoundGain=userRoundGain[user][rid];
        uRoundKeys=userRoundKeys[user][rid];
        uRoundAmount=userRoundAmount[user][rid];
        uTotalGain=userTotalGain[user];
        uGainBalance=userTotalGain[user]-userTotalGainWithdraw[user];
        uTotalSeeAmount=userTotalSeeAmount[user];
    }

    function queryProfitAmount(address user, uint256 roundId) external view returns(uint256 userAmount) {
        // 判断轮次结束
        Round memory round=roundMap[roundId];
        require(round.hasClosed, "轮次未结束");
        uint256 uesrKeys=userRoundKeys[user][roundId];
        // 提现金额计算
        userAmount=uesrKeys.mul(round.profitPoolAmount).div(round.keys);
    }
}
