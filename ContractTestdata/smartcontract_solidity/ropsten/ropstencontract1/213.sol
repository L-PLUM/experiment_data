/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.2;


/**
* @title ERC223ReceivingContract
* @dev ERC223 Receiving Contract interface
*/
contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes memory _data)public;
}


/**
* @title ERC223Interface
* @dev ERC223 Contract Interface
*/
contract ERC223Interface {
    function balanceOf(address who)public view returns (uint);
    function transfer(address to, uint value)public returns (bool success);
    function transfer(address to, uint value, bytes memory data)public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}


/**
* @title UpgradedStandardToken
* @dev Contract Upgraded Interface
*/
contract UpgradedStandardToken{
    function transferByHolder(address to, uint value)public returns (bool success);
}


/**
* @title Authenticity
* @dev Address Authenticity Interface
*/
contract Authenticity{
    function getAddress(address contratAddress) public view returns (bool);
}


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library safeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal{
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}


/**
 * @title BlackList
 * @dev The BlackList contract has an BlackList address, and provides basic authorization control
 * functions, this simplifies the implementation of "user address authorization".
*/
contract BlackList is Ownable{
    
    mapping (address => bool) internal isBlackListed;
    mapping (address => uint) public holderId;
    address[] holders;
    
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
    
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }
    
    /**
    *@Params _evilUser address of user the owner want to add in BlackList 
    */
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        removeHolder(_evilUser);
        emit AddedBlackList(_evilUser);
    }

    /**
    *@Params _clearedUser address of user the owner want to remove BlackList 
    */
    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
    
    function removeHolder(address holderAddress) onlyOwner internal {
        for (uint i = holderId[holderAddress];i<holders.length-1; i++){
            holders[i] = holders[i+1];
        }
        delete holders[holders.length-1];
        holders.length--;
    }
}

