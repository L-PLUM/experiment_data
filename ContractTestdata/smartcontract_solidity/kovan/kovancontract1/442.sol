/**
 *Submitted for verification at Etherscan.io on 2019-01-28
*/

pragma solidity 0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
 function Ownable() {
    owner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Blueprint is Ownable {
    string exchange;
    string security;
    uint256 entry; 
    uint256 exit;
    uint256 expires;
    
    
    struct BlueprintInfo {
        string exchange;
        string security;
        string entry; 
        string exit;
        string expires;
        address creator;
        uint256 createTime;
    }

    mapping(string => BlueprintInfo) private  _bluePrint;

    function createExchange(string _id,string _exchange, string _security, string _entry, string _exit, string _expires) public onlyOwner
          
    returns (bool)
   
    {
         BlueprintInfo memory info;
         info.exchange=_exchange;
         info.security=_security;
         info.entry=_entry;
         info.exit=_exit;
         info.expires=_expires;
         info.creator=msg.sender;
         info.createTime=block.timestamp;
         _bluePrint[_id] = info;
         return true;
         
    }
    
    /**
  * @dev Gets the BluePrint details of the specified id.
  */
  function getBluePrint(string _id) public view returns (string,string,string,string,string,uint256) {
    return (_bluePrint[_id].exchange,_bluePrint[_id].security,_bluePrint[_id].entry,_bluePrint[_id].exit,_bluePrint[_id].expires,_bluePrint[_id].createTime);
  }
    
}
