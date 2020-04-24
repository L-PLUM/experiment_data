/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.18;

contract Currency {
    uint256 TOTAL = 0;
    string NAME = "";
    mapping(address => uint256) USERS;
    address OWNER;
    
    modifier onlyOwner {
        if (msg.sender != OWNER)
            revert(); 
        _;
    }
    
    constructor(string name, address owner) public {
        NAME = name;
        OWNER = owner;
    }
    
    function balanceOf(address tokenOwner) public constant returns(uint256) {
        uint256 balance = USERS[tokenOwner];
        return balance;
    }
    
    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 fromBalance = USERS[msg.sender];
        uint256 toBalance = USERS[_to];
        
        if (fromBalance < _amount) {
           revert();
        }
        
        USERS[msg.sender] = fromBalance - _amount;
        USERS[_to] = toBalance + _amount;
        
        return true;
    }
    
    function transferFor(address _from, address _to, uint256 _amount) public onlyOwner returns (bool) {
        uint256 fromBalance = USERS[_from];
        uint256 toBalance = USERS[_to];
        
        if (fromBalance < _amount) {
           revert();
        }
        
        USERS[_from] = fromBalance - _amount;
        USERS[_to] = toBalance + _amount;
        
        return true;
    }
    
    function load(address _to, uint256 _amount) public onlyOwner returns (bool) {
        uint256 toBalance = USERS[_to];
        USERS[_to] = toBalance + _amount;
        TOTAL = TOTAL + _amount;
        
        return true;
    }
    
    
    function withdraw(address _from, uint256 _amount) public onlyOwner returns (bool) {
        uint256 fromBalance = USERS[_from];
        if (fromBalance < _amount){
            revert();
        }
        
        USERS[_from] = fromBalance - _amount;
        TOTAL = TOTAL - _amount;
        return true;
    }
    
    function hasValue(address _user, uint256 _amount) public constant returns (bool) {
        if (USERS[_user] < _amount) {
           return false; 
        } else {
            return true;
        }
    }
    
    function getName() public constant returns (string) {
        return NAME;
    }
    
    function getTotal() public constant returns (uint256) {
        return TOTAL;
    }
}