/**
 * @title ERC223
 * @dev 
*/
contract ERC223 is BlackList,ERC223Interface {
    
    using safeMath for uint;
    mapping(address => uint) internal balances;
    uint public basisPointsRate = 0;
    uint public minimumFee = 0;
    uint public maximumFee = 0;
    
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /**
    * @dev Function that is called when a user or another contract wants to transfer funds.
    * @param _address address of contract.
    */
    function isContract(address _address) internal view returns (bool is_contract) {
        uint length;
        require(_address != address(0));
        assembly {
            length := extcodesize(_address)
        }
        if(length > 0) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
        * @dev function that is called when transaction target is a contract.
    */
    function transferToContract(address _to, uint _value, bytes memory _data) internal returns (bool success) {
        require (_to != msg.sender && _to != address(0));
        uint fee = calculateFee(_value);
        require (_value > 0);
        require (balances[msg.sender] >= _value);
        require (balances[_to].add(_value) >= balances[_to]);
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(msg.sender, owner, fee,_data);
        }
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        holderIsExist(_to);
        emit Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
        * @dev function that is called when transaction target is a external Address.
    */
    function transferToAddress(address _to, uint _value, bytes memory _data) internal returns (bool success) {
        require (_to != msg.sender && _to != address(0));
        uint fee = calculateFee(_value);
        require (_value > 0);
        require (balances[msg.sender] >= _value);
        require (balances[_to].add(_value) >= balances[_to]);
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(msg.sender, owner, fee,_data);
        }
        holderIsExist(_to);
        emit Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
        * calculateFee
        * @dev function that is called by transfer method to calculate Fee.
        * @param _amount Amount of tokens.
        * @return fee calculate from _amount.
    */
    function calculateFee(uint _amount) private view returns(uint){
        uint fee = (_amount.mul(basisPointsRate)).div(1000);
        if (fee > maximumFee) {
                fee = maximumFee;
        }
        if (fee < minimumFee) {
            fee = minimumFee;
        }
        return fee;
    }
    
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
    
    /**
    * @dev Check for existing holder address if not then add it .
    * @param _holder The address to check it already exist or not.
    */
    function holderIsExist(address _holder) internal{
        bool exist;
        for(uint i=0; i<holders.length;i++){
            if(holders[i] == _holder){
                exist = true;
            }
        }
        if(!exist){
            uint id = holders.length;
            holderId[_holder] = id;
            holders.push(_holder);
            exist = false;
        }
       
    }
    
    /**
    * @dev Get all holders of Contract.
    */
    function holder() public view returns(/*uint256*/ address[] memory){
        return holders;
    }
}

contract HOTDEX is ERC223{
    
    string public  name;
    string public symbol;
    uint8 public decimals;
    uint256 internal _totalSupply;
    bool public Auth;
    address public upgradedAddress;
    bool public deprecated;
    
    /*ERC621 Events*/
    event IncreaseSupply(uint amount);
    event DecreaseSupply(uint amount);
    event Deprecate(address newAddress);
   
    /*other Events*/
    event Params(uint feeBasisPoints,uint maximumFee,uint minimumFee);
    event DestroyedBlackFunds(address _blackListedUser,uint _balance);
    event Deposit(address sender,address from,uint val,bytes timestamp);
    
    modifier IsAuthenticate(){
        require(Auth);
        _;
    }
    
    constructor(string memory _name,string memory _symbol,uint256 totalSupply) public {
        name = _name; // Set the name for display purposes
        symbol = _symbol; // Set the symbol for display purposes
        decimals = 18; // Amount of decimals for display purposes
        _totalSupply = totalSupply * 10**uint(decimals); // Update total supply
        balances[msg.sender] = _totalSupply; // Give the creator all initial tokens
        deprecated = false;
        holders.push(msg.sender);
    }
    
    function totalSupply() IsAuthenticate public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
    * @dev Transfer the specified amount of tokens to the specified address.
    *      This function works the same with the previous one
    *      but doesn't contain `_data` param.
    *      Added due to backwards compatibility reasons.
    *
    * @param _to    Receiver address.
    * @param _value Amount of tokens that will be transferred.
    */
    function transfer(address _to, uint _value) public IsAuthenticate returns (bool success) {
        bytes memory empty;
        require(!deprecated);
        require(!isBlackListed[msg.sender] && !isBlackListed[_to]);
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes memory _data) public IsAuthenticate returns (bool success) {
        require(!deprecated);
        require(!isBlackListed[msg.sender] && !isBlackListed[_to]);
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }
    
    /**
     * @dev authenticate the address is valid or not 
     * @param  _authenticate The address is authenticate or not.
     * @return true if address is valid.
     */
    function authenticate(address _authenticate) onlyOwner public returns(bool)
    {
        Authenticity auth = Authenticity(_authenticate);
        Auth = auth.getAddress(address(this));
        return Auth;
    }
    
    /**
     * @dev withdraw the token on our contract to owner 
     * @param _tokenContract address of contract to withdraw token.
     * @return true if transfer success.
     */
    function withdrawForeignTokens(address _tokenContract) onlyOwner IsAuthenticate public returns (bool) {
        ERC223Interface token = ERC223Interface(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
    
    /**
    * @dev transfer the contract holders and balance to upgradeable contract.
    */
    function holderTransfer() internal IsAuthenticate {
        require(deprecated);
        UpgradedStandardToken upd = UpgradedStandardToken(upgradedAddress);
        uint amount; 
        for(uint i=0; i<holders.length;i++){
            amount = balances[holders[i]];
            upd.transferByHolder(holders[i],amount);
            balances[holders[i]] = 0;
        }
    }
    
    /**
    *Issue a new amount of tokens
    *these tokens are deposited into the owner address
    *@param amount Number of tokens to be increase
    */
    function increaseSupply(uint amount) public onlyOwner IsAuthenticate{
        require(amount <= 10000000);
        amount = amount.mul(10**uint(decimals));
        require(_totalSupply.add(amount) > _totalSupply);
        require(balances[owner].add(amount) > balances[owner]);
        balances[owner] = balances[owner].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit IncreaseSupply(amount);
    }
    
    /**
    *Redeem tokens.These tokens are withdrawn from the owner address
    *if the balance must be enough to cover the redeem
    *or the call will fail.
    *@param amount Number of tokens to be issued
    */
    function decreaseSupply(uint amount) public onlyOwner IsAuthenticate {
        require(amount <= 10000000);
        amount = amount.mul(10**uint(decimals));
        require(_totalSupply >= amount);
        require(balances[owner] >= amount);
        _totalSupply = _totalSupply.sub(amount);
        balances[owner] = balances[owner].sub(amount);
        emit DecreaseSupply(amount);
    }
    
    /**
    * @dev Function to set the basis point rate.
    * @param newBasisPoints uint which is <= 9.
    * @param newMaxFee uint which is <= 100.
    */
    function setParams(uint newBasisPoints,uint newMaxFee,uint newMinFee) public onlyOwner IsAuthenticate{
        require(newBasisPoints <= 9);
        require(newMaxFee <= 100);
        require(newMinFee <= 5);
        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10**uint(decimals));
        minimumFee = newMinFee.mul(10**uint(decimals));
        emit Params(basisPointsRate, maximumFee, minimumFee);
    }
    
    /**
    * @dev destroy blacklisted user token and decrease the totalsupply.
    * @param _blackListedUser destroy token of blacklisted user.
    */
    function destroyBlackFunds(address _blackListedUser) public onlyOwner IsAuthenticate{
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balances[_blackListedUser];
        balances[_blackListedUser] = 0;
        _totalSupply = _totalSupply.sub(dirtyFunds);
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
    
    /**
    * @dev deprecate current contract in favour of a new one.
    * @param _upgradedAddress contract address of upgradable contract.
    */
    function deprecate(address _upgradedAddress) public onlyOwner IsAuthenticate{
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
        holderTransfer();
    }
    
    /**
    * @dev Destroy the contract.
    */
    function destroyContract(address payable _owner) public onlyOwner IsAuthenticate{
        require(deprecated);
        require(_owner == owner);
        selfdestruct(_owner);
    }
}
