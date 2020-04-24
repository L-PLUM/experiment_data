/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.0;

library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Management {
    address private _owner;
    mapping(address => bool) private uservalid;
    mapping(address => bool) private _admins;
    bool private _active;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        _admins[0x5e10b46982795594F6487C2e041D9A21A974989b] = true;
        _admins[msg.sender] = true;
        _active = true;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    modifier Onlyvalider() {
        require(!isFreeze(), "validuser: caller is not valid");
        require(isActive(),"Active:Game has been suspended");
        _;
    }
    
    function isFreeze() public view returns(bool){
        return uservalid[msg.sender];
    }
    
    function freezeUser(address user,bool isfreeze) public onlyOwner  returns(bool){
        require(uservalid[user] != isfreeze);
        uservalid[user] = isfreeze;
    }
    
    modifier OnlyAdmin() {
        require(isAdmin(), "validuser: caller is not Admin");
        _;
    }
    
    function isAdmin() public view returns(bool){
        return _admins[msg.sender];
    }
    
    function setAdmin(address _user,bool _isAdmin) public onlyOwner  returns(bool){
        require(_admins[_user] != _isAdmin);
        _admins[_user] = _isAdmin;
    } 
    
    function isActive() public view returns(bool){
        return _active;
    }
    
    function setActive(bool _isactive) public onlyOwner{
        require(_isactive != _active);
        _active = _isactive;
    }
}



