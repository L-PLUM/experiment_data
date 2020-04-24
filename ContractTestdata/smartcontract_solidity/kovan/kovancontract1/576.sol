/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.25;

contract Ownable {
  address public owner;
  address[] public owners;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event OwnershipAdded(address indexed owner, address indexed newOwner);

  /**
   * @dev Ownable constructor ตั้งค่าบัญชีของ sender ให้เป็น owner ดั้งเดิมของ contract 
   *
   */
   constructor() public {
    owner = msg.sender;
  }

  function isContract(address _addr) internal view returns(bool){
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
    bool isOwner;
    uint i;
    while (i < owners.length) {
        if(msg.sender == owners[i])
            isOwner=true;
        i++;
    }
    require(msg.sender == owner || isOwner);
    _;
  }
  
  function addOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false); // ตรวจสอบว่าไม่ได้เผลอเอา contract address มาใส่
    emit OwnershipAdded(owner, newOwner);
    owners[owners.length] = newOwner;
  }
  
// ตรวจสอบว่า ไม่ใช่ contract address 
  function transferOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false); // ตรวจสอบว่าไม่ได้เผลอเอา contract address มาใส่
    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

}

contract ThepSimpleContract is Ownable {
   
    uint balance;
    //address owner;
    
    constructor() public{
        balance = 1000;
        owner = msg.sender;
    }
    function setBalance(uint newBalance) public{
        balance = newBalance;
    }
    function getBalance() public view returns (uint){
        return balance;
    }
    // function setOwer(address _owner) public onlyOwner{
    //     owner = _owner;
    // }
    function setBalanceOwner(uint newBalance) public onlyOwner{
        //require(owner == msg.sender);
        balance = newBalance;
    }
    // function setBalanceOwner2(uint newBalance) public returns (bool){
    //     if(owner == msg.sender) {
    //         balance = newBalance;
    //         return true;
    //     }
    //     return false;
    // }
}
