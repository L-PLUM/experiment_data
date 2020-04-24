/**
 *Submitted for verification at Etherscan.io on 2019-01-06
*/

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  constructor() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




/**
 * @title Galleri
 * @author Komhar  (@komhar)
 *
 * The digest is 32 bytes long and can be stored using bytes32 efficiently.
 */
contract Galleri is Destructible{
  
  uint constant WALL_SIZE = 8;
 bytes32 constant REMOVED = "REMOVED";
 uint public cost = 50 wei;
 uint public proportion = 25 wei;
 
  
  

  
  struct Wall {
      bytes32 [] creations;
     mapping (uint => Interests) creationInterest;
      
  }
  
  struct Interests {
      string [] interests;
  }
  
  struct Artist{
      address add;
      string pubKey;
  }
  
 
  mapping (address => Wall) private wall;
  mapping (uint => Artist) private artists;
  uint public count;

  /**
   * @dev associate a multihash entry with the sender address
   * @param _digest hash digest produced by hashing content using hash function
   * 
   */
  function addCreation(bytes32 _digest, string publicKey)
  public
  {
    if (wall[msg.sender].creations.length < WALL_SIZE){
        if (wall[msg.sender].creations.length== 0) {
            artists[count].add = msg.sender;
            artists[count].pubKey = publicKey;
            count++;
        }
        wall[msg.sender].creations.push(_digest); 
    } 
  }
  
  function addCreation(bytes32 _digest)
  public
  {
    if (wall[msg.sender].creations.length < WALL_SIZE){
        
        wall[msg.sender].creations.push(_digest); 
    } 
  }

  function getArtistAddress(uint index) constant returns (address){
      return artists[index].add;
  }
  function getArtistPubKey(uint index) constant returns (string){
      return artists[index].pubKey;
  }
  function refund(address _address, uint amount) onlyOwner {
      _address.transfer(amount);
  }
  
  function updateConfig(uint _cost, uint _proportion) onlyOwner{
      cost = _cost;
      proportion = _proportion;
  }
  
  
  function () payable {
      
  }
  
  function  showInterest(address _address, uint8 index, string interest) payable {
      require(msg.value > cost);
      wall[_address].creationInterest[index].interests.push(interest);
      _address.transfer(sub(cost,proportion));
  }


function updateCreation(bytes32 _digest, uint8 index)
  public
  {
    wall[msg.sender].creations[index] = _digest;
     delete wall[msg.sender].creationInterest[index].interests;
  }
  /**
   * @dev deassociate any multihash entry with the sender address
   */
  function removeWall(address _address) onlyOwner
  public
  {
    delete wall[_address];
  }
  
  function removeSpace(address _address, uint8 _index) onlyOwner
  public
  {
    wall[_address].creations[_index] = REMOVED;
  }

  /**
   * @dev retrieve multihash entry associated with an address
   * @param _address address used as key
   */
  function getWall(address _address) 
  public
  view
  returns(bytes32[])
  {
    return wall[_address].creations;
  }
  
  function getArtistWorkCount(address _address) public view returns (uint){
      return wall[_address].creations.length;
      
  }
  
  function getArtistLink(address _address) public view returns(bytes32 work, uint interest){
      for (uint i=0; i< wall[_address].creations.length; i++){
          interest = interest+ wall[_address].creationInterest[i].interests.length;
      }
      work = wall[_address].creations[0];
  }
  
  function getArtistInterest(address _address, uint index, uint interestIndex) public view returns (string){
      return  wall[_address].creationInterest[index].interests[interestIndex];
  }
  
  function getCreationInterest(address _address, uint index) public view returns (uint){
      return wall[_address].creationInterest[index].interests.length;
  }
  
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
}
