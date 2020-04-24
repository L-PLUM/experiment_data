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

contract WHITELIST is Ownable {
    
    bytes32 constant private ZERO_BYTES = bytes32(0);
    bytes32 constant private TRUE_BYTES = 0x0000000000000000000000000000000000000000000000000000000000000001;
    address constant private ZERO_ADDRESS = address(0);
    
    address private _creosafeContract;
    
    bool public _frozen = false;
    bool public _dead = false;
    
    struct Customer {
        bool isExist;
        bool isLocked;
        bool inBlackList;
    }
    
    struct Approval {
        bytes32 hashKYC;
        uint expiredtimeKYC;
        bytes32 hashACC;
        uint expiredtimeACC;
    }
    
    struct Provider {
        bool isExist;
        bool isLocked;
    }
    
    mapping (address => Customer) public _customers;
    mapping (address => Approval) public _customersApproval;
    mapping (address => Provider) public _providers;
    
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
    
    modifier isCustomerNotAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(!_customers[addr].isExist,"Customer already added");
        _;
    }
    
    modifier isCustomerAdded(address addr) {
        require(addr != ZERO_ADDRESS,"Address must be valid");
        require(_customers[addr].isExist,"Not found customer");
        _;
    }
    
    modifier isAdmin(address whois, address contractAddress){
        require(whois != ZERO_ADDRESS, "Zero address");
        Provider memory p = _providers[contractAddress]; 
        require(p.isExist && !p.isLocked, "Provide is locked or not exists");
        bytes memory payload = abi.encodeWithSignature("isProviderAdmin(address)", whois);
        (bool success, bytes memory returnData) = address(contractAddress).staticcall(payload);
        require(success, "Creo contract reverted that isCreoAdmin");
        require(keccak256(returnData) ==  keccak256(abi.encodePacked(TRUE_BYTES)),"Wallet address has not authorization in Creo Contract"); 
        _;
    }
    
    constructor (address transferAgent, address creosafeContract, address killer) Ownable(killer) public isContract(creosafeContract) isContract(transferAgent) {
        _creosafeContract = creosafeContract;
        _providers[creosafeContract] = Provider(true, false);
        _providers[transferAgent] = Provider(true, false);
    }
    
    function killEmAll() public onlyKiller{
        _dead = true;
    }
    
    function freeze() public isAdmin(msg.sender, _creosafeContract){
        require(!_dead);
        _frozen = true;
    }
    
    function defrost() public isAdmin(msg.sender, _creosafeContract){
        require(!_dead);
        _frozen = false;
    }
    
    function addProvider(address provider) public available isAdmin(msg.sender, _creosafeContract) isContract(provider){
        _providers[provider] = Provider(true, false);
    }
    
    function freezeProvider(address provider) public isAdmin(msg.sender, _creosafeContract) isContract(provider){
         _providers[provider] = Provider(true, true);
    }
    
    function getProvider(address provider) public view returns(bool, bool){
        Provider memory p = _providers[provider];
        return (p.isExist ,p.isLocked);
    }
    
    function getCreosafeContract() public view returns(address){
        return _creosafeContract;
    }
    
    function setCreosafeContract(address creosafeContract) public available isAdmin(msg.sender, creosafeContract) isContract(creosafeContract){
        _creosafeContract = creosafeContract;
    }
    
    function approveKYC(address customer, address provider, bytes32 hashKYC, uint expiredtimeKYC)public available isAdmin(msg.sender, provider){
        approve(customer, hashKYC, expiredtimeKYC, ZERO_BYTES,now);
    }
    
    function approveACC(address customer, address provider, bytes32 hashACC, uint expiredtimeACC)public available isAdmin(msg.sender, provider){
        approve(customer, ZERO_BYTES,now, hashACC, expiredtimeACC);
    }
    
    function approveCustomer(address customer, address provider, bytes32 hashKYC, uint expiredtimeKYC, bytes32 hashACC, uint expiredtimeACC)public available isAdmin(msg.sender, provider){
       approve(customer, hashKYC, expiredtimeKYC, hashACC, expiredtimeACC);
    }
    
    function approve(address customer, bytes32 hashKYC, uint expiredtimeKYC, bytes32 hashACC, uint expiredtimeACC) internal {
        if(!_customers[customer].isExist){
            _customers[customer] = Customer(true, false, false);
            _customersApproval[customer] = Approval(hashKYC, expiredtimeKYC, hashACC, expiredtimeACC);
        }else{
            Approval storage approval = _customersApproval[customer];
            if(hashKYC != ZERO_BYTES){
                approval.hashKYC = hashKYC;
                if(expiredtimeKYC > approval.expiredtimeKYC) approval.expiredtimeKYC = expiredtimeKYC;
            }
            if(hashACC != ZERO_BYTES){
                approval.hashACC = hashACC;
                if(expiredtimeACC > approval.expiredtimeACC) approval.expiredtimeACC = expiredtimeACC;
            }
        }
    }
    
    function updateCustomer(address customer, address provider, bool isLocked, bool inBlackList) public available isAdmin(msg.sender, provider) isCustomerAdded(customer){
        Customer storage c = _customers[customer];
        c.isLocked = isLocked;
        c.inBlackList = inBlackList;
    }
    
    function getCustomer(address customer) public view returns(bool,bool,bool,bool,bool){
        Customer memory c = _customers[customer];
        if(!c.isExist){
            return (false,false,false, false,false);
        }else{
            Approval memory a = _customersApproval[customer];
            return(true, c.isLocked, c.inBlackList, a.expiredtimeKYC>now, a.expiredtimeACC > now );
        }
    }
    
    function() external payable {
        revert(); 
    }
}
