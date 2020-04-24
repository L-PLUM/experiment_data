/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.0;


contract BlockRelay {

  struct MerkleRoots {
    
    uint256 drHashMerkleRoot;
    
    uint256 tallyHashMerkleRoot;
  }
  struct Beacon {
    
    uint256 blockHash;
    
    uint256 epoch;
  }

  
  address witnet;
  
  Beacon lastBlock;

  mapping (uint256 => MerkleRoots) public blocks;

  
  event NewBlock(address indexed _from, uint256 _id);

  constructor() public{
    
    witnet = msg.sender;
  }

  
  modifier isOwner() {
    require(msg.sender == witnet, "Sender not authorized"); 
    _; 
  }
  
  modifier blockExists(uint256 _id){
    require(blocks[_id].drHashMerkleRoot!=0, "Non-existing block");
    _;
  }
   
  modifier blockDoesNotExist(uint256 _id){
    require(blocks[_id].drHashMerkleRoot==0, "The block already existed");
    _;
  }

  
  
  
  
  
  function postNewBlock(uint256 _blockHash, uint256 _epoch, uint256 _drMerkleRoot, uint256 _tallyMerkleRoot)
    public
    isOwner
    blockDoesNotExist(_blockHash)
  {
    uint256 id = _blockHash;
    lastBlock.blockHash = id;
    lastBlock.epoch = _epoch;
    blocks[id].drHashMerkleRoot = _drMerkleRoot;
    blocks[id].tallyHashMerkleRoot = _tallyMerkleRoot;
  }

  
  
  
  function readDrMerkleRoot(uint256 _blockHash)
    public
    view
    blockExists(_blockHash)
  returns(uint256 drMerkleRoot)
    {
    drMerkleRoot = blocks[_blockHash].drHashMerkleRoot;
  }

  
  
  
  function readTallyMerkleRoot(uint256 _blockHash)
    public
    view
    blockExists(_blockHash)
  returns(uint256 tallyMerkleRoot)
  {
    tallyMerkleRoot = blocks[_blockHash].tallyHashMerkleRoot;
  }

  
  
  function getLastBeacon()
    public
    view
  returns(bytes memory)
  {
    return abi.encodePacked(lastBlock.blockHash, lastBlock.epoch);
  }
}
