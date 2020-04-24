/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.18;


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Ownable constructor ตั้งค่าบัญชีของ sender ให้เป็น owner ดั้งเดิมของ contract 
   *
   */
   constructor() public {
    owner = msg.sender;
  }

  function isContract(address _addr) internal view returns(bool)//เช็คว่า เป็น คอนเทค หรือ วอเล็ท 
  {
     uint256 length;
     assembly{
      length := extcodesize(_addr)
     }
     if(length > 0){
       return true;
    }
    else {
      return false;
    }

  }

 // ถ้าคนที่เรียกใช้ไม่ใช่คนสร้าง smart contract จะหยุดทำงานและคืนค่า gas
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }
// ตรวจสอบว่า ไม่ใช่ contract address 

  function transferOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false); // ตรวจสอบว่าไม่ได้เผลอเอา contract address มาใส่
    emit OwnershipTransferred(owner,newOwner);//คนใหม่เข้ามาจะต้องเป็น flase
    owner = newOwner;

  }

}



contract IceContract  is Ownable
{
    uint balance ;
   address  public owner;
    
    constructor() public
    {
        balance = 1000;
        owner = msg.sender; // owner is my  address 
        
    }
    
  
    
    // Query the balance of the contract 
    function getBalance() public view returns (uint)
    {
        return balance;
        
    }
    // address 
    function setOwener(address _owner) public onlyOwner
    {   //require(owner == msg.sender); //msg.sengar is my private key 
        owner = _owner;
    }
    //who call this function is owner
    function setBalanceOwner(uint newBalance) public onlyOwner // onlyOwner คล้าย require 
    {
       // require(owner == msg.sender);
        balance = newBalance;
        
    }
    
   /* function setBalanceOwner2(uint newBalance) public returns (bool)
    {
        if(owner == msg.sender)
       {
            balance = newBalance;
            return true;
            
    
        }
        return false;
    }*/
    
}
