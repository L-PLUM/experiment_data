/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.3;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

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

contract TokenBase is ERC20 {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) allowed;

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract WR2Token is TokenBase {
    
    WiredToken public wiredToken;

    string public constant name = "WiredToken2";
    string public constant symbol = "WR2";
    uint8 public constant decimals = 18;
    
    constructor() public {
        wiredToken = WiredToken(msg.sender);
    }

    function balanceOf(address _holder) public view returns (uint256) {
        return wiredToken.lookBalanceWR2(_holder);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        wiredToken.transferWR2(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);

        wiredToken.transferWR2(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return wiredToken.totalWR2();
    }
    
    function mint(address _holder, uint256 _value) external {
        require(msg.sender == address(wiredToken));
        wiredToken.mintWR2(_holder, _value);
        emit Transfer(address(0), _holder, _value);
    }
}

contract WiredToken is WhitelistedRole, TokenBase {
    using SafeMath for uint256;
    
    string public constant name = "WiredToken";
    string public constant symbol = "WRD";
    uint8 public constant decimals = 3;
    
    uint32 constant month = 30 days;
    uint8 public constant divBonus = 20;
    uint256 public initialSupply = 10000;

    WR2Token public wr2Token;
    address public founder = 0xF5772d356ce160bAEa58A15c719be6e97975C6D5;
    uint256 public supply;
    uint256 public totalWR2;

    bool public listing = false;
    uint256 public launchTime = 9999999999999999999999;

    mapping(address => uint256) lastUpdate;
//    mapping(address => uint256) public startTime;
    mapping(address => uint256) WRDBalances;
    mapping(address => uint256) WRDMonthHoldBalances;
    mapping(address => uint256) WR2Balances;
    mapping(address => uint256) WR2MonthHoldBalances;

    mapping(address => uint256) public presaleTokens;

    uint256 public totalAirdropTokens;
    uint256 public totalPresaleTokens;

    constructor() public {
        wr2Token = new WR2Token();

        mint(address(this), initialSupply.mul(6).div(10));
        WRDMonthHoldBalances[address(this)] = initialSupply.mul(6).div(10);
        
        mint(founder, initialSupply.mul(4).div(10));
        WRDMonthHoldBalances[founder] = initialSupply.mul(4).div(10);
        
        _addWhitelisted(founder);
        _addWhitelisted(address(this));
    }
    
    function totalSupply() public view returns (uint) {
        return supply;
    }

    function balanceOf(address _holder) public view returns (uint256) {
        uint[2] memory arr = lookBonus(_holder);
        return WRDBalances[_holder].add(arr[0]).sub(lockUpAmount(_holder));
    }
    
    function lookBalanceWR2(address _holder) public view returns (uint256) {
        uint[2] memory arr = lookBonus(_holder);
        return WR2Balances[_holder].add(arr[1]);
    }
    
    function lockUpAmount(address _holder) internal view returns (uint) {
        uint percentage = 100;
        if (now >= launchTime.add(uint(12).mul(month))) {
            uint pastMonths = (now.sub(launchTime.add(uint(12).mul(month)))).div(month);
            percentage = 0;
            if (pastMonths < 50) {
                percentage = uint(100).sub(uint(2).mul(pastMonths));
            }
        }
        return (presaleTokens[_holder]).mul(percentage).div(100);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        transferWRD(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);

        transferWRD(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferWRD(address _from, address _to, uint256 _value) internal {
        if (listing) {
            updateBonus(_from);
            updateBonus(_to);
        } else {
            WRDMonthHoldBalances[_to] = WRDMonthHoldBalances[_to].add(_value);
        }
        
        require(WRDBalances[_from].sub(lockUpAmount(_from)) >= _value);

        WRDBalances[_from] = WRDBalances[_from].sub(_value);
        WRDBalances[_to] = WRDBalances[_to].add(_value);
        
        WRDMonthHoldBalances[_from] = min(
            WRDMonthHoldBalances[_from],
            WRDBalances[_from]
        );
    }

    function transferWR2(address _from, address _to, uint256 _value) external {
        require(msg.sender == address(wr2Token));
        
        if (listing) {
            updateBonus(_from);
            updateBonus(_to);
        } else {
            WR2MonthHoldBalances[_to] = WR2MonthHoldBalances[_to].add(_value);
        }
        
        require(WR2Balances[_from] >= _value);

        WR2Balances[_from] = WR2Balances[_from].sub(_value);
        WR2Balances[_to] = WR2Balances[_to].add(_value);
        
        
        WR2MonthHoldBalances[_from] = min(
            WR2MonthHoldBalances[_from],
            WR2Balances[_from]
        );
    }
    
    function mint(address _holder, uint _value) internal {
        WRDBalances[_holder] = WRDBalances[_holder].add(_value);
        supply = supply.add(_value);
        emit Transfer(address(0), _holder, _value);
    }
    
    function mintWR2(address _holder, uint _value) external {
        require(msg.sender == address(wr2Token));
        WR2Balances[_holder] = WR2Balances[_holder].add(_value);
        totalWR2 = totalWR2.add(_value);
    }
    
    function min(uint a, uint b) internal pure returns (uint) {
        if(a > b) return b;
        return a;
    }

/*lastUpdateはlistingから何ヶ月目にupdateしたかを表す
listing以前から保有していた場合:mapは初期値0のため問題ない
listing後に手に入れた場合:mapは初期値0のためlisting時から保有していたことになるが
monthHoldBalance,balanceともに初期値0なのでbonusは0
よって初回にlastUpdateのみが正しく更新される
一度balance0にした場合も同じ*/
    function updateBonus(address _holder) internal {
        uint256 pastMonths = now.sub((lastUpdate[_holder].mul(month)).add(launchTime)).div(month);
        if (pastMonths > 0) {
            uint256[2] memory arr = lookBonus(_holder);

            lastUpdate[_holder] = lastUpdate[_holder].add(pastMonths);
            WRDMonthHoldBalances[_holder] = WRDBalances[_holder].add(arr[0]);
            WR2MonthHoldBalances[_holder] = WR2Balances[_holder].add(arr[1]);
            
            if(arr[0] > 0) mint(_holder, arr[0]);
            if(arr[1] > 0) wr2Token.mint(_holder, arr[1]);
        }
    }

    function lookBonus(address _holder) internal view returns (uint256[2] memory) {
        uint[2] memory arr;
        arr[0] = 0;
        arr[1] = 0;
        if (isBonus(_holder) && listing){
            uint newWRDBonus;
            uint256 pastMonths = now.sub((lastUpdate[_holder].mul(month)).add(launchTime)).div(month);
            
            for (uint i = 0; i < pastMonths; i++) {
                if (i == 0){
                    arr[0] = (WR2MonthHoldBalances[_holder]).div(divBonus);
                    arr[1] = (WRDMonthHoldBalances[_holder]).div(divBonus);
                } else {
                    newWRDBonus = arr[0].add((WR2Balances[_holder].add(arr[1])).div(divBonus));
                    arr[1] = arr[1].add((WRDBalances[_holder].add(arr[0])).div(divBonus));
                    arr[0] = newWRDBonus;
                }
            }
        }
        return arr;
    }
    
    function isBonus(address _holder) internal view returns(bool) {
        return !isWhitelistAdmin(_holder) && !isWhitelisted(_holder);
    }

    function startListing() public onlyWhitelistAdmin {
        require(!listing);
        launchTime = now;
        listing = true;
    }

    function addAirdropTokens(address[] calldata sender, uint256[] calldata amount) external onlyWhitelistAdmin {
        require(sender.length > 0 && sender.length == amount.length);

        for (uint i = 0; i < sender.length; i++) {
            transferWRD(address(this), sender[i], amount[i]);
            //send as presaletoken
            presaleTokens[sender[i]] = presaleTokens[sender[i]].add(amount[i]);
            totalAirdropTokens = totalAirdropTokens.add(amount[i]);
            emit Transfer(address(this), sender[i], amount[i]);
        }
        require(totalAirdropTokens <= totalSupply().mul(5).div(100));
    }

    function addPresaleTokens(address[] calldata sender, uint256[] calldata amount) external onlyWhitelistAdmin {
        require(sender.length > 0 && sender.length == amount.length);

        for (uint i = 0; i < sender.length; i++) {
            transferWRD(address(this), sender[i], amount[i]);
            presaleTokens[sender[i]] = presaleTokens[sender[i]].add(amount[i]);
            totalPresaleTokens = totalPresaleTokens.add(amount[i]);
            emit Transfer(address(this), sender[i], amount[i]);
        }
        require(totalPresaleTokens <= totalSupply().mul(15).div(100));
    }
    
    function addSpecialsaleTokens(address to, uint256 amount) external onlyWhitelisted {
            transferWRD(msg.sender, to, amount);
            presaleTokens[to] = presaleTokens[to].add(amount);
            emit Transfer(msg.sender, to, amount);
    }
}
