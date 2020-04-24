/**
 *Submitted for verification at Etherscan.io on 2019-01-26
*/

pragma solidity ^0.5.2;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
    }
  }
}


contract FIH {
    using SafeMath for uint256;

    string ret = "return";
    uint256 fee = 0.001 ether;
    uint256 bonusCodeNonce;

    uint256 stake = 0.01 ether;

    uint256 currentPeriod;

    struct BonusCode{
        uint8 prefix;
        uint256 code;
        uint256 nums;
        address addr;
        uint256 amount;
    }

    address owner;
    //user balance
    mapping(address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    // _period => result => address winnerInfo
    mapping(uint256 => BonusCode) winnerInfoPerPeriod;

    mapping(uint256 => mapping(uint8 => uint256)) sideTotalAmount;
    // bonus pool;
    mapping(uint256 => uint256) bonusPoolPerPeriod;
    //_period => address => amount
    mapping(uint256 => mapping(address => uint256)) invitedBonusPerPeriod;
    // invite relation
    mapping(address => address) invitedRelations;
    // team bonus per _period
    mapping(uint256 => uint256) teamBonusPerPeriod;
    // game bonus per _period
    mapping(uint256 => uint256) gameBonusPerPeriod;
    //period => user => orders => bonusCodes
    mapping(uint256 => mapping(address => mapping(uint256 => BonusCode))) userOrderBonusCodes;
    mapping(uint256 => mapping(address =>uint256[])) userOrders;

    // period => prefix => BonusCode
    mapping(uint256 => mapping(uint8 => BonusCode[])) sideOrderBonusCodes;

    // period => code => BonusCode
    mapping(uint256 => mapping(uint256 => BonusCode)) revealBonusCodes;
    // period => code
    mapping(uint256 => uint256[]) bcodes;

    // admin
    mapping(address => bool) isAdmin;

    event Bet(uint256 _orderId);
    event Deposit(address _from, address _to, uint256 _amount);
    event Reveal();
    event Withdrawal(address _to, uint256 _amount);

    constructor () public {
        owner = msg.sender;
        isAdmin[owner] = true;
        currentPeriod = 1;
        bonusCodeNonce = 0;
        teamBonusPerPeriod[currentPeriod] = 0;
        gameBonusPerPeriod[currentPeriod] = 0;
        bonusPoolPerPeriod[currentPeriod] = 0;
    }

    modifier isContractOwner() {
        require(owner == msg.sender);
        _;
    }

    // privileage
    modifier onlyAdmins() {
        require(isAdmin[msg.sender] == true);
        _;
    }

    function addAdmin(address _addr) isContractOwner public {
        isAdmin[_addr] = true;
    }

    function removeAdmin(address _addr) isContractOwner public {
        isAdmin[_addr] = false;
    }

    function transferOwner(address _addr) isContractOwner public {
        owner = _addr;
    }

    function approve(address _spender, uint256 _value) internal returns (bool success) {
		require(_value > 0);
        allowance[_spender][msg.sender] = _value;
        allowance[_spender][_spender] = balanceOf[_spender];
        return true;
    }

    /**
     *   _to == 0x0  allowance self
     *  _to != null need allowance
     *
     * */
    function deposit(address _to) payable public returns(bool) {
        require(msg.value > 0);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], msg.value);
        assert(approve(_to, balanceOf[_to]));
        emit Deposit(msg.sender, _to, msg.value);
        return true;
    }

    function bet(address _from, address _invitedAddr, uint256 _amount, uint8 _fType) public {
        //validate
        require(_amount >= stake, "bet amount shoud > stake");
        require(0 < _amount  && _amount <= balanceOf[_from], "_amount is out of bound");
        require(allowance[_from][msg.sender] >= _amount);
        if(_invitedAddr != address(0x0)) {
             require(_from != _invitedAddr, "bet _from is not equals _invitedAddr");
        }

        //handler balance and allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].safeSub(_amount);
        balanceOf[_from] = balanceOf[_from].safeSub(_amount);

        sideTotalAmount[currentPeriod][_fType] = sideTotalAmount[currentPeriod][_fType].safeAdd(_amount);
        /*
         * split amount
         */
         //1. bonusPool
         uint256 currentAmount = _amount;
         uint256 gameBonusPercentVal = _amount.safeMul(20).safeDiv(100);
         uint256 teamBonusPercentVal = _amount.safeMul(15).safeDiv(100);
         uint256 bonusPoolPercentVal = _amount.safeMul(50).safeDiv(100);

         gameBonusPerPeriod[currentPeriod] = gameBonusPerPeriod[currentPeriod].safeAdd(gameBonusPercentVal);
         currentAmount = currentAmount.safeSub(gameBonusPercentVal);

         teamBonusPerPeriod[currentPeriod] = teamBonusPerPeriod[currentPeriod].safeAdd(teamBonusPercentVal);
         currentAmount = currentAmount.safeSub(teamBonusPercentVal);

         bonusPoolPerPeriod[currentPeriod] = bonusPoolPerPeriod[currentPeriod].safeAdd(bonusPoolPercentVal);
         currentAmount = currentAmount.safeSub(bonusPoolPercentVal);

         //invited bonus
         uint256 bonusLevelOne = _amount.safeMul(10).safeDiv(100);
         uint256 bonusLevelTwo = _amount.safeMul(5).safeDiv(100);

         if(_invitedAddr != address(0x0)) {
             invitedRelations[_from] = _invitedAddr;
         }
         if (invitedRelations[_from] != address(0x0)) {
             address fa = invitedRelations[_from];
             invitedBonusPerPeriod[currentPeriod][fa] = invitedBonusPerPeriod[currentPeriod][fa].safeAdd(bonusLevelOne);
             currentAmount = currentAmount.safeSub(bonusLevelOne);
             address gfa = invitedRelations[fa];
             if (gfa != address(0x0)) {

                invitedBonusPerPeriod[currentPeriod][gfa] = invitedBonusPerPeriod[currentPeriod][gfa].safeAdd(bonusLevelTwo);
                currentAmount = currentAmount.safeSub(bonusLevelTwo);
             }
         }
         assert(currentAmount >= 0);

         bonusPoolPerPeriod[currentPeriod] = bonusPoolPerPeriod[currentPeriod].safeAdd(currentAmount);

        //generate order and bonusCodes
        uint256 orderId = now;
        uint256 n = _amount.safeDiv(stake);
        userOrderBonusCodes[currentPeriod][_from][orderId] = BonusCode({
            prefix : _fType,
            code : bonusCodeNonce,
            nums : n,
            addr : _from,
            amount : _amount
        });
        bonusCodeNonce = bonusCodeNonce.safeAdd(_amount.safeDiv(stake));
        userOrders[currentPeriod][_from].push(orderId);

       emit Bet(orderId);
    }

    function reveal(string memory _seed) public onlyAdmins {
        //
       //random winner index
        uint256 winner = uint256(keccak256(abi.encodePacked(_seed, msg.sender, now))) % bonusCodeNonce;
        uint256 lt = 0;
        uint256 rt = bcodes[currentPeriod].length - 1;
        uint256 pos = lt;
        while (lt <= rt) {
            uint256 mid = lt + (rt - lt) / 2;
            if (bcodes[currentPeriod][mid] <= winner) {
                pos = mid;
                lt = mid + 1;
            } else {
                rt = mid - 1;
            }
        }

        BonusCode memory winnerBcode = revealBonusCodes[currentPeriod][pos];

        BonusCode[] memory sideBcodes = sideOrderBonusCodes[currentPeriod][winnerBcode.prefix];
        // iterate sideBcodes;
        for(uint256 i = 0; i < sideBcodes.length; i++) {
            if(sideBcodes[i].addr == winnerBcode.addr) {
                balanceOf[winnerBcode.addr] = balanceOf[winnerBcode.addr].safeAdd(bonusPoolPerPeriod[currentPeriod].safeMul(50).safeDiv(100));
                allowance[winnerBcode.addr][msg.sender] = allowance[winnerBcode.addr][msg.sender].safeAdd(bonusPoolPerPeriod[currentPeriod].safeMul(50).safeDiv(100));
            }else {

                uint256 bonusAmount = bonusPoolPerPeriod[currentPeriod].safeMul(50).safeDiv(100).safeMul(
                        sideBcodes[i].amount).safeDiv(sideTotalAmount[currentPeriod][sideBcodes[i].prefix]
                        );
                balanceOf[sideBcodes[i].addr] = balanceOf[sideBcodes[i].addr].safeAdd(bonusAmount);
                allowance[sideBcodes[i].addr][msg.sender] = allowance[sideBcodes[i].addr][msg.sender].safeAdd(bonusAmount);
            }
        }
        winnerInfoPerPeriod[currentPeriod] = winnerBcode;

        currentPeriod++;

        emit Reveal();
    }

    function withdrawal(address _from, address payable _to, uint256 amount) public {
        if (msg.sender == _from || allowance[_from][msg.sender] >= amount) {
		    allowance[_from][msg.sender] -= amount;
	    }
	    balanceOf[_from] -= amount;
	  	_to.transfer(amount);
	    emit Withdrawal(_to, amount);
    }

    //query
    function getBalance(address _addr) public view returns(uint256) {
        return balanceOf[_addr];
    }

    function getBonusPool() public view returns(uint256) {
        return gameBonusPerPeriod[currentPeriod];
    }

    function getBonusCode(int _period, address _from) public view returns(string memory) {

    }

    function getBonusRes() public view {

    }

    function getBonusInvited(address _from, int _period) public view returns(int) {

    }

    function getBonusInvited(address _from) public view returns(int) {

    }


}
