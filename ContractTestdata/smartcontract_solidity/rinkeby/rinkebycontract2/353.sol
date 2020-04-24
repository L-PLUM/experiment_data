/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^0.5.0;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    
    function paused() public view returns (bool) {
        return _paused;
    }

    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    
    modifier whenPaused() {
        require(_paused);
        _;
    }

    
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract InterplanetaryStorage is Ownable, Pausable {


  event LogUploadFile(address indexed accountAddress, string ipfsName, string ipfsHash, string ipfsTags, uint ipfsDate);

  struct IpfsDataStruct {
    string ipfsName;
    string ipfsHash;
    string ipfsTags;
    uint ipfsDate;
  }

  IpfsDataStruct[] public ipfsDataStruct;

  uint private fileLimit = 4;

  mapping (address => uint[]) private addressToFiles;
  mapping (address => uint) private userFilesCount;
  mapping (uint => address) public ownersMap;


  
  modifier notExceedsFileLimit() {
    require(userFilesCount[msg.sender] < fileLimit);
    _;
  }

  
  function setFileLimit(uint _fileLimit) public
   onlyOwner
  returns (uint) {
    
    require(_fileLimit > fileLimit);
    fileLimit = _fileLimit;
    return fileLimit;
  }

  
  function getFileLimit()
   onlyOwner
   public view returns (uint) {
    return fileLimit;
  }

  
  function getYourFileCount()
  public view returns (uint) {
    return userFilesCount[msg.sender];
  }

  
  function getUserFileCount(address _userAddress)
  onlyOwner
  public view returns (uint) {
    return userFilesCount[_userAddress];
  }


  
  modifier inputCheck(string memory _ipfsName, string memory _ipfsHash, string memory _ipfsTags) {
    require(bytes(_ipfsName).length <= 50);
    require(bytes(_ipfsTags).length <= 50);
    require(bytes(_ipfsHash).length <= 46);
    _;
  }

  
  function insertFile(string memory _ipfsName, string memory _ipfsHash, string memory _ipfsTags)
    public
    whenNotPaused
    notExceedsFileLimit
    inputCheck(_ipfsName,_ipfsHash,_ipfsTags)
    returns (uint)
  {
    uint fileId = ipfsDataStruct.push(IpfsDataStruct(
                                                      _ipfsName,
                                                      _ipfsHash,
                                                      _ipfsTags,
                                                      block.timestamp
                                                      )) - 1;
    addressToFiles[msg.sender].push(fileId);
    ownersMap[fileId] = msg.sender;
    emit LogUploadFile(
                      msg.sender,
                      _ipfsName,
                      _ipfsHash,
                      _ipfsTags,
                      block.timestamp);
    userFilesCount[msg.sender]++;
    return fileId;
  }


  
  function getFile(uint _index) public view returns (string memory, string memory, string memory, uint) {
    require(msg.sender == ownersMap[_index]);

    return (
      ipfsDataStruct[_index].ipfsName,
      ipfsDataStruct[_index].ipfsHash,
      ipfsDataStruct[_index].ipfsTags,
      ipfsDataStruct[_index].ipfsDate
      );
  }

  
  function getFileIndexes() public view returns (uint[] memory) {
    return addressToFiles[msg.sender];
  }
}
