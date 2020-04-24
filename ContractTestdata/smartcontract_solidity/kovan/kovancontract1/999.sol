/**
 *Submitted for verification at Etherscan.io on 2018-12-11
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

contract GroupReader {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-group-config-store-slots"));
    bytes32 internal constant GROUP_CONFIG_STORE_SLOT = 0x8ad7eb591937695082ebce99794911fcb3aa811ac112bbc562fd368751bb9ae2;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-master-method-group"));
    bytes32 internal constant MASTER_METHOD_GROUP = 0x59d3a36e9cdc22e8a3f7f0c855d500876dbd0c457339ce4f7850a44a514faf63;
    
    bytes32 internal constant INVALID_GROUP = bytes32(0);
    
    function _group(bytes4 methodID) internal view returns (bytes32 group) {
        bytes32 position = keccak256(abi.encodePacked(GROUP_CONFIG_STORE_SLOT, methodID));
        
        assembly {
            group := sload(position)
        }
        
        if (group == INVALID_GROUP) {
            group = MASTER_METHOD_GROUP;
        }
    }        
}

contract OperationStatus {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-opt-signed-store-slot"));
    bytes32 internal constant OPT_SIGNED_STORE_SLOT = 0xcd83bacdf6208f6e511a9d677ab21b0d39544f1f1653f9ada000921e6fde20ea;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-opt-done-store-slot"));
    bytes32 internal constant OPT_DONE_STORE_SLOT = 0x77b9a1d70f5b2c0de6929fc339e5bd0c4c369c39cd7a2c1bf9b34b9976bfe5dc;
    
    
    function _optStatusPosition(bytes32 slotType, bytes32 group, bytes32 optHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(slotType, group, optHash));
    }
    
    function _storeStatus(bytes32 position, bool status) public {
        assembly {
            sstore(position, status)
        }
    }

    function _optSigned(bytes32 group, bytes32 optHash) public {
        bytes32 position = keccak256(abi.encodePacked(OPT_SIGNED_STORE_SLOT, group, optHash));
        bool status = true;
        assembly {
            sstore(position, status)
        }
    }
    
    function _optDone(bytes32 group, bytes32 optHash) public {
        bytes32 position = keccak256(abi.encodePacked(OPT_DONE_STORE_SLOT, group, optHash));
        bool status = true;
        assembly {
            sstore(position, status)
        }
    }
   
    function _loadOptStatus(bytes32 position) public view returns (bool status) {
        assembly {
            status := sload(position)
        }
    }
    
    function _isSigned( bytes32 group, bytes32 optHash) public view returns (bool status) {
        bytes32 position = keccak256(abi.encodePacked(OPT_SIGNED_STORE_SLOT, group, optHash)); 
        assembly {
            status := sload(position)
        }
    }
    
    function _isDone(bytes32 group, bytes32 optHash) public view returns (bool status) {
        bytes32 position = keccak256(abi.encodePacked(OPT_DONE_STORE_SLOT, group, optHash)); 
        assembly {
            status := sload(position)
        }
    }
}

contract ShouldMultiSign is GroupReader, OperationStatus {
    
    modifier shouldMultiSign(){
        bytes32 optHash = keccak256(msg.data);
        bytes32 group = _group(msg.sig);
    
        bytes32 doneStatusPosition = _optStatusPosition(OPT_DONE_STORE_SLOT, group, optHash);
        require(_isSigned(group, optHash) && !_loadOptStatus(doneStatusPosition), "require invalid");
        _storeStatus(doneStatusPosition, true);
        
        _;
    }
}


contract PauseManage is ShouldMultiSign {
    
    event Pause(address indexed caller, string proposal);
    event Unpause(address indexed caller, string proposal);
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-pause-slot"));
    bytes32 private constant PAUSE_STORE_SLOT = 0xdece98116e7666b6794526da4b7929f09e1e394b89a6253e6761a4c75c1f4fa7;
    
    modifier whenNotPaused() {
        require(!isPaused());
        
        _;
    }
    
    function isPaused() public view returns (bool pause){
        bytes32 position = PAUSE_STORE_SLOT;
        
        assembly{
            pause := sload(position)
        }
    }

    function pause(string proposal) shouldMultiSign external {
        bool shouldPause = true;
        bytes32 position = PAUSE_STORE_SLOT;
        
        assembly {
            sstore(position, shouldPause)
        }
        
        emit Pause(msg.sender, proposal);
    }

    function unpause(string proposal) shouldMultiSign external {
        bool shouldPause = false;
        bytes32 position = PAUSE_STORE_SLOT;
        
        assembly {
            sstore(position, shouldPause)
        }
        
        emit Unpause(msg.sender, proposal);
    }
}

contract BlacklistManage is PauseManage {
    event Blacklisted(address indexed caller, address indexed _account, string proposal);
    event UnBlacklisted(address indexed caller, address indexed _account, string proposal);

    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-blacklist-store-base-slot"));
    bytes32 private constant BLACKLIST_STORE_SLOT = 0x5b6abbfe7a71d55abd3fdf55fc1da648e4733132035d11f860a19997e5e0c0eb;
    
    modifier notBlacklisted(address _account) {
        require(!isBlacklisted(_account));
        
        _;
    }
    
    modifier blacklisted(address _account) {
        require(isBlacklisted(_account));
        
        _;
    }

    function isBlacklisted(address _account) public view returns (bool flag) {
        bytes32 position = keccak256(abi.encodePacked(BLACKLIST_STORE_SLOT, _account));
        
        assembly {
            flag := sload(position)
        }
    }

    function blacklist(address _account, string proposal) whenNotPaused shouldMultiSign external {
        bool shouldBlacklisted = true;
        bytes32 position = keccak256(abi.encodePacked(BLACKLIST_STORE_SLOT, _account));
        
        assembly {
            sstore(position, shouldBlacklisted)
        }
        
        emit Blacklisted(msg.sender, _account, proposal);
    }

    function unBlacklist(address _account, string proposal) whenNotPaused shouldMultiSign external {
        bool shouldBlacklisted = false;
        bytes32 position = keccak256(abi.encodePacked(BLACKLIST_STORE_SLOT, _account));
        
        assembly {
            sstore(position, shouldBlacklisted)
        }
        
        emit UnBlacklisted(msg.sender, _account, proposal);
    }
}

contract GroupedErc20 is BlacklistManage {

    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-decimals-store-slot"));
    bytes32 private constant DECIMALS_STORE_SLOT = 0xfc69a356dabe3dd8de93e63e895a8748ea006043d3fdc5548d6d91426bb0156a;
    
    function decimals() public view returns (uint8 _decimals) {
        bytes32 position = DECIMALS_STORE_SLOT;
        assembly {
            _decimals := sload(position)
        }
    }
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-erc20-initialized-slot"));
    bytes32 private constant ERC20_INITIALIZED_STORE_SLOT = 0x5e3553a5a0fc02e3308900ea1af01f9b365a5be4b8d25cf3ade45643f150509d;
    
    function initErc20(string erc20Name, string erc20Symbol, uint8 erc20Decimals) external {
        bytes32 position = ERC20_INITIALIZED_STORE_SLOT;
        bool initialized;
        assembly{
            initialized := sload(position)
        }
        require(!initialized, "initialized");
        
        name = erc20Name;
        symbol = erc20Symbol;
        
        bytes32 decimalsPosition = DECIMALS_STORE_SLOT;
        initialized = true;
        assembly {
            sstore(decimalsPosition, erc20Decimals)
            sstore(position, initialized)
        }
    }
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-total-supply-store-slot"));
    bytes32 private constant TOTAL_SUPPLY_STORE_SLOT = 0x03858a3b2e112412c360f04e3099b677d9f0e3d2ab1555800512c6076d2d37fb;
    
    function totalSupply() public view returns (uint256 _wad) {
        bytes32 position = TOTAL_SUPPLY_STORE_SLOT;
        
        assembly {
            _wad := sload(position)
        }
    }
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-balances-store-base-slot"));
    bytes32 private constant BALANCES_STORE_BASE_SLOT = 0x00acc4fa06f2303e67238f9ee3b1038ccb7495ddd4b651478af485efd9de4259;
    
    function balanceOf(address _account) public view returns (uint256 _wad) {
        bytes32 position = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _account));
        
        assembly {
            _wad := sload(position)
        }
    }

    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-allowed-store-base-slot"));
    bytes32 private constant ALLOWED_STORE_BASE_SLOT = 0x2f87cc8e511d8590f01592ce748531ec45fa77d44cb6534010debc5bc8924c69;
    
    function allowance(address owner, address spender) public view returns (uint256 _wad) {
        bytes32 position = keccak256(abi.encodePacked(ALLOWED_STORE_BASE_SLOT, owner, spender));
        
        assembly {
            _wad := sload(position)
        }
    }
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-issued-amount-store-base-slot"));
    bytes32 private constant ISSUED_AMOUNT_STORE_BASE_SLOT = 0xef79d315a90f5b06c2a9a396e1dad19dfcb682ad90d8ec174871811ecc7b8da1;
    
    function issuedAmount(address _issuer) public view returns (uint256 _wad) {
        bytes32 position = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, _issuer));
        
        assembly {
            _wad := sload(position)
        }
    }
    
    event Burn(address indexed burner, uint256 amount);
    event Mint(address indexed issuer, address indexed to, uint256 amount, string proposal);
    
    event Erc20Fallback(address caller, bytes data);
    

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    event BlacklistedAddressWiped(address indexed issuer, address indexed addr, uint256 value);
    event BlacklistedIssuerWiped(address indexed redIssuer, address indexed badIssuer, uint256 balance, uint256 issuedAmount);

    // blacklist


    // ERC20
    modifier notIssuer(address _account) {
        require(issuedAmount(_account) == 0);
        _;
    }
    
    modifier onlyIssuer(address _account) {
        require(issuedAmount(_account) > 0);
        _;
    }

    function approve(address _spender, uint256 _value) 
        whenNotPaused 
        public 
    returns (bool) 
    {
        bytes32 position = keccak256(abi.encodePacked(ALLOWED_STORE_BASE_SLOT, msg.sender, _spender));
        
        assembly {
            sstore(position, _value)
        }

        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) 
        whenNotPaused 
        notIssuer(_from) 
        notBlacklisted(_from) 
        notBlacklisted(_to) 
        notBlacklisted(msg.sender)
        public 
    returns (bool) 
    {
        require(_to != address(0));
        
        bytes32 fromBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _from));
        bytes32 toBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _to));
        bytes32 fromAllowedPosition = keccak256(abi.encodePacked(ALLOWED_STORE_BASE_SLOT, _from, msg.sender));
        
        uint256 _balanceFrom; uint256 _allowed; uint256 _balanceTo;
        
        assembly {
            _balanceFrom := sload(fromBalancePosition)
            _balanceTo := sload(toBalancePosition)
            _allowed := sload(fromAllowedPosition)
        }
        
        require(_value <= _balanceFrom && _value <= _allowed);
        
        _balanceFrom = _balanceFrom.sub(_value);
        _balanceTo = _balanceTo.add(_value);
        _allowed = _allowed.sub(_value);
        
        assembly {
            sstore(fromBalancePosition, _balanceFrom)
            sstore(toBalancePosition, _balanceTo)
            sstore(fromAllowedPosition, _allowed)
        }

        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function transfer(address _to, uint256 _value) 
        whenNotPaused 
        notIssuer(msg.sender) 
        notBlacklisted(msg.sender) 
        notBlacklisted(_to) 
        public 
    returns (bool) 
    {
        require(_to != address(0));
        
        bytes32 fromBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, msg.sender));
        bytes32 toBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _to));
        
        uint256 _balanceFrom; uint256 _balanceTo;
        
        assembly {
            _balanceFrom := sload(fromBalancePosition)
            _balanceTo := sload(toBalancePosition)
        }
        
        require(_value <= _balanceFrom);
        
        _balanceFrom = _balanceFrom.sub(_value);
        _balanceTo = _balanceTo.add(_value);
        
        assembly {
            sstore(fromBalancePosition, _balanceFrom)
            sstore(toBalancePosition, _balanceTo)
        }

        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    // lawEnforcement
    function wipeBlacklistedAddress(address issuer, address _account) 
        whenNotPaused 
        blacklisted(_account)
        onlyIssuer(issuer)
        notBlacklisted(issuer) 
        shouldMultiSign 
        public 
    returns (bool)  
    {
        bytes32 fromBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _account));
        bytes32 toBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, issuer));
        uint256 _balanceFrom; uint256 _balanceTo;
        
        assembly {
            _balanceFrom := sload(fromBalancePosition)
            _balanceTo := sload(toBalancePosition)
        }
        
        _balanceTo = _balanceTo.add(_balanceFrom);
        
        assembly {
            sstore(fromBalancePosition, 0)
            sstore(toBalancePosition, _balanceTo)
        }
        
        emit BlacklistedAddressWiped(issuer, _account, _balanceFrom);
        
        emit Transfer(_account, issuer, _balanceFrom);
        
        return true;
    } 
    
    function doWipeBlacklistedIssuer (address badIssuer, address redIssuer) internal returns (bool) {
        bytes32 fromBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, badIssuer));
        bytes32 toBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, redIssuer));
        uint256 _balanceFrom; uint256 _balanceTo;
        
        bytes32 fromIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, badIssuer));
        bytes32 toIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, redIssuer));
        uint256 _issuedFrom; uint256 _issuedTo;
        
        assembly {
            _balanceFrom := sload(fromBalancePosition)
            _balanceTo := sload(toBalancePosition)
            _issuedFrom := sload(fromIssuedPosition)
            _issuedTo := sload(toIssuedPosition)
        }
        
        _balanceTo = _balanceTo.add(_balanceFrom);
        _issuedTo = _issuedTo.add(_issuedFrom);
        
        assembly{
            sstore(fromBalancePosition, 0)
            sstore(toBalancePosition, _balanceTo)
            sstore(fromIssuedPosition, 0)
            sstore(toIssuedPosition, _issuedTo)
        }

        emit BlacklistedIssuerWiped(redIssuer, badIssuer, _balanceFrom, _issuedFrom);
        
        emit Transfer(badIssuer, redIssuer, _balanceFrom);
        
        return true;        
    }
    
    function wipeBlacklistedIssuer(address badIssuer, address redIssuer) 
        whenNotPaused 
        onlyIssuer(redIssuer)
        onlyIssuer(badIssuer)
        blacklisted(badIssuer)
        notBlacklisted(redIssuer)
        shouldMultiSign 
        public 
    returns (bool)  
    {
        return doWipeBlacklistedIssuer(badIssuer, redIssuer);
    }

    function () payable public {
        emit Erc20Fallback(msg.sender, msg.data);
    }
    
    function doMint(address issuer, address _to, uint256 _amount, string proposal) internal returns (bool) {
        require(issuer != address(0) && _to != address(0) && _amount > 0);
        
        bytes32 totalSupplyPosition = TOTAL_SUPPLY_STORE_SLOT;
        bytes32 toBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, _to));
        bytes32 fromIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, issuer));
        uint256 totalSupply_; uint256 _balanceTo; uint256 _issuedFrom;
        
        assembly {
            totalSupply_ := sload(totalSupplyPosition)
            _balanceTo := sload(toBalancePosition)
            _issuedFrom := sload(fromIssuedPosition)
        }
        
        totalSupply_ = totalSupply_.add(_amount);
        _balanceTo = _balanceTo.add(_amount);
        _issuedFrom = _issuedFrom.add(_amount);
        
        assembly {
            sstore(totalSupplyPosition, totalSupply_)
            sstore(toBalancePosition, _balanceTo)
            sstore(fromIssuedPosition, _issuedFrom)
        }
        
        emit Mint(issuer, _to, _amount, proposal);
        
        emit Transfer(0x0, _to, _amount);
        
        return true;        
    }
    
    function mint(address issuer, address _to, uint256 _amount, string proposal) 
        whenNotPaused
        notBlacklisted(issuer) 
        notBlacklisted(_to) 
        shouldMultiSign
        public 
    returns (bool) 
    {
        return doMint(issuer, _to, _amount, proposal);
    }
    
    function issuerTransfer(address _from, address _to, uint256 _value) 
        whenNotPaused 
        onlyIssuer(_from) 
        onlyIssuer(_to) 
        notBlacklisted(_from) 
        notBlacklisted(_to) 
        shouldMultiSign 
        public 
    returns (bool) 
    {

        bytes32 fromIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, _from));
        bytes32 toIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, _to));
        uint256 _issuedFrom; uint256 _issuedTo;
        
        assembly {
            _issuedFrom := sload(fromIssuedPosition)
            _issuedTo := sload(toIssuedPosition)
        }
        
        require(_value <= _issuedFrom);
        
        _issuedFrom = _issuedFrom.sub(_value);
        _issuedTo = _issuedTo.add(_value);
        
        return true;
    }
    
    function burn(uint256 _amount) 
        whenNotPaused 
        onlyIssuer(msg.sender) 
        notBlacklisted(msg.sender) 
        public 
    returns (bool) 
    {
        
        bytes32 fromBalancePosition = keccak256(abi.encodePacked(BALANCES_STORE_BASE_SLOT, msg.sender));
        uint256 _balanceFrom;
        
        bytes32 fromIssuedPosition = keccak256(abi.encodePacked(ISSUED_AMOUNT_STORE_BASE_SLOT, msg.sender));
        uint256 _issuedFrom;
        
        bytes32 totalSupplyPosition = TOTAL_SUPPLY_STORE_SLOT;
        uint256 totalSupply_;
        
        assembly {
            _balanceFrom := sload(fromBalancePosition)
            _issuedFrom := sload(fromIssuedPosition)
            totalSupply_ := sload(totalSupplyPosition)
        }

        require(_amount > 0 && totalSupply_ >= _amount && _balanceFrom >= _amount && _issuedFrom >= _amount);

        totalSupply_ = totalSupply_.sub(_amount);
        _balanceFrom = _balanceFrom.sub(_amount);
        _issuedFrom = _issuedFrom.sub(_amount);
        
        assembly {
            sstore(totalSupplyPosition, totalSupply_)
            sstore(fromBalancePosition, _balanceFrom)
            sstore(fromIssuedPosition, _issuedFrom)
        }
        
        emit Burn(msg.sender, _amount);
        
        emit Transfer(msg.sender, address(0), _amount);
        
        return true;
    } 
}