contract PrivateTransaction {
    event Transfer(address indexed _from, address indexed _to, uint8 indexed _target, uint256 _targetAmount);
    event Load(address indexed _to, uint8 indexed _target, uint256 _targetAmount);
    event Withdraw(address indexed _from, uint8 indexed _source, uint256 _sourceAmount);
    event Exchange(address indexed _from, address indexed _to, uint8 _source, uint8 _target, uint256 _sourceAmount, uint256 _targetAmount);
    event NewCurrency(address indexed _address, string _name);
    event AddAdmin(address indexed _address);
    event Wallet(address indexed _address, uint8 indexed _currency, uint256 _balance);
    
    address[] CURRENCY_LIST;
    address owner;
    mapping(address => bool) admins;
    uint256 fundToAdmin = 0.1 ether;
    
    /*
    * modifier
    */
    modifier onlyOwner {
        if (msg.sender != owner)
            revert(); 
        _;
    }
    
    modifier onlyAdmin {
        if (admins[msg.sender] != true)
            revert();
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
        
        deployCurrency("eur");
        deployCurrency("usd");
        deployCurrency("gbp");
        deployCurrency("barc");
        deployCurrency("btc");
        deployCurrency("eth");
    }
    
    function isSupportCurrency(uint8 _currency) constant internal returns (bool) {
        if (_currency >= CURRENCY_LIST.length){
           return false; 
        }
        
        return true;
    }
    
    function load(address _to, uint8 _source, uint8 _target, uint256 _sourceAmount, uint256 _targetAmount) public onlyAdmin {
        if (!isSupportCurrency(_source)){
           revert();
        }
        
        if (!isSupportCurrency(_target)){
           revert();
        }
        
        //Load to user wallet
        Currency _selectedTarget = Currency(CURRENCY_LIST[_target]);
        _selectedTarget.load(_to, _targetAmount);
        
        //Load to master wallet
        Currency _selectedSource = Currency(CURRENCY_LIST[_source]);
        _selectedSource.load(owner, _sourceAmount);
        
        emit Load(_to, _target, _targetAmount);
        emit Load(owner, _source, _sourceAmount);
        
        uint256 toBalance = _selectedTarget.balanceOf(_to);
        uint256 ownerBalance = _selectedSource.balanceOf(owner);
        emit Wallet(_to, _target, toBalance);
        emit Wallet(owner, _source, ownerBalance);
    }
    
    function withdraw(address _from, uint8 _source, uint256 _sourceAmount) public onlyAdmin {
        if (!isSupportCurrency(_source)) {
           revert();
        }
        
        Currency _selectedSource = Currency(CURRENCY_LIST[_source]);
        if (!_selectedSource.hasValue(_from, _sourceAmount)) {
            revert();
        }
        
        _selectedSource.withdraw(_from, _sourceAmount);
        uint256 fromBalance = _selectedSource.balanceOf(_from);
        emit Withdraw(_from, _source, _sourceAmount);
        emit Wallet(_from, _source, fromBalance);
    }
    
    function transfer(address _from, address _to, uint8 _target, uint256 _targetAmount) public onlyAdmin {
        if (!isSupportCurrency(_target)) {
           revert();
        }
        
        Currency _selected = Currency(CURRENCY_LIST[_target]);
        if (!_selected.hasValue(_from, _targetAmount)) {
            revert();
        }
        
        _selected.transferFor(_from, _to, _targetAmount);
        uint256 fromBalance = _selected.balanceOf(_from);
        uint256 toBalance = _selected.balanceOf(_to);
        
        emit Transfer(_from, _to, _target, _targetAmount);
        emit Wallet(_from, _target, fromBalance);
        emit Wallet(_to, _target, toBalance);
    }
    
    function exchange(address _from, address _to, uint8 _source, uint8 _target, uint256 _sourceAmount, uint256 _targetAmount) public onlyAdmin {
        if (!isSupportCurrency(_source)) {
           revert();
        }
        
        if (!isSupportCurrency(_target)) {
           revert();
        }
        
        Currency _selectedSource = Currency(CURRENCY_LIST[_source]);
        Currency _selectedTarget = Currency(CURRENCY_LIST[_target]);
        
        if (!_selectedSource.hasValue(_from, _sourceAmount)) {
            revert();
        }
        
        if (!_selectedTarget.hasValue(owner, _targetAmount)) {
            revert();
        }
        
        _selectedSource.transferFor(_from, owner, _sourceAmount);
        _selectedTarget.transferFor(owner, _to, _targetAmount);
        
        uint256 fromBalance = _selectedSource.balanceOf(_from);
        uint256 toBalance = _selectedTarget.balanceOf(_to);
        uint256 sourceOwnerBalance = _selectedSource.balanceOf(owner);
        uint256 targetOwnerBalance = _selectedTarget.balanceOf(owner);
        
        emit Transfer(_from, owner, _source, _sourceAmount);
        emit Transfer(owner, _to, _target, _targetAmount);
        emit Exchange(_from, _to, _source, _target, _sourceAmount, _targetAmount);
        emit Wallet(_from, _source, fromBalance);
        emit Wallet(_to, _target, toBalance);
        emit Wallet(owner, _source, sourceOwnerBalance);
        emit Wallet(owner, _target, targetOwnerBalance);
    }
    
    function balanceOf(address tokenOwner, uint8 currency) public constant returns(uint256 balance) {
        Currency _selectedSource = Currency(CURRENCY_LIST[currency]);
        return _selectedSource.balanceOf(tokenOwner);
    }
    
    //Currency management
    function deployCurrency(string name) onlyOwner public returns (address)  {
        Currency newCurrrency = new Currency(name, this);
        CURRENCY_LIST.push(newCurrrency);
        
        emit NewCurrency(newCurrrency, name);
        return newCurrrency;
    }
    
    function getTotalCurrency() public constant returns (uint256) {
        return CURRENCY_LIST.length;
    }
    
    function getCurrencyCapital(uint8 _currency) public constant returns (address location, uint256 total) {
        if (!isSupportCurrency(_currency)) {
           return (this, 0);
        }
        
        Currency _selected = Currency(CURRENCY_LIST[_currency]);
        uint256 _total = _selected.getTotal();
        return (CURRENCY_LIST[_currency], _total);
    }
    
    //Permission
    function setAdmin(address user) public onlyOwner {
        admins[user] = true;
        if (!user.send(fundToAdmin)) {
            revert();
        }
    }
    
    function revokeAdmin(address user) public onlyOwner {
        admins[user] = false;
    }
    
    function isAdmin(address user) public constant returns(bool) {
        return admins[user];
    }
    
    function isOwner(address user) public constant returns(bool) {
        return owner == user;
    }
    
    function getOwner() public constant returns(address) {
        return (owner);
    }
    
    function() payable public {
        
    }
}
