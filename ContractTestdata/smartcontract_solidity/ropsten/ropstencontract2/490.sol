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
  constructor(address killer, address owner) internal {
    _owner = owner;
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

contract CREOSAFE is Ownable{
    using SafeMath for uint256;
    
    address constant private ZERO_ADDRESS = address(0);
    string constant public _partnerName = "Creosafe";
    
    address private _paymentContract;
    mapping(address => bool) _providerAdmins;
    
    bool public _frozen = false;
    bool public _dead = false;
    
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
    
    constructor(address mainCreoAddress, address killer) Ownable(killer, mainCreoAddress) public isValidAddress(killer) isValidAddress(mainCreoAddress) {
        _providerAdmins[mainCreoAddress] = true;
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
    
    function getPaymentContract() public view returns(address){
        return _paymentContract;
    }
    
    function setPaymentContract(address paymentContract) public available onlyOwner isContract(paymentContract){
        _paymentContract = paymentContract;
    }
    
    function addProviderAdmin(address adminAddress) public available onlyOwner isValidAddress(adminAddress){
        _providerAdmins[adminAddress] = true;
    }
    
    function removeProviderAdmin(address adminAddress) public available onlyOwner isValidAddress(adminAddress){
        _providerAdmins[adminAddress] = false;
    }
    
    function isProviderAdmin(address adminAddress) public view isValidAddress(adminAddress) returns(bool){
        return _providerAdmins[adminAddress];
    }
    
    
    function startPaymentProcess(address paymentAddress) public onlyOwner isValidAddress(paymentAddress) returns(bool){
        bytes memory payload = abi.encodeWithSignature("payProviderFee(address)", paymentAddress);
        (bool success,) = address(_paymentContract).call(payload);
        return success;
    }
    
    function() external payable {
        revert(); 
    }
    
}