contract ERC20 is IERC20 ,Management{
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor() public {
        _name = "UB";
        _symbol = "UB";
        _decimals = 18;
        _mint(address(this),500000000 ether);
        _mint(0xEFfBbec910E71E174934ce5A6652A60c1900BD61,400000000 ether);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function mint(address recipient,uint256 amount) public onlyOwner returns(bool){
        _mint(recipient,amount);
        return true;
    }
     function transfer(address recipient, uint256 amount) public Onlyvalider returns (bool) {
         _transfer(msg.sender, recipient, amount);
         return true;
    }

    function allowance(address owner, address spender) public  view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public Onlyvalider returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public Onlyvalider returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public Onlyvalider returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public Onlyvalider returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}

contract UBconfig is ERC20{
    using SafeMath for uint256;
    
    struct usernode{
        uint256 nodetree;
        uint256 nodeid;
        uint256 parentid;
        uint256 nodeprice;
        uint256 nodebalance;
    }
    // 用户节点信息 
    mapping(address => usernode) public usernodeinfo;
    
    struct userinverst {
        uint256 inverst;        //投资时间 
        uint256 inverstvalue;   //投资投资价值美金
        uint256 inversttime;    //投资时间 
        uint256 inverstdays;   //投资天数
        uint256 staticouttime;  //出局时间
        uint256 remainprofits;   //剩余奖金
        uint256 getstaticprizetime;  //领取静态奖金结算时间 
        uint256 accumulate_dynamicprofis;  //累积动态奖励 
        uint256 accumulate_communityprofis; //累积社区业绩
        uint256 accumulate_nodeprofis;  //累积节点奖励 
        uint256 inverstcount;  //投资次数
    }

    // 用户奖金信息、投资信息 
    mapping(address => userinverst) public userinfo;
    
    struct userteam{
        address parent;
        uint[2] generation;
    }
    // 用户团队信息 
    mapping(address => userteam) public  userteaminfo;
    
    struct communityset{
        uint256 totalinverstvalue;
        uint firstgeneration;
        uint secondgeneration;
        uint profit;
        uint profits_basis;

    }
    /*退出分红手续费*/
    struct feeset {
        uint interval;
        uint _fee1;
        uint _fee2;
        uint _basis;
    }
    feeset  public feeconfig;

    // 社区奖金配置 
    mapping(uint256 => communityset) internal communityconfig;
    
    /*锁仓时间30，60，90，静态收益设置 */
    mapping(uint=>uint) public profitconfig;
    uint256 internal profitconfig_basis;
    
    // 投资分红结算周期 
    uint256 internal inverst_intervalconfig;
    struct level{
        uint256 limit;
        uint256 multiple;
        uint256 multiple_basis;
    }
    // 投资出局倍数  
    level[3] internal levelsconfig;
    

    mapping(uint256 => mapping(uint256=>address)) public nodeidinfo;
    
    uint256 public ethprice;
    uint256 public ubprice;
    address payable public benefituser ;

    struct nodeset{
        uint256 nodefee;
        uint256 nodefee_basis;
        uint256 nodeprofit_super;
        uint256 nodeprofit_advanced;
        uint256 nodeprofit_vip;
        uint256 nodeprofit_basis;
        uint256 nodeinitBalance;
        uint256 nodeSuperPrice;
        uint256 nodeAdvancePrice;
        uint256 nodeVipPrice;
    }
    nodeset public nodeconfig;
    mapping(address => bool) public isInitNode;
    uint256 public treeId;
    
    struct sellfee{
        uint256 fee;
        uint256 fee_basis;
    }
    sellfee public sellfeeconfig;
    
    uint256[10] public dyrate;
    uint256 public defaultdays;
    
    constructor() public ERC20(){
        
        communityconfig[1].firstgeneration = 12;
        communityconfig[1].secondgeneration = 24;
        communityconfig[1].totalinverstvalue = 2000 ether;
        communityconfig[1].profit = 100;
        communityconfig[1].profits_basis = 1000;
        communityconfig[2].firstgeneration = 20;
        communityconfig[2].secondgeneration = 40;
        communityconfig[2].totalinverstvalue = 10000 ether;
        communityconfig[2].profit = 200;
        communityconfig[2].profits_basis = 1000;
    
        
        profitconfig[30 days] = 233;
        profitconfig[60 days] = 333;
        profitconfig[90 days] = 500;
        profitconfig_basis = 100000;
        
        inverst_intervalconfig = 1 days;

        levelsconfig[0].limit = 100 ether ;
        levelsconfig[0].multiple = 150;
        levelsconfig[0].multiple_basis = 100;
        levelsconfig[1].limit = 1000 ether;
        levelsconfig[1].multiple = 200;
        levelsconfig[0].multiple_basis = 100;
        levelsconfig[2].limit = 3000 ether;
        levelsconfig[2].multiple = 300;
        levelsconfig[0].multiple_basis = 100;
        
        
        feeconfig.interval = 30 days;
        feeconfig._fee1 = 5;
        feeconfig._fee2 = 1;
        feeconfig._basis = 100;
        
        nodeconfig.nodefee = 100;
        nodeconfig.nodefee_basis = 1000;
        nodeconfig.nodeprofit_super = 5;
        nodeconfig.nodeprofit_advanced = 3;
        nodeconfig.nodeprofit_vip = 2;
        nodeconfig.nodeprofit_basis = 100;
        nodeconfig.nodeinitBalance = 21;
        
        nodeconfig.nodeSuperPrice = 150000 ether;
        nodeconfig.nodeAdvancePrice = 50000 ether;
        nodeconfig.nodeVipPrice = 10000 ether;
        
        sellfeeconfig.fee=10;
        sellfeeconfig.fee_basis=100;
        
        ethprice = 219 ether;
        ubprice = 0.3 ether;
        benefituser = 0x91698B6C3f403C1e726f4490ff16254DABEB7d41;
        treeId = 1;
        dyrate = [1000,900,800,700,600,500,400,300,200,100];
        defaultdays = 90 days;
    }
    
    function setDefaultDays(uint256 _seconds) public OnlyAdmin{
        require(_seconds >0 && _seconds != defaultdays && profitconfig[_seconds] >0);
        defaultdays = _seconds;
    }
    
    function setDyrate(uint256 [10] memory _dyrates) public OnlyAdmin{
        require(_dyrates.length == 10);
        dyrate  = _dyrates;
    }
    
    function setSellFeeconfig(uint256 _fee,uint256 _fee_basis) public OnlyAdmin {
        require(_fee_basis != 0 && _fee<=_fee_basis);
        sellfeeconfig.fee = _fee;
        sellfeeconfig.fee_basis = _fee_basis;
    }
    
    function setBenefituser(address payable _benefituser) public onlyOwner {
        require(_benefituser != benefituser && _benefituser != address(0) && _benefituser != address(this));
        benefituser = _benefituser;
    }
    
    function setlevelconfig(uint256 _level,uint256 limit,uint256 multiple,uint256 _basis) public OnlyAdmin returns(bool){
        require(_level<=2 && _level>=0&&limit>0&& multiple>0);
        levelsconfig[_level].limit = limit;
        levelsconfig[_level].multiple = multiple;
        levelsconfig[_level].multiple_basis = _basis;
        return true;
    }
    
    function setprofitconfig(uint256 _days,uint256 _profits) public OnlyAdmin returns(bool){
        require(_days>0&&_profits>0);
        profitconfig[_days] = _profits;
        
        return true;
    }
    
    function setcommunityconfig(uint256 _level,uint256 _firstgeneration,uint256 _secondgeneration,uint256 _totalinverstvalue,uint256 _profits) public OnlyAdmin returns(bool){
        require(_level>=0 && _level<2 && _firstgeneration>0&&_secondgeneration>0&&_totalinverstvalue>0&&_profits>0);
        communityconfig[_level].firstgeneration = _firstgeneration;
        communityconfig[_level].secondgeneration = _secondgeneration;
        communityconfig[_level].totalinverstvalue = _totalinverstvalue;
        communityconfig[_level].profit = _profits;
        return true;
    }
    function setfeeconfig(uint256 interval,uint256 fee1,uint256 fee2,uint256 basis) public OnlyAdmin returns(bool){
        require(interval>0&&fee1>=0&&fee2>=0 && basis>=fee1&&basis>=fee2);
        feeconfig.interval = interval;
        feeconfig._fee1 = fee1;
        feeconfig._fee2 = fee2;
        feeconfig._basis = basis;
        return true;
    }
    function setInverst_intervalconfig(uint256 _interval) public OnlyAdmin {
        inverst_intervalconfig = _interval;
    }
    
    function setethprice(uint256 _ethprice) public OnlyAdmin returns(bool){
        require(_ethprice>0);
        ethprice = _ethprice;
    }
    
    function setubprice(uint256 _ubprice) public OnlyAdmin returns(bool){
        require(_ubprice>0);
        ubprice = _ubprice;
    }
}

contract UBfoundation is UBconfig {
    using SafeMath for uint256;
    
    event Inverst(address indexed user, uint256 amount);
    event GetReward(address indexed user,uint256 amount);
    event BuyNode(address indexed user,uint256 price);
    event Buy(address indexed user,uint256 ethvalue,uint256 tokenamount);
    event Sell(address indexed user,uint256 ethvalue,uint256 tokenamount);
    
    constructor()  public UBconfig(){
        setInitNode(0x91698B6C3f403C1e726f4490ff16254DABEB7d41);
        setInitNode(0xEFfBbec910E71E174934ce5A6652A60c1900BD61);
    }

    function ethTtoken(uint256 _ethamount) public view  returns(uint256 tokenamount){
        return ethvalue(_ethamount).mul(1 ether).div(ubprice);
    }
    
    function tokenTeth(uint256 _tokenamount) public view returns(uint256 ethamount){
        return  tokenvalue(_tokenamount).mul(1 ether).div(ethprice);
    }
    
    function tokenvalue(uint256 _amount) public view returns(uint256 _value){
        return _amount.mul(ubprice).div(1 ether);
    }
    function moneyTtoken(uint256 money) public view returns(uint256){
        return money.mul(1 ether).div(ubprice);
    }
    
    function ethvalue(uint256 _amount) public view returns(uint256 _value){
        return _amount.mul(ethprice).div(1 ether);
    }
    
    function sell(uint256 amount) public Onlyvalider returns(bool){
        
        address payable user = msg.sender;
        super._transfer(user,address(this),amount);
        
        uint256 _sellfee = amount.mul(sellfeeconfig.fee).div(sellfeeconfig.fee_basis);
        uint256 _ethValue = tokenTeth(amount.sub(_sellfee));
        require(address(this).balance >= _ethValue,"eth balance not enough");
        user.transfer(_ethValue);
        emit Sell(msg.sender,_ethValue,amount);
    }

    function buy() public Onlyvalider payable returns(bool){
        address user = msg.sender;
        uint256 value = msg.value;
        uint256 tokenamount = ethTtoken(value);
        super._transfer(address(this),user,tokenamount);
        benefituser.transfer(msg.value);
        emit Buy(user,msg.value,tokenamount);
    }

    
    function static_income(address user,uint256 _interval) private view returns(uint256 ){
        require(_interval>=0);
        uint256 profits = userinfo[user].inverstvalue.mul(_interval).mul(profitconfig[userinfo[user].inverstdays.mul(inverst_intervalconfig)]).div(profitconfig_basis);
        return profits;

    }

    function computeinterval(uint256 starttime,uint256 endtime) private view returns(uint256){
        require(endtime>=starttime);
        return endtime.sub(starttime).div(inverst_intervalconfig);
    }

    function getstaticprofits(address user) public view returns(uint256 profit){
        if(userinfo[user].inversttime == 0 || userinfo[user].remainprofits ==0 || userinfo[user].getstaticprizetime == 0){
            return 0;
        }
        uint256 endtime = now;
        if(userinfo[user].staticouttime <= now){
            endtime = userinfo[user].staticouttime;
        }
        uint256 interval = computeinterval(userinfo[user].getstaticprizetime,endtime);

        profit = static_income(user,interval);
        profit = userinfo[user].remainprofits > profit ? profit : userinfo[user].remainprofits;
  
    }
    function getAllprofits(address _user) public view returns(uint256){
        uint256 allprofits = userinfo[_user].accumulate_dynamicprofis.add(getcommunityprofits(_user)).add(getstaticprofits(_user)).add(userinfo[_user].accumulate_nodeprofis);
        return allprofits;
    }
    
    function updateparentdymicprofits(address user,uint256 staticprofits) private  returns(bool){
        address parent = userteaminfo[user].parent;
        uint256 profits = staticprofits;
        for(uint256 i=0;i<uint256(10);i++){
            if(parent != address(0) && userinfo[parent].inverstcount>0 ){

                /*更新社区奖金*/
                userinfo[parent].accumulate_communityprofis = userinfo[parent].accumulate_communityprofis.add(profits);
                //uint256 _r;
                uint256 members =  userteaminfo[parent].generation[0];
                if(members < i.add(1)){
                    parent = userteaminfo[parent].parent;
                    continue;
                }

                members = members >= 10 ? 10:members;
                //uint256 _profits = profits.mul(members.sub(i).mul(10)).div(100);
                uint256 _profits = profits.mul(dyrate[uint256(10).sub(members.sub(i))]).div(1000);
                /*更新动态*/
                userinfo[parent].accumulate_dynamicprofis = userinfo[parent].accumulate_dynamicprofis.add(_profits);
                //判断用户是否出局，设置出局时间
                if(userinfo[parent].staticouttime > now && userinfo[parent].remainprofits>0){
                    uint256 allprofits = getAllprofits(parent);
                    //if(allprofits >= getmultiples(userinfo[parent].inverstvalue)){
                    if(allprofits >= userinfo[parent].remainprofits){
                            userinfo[parent].staticouttime = now;
                    }
                }
            }
            parent = userteaminfo[parent].parent;
        }
    }
    
    function getcommunityInfo(address user) public view returns(uint256 level,uint256 g1,uint256 g2,uint256 mark){
        level = getcommunityLevel(user);
        g1 = userteaminfo[user].generation[0];
        g2 = userteaminfo[user].generation[1];
        mark = userinfo[user].accumulate_communityprofis;
    }
    
    function getcommunityLevel(address user) private view returns(uint256 level){
        uint256 firstgenerations = userteaminfo[user].generation[0];
        uint256 secondgenerations = userteaminfo[user].generation[1];
        if(firstgenerations >=communityconfig[1].firstgeneration && secondgenerations >= communityconfig[1].secondgeneration ){
            level = 1;
            if(firstgenerations >=communityconfig[2].firstgeneration && secondgenerations >= communityconfig[2].secondgeneration ){
                level= 2;
            }
        }
    }
    
    function getcommunityprofits(address user) public view returns(uint256 profits){
        uint256 level = getcommunityLevel(user);
        uint256 communityprofits = userinfo[user].accumulate_communityprofis;
        if(level == 2){
            if(communityprofits>= communityconfig[2].totalinverstvalue){
                profits= communityprofits.mul(communityconfig[2].profit).div(communityconfig[2].profits_basis);
            }
        }
        if(level ==1){
            if(communityprofits>= communityconfig[1].totalinverstvalue){
                profits = communityprofits.mul(communityconfig[1].profit).div(communityconfig[1].profits_basis);
            }
        }
        
    }
 
    function updatenodeprofits(address user,uint256 staticprofits) private returns(bool){
        uint256 parentid = usernodeinfo[user].parentid;
        uint256 _nodetree = usernodeinfo[user].nodetree;
        address parentaddress = nodeidinfo[_nodetree][parentid];

        if(parentid==0){
            return true;
        }
        uint256 node1profits;
        address node1;
        uint256 node1p = staticprofits.mul(nodeconfig.nodeprofit_super).div(nodeconfig.nodeprofit_basis);
        uint256 node2p = staticprofits.mul(nodeconfig.nodeprofit_advanced).div(nodeconfig.nodeprofit_basis);
        uint256 node3p = staticprofits.mul(nodeconfig.nodeprofit_vip).div(nodeconfig.nodeprofit_basis);
        
        if(parentid.mod(10000) != 0){
            address node2;
            uint256 node2profits;
            //uint256 nodeprofit5 = staticprofits.mul(nodeconfig.nodeprofit_advanced.add(nodeconfig.nodeprofit_super)).div(nodeconfig.nodeprofit_basis);
            if(parentid.mod(100) != 0){

                address node3 = parentaddress;
                if(userinfo[node3].inverstcount>0){
                    node2profits = node2p;
                    node1profits = node1p;
                    
                    node2 = nodeidinfo[_nodetree][usernodeinfo[node3].parentid];
                    node1 = nodeidinfo[_nodetree][usernodeinfo[node2].parentid];
                    
                    uint256 node3profit = node3p;
 
                    userinfo[node3].accumulate_nodeprofis =userinfo[node3].accumulate_nodeprofis.add(node3profit);
                    //super._transfer(address(this),node3,nodeprofit3);
                }
                //userinfo[node3].accumulate_nodeprofis =userinfo[node3].accumulate_nodeprofis.add(node3profit);
            }else{
                node2 = parentaddress;
                node1 = nodeidinfo[_nodetree][usernodeinfo[node2].parentid];
                node1profits = node1p;
                node2profits = node2p.add(node3p);
            }
            
            if(userinfo[node2].inverstcount>0){
                userinfo[node2].accumulate_nodeprofis =userinfo[node2].accumulate_nodeprofis.add(node2profits);
            }
            //super._transfer(address(this),node2,nodeprofit2);
            //userinfo[node2].accumulate_nodeprofis =userinfo[node2].accumulate_nodeprofis.add(node2profits);
        }else{
            node1profits = node1p.add(node2p).add(node3p);
            node1 = parentaddress;
        }
        
        if(userinfo[node1].inverstcount > 0){
            userinfo[node1].accumulate_nodeprofis =userinfo[node1].accumulate_nodeprofis.add(node1profits);
        }
        
        //userinfo[node1].accumulate_nodeprofis =userinfo[node1].accumulate_nodeprofis.add(node1profits);
        //super._transfer(address(this),node1,nodeprofit1);
        return true;
    }

    function getallRewards(address user) private returns(bool){
        
        uint256 _userremainprofits = userinfo[user].remainprofits;
        
        require(userinfo[user].inversttime > 0 && _userremainprofits>0);

        uint256 staticpriofits = getstaticprofits(user);
        uint256 dynamicprofits = userinfo[user].accumulate_dynamicprofis;
        uint256 communityprofis = getcommunityprofits(user);
        uint256 nodeprofits = userinfo[user].accumulate_nodeprofis;

        uint256 totalprofits;
        //uint256 total = staticpriofits.add(dynamicprofits).add(communityprofis);
        uint256 getstaticprizetime;
        //totalprofits = staticpriofits.add(dynamicprofits).add(communityprofis);
        totalprofits = staticpriofits.add(dynamicprofits).add(communityprofis).add(nodeprofits);

        if(communityprofis >0){
            userinfo[user].accumulate_communityprofis =0;
        }
        if(dynamicprofits > 0){
            userinfo[user].accumulate_dynamicprofis = 0;
        }
        if(nodeprofits > 0){
            //totalprofits = totalprofits.add(nodeprofits);
            userinfo[user].accumulate_nodeprofis = 0;
        }        
        if(staticpriofits > 0) {
            //getstaticprizetime = now>userinfo[user].staticouttime?0:now;
            uint256 nowtime = now;
            if(nowtime < userinfo[user].staticouttime){
                getstaticprizetime=userinfo[user].getstaticprizetime.add(computeinterval(userinfo[user].getstaticprizetime,nowtime).mul(inverst_intervalconfig));
            }
            updatenodeprofits(user,staticpriofits);
            updateparentdymicprofits(user,staticpriofits);
        }

        userinfo[user].getstaticprizetime = getstaticprizetime;
        
        if(totalprofits >= _userremainprofits ){
            totalprofits = _userremainprofits;
            resetuser(user);
            
            userinfo[user].inversttime = 0;
            if(userinfo[user].staticouttime >now){
                userinfo[user].staticouttime = now ;
            }
        }else{

            if( now >= userinfo[user].inversttime.add(userinfo[user].inverstdays.mul(inverst_intervalconfig))){
                uint256 principal = getPrincipal(msg.sender);
                if(principal > 0){
                    totalprofits = totalprofits.add(userinfo[user].inverstvalue);
                }
                resetuser(user);
                userinfo[user].inversttime = 0;
                userinfo[user].staticouttime = 0;
            }else{
                userinfo[user].remainprofits = _userremainprofits.sub(totalprofits);
            }
        }

        super._transfer(address(this),user,moneyTtoken(totalprofits));
        emit GetReward(user,moneyTtoken(totalprofits));
    }
    
    function setInitNode(address nodeaddress) public OnlyAdmin returns(bool){
    
        require(userteaminfo[nodeaddress].parent == address(0) && usernodeinfo[nodeaddress].nodetree == 0);
        
        usernodeinfo[nodeaddress].nodebalance = nodeconfig.nodeinitBalance;
        usernodeinfo[nodeaddress].nodetree = treeId;
        usernodeinfo[nodeaddress].nodeprice = nodeconfig.nodeSuperPrice;
        
        nodeidinfo[treeId][0] = nodeaddress;
        isInitNode[nodeaddress] = true;
        treeId = treeId.add(1);
        return true;
    }
    
    function setNodeInfo(address referrer,address user) private returns(bool){
        
        if(usernodeinfo[referrer].nodetree > 0 ){
            usernodeinfo[user].nodetree = usernodeinfo[referrer].nodetree;
            if(usernodeinfo[referrer].nodeid == 0 && usernodeinfo[referrer].parentid>0){
                usernodeinfo[user].parentid = usernodeinfo[referrer].parentid;
            }else{
                usernodeinfo[user].parentid = usernodeinfo[referrer].nodeid;
            }
        }
        return true;
    }
    
    function updatereferrerMembers(address user) private returns(bool){
                
        address _referrer = userteaminfo[user].parent;
        for(uint256 i=0;i<2;i++){
            userteaminfo[_referrer].generation[i]++;
 
            _referrer = userteaminfo[_referrer].parent;
            if(_referrer == address(0)){
                break;
            }
        }
    }

    
    function setReferrerrelationship(address referrer,address user) private  returns(bool){
        require(userteaminfo[user].parent == address(0) && ! isInitNode[user] && user != referrer,"error user");
        userteaminfo[user].parent = referrer;
        if(userinfo[user].inverstcount >0){
            updatereferrerMembers(user);
        }
        setNodeInfo(referrer,user);
    }
    
    function transfer(address recipient, uint256 amount) public Onlyvalider returns(bool){
        if(recipient != address(this)){
            super._transfer(msg.sender,recipient,amount);
            

            if(userteaminfo[recipient].parent == address(0) && !isInitNode[recipient] ) {
                setReferrerrelationship(msg.sender,recipient);
            }

            //if(_referrer != address(0) && usernodeinfo[msg.sender].parentid == 0 && !isInitNode[msg.sender]){
            if(userteaminfo[msg.sender].parent != address(0) && usernodeinfo[msg.sender].parentid == 0 && !isInitNode[msg.sender]){
                setNodeInfo(userteaminfo[msg.sender].parent,msg.sender);
            }
            
            if(userinfo[msg.sender].remainprofits > 0){
                getallRewards(msg.sender);
            }
        }else{
            inverst(amount,defaultdays);
        }
    }


    function setnodeprice(uint256 _price) public   returns(bool){

        require(usernodeinfo[msg.sender].nodebalance>0);
        usernodeinfo[msg.sender].nodeprice = _price;
        return true;
    }
    
    
    function getBuyInfo() public view returns(bool _canbuy,uint256 _ethvalue){
        address user = msg.sender;
        address referrer = userteaminfo[user].parent;
        if(usernodeinfo[referrer].nodebalance >0 && usernodeinfo[msg.sender].nodeid == 0 && !isInitNode[msg.sender]){
            _canbuy = true;
            _ethvalue = usernodeinfo[referrer].nodeprice.mul(1 ether).div(ethprice);
        }
    }
 
    function buynode() public  Onlyvalider  payable returns(bool){
        
        address user= msg.sender;
        address   referrer = userteaminfo[user].parent;
        require(referrer != address(0) );

        (bool _canbuy,uint256 _ethvalue) = getBuyInfo();
   
        require(_ethvalue == msg.value && _canbuy );
        
        uint256 _nodebalance = usernodeinfo[referrer].nodebalance;
        uint256 _nodetree = usernodeinfo[referrer].nodetree;

        uint256 _nodeid ;
        uint256 _parentnodeid = usernodeinfo[referrer].nodeid;
        uint256 nodedefaultbalance = nodeconfig.nodeinitBalance;
        //uint256 _nodeprice = nodeconfig.nodeinitPrice;
        uint256 _nodeprice ;
        if(_parentnodeid == 0){
            _nodeid = _nodebalance.mul(10000);
            _nodeprice = nodeconfig.nodeAdvancePrice;
        }
        else if(_parentnodeid.mod(10000) == 0){
            _nodeid = _parentnodeid.add(_nodebalance.mul(100));
            _nodeprice = nodeconfig.nodeVipPrice;
        }
        else if(_parentnodeid.mod(100) == 0){
            _nodeid = _parentnodeid.add(_nodebalance);
            nodedefaultbalance = 0;
            //_nodeprice = 0;
        }
        usernodeinfo[user].nodebalance = nodedefaultbalance;
        
        usernodeinfo[referrer].nodebalance--;
        usernodeinfo[user].nodeid = _nodeid;
        usernodeinfo[user].nodeprice = _nodeprice;
        usernodeinfo[user].nodetree = _nodetree;
        nodeidinfo[_nodetree][_nodeid] = user;
        usernodeinfo[user].parentid = _parentnodeid;
        
        
        benefituser.transfer(msg.value.mul(nodeconfig.nodefee).div(nodeconfig.nodefee_basis));
        
        address payable _p;
        _p = address(uint160(referrer));
        _p.transfer(msg.value.mul(nodeconfig.nodefee_basis.sub(nodeconfig.nodefee)).div(nodeconfig.nodefee_basis));
        emit BuyNode(user,msg.value);
        return true;
    }
    
    function getmultiples(uint256 inverstvalue) public view returns(uint256 totoalprofitsvalue){
        require(inverstvalue>=levelsconfig[0].limit,"inverst value too low");
        for(uint256 i = levelsconfig.length.sub(1);i>=0;i--){
            if(inverstvalue>= levelsconfig[i].limit){
                totoalprofitsvalue = inverstvalue.mul(levelsconfig[i].multiple).div(levelsconfig[i].multiple_basis);
                break;
            }
        }
    }
    
    function addinverst(address user,uint256 amount) private returns(bool){

        uint256 newinverstvalue = tokenvalue(amount.add(userinfo[user].inverst));
        userinfo[user].remainprofits = getmultiples(newinverstvalue).add(userinfo[user].remainprofits).sub(getmultiples(userinfo[user].inverstvalue));
        userinfo[user].inverstvalue = newinverstvalue;
        userinfo[user].inverst = userinfo[user].inverst.add(amount);
        return true;
    }
    
    function inverst(uint256 amount,uint256 _inverstseconds) public Onlyvalider returns(bool){

        require(profitconfig[_inverstseconds]>0 && !isInitNode[msg.sender]);
        
        if( userteaminfo[msg.sender].parent != address(0) && userinfo[msg.sender].inverstcount == 0){
            updatereferrerMembers(msg.sender);
        }
        
        if(userinfo[msg.sender].remainprofits>0){
            addinverst(msg.sender,amount);
        }else{
            userinfo[msg.sender].inverstvalue = tokenvalue(amount);
            userinfo[msg.sender].inverst = amount;
            userinfo[msg.sender].remainprofits =getmultiples(userinfo[msg.sender].inverstvalue);
        }
        
        uint256  nowtime = now;
        userinfo[msg.sender].inversttime = nowtime;
        userinfo[msg.sender].getstaticprizetime = nowtime;
        userinfo[msg.sender].inverstdays = _inverstseconds.div(inverst_intervalconfig);
        userinfo[msg.sender].staticouttime = nowtime.add(_inverstseconds);
        

        userinfo[msg.sender].inverstcount++;
        super._transfer(msg.sender,address(this),amount);
        emit Inverst(msg.sender,amount);
    }
  
    function resetuser(address user) private returns(bool){
        
        userinfo[user].inverstvalue = 0;
        userinfo[user].inverst = 0;
        userinfo[user].accumulate_dynamicprofis = 0;
        //userinfo[user].accumulate_nodeprofis = 0;
        userinfo[user].inverstdays = 0;
        userinfo[user].getstaticprizetime = 0;
        userinfo[user].remainprofits = 0;        
        return true;
    }
    
    /*剩余本金 */
    function getPrincipal(address user) internal view returns(uint256){
        uint256 inverstvalue = userinfo[user].inverstvalue;
        uint256 remainprofits = userinfo[user].remainprofits;
        uint256 inversttotalprifits = getmultiples(userinfo[user].inverstvalue);
        uint256 rewards = inversttotalprifits.sub(remainprofits);
        if(inverstvalue == 0 || userinfo[user].inversttime ==0 || rewards >= inverstvalue){
            return 0;
        }
        return moneyTtoken(inverstvalue.sub(rewards));
    }
    function exit() public Onlyvalider returns(bool){
        
        uint256 principal = getPrincipal(msg.sender);
        if(principal > 0){
            uint256 fee ;
            
            if(userinfo[msg.sender].inversttime.add(feeconfig.interval)>=now){
                fee = feeconfig._fee2;
            }else{
                fee = feeconfig._fee1;
            }
            
            uint256 totalfee = principal.mul(fee).div(feeconfig._basis);
            super._transfer(address(this),msg.sender,principal.sub(totalfee));
        
        }
        resetuser(msg.sender);
        userinfo[msg.sender].inverstcount = 0;
        userinfo[msg.sender].inversttime = 0;
        userinfo[msg.sender].staticouttime = 0;
        userinfo[msg.sender].accumulate_communityprofis = 0;
    }
    function () payable external {
        buy();
    }
}
