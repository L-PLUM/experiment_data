/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity ^0.5.2;

// File: contracts/lib/Ownable.sol

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnershipOfContract(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

// File: contracts/lib/SafeMath.sol

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
}

// File: contracts/lib/Roles.sol

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: contracts/lib/StoreRole.sol

contract StoreRole {
    using Roles for Roles.Role;

    event StoreAdded(address indexed account);
    event StoreRemoved(address indexed account);

    Roles.Role private _stores;

    constructor () internal {
        _addStore(msg.sender);
    }

    modifier onlyStore() {
        require(isStore(msg.sender), "StoreRole: caller does not have the Store role");
        _;
    }

    function isStore(address account) public view returns (bool) {
        return _stores.has(account);
    }

    function addStore(address account) public onlyStore {
        _addStore(account);
    }

    function removeStore() public {
        _removeStore(msg.sender);
    }

    function _addStore(address account) internal {
        _stores.add(account);
        emit StoreAdded(account);
    }

    function _removeStore(address account) internal {
        _stores.remove(account);
        emit StoreRemoved(account);
    }
}

// File: contracts/EthPubDRM.sol

/**
 * @title DRM on Blockchain
 * @author Yoshi Nishimura, G.U.Lab
 * @dev Digital rights management on Blockchain
 */

