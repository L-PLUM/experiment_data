/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.23;                                                  //Issue 6 : Newer solidity version  : Modified

library SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

}



contract XID {                                                            //Issue 7:  Redundant XID contract declaration
    function balanceOf(address _address) public view returns(uint);
    function transfer(address to, uint amount) public;
}




contract MediatorWallet{
    using SafeMath for uint256;
    address public xidAddress;
    mapping(address => uint256) public balances;                             //Issue 10 : Explicitly definded variable types    :  Modified
    mapping(address => uint256) public lastPaymentReceived;                  //Issue 10 : Explicitly definded variable types    : Modified
    uint256 public debt;                                                     //Issue 10 : Explicitly definded variable types    : Modified
    address public owner;
    address public distributorAddress;                                       // Added to control the ownership only to Distributor
    uint public EXPIRATION_TIME;

    constructor(address _xidAddress, uint256 _expiration_time) public {
        xidAddress = _xidAddress;
        owner = msg.sender;
        EXPIRATION_TIME = _expiration_time;
    }

    event Sent(address to, address from, uint256 amount,uint256 dateTime);                          // Issue 5 :  log current Date/time  : Modified
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can do it");
        _;
    }

    modifier onlyDistributor(){
        require(msg.sender == distributorAddress , "Only Distributor can do it");
        _;
    }

    function setDistributor(address _distributorAddress) public onlyOwner {
      require(_distributorAddress != address(0));
      distributorAddress = _distributorAddress;
    }

    function replenish(uint256 amount) public onlyOwner {
        require(distributorAddress != address(0));
        //checking for sufficient funds
        require(contractBalance() - debt >= amount);

        //balances[to] += amount;
        balances[distributorAddress] = balances[distributorAddress].safeAdd(amount);
        //debt += amount;
        debt = debt.safeAdd(amount);
        lastPaymentReceived[distributorAddress] = now;
        emit Sent(distributorAddress, owner, amount, now);
    }

    
    function updateOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }


/*
    function updateXIDAddress(address newXIDAddress) public onlyOwner {             //Issue 11 : Check address is valid ERC20  , Removing fromt he smartcontract to prevent locking of tokens
        xidAddress = newXIDAddress;
    }
*/

    function contractBalance() public view returns (uint256 _myBalanceXID) {
        XID xidContract = XID(xidAddress);
        _myBalanceXID = xidContract.balanceOf(this);
    }

    //transferring tokens to inside original XID contract
    function withdraw(uint256 amount) public {                         //Issue 8 : Check address is Valid and a real one : Modified ; Issue 3 :  User A can withdraw funds of User B.
        require(msg.sender != address(0));
        require(balances[msg.sender] >= amount);

        XID xidContract = XID(xidAddress);
        //debt -= amount;
        debt = debt.safeSub(amount);                                           //Issue 1 : Underflow errors     : Modified
        //balances[to] -= amount;
        balances[msg.sender] = balances[msg.sender].safeSub(amount);
        xidContract.transfer(msg.sender, amount);                                       // Issue 2 :  Race condition  : Modified

    }

    //transferring tokens inside mediator contract
    function send(address to, uint256 amount) public {                           //Issue 8 : Check address is Valid and a real one : Modified
        require(to != address(0));
        require(balances[msg.sender] >= amount);
        //balances[to] += amount;
        //balances[msg.sender] -= amount;                                       // Issue 2 :  Race condition    : Modified
        balances[msg.sender] = balances[msg.sender].safeSub(amount);
        lastPaymentReceived[to] = now; 
        balances[to] = balances[to].safeAdd(amount);                                       // Issue 2 :  Race condition   : Modified
        emit Sent(to, msg.sender, amount,now);
    }
    
    function sendMany(address[] addresses, uint256[] amounts) public {
        for(uint256 i=0;i<addresses.length;i++){
            send(addresses[i], amounts[i]);
        }
    }

    //transferring tokens from unactive account inside smart contract
    function transferExpiredFrom(address from, address to, uint256 amount) public onlyOwner {      
        require(from != address(0));                                                            //Issue 8 : Check address is Valid and a real one  : Modified
        require(to != address(0));
        require(now > lastPaymentReceived[from] + EXPIRATION_TIME);                             
        require(amount <= balances[from]);
        //balances[to] += amount;
        //balances[from] -= amount;
        balances[from] = balances[from].safeSub(amount);
        balances[to] = balances[to].safeAdd(amount);
        emit Sent(to, owner, amount,now);                                                          // Issue 4 : Should have event emitted    : Modified
    }

    //Read the contract Ether balance
    function weiBalance() public constant returns(uint256) {
        return this.balance;
    }
    function claim(address destination) public onlyOwner {
        destination.transfer(this.balance);
    }

    //Function to claim the tokens for 
    function claimTokens(address _token) onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        XID token = XID(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }
}
