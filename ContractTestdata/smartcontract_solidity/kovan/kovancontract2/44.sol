/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.4.23;

contract DEPEvents 
{
    event onDeposit // deposit money
    (
        address pAddr,
        uint256 eth, 
        uint256 ts
    );
    event onReDep   // re-deposit
    (
        address pAddr,
        uint256 eth, 
        uint256 ts
    );
    event onWithdraw  // withdraw
    (
        address pAddr,
        uint256 eth, 
        uint256 ts
    );
}

contract Deposit is DEPEvents{
    using SafeMath for *;

    address internal ga_CEO;
    address internal ga_CFO = address(0x22f7507301ea5816829FF38933544492A33b98E5);
    
    uint256 public gu_LastPID;        // 有多少玩家 
    mapping (address => uint256) internal gd_Addr2PID;
    mapping (uint256 => DEPdatasets.Player) public gd_Player;

    mapping (uint256 => uint256[5]) internal gd_dayDisRate ; // gd_dayDisRate[day_cnt][c_level]
    mapping (uint256 => uint256) internal gd_VLvlFactor ;
    mapping (uint256 => uint256[2]) internal gd_VLvlAffFac ;

    constructor()
        public
    {
        ga_CEO = msg.sender;
        gd_dayDisRate[1] = [200000000000, 250000000000, 300000000000, 350000000000, 400000000000] ;
        gd_dayDisRate[2] = [399600000000, 499375000000, 599100000000, 698775000000, 798400000000] ;
        gd_dayDisRate[3] = [598800800000, 748126562500, 897302700000, 1046329287500, 1195206400000] ;
        gd_dayDisRate[4] = [797603198400, 996256246094, 1194610791900, 1392667134990, 1590425574400] ;
        gd_dayDisRate[5] = [996007992003, 1243765605480, 1491026959520, 1737792800020, 1984063872100] ;
        gd_dayDisRate[6] = [1194015976020, 1490656191460, 1786553878650, 2081710525220, 2376127616610] ;
        gd_dayDisRate[7] = [1391627944070, 1736929550990, 2081194217010, 2424424538380, 2766623106150] ;
        gd_dayDisRate[8] = [1588844688180, 1982587227110, 2374950634360, 2765939052500, 3155556613720] ;
        gd_dayDisRate[9] = [1785666998800, 2227630759040, 2667825782460, 3106258265810, 3542934387270] ;
        gd_dayDisRate[10] =[1982095664810, 2472061682140, 2959822305110, 3445386361880, 3928762649720] ;
        

        gd_VLvlFactor[0] = 10;
        gd_VLvlFactor[1] = 25;
        gd_VLvlFactor[2] = 30;
        gd_VLvlFactor[3] = 40;
        gd_VLvlFactor[4] = 50;

        gd_VLvlAffFac[0] = [7, 3] ;
        gd_VLvlAffFac[1] = [7, 3] ;
        gd_VLvlAffFac[2] = [10, 5] ;
        gd_VLvlAffFac[3] = [13, 7] ;
        gd_VLvlAffFac[4] = [20, 10] ;
 	}

    modifier IsCEO()
    {
        require(ga_CEO == msg.sender, "only ga_CEO can modify ga_CEO");
        _;
    } 

    function ModCEO(address newCEO) 
        IsCEO()
        external
    {
        require(address(0) != newCEO, "CEO Can not be 0");
        ga_CEO = newCEO;
    }

    function ModCFO(address newCFO) 
        IsCEO()
        external
    {
        require(address(0) != newCFO, "CEO Can not be 0");
        ga_CFO = newCFO;
    }

    function Kill() IsCEO() public
    {
        selfdestruct(ga_CFO);
    }

    function GetPIDXAddr(address addr, address affAddr)
        private
        returns (uint256)
    {
        uint256 pID = gd_Addr2PID[addr];
        if ( pID == 0 && gd_Player[pID].addr != addr) // 不存在，创建一个
        {
            // gu_LastPID++;
            gd_Addr2PID[addr] = gu_LastPID ;
            gd_Player[gu_LastPID].addr = addr ;
            gd_Player[gu_LastPID].lday = now/60 ;
            if(addr != affAddr)
            {
                gd_Player[gu_LastPID].aid = gd_Addr2PID[affAddr] ;
            }
            gu_LastPID++ ;
            return (gd_Addr2PID[addr]) ;
        } else {
            return (pID);
        }
    }

    function SetCLevel(uint256 pID) internal {
        if(gd_Player[pID].c_level == 4) {
            return ;
        }
        if(gd_Player[pID].dep_eth >= 4500000000000000000000 || gd_Player[pID].aff_eth >= 9000000000000000000000){
            gd_Player[pID].c_level = 4;
        } else if(gd_Player[pID].dep_eth >= 1500000000000000000000 || gd_Player[pID].aff_eth >= 4500000000000000000000){
            gd_Player[pID].c_level = 3;
        } else if(gd_Player[pID].dep_eth >= 500000000000000000000 || gd_Player[pID].aff_eth >= 1500000000000000000000){
            gd_Player[pID].c_level = 2;
        } else if(gd_Player[pID].dep_eth >= 150000000000000000000 || gd_Player[pID].aff_eth >= 450000000000000000000){
            gd_Player[pID].c_level = 1;
        }
    }

    function SetVLevel(uint256 pID) internal {
        if(gd_Player[pID].v_level == 4) {
            return ;
        }
        if(gd_Player[pID].dep_eth >= 70000000000000000000) {
            gd_Player[pID].v_level = 4;
        }else if(gd_Player[pID].dep_eth >= 40000000000000000000) {
            gd_Player[pID].v_level = 3;
        }else if(gd_Player[pID].dep_eth >= 20000000000000000000) {
            gd_Player[pID].v_level = 2;
        }else if(gd_Player[pID].dep_eth >= 1000000000000000000) {
            gd_Player[pID].v_level = 1;
        }
    }

    function AddAffOnBuy(uint256 pID, uint256 level, uint256 E) internal{
        if(level > 1) {
            return ;
        }
        UpdateVault(pID) ; 
        uint256 addE = E.mul(gd_VLvlAffFac[gd_Player[pID].v_level][level])/100;
        gd_Player[pID].win = gd_Player[pID].win.add(addE) ;
        gd_Player[pID].aff_eth = gd_Player[pID].aff_eth.add(E) ;
        SetCLevel(pID) ;
        if(pID != gd_Player[pID].aid) {
            AddAffOnBuy(gd_Player[pID].aid, level+1, E) ;
        }
    }

    function CalcWinXDay(uint256 dis_aff_eth, uint256 cLvl, uint256 n) view public returns(uint256)
    {
        if(n == 0) {
            return 0 ;
        }
        uint256 dis_eth = 0;
        uint256 cur_dis_eth = 0;
        while(n > 10) {
            cur_dis_eth = dis_aff_eth.mul(gd_dayDisRate[10][cLvl])/100000000000000 ;
            dis_aff_eth = dis_aff_eth.sub(cur_dis_eth);
            dis_eth = dis_eth.add(cur_dis_eth);
            n -= 10;
        }
        cur_dis_eth = dis_aff_eth.mul(gd_dayDisRate[n][cLvl])/100000000000000 ;
        dis_aff_eth = dis_aff_eth.sub(cur_dis_eth);
        dis_eth = dis_eth.add(cur_dis_eth);
        
        return dis_eth ;
    }

    function UpdateVault(uint256 pID) internal {
        uint256 cur_day = now/60;
        if(cur_day > gd_Player[pID].lday) 
        {
            uint256 day_cnt = cur_day.sub(gd_Player[pID].lday);
            uint256 total_eth = gd_Player[pID].dep_eth.mul(gd_VLvlFactor[gd_Player[pID].v_level])/10;
            if(gd_Player[pID].dis_dep_eth < total_eth) {
                uint256 win_dep = CalcWinXDay(total_eth-gd_Player[pID].dis_dep_eth, gd_Player[pID].c_level, day_cnt);
                gd_Player[pID].dis_dep_eth = gd_Player[pID].dis_dep_eth.add(win_dep);
                gd_Player[pID].win = gd_Player[pID].win.add(win_dep);
                
            }
            if(gd_Player[pID].dis_aff_eth < gd_Player[pID].aff_eth) {
                uint256 win_aff = CalcWinXDay(gd_Player[pID].aff_eth-gd_Player[pID].dis_aff_eth, gd_Player[pID].c_level, day_cnt) ;
                gd_Player[pID].dis_aff_eth = gd_Player[pID].dis_aff_eth.add(win_aff);
                gd_Player[pID].win = gd_Player[pID].win.add(win_aff);
            }
            gd_Player[pID].lday = cur_day ;
        }
    }
    
    function CalcVault(uint256 pID) view internal returns(uint256) {
        uint256 cur_day = now/60;
        uint256 win = 0;
        if(cur_day > gd_Player[pID].lday) 
        {
            uint256 day_cnt = cur_day.sub(gd_Player[pID].lday);
            uint256 total_eth = gd_Player[pID].dep_eth.mul(gd_VLvlFactor[gd_Player[pID].v_level])/10;
            if(gd_Player[pID].dis_dep_eth < total_eth) {
                win = CalcWinXDay(total_eth-gd_Player[pID].dis_dep_eth, gd_Player[pID].c_level, day_cnt);
                
            }
            if(gd_Player[pID].dis_aff_eth < gd_Player[pID].aff_eth) {
                win = win.add(CalcWinXDay(gd_Player[pID].aff_eth-gd_Player[pID].dis_aff_eth, gd_Player[pID].c_level, day_cnt)) ;
            }
        }
        return win;
    }
    
    function Dep(address affAddr) external payable
    {
        require(msg.value > 0, "ETH ERROR!") ;

        uint256 pID = GetPIDXAddr(msg.sender, affAddr) ;
        UpdateVault(pID) ;

        ga_CFO.transfer(msg.value/100) ;
        gd_Player[pID].dep_eth = gd_Player[pID].dep_eth.add(msg.value);
        
        SetVLevel(pID) ;
        SetCLevel(pID) ;
        
        AddAffOnBuy(gd_Player[pID].aid, 0, msg.value) ;
        emit DEPEvents.onDeposit(msg.sender, msg.value, now) ;
    }

    function ReDep(uint256 amount) external payable
    {
        uint256 pID = GetPIDXAddr(msg.sender, address(0)) ;
        UpdateVault(pID) ;
        require(gd_Player[pID].win >= amount, "ETH ERROR!");

        ga_CFO.transfer(amount/100) ;
        gd_Player[pID].win = gd_Player[pID].win.sub(amount) ;
        
        gd_Player[pID].dep_eth = gd_Player[pID].dep_eth.add(amount);
        SetVLevel(pID) ;
        SetCLevel(pID) ;

        AddAffOnBuy(gd_Player[pID].aid, 1, amount) ;
        emit DEPEvents.onReDep(msg.sender, amount, now) ;
    }

    function Withdraw() external
    {
        uint256 pID = GetPIDXAddr(msg.sender, address(0)) ;
        UpdateVault(pID);
        if (gd_Player[pID].win > 0)
        {
            uint256 fee= gd_Player[pID].win.mul(3)/100;
            ga_CFO.transfer(fee) ;
            msg.sender.transfer(gd_Player[pID].win.sub(fee));
            emit DEPEvents.onWithdraw (msg.sender, gd_Player[pID].win, now);
            gd_Player[pID].win = 0;
        }
    }    

    function GetPlayerInfoXAddr(address addr)
        external 
        view 
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        if (addr == address(0))
        {
            addr == msg.sender;
        }
        uint256 pID = gd_Addr2PID[addr];
        return
        (
            gd_Player[pID].v_level,
            gd_Player[pID].c_level,
            gd_Player[pID].dep_eth,
            gd_Player[pID].dis_dep_eth,
            gd_Player[pID].aff_eth,
            gd_Player[pID].dis_aff_eth,
            gd_Player[pID].win.add(CalcVault(pID))
        );
    }
}

library DEPdatasets {
    struct Player {
        address addr;
        uint256 v_level ;  // deposit multiple factor   
        uint256 c_level ;  // distribute factor
        uint256 dep_eth;   // total deposit eth 
        uint256 dis_dep_eth;   // distribute eth from deposit
        uint256 aff_eth;   // total aff eth
        uint256 dis_aff_eth;  // distribut eth from aff
        uint256 win;  // money can be withdraw;
        uint256 aid; //  the one who recommend you;
        uint256 lday; // last day get distribute; 
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) 
        {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Mul Failed");
        return c;
    }
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "Sub Failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "Add Failed");
        return c;
    }

    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    function pow(uint256 x, uint256 n) internal pure returns(uint256) 
    {
        uint256 r = x;
        for(uint256 i = 1 ; i < n; i ++) {
            r = mul(r, x) ;
        }
        return r ;
    }
}
