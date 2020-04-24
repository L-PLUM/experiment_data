/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.25;

contract Ownable {


  string [] ownerName;

  mapping (address=>bool) owners;
  mapping (address=>uint256) ownerToProfile;
  address owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AddOwner(address newOwner,string name);
  event RemoveOwner(address owner);
  /**
   * @dev Ownable constructor ตั้งค่าบัญชีของ sender ให้เป็น `owner` ดั้งเดิมของ contract 
   *
   */
   constructor() public {
    owner = msg.sender;
    owners[msg.sender] = true;
    uint256 idx = ownerName.push("ICOINIZE CO.,Ltd.");
    ownerToProfile[msg.sender] = idx;

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

 // For Single Owner
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner,string newOwnerName) public onlyOwner{
    require(isContract(newOwner) == false); // Owner can be only wallet address can't use contract address
    uint256 idx;
    if(ownerToProfile[newOwner] == 0)
    {
    	idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }


    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

  //For multiple Owner
  modifier onlyOwners(){
    require(owners[msg.sender] == true);
    _;
  }

  function addOwner(address newOwner,string newOwnerName) public onlyOwners{
    require(owners[newOwner] == false);
    require(newOwner != msg.sender);
    if(ownerToProfile[newOwner] == 0)
    {
    	uint256 idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }
    owners[newOwner] = true;
    emit AddOwner(newOwner,newOwnerName);
  }

  function removeOwner(address _owner) public onlyOwners{
    require(_owner != msg.sender);  // can't remove your self
    owners[_owner] = false;
    emit RemoveOwner(_owner);
  }

  function isOwner(address _owner) public view returns(bool){
    return owners[_owner];
  }

  function getOwnerName(address ownerAddr) onlyOwners public view returns (string){
  	require(ownerToProfile[ownerAddr] > 0);
  	
  	return ownerName[ownerToProfile[ownerAddr] - 1];
  }
}

contract WhitelistAddr is Ownable{
  uint256 public version =  101;
  mapping (address=>uint256)  whitelists;
  uint256[4]  invesTypes; // 0 mean unlimited

  event CreateWhitelist(address indexed _addr);
  
  constructor() public{
      invesTypes[0] = 300000;
  }

  function addAddress(address _addr,uint256 invesType) public onlyOwners returns(bool){
     require(whitelists[_addr] == 0);
     require(invesType > 0);

     whitelists[_addr] = invesType;
     return true;
  }
  // return thai bath with 4 digit
  function getMaxInvest(address _addr) external view onlyOwners returns(uint256){
        uint256 invesType = whitelists[_addr];
        return invesTypes[invesType-1];
  }

  function haveWhitelist(address _addr) external onlyOwners view returns(uint256){
    return whitelists[_addr];
  }

// set thai bath with 4 digit
  function setMaxInvesment(uint256  thaiBath,uint256 invesType) onlyOwners public{
      invesTypes[invesType] = thaiBath;
  }
  
  function getMaxInvestType(uint256 invesType) onlyOwners public view returns(uint256){
      return invesTypes[invesType];
  }

}