contract EthPubDRM is Ownable, StoreRole {
    using SafeMath for uint256;

    mapping(bytes16 => mapping(address => Balance)) private _balances;
    mapping(bytes16 => Content) public contents;

    mapping(address => mapping(uint256 => bytes16)) public balanceIndex;
    mapping(address => uint256) public balanceCount;

    mapping(address => mapping(uint256 => bytes16)) public publishIndex;
    mapping(address => uint256) public publishCount;
    
    mapping(bytes16 => mapping(address => mapping(address => uint256))) public allowance;
    mapping(address => mapping(address => mapping(uint256 => bytes16))) public allowedIndex;
    mapping(bytes16 => mapping(address => mapping(uint256 => address))) public allowanceIndex;
    mapping(address => mapping(address => uint256)) public allowedCount;
    mapping(bytes16 => mapping(address => uint256)) public allowanceCount;
    mapping(bytes16 => mapping(address => uint256)) public allowanceTotal;

    struct Content {
        address publisher;
        string title;
        string thumbnail;
        string contentProvider;
        string encryptionMethod;
        uint256 totalSupply;
        string contentPath;
    }
    
    struct Balance {
        uint256 balance;
        bool hasValue;
    }

    modifier onlyPublisher(bytes16 _contentHash) {
      require(contents[_contentHash].publisher == msg.sender);
      _;
    }

    constructor() public {}
    
    /**
    * @dev Get a publisher address form the content
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    */
    function getPublisher (bytes16 _contentHash) external view returns (address) {
        return contents[_contentHash].publisher;
    }

    /**
    * @dev Newly publish a content
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _contentPath string content path either of IPFS hash/path or web URL
    */
    function publish (bytes16 _contentHash, string calldata _title, string calldata _thumbnail, string calldata _contentProvider, string calldata _encryptionMethod, string calldata _contentPath) external returns (bool) {
        require(contents[_contentHash].publisher == address(0)); // only if the content hash is not already used
        contents[_contentHash].publisher = msg.sender;
        contents[_contentHash].title = _title;
        contents[_contentHash].thumbnail = _thumbnail;
        contents[_contentHash].contentProvider = _contentProvider;
        contents[_contentHash].encryptionMethod = _encryptionMethod;
        contents[_contentHash].totalSupply = 0;
        contents[_contentHash].contentPath = _contentPath;
        publishIndex[msg.sender][publishCount[msg.sender]] = _contentHash;
        publishCount[msg.sender] = publishCount[msg.sender].add(1);
    }

    /**
    * @dev Issue contents to allow agents or stores to transfer ownership ownership
    * @param _to address address of an account who will obtain allowance of the content
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _amount uint256 the number of contents to issue
    */
    function issue(address _to, bytes16 _contentHash, uint256 _amount) external onlyPublisher(_contentHash) {
        if(!_balances[_contentHash][_to].hasValue){
            balanceIndex[_to][balanceCount[_to]] = _contentHash;
            balanceCount[_to] = balanceCount[_to].add(1);
        }
        _balances[_contentHash][_to] = Balance(_balances[_contentHash][_to].balance.add(_amount), true);
        contents[_contentHash].totalSupply = contents[_contentHash].totalSupply.add(_amount); // count up total number of issuance of the content
    }
    /**
    * @dev get a balance of the specified content
    * @param _owner address content's owner
    * @param  _contentHash bytes16 unique id of the content (it can be IPFS hash)
    */
    function getBalanceOf(address _owner, bytes16 _contentHash) external view returns (uint256) {
        return _balances[_contentHash][_owner].balance;
    }

    /**
    * @dev Transfer a content ownership from one to another account
    * @param _to address address of an account who will obtain ownership of the content
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _amount uint256 the number of contents to transfer
    */
    function transfer(address _to, bytes16 _contentHash, uint256 _amount) external {
        _transfer(msg.sender, _to, _contentHash, _amount);
    }
    
    /**
    * @dev Approve contents transfer limiting to the amount to someone else
    * @param _to address address of an account who will be allowed to take ownership
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _amount uint256 the number of contents to be allowed
    */
    function approve(address _to, bytes16 _contentHash, uint256 _amount) external returns (bool) {
        require(_balances[_contentHash][msg.sender].balance.sub(allowanceTotal[_contentHash][msg.sender]).add(allowance[_contentHash][msg.sender][_to]) >= _amount);
        uint256 _allowance = allowance[_contentHash][msg.sender][_to];
        uint256 _allowedCount = allowedCount[msg.sender][_to];
        uint256 _allowanceCount = allowanceCount[_contentHash][msg.sender];
        if(allowance[_contentHash][msg.sender][_to] == 0) {
            allowedIndex[msg.sender][_to][_allowedCount] = _contentHash;
            allowedCount[msg.sender][_to] = _allowedCount.add(1);
            allowanceIndex[_contentHash][msg.sender][_allowanceCount] = _to;
            allowanceCount[_contentHash][msg.sender] = _allowanceCount.add(1);
        }
        allowance[_contentHash][msg.sender][_to] = _amount;
        allowanceTotal[_contentHash][msg.sender] = allowanceTotal[_contentHash][msg.sender].sub(_allowance).add(_amount);
        return true;
    }
    
    /**
    * @dev Transfer allowed amount of content ownership from one to another account
    * @param _from address address of an account who will transfer ownership from
    * @param _to address address of an account who will be allowed to take ownership
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _amount uint256 the number of contents to be transfer
    */
    function transferFrom(address _from, address _to, bytes16 _contentHash, uint256 _amount) external returns (bool) {
        require(msg.sender == _to);
        require(allowance[_contentHash][_from][_to] >= _amount);

        allowance[_contentHash][_from][_to] = allowance[_contentHash][_from][_to].sub(_amount);
        allowanceTotal[_contentHash][_from] = allowanceTotal[_contentHash][_from].sub(_amount);
        
        _transfer(_from, _to, _contentHash, _amount);
    }

    /**
    * @dev Transfer contents to a white-listed store
    * @param _from address address of an account who will transfer ownership from
    * @param _contentHash bytes16 unique id of the content (it can be IPFS hash)
    * @param _amount uint256 the number of contents to be transfer
    */
    function transferToStore(address _from, bytes16 _contentHash, uint256 _amount) external onlyStore returns (bool) {
        _transfer(_from, msg.sender, _contentHash, _amount);
    }

    function _transfer(address _from, address _to, bytes16 _contentHash, uint256 _amount) internal returns (bool) {
        require(_balances[_contentHash][_from].balance >= _amount);
        if(!_balances[_contentHash][_to].hasValue){
            balanceIndex[_to][balanceCount[_to]] = _contentHash;
            balanceCount[_to] = balanceCount[_to].add(1);
        }
        _balances[_contentHash][_from] = Balance(_balances[_contentHash][_from].balance.sub(_amount), true);
        _balances[_contentHash][_to] = Balance(_balances[_contentHash][_to].balance.add(_amount), true);
    }
    function destruct() public onlyOwner {
        selfdestruct(msg.sender);
    }
}
