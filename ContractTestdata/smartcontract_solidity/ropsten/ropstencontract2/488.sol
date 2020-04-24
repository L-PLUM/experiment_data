/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.5.10;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;
  address private _killer;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor(address killer) internal {
    _owner = msg.sender;
    _killer = killer;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the killer.
   */
  function killer() public view returns(address) {
    return _killer;
  }
  
  /**
   * @dev Throws if called by any account other than the killer.
   */
  modifier onlyKiller() {
    require(isKiller(), "Only killer wallet call that function");
    _;
  }
  
  /**
   * @return true if `msg.sender` is the killer of the contract.
   */
  function isKiller() public view returns(bool) {
    return msg.sender == _killer;
  }
  
  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner(), "Only owner wallet call that function");
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
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
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract ERC20 {
    function totalSupply() public returns (uint);
    function balanceOf(address tokenOwner) public returns (uint balance);
    function allowance(address tokenOwner, address spender) public returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract PAYMENT is Ownable {
    
    using SafeMath for uint256;
    address constant private ZERO_ADDRESS = address(0);
    address constant private USDC_ADDRESS = 0x072Ea7c455e5f3D6F3c318A55aE55D805096bc1A;
    bytes32 constant private TRUE_BYTES = 0x0000000000000000000000000000000000000000000000000000000000000001;
    
    bool public _frozen = false;
    bool public _dead = false;
    
    //CUSTOMER PARAMETER
    struct Customer {
        address addr;
        bool isLocked;
        uint tokenBalance;
        uint weiBalance;
    }
    
    mapping(address => Customer) private _customers;
    mapping(address => address) private _linkedAddress;
    
    //PROVIDER PARAMETER
    struct Provider {
        address providerAddr;
        bool isLocked;
        uint tokenBalance;
        uint tokenLimit;
        uint weiBalance;
        uint weiLimit;
    }
    
    //uint creoTokenBalance = 0;
    //uint creoWeiBalance = 0;
    
    mapping(address => Provider) private _providers;
    address private _creosafeContract;
    
    //BEGIN OF CUSTOMERS VALIDATIONS
    
    modifier available(){
        require(!_frozen && !_dead, "Contract is not available");
        _;
    }
    
    modifier isValidAddress(address addr) {
        require(addr != ZERO_ADDRESS, "Wallet address is not valid");
        _;
    }
    
    modifier isContract(address addr){
        require(AddressUtils.isContract(addr), "Contract address is not valid");
        _;
    }
    
    modifier isCreosafeAdmin(address addr){
        require(addr != ZERO_ADDRESS);
        bytes memory payload = abi.encodeWithSignature("isProviderAdmin(address)", addr);
        (bool success, bytes memory returnData) = _creosafeContract.staticcall(payload);
        require(success, "Creo contract reverted that isCreoAdmin");
        require(keccak256(returnData) ==  keccak256(abi.encodePacked(TRUE_BYTES)),"Wallet address has not authorization in Creo Contract"); 
        _;
    }
    
    modifier isCustomerNotAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(_customers[addr].addr == ZERO_ADDRESS,"Customer already added");
        _;
    }
    
    modifier isCustomerAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(_customers[addr].addr != ZERO_ADDRESS,"Not found customer");
        _;
    }
    
    modifier checkSecondaryAddress(address secondaryAddress){
        require(secondaryAddress != ZERO_ADDRESS,"Address must be valid");
        require(_linkedAddress[secondaryAddress] == ZERO_ADDRESS,"secondary Address already added");
        _;
    }
    
    modifier isSecondaryAddrAdded(address addr, address secondaryAddress){
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(secondaryAddress != ZERO_ADDRESS,"Secondary Address must be valid");
        require(secondaryAddress != addr,"Primary and Secondray Address must be different");
        require(_linkedAddress[secondaryAddress] == addr,"Secondary Address is not linked Primary Address");
        _;
    }
    
    modifier isLockedCustomer(address addr) {
        require(addr != ZERO_ADDRESS, "Address must be valid");
        require(_customers[addr].isLocked, "Not locked address ");
        _;
    }
    
    modifier isUnLockedCustomer(address addr) {
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(!_customers[addr].isLocked, "Address already locked");
        _; 
    }
    
    //END OF CUSTOMERS VALIDATIONS
    
    //BEGIN OF PROVIDERS VALIDATIONS
    
    modifier isProviderNotAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Provider must be valid");
        require(_providers[addr].providerAddr == ZERO_ADDRESS,"Provider already added");
        _;
    }
    
    modifier isProviderAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Provider must be valid");
        require(_providers[addr].providerAddr == addr,"Not found Provider");
        _;
    }
    
    modifier isLockedProvider(address addr) {
        require(addr != ZERO_ADDRESS,"Provider must be valid");
        require(_providers[addr].isLocked,"Not locked Provider");
        _;
    }
    
    modifier isUnLockedProvider(address addr) {
        require(addr != ZERO_ADDRESS,"Provider must be valid");
        require(!_providers[addr].isLocked,"Provider already locked");
        _; 
    }
    
    //END OF PROVIDERS VALIDATIONS
    
    // BEGIN OF TRANSFER VALIDATIONS
    
    modifier isAvailableTokenBalance( uint tokenAmount) {
        require(tokenAmount > 0,"Token must be greater than 0");
        require(ERC20(USDC_ADDRESS).balanceOf(address(this)) >= tokenAmount,"Not enough token");
        _;
    }
    
    modifier isAvailableETHBalance(uint amount) {
        require(amount > 0,"Eth must be greater than 0");
        require(address(this).balance > amount,"Not enough eth");
        _;
    }
    
    modifier isAvailableTokenBalancewithTokenAddress(address tokenAddr, uint tokenAmount) {
        require(tokenAmount > 0,"Token must be greater than 0");
        require(ERC20(tokenAddr).balanceOf(address(this)) >= tokenAmount,"Not enough token");
        _;
    }
    
    // END OF TRANSFER VALIDATIONS
    
    constructor(address creosafeContract, address killer) 
    Ownable(killer)
    isContract(creosafeContract) 
    public {
       _creosafeContract = creosafeContract;
    }
    
    function killEmAll() public onlyKiller{
        _dead = true;
    }
    
    function freeze() public onlyOwner{
        require(!_dead);
        _frozen = true;
    }
    
    function defrost() public onlyOwner{
        require(!_dead);
        _frozen = false;
    }
    
    function getCreosafeContract() public view returns(address){
        return _creosafeContract;
    }
    
    function setCreosafeContract(address creosafeContract) public available isCreosafeAdmin(msg.sender) isContract(creosafeContract){
        _creosafeContract = creosafeContract;
    }
    
    //BEGIN OF CUSTOMERS FUNCTIONS 
    
    function addCustomer(address customerAddress) public available isCreosafeAdmin(msg.sender) isCustomerNotAdded(customerAddress) checkSecondaryAddress(customerAddress){
        _customers[customerAddress] = Customer(customerAddress, false, 0, 0);
        _linkedAddress[customerAddress] = customerAddress;
    }

    function addTokentoCustomer(address customerAddress, uint tokenAmount) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress){
        require(tokenAmount > 0);
        Customer storage c = _customers[customerAddress];
        c.tokenBalance = c.tokenBalance.add(tokenAmount);
    }
    
    function addEthtoCustomer(address customerAddress, uint weiAmount) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress){
        require(weiAmount > 0);
        Customer storage c = _customers[customerAddress];
        c.weiBalance = c.weiBalance.add(weiAmount);
    }
    
    function removeTokenfromCustomer(address customerAddress, uint tokenAmount) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress){
        Customer storage c = _customers[customerAddress];
        require(c.tokenBalance >= tokenAmount );
        c.tokenBalance = c.tokenBalance.sub(tokenAmount);
    }
    
    /*
    function transferEthtoCreo(address _customerAddress, uint _weiAmount) public onlyOwner isCustomerAdded(_customerAddress) returns (bool){
        require(_weiAmount > 0);
        Customer storage c = customers[_customerAddress];
        require(_weiAmount<=c.weiBalance);
        c.weiBalance = c.weiBalance.sub(_weiAmount);
        creoWeiBalance = creoWeiBalance.add(_weiAmount);
        return true;
    }
    
    function transferTokentoCreo(address _customerAddress, uint _tokenAmount) public onlyOwner isCustomerAdded(_customerAddress) returns (bool){
        require(_tokenAmount > 0);
        Customer storage c = customers[_customerAddress];
        require(c.tokenBalance >= _tokenAmount );
        c.tokenBalance = c.tokenBalance.sub(_tokenAmount);
        creoTokenBalance = creoTokenBalance.add(_tokenAmount);
        return true;
    }
    */
    
    function getCustomer(address customerAddress) public view returns(bool, bool, uint, uint){
        Customer memory c = _customers[customerAddress];
        bool isExist = _customers[customerAddress].addr != ZERO_ADDRESS;
        return (isExist, c.isLocked, c.weiBalance, c.tokenBalance);
    }
    
    function addSecondaryAddress(address customerAddress, address secondaryAddress) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress) 
        checkSecondaryAddress(secondaryAddress){
            _linkedAddress[secondaryAddress] = customerAddress;
    }
    
    function deleteSecondaryAddress(address customerAddress, address secondaryAddress) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress)
        isSecondaryAddrAdded(customerAddress, secondaryAddress){
            require(customerAddress != secondaryAddress);
            _linkedAddress[secondaryAddress] = ZERO_ADDRESS;
    }
    
    function lockCustomer(address customerAddress) public available isCreosafeAdmin(msg.sender)  
        isCustomerAdded(customerAddress) isUnLockedCustomer(customerAddress) {
        Customer storage c = _customers[customerAddress];
        c.isLocked = true;
    }

    function unlockCustomer(address customerAddress) public available isCreosafeAdmin(msg.sender)  
        isCustomerAdded(customerAddress) isLockedCustomer(customerAddress) {
        Customer storage c = _customers[customerAddress];
        c.isLocked = false;
    }
    
    function getLinkedAddress(address linkedAddress) public view isValidAddress(linkedAddress) returns(address){
       return(_linkedAddress[linkedAddress]);
    }

    function transferETHtoProvider(address customerAddress, address providerCA, uint providerFee)
        public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress) isProviderAdded(providerCA) {
            require(providerFee > 0 );
            Customer storage c = _customers[customerAddress];
            Provider storage p = _providers[providerCA];
            require(c.weiBalance >= providerFee);
            p.weiBalance = p.weiBalance.add(providerFee);
            c.weiBalance = c.weiBalance.sub(providerFee);
    }
    
    function transferTOKENtoProvider(address customerAddress, address providerCA, uint providerFee)
        public available isCreosafeAdmin(msg.sender) isCustomerAdded(customerAddress) isProviderAdded(providerCA) {
            require(providerFee > 0);
            Customer storage c = _customers[customerAddress];
            Provider storage p = _providers[providerCA];
            require(c.tokenBalance >= providerFee);
            p.tokenBalance = p.tokenBalance.add(providerFee);
            c.tokenBalance = c.tokenBalance.sub(providerFee);
    }
    
    //END OF CUSTOMERS FUNCTIONS
    
    //BEGIN OF PROVIDERS FUNCTIONS
    function addProvider(address provider, uint weiLimit, uint tokenLimit) public available isCreosafeAdmin(msg.sender) isValidAddress(provider) 
        isProviderNotAdded(provider) {
            _providers[provider] = Provider(provider, false, 0, tokenLimit, 0, weiLimit);
    }
    
    function setProviderLimits(address provider, uint weiLimit, uint tokenLimit) public available isCreosafeAdmin(msg.sender) isValidAddress(provider) 
        isProviderAdded(provider){
            Provider storage p = _providers[provider];
            p.weiLimit = weiLimit;
            p.tokenLimit = tokenLimit;
    }

    function setProviderLimit(address provider, bool isEth, uint limit) public available isCreosafeAdmin(msg.sender) isValidAddress(provider) 
        isProviderAdded(provider) {
            Provider storage p = _providers[provider];
            if(isEth){
                p.weiLimit = limit;
            }else{
                p.tokenLimit = limit;
            }
    }

    function getProvider(address provider) public view isValidAddress(provider)
        returns(bool, bool, uint, uint, uint, uint){
            Provider memory p = _providers[provider];
            bool isExist = p.providerAddr != ZERO_ADDRESS;
            return(isExist, p.isLocked, p.weiBalance, p.weiLimit, p.tokenBalance, p.tokenLimit);
    }
    
    function lockProvider(address provider) public available isCreosafeAdmin(msg.sender) isProviderAdded(provider) isUnLockedProvider(provider) {
        Provider storage p = _providers[provider];
        p.isLocked = true;
    }
    
    function unlockProvider(address provider) public available isCreosafeAdmin(msg.sender) isProviderAdded(provider) isLockedProvider(provider) {
        Provider storage p = _providers[provider];
        p.isLocked = false;
    }
    
    //END OF PROVIDERS FUNCTIONS
    
    // BEGIN OF PAYABLE FUNCTIONS
    
    function() external payable {
        require(msg.sender != ZERO_ADDRESS);
        require(_linkedAddress[msg.sender] != ZERO_ADDRESS);
        require(msg.value > 0);
        address customerAddress = _linkedAddress[msg.sender];
        Customer memory c = _customers[customerAddress];
        require(c.addr != ZERO_ADDRESS);
        require(!c.isLocked);
        //c.weiBalance = c.weiBalance.add(msg.value);
    }
    
    function refundETHToCustomer(address payable customer, uint refundAmount) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customer) isAvailableETHBalance(refundAmount){
        Customer storage c = _customers[customer];
        require(refundAmount > 0 && c.weiBalance>=refundAmount);
        customer.transfer(refundAmount);
        c.weiBalance = c.weiBalance.sub(refundAmount);
    }
    
    function refundTokenToCustomer(address customer, uint refundAmount) public available isCreosafeAdmin(msg.sender) isCustomerAdded(customer) isAvailableTokenBalance(refundAmount) {
        Customer storage c = _customers[customer];
        require(refundAmount > 0 && c.tokenBalance>=refundAmount);
        ERC20(USDC_ADDRESS).transfer(customer, refundAmount);
        c.tokenBalance = c.tokenBalance.sub(refundAmount);
    }
    
        
    function payProviderFee(address payable providerWallet) public isProviderAdded(msg.sender) isValidAddress(providerWallet) returns(bool){
        Provider memory p = _providers[msg.sender];
        require(!p.isLocked);
        if(p.weiBalance >= p.weiLimit){
            payETHToProvider(providerWallet, msg.sender, p.weiBalance);
        }
        if(p.tokenBalance >= p.tokenLimit){
            payUSDCToProvider(providerWallet, msg.sender, p.tokenBalance); 
        }
        return true;
    }
    
    function payETHToProvider(address payable providerWallet, address providerCA, uint amount) internal isAvailableETHBalance(amount) {
        Provider storage p = _providers[providerCA];
        providerWallet.transfer(p.weiBalance);
        p.weiBalance = 0;
    }
    
    function payUSDCToProvider(address providerWallet, address providerCA, uint amount) internal isAvailableTokenBalance(amount) {
        Provider storage p = _providers[providerCA];
        ERC20(USDC_ADDRESS).transfer(providerWallet, p.tokenBalance);
        p.tokenBalance = 0;
    }
    
    function transferAnyERC20Token(address _address, address _tokenAddress, uint _tokenAmount) public isCreosafeAdmin(msg.sender) isValidAddress(_address) 
        isContract(_tokenAddress) isAvailableTokenBalancewithTokenAddress(_tokenAddress, _tokenAmount) returns(bool){
            ERC20(_tokenAddress).transfer(_address, _tokenAmount);
            return true;
    }
    
    //END OF PAYALE FUNCTION
}
