/**
 *Submitted for verification at Etherscan.io on 2019-07-28
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

contract Poe is Ownable, Pausable {

  
  struct IpfsData {
    string name;
    string hashLink;
    string tags;
    uint timestamp;
    string dataExt;
  }

  
  event newData(
                  address indexed dataOwner,
                  string name,
                  string hashLink,
                  string tags,
                  uint timestamp,
                  string _dataExt
                );

  IpfsData[] public ipfsData;
  mapping (address => uint[]) private ownerIndexes;
  mapping (uint => address) public dataOwner;

  
  function getIndexes() public view returns (uint[] memory) {
    return ownerIndexes[msg.sender];
  }

  
  function getData(uint _index) public view returns (string memory, string memory, string memory, uint, string memory) {
    require(msg.sender == dataOwner[_index]);
    return (
      ipfsData[_index].name,
      ipfsData[_index].hashLink,
      ipfsData[_index].tags,
      ipfsData[_index].timestamp,
      ipfsData[_index].dataExt
      );
  }

  
  modifier isTextLengthOk(string memory _name, string memory _hashLink, string memory _tags, string memory _dataExt) {
    require(bytes(_hashLink).length <= 46);
    require(bytes(_tags).length <= 60);
    require(bytes(_name).length <= 60);
    require(bytes(_dataExt).length <= 4);
    _;
  }

  
  function setData(string memory _name, string memory _hashLink, string memory _tags, string memory _dataExt)
    public
    whenNotPaused
    isTextLengthOk(_name,_hashLink,_tags, _dataExt)
  {
    uint id = ipfsData.push(IpfsData(_name, _hashLink, _tags, now, _dataExt)) - 1;
    ownerIndexes[msg.sender].push(id);
    dataOwner[id] = msg.sender;
    emit newData(msg.sender, _name, _hashLink, _tags, now, _dataExt);
  }



}
