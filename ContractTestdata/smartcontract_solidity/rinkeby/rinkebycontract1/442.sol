/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract FSUtils {
    
    function idToString(bytes32 id) internal pure returns (string memory) {
	bytes memory res = new bytes(64);
	for (uint i = 0; i < 64; i++) res[i] = bytes1(uint8(((uint(id) / (2**(4*i))) & 0xf) + 65));
	return string(res);
    }

    function makeMerkle(bytes memory arr, uint idx, uint level) internal pure returns (bytes32) {
	if (level == 0) return idx < arr.length ? bytes32(uint(uint8(arr[idx]))) : bytes32(0);
	else return keccak256(abi.encodePacked(makeMerkle(arr, idx, level-1), makeMerkle(arr, idx+(2**(level-1)), level-1)));
    }

    function calcMerkle(bytes32[] memory arr, uint idx, uint level) internal returns (bytes32) {
	if (level == 0) return idx < arr.length ? arr[idx] : bytes32(0);
	else return keccak256(abi.encodePacked(calcMerkle(arr, idx, level-1), calcMerkle(arr, idx+(2**(level-1)), level-1)));
    }

    // assume 256 bytes?
    function hashName(string memory name) public pure returns (bytes32) {
	return makeMerkle(bytes(name), 0, 8);
    }

    function getCodeAtAddress(address a) internal view returns (bytes memory) {
        uint len;
        assembly {
	len := extcodesize(a)
		}
        bytes memory bs = new bytes(len);
        assembly {
            extcodecopy(a, add(bs,32), 0, len)
		}
        return bs;
    }
        
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}













/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  mapping (address => bool) minters;

  modifier hasMintPermission() {
    require(minters[msg.sender]);
    _;
  }

  function addMinter(address a) public onlyOwner {
    minters[a] = true;
  }

  function removeMinter(address a) public onlyOwner {
    minters[a] = false;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}






/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}


contract TRU is MintableToken, BurnableToken {
    string public constant name = "TRU Token";
    string public constant symbol = "TRU";
    uint8 public constant decimals = 18;
/*
    event Burn(address indexed from, uint256 amount);
*/

    mapping (address => uint) test_tokens;

    bool faucetEnabled;

    function enableFaucet() public onlyOwner {
        faucetEnabled = true;
    }

    function disableFaucet() public onlyOwner {
        faucetEnabled = false;
    }

    function getTestTokens() public returns (bool) {
        require (faucetEnabled);
        if (test_tokens[msg.sender] != 0) return false;
        test_tokens[msg.sender] = block.number;
        balances[msg.sender] += 100000000000000000000000;
        totalSupply_ += 100000000000000000000000;
        return true;
    }

    function () external payable {
        revert("Contract has disabled receiving ether");
    }

}


interface IDisputeResolutionLayer {
    function status(bytes32 id) external view returns (uint8); //returns State enum
    function timeoutBlock(bytes32 id) external view returns (uint);
}


interface IGameMaker {    
    function make(bytes32 taskID, address solver, address verifier, bytes32 startStateHash, bytes32 endStateHash, uint256 size, uint timeout) external returns (bytes32);
}





contract RewardsManager {
    using SafeMath for uint;

    mapping(bytes32 => uint) public rewards;
    mapping(bytes32 => uint) public taxes;
    address public owner;
    TRU public token;

    event RewardDeposit(bytes32 indexed task, address who, uint amount, uint tax);
    event RewardClaimed(bytes32 indexed task, address who, uint amount, uint tax);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address payable _tru) public {
        owner = msg.sender;
        token = TRU(_tru);
    }

    function getTaskReward(bytes32 taskID) public view returns (uint) {
        return rewards[taskID];
    }

    function depositReward(bytes32 taskID, uint reward, uint tax) internal returns (bool) {
        // require(token.allowance(msg.sender, address(this)) >= reward + tax);
        // token.transferFrom(msg.sender, address(this), reward + tax);

        rewards[taskID] = rewards[taskID].add(reward);
        taxes[taskID] = rewards[taskID].add(tax);
        emit RewardDeposit(taskID, msg.sender, reward, tax);
        return true; 
    }

    function payReward(bytes32 taskID, address to) internal returns (bool) {
        require(rewards[taskID] > 0);
        uint payout = rewards[taskID];
        rewards[taskID] = 0;

        uint tax = taxes[taskID];
        taxes[taskID] = 0;
        // No minting, so just keep the tokens here
        // token.burn(tax); 

        token.transfer(to, payout);
        emit RewardClaimed(taskID, to, payout, tax);
        return true;
    }

    function getTax(bytes32 taskID) public view returns (uint) {
        return taxes[taskID];
    }

}





contract DepositsManager {
    using SafeMath for uint;

    mapping(address => uint) public deposits;
    address public owner;
    TRU public token;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

    // @dev â€“ the constructor
    constructor(address payable _tru) public {
        owner = msg.sender;
        token = TRU(_tru);
    }
    
    // @dev - fallback does nothing since we only accept TRU tokens
    function () external payable {
        revert();
    }

    // @dev â€“ returns an account's deposit
    // @param who â€“ the account's address.
    // @return â€“ the account's deposit.
    function getDeposit(address who) view public returns (uint) {
        return deposits[who];
    }

    // @dev - allows a user to deposit TRU tokens
    // @return - the uer's update deposit amount
    function makeDeposit(uint _deposit) public payable returns (uint) {
	require(_deposit > 0);
        require(token.allowance(msg.sender, address(this)) >= _deposit);
        token.transferFrom(msg.sender, address(this), _deposit);

        deposits[msg.sender] = deposits[msg.sender].add(_deposit);
        emit DepositMade(msg.sender, _deposit);
        return deposits[msg.sender];
    }

    // @dev - allows a user to withdraw TRU from their deposit
    // @param amount - how much TRU to withdraw
    // @return - the user's updated deposit
    function withdrawDeposit(uint amount) public returns (uint) {
        require(deposits[msg.sender] >= amount);
        
        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        token.transfer(msg.sender, amount);

        emit DepositWithdrawn(msg.sender, amount);
        return deposits[msg.sender];
    }

}



// import "./JackpotManager.sol";









interface Consumer {
   function consume(bytes32 id, bytes32[] calldata dta) external;
}

contract FileManager is FSUtils {

    bytes32[] zero;
    bytes32[] zero_files;

    bytes32 empty_file = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;    
    
    struct File {
	uint bytesize;
	bytes32[] data;
	string name;
     
	string ipfs_hash;
	address contractAddress;
	bytes32 root;
	bytes32 codeRoot;
	bool codeRootSet;
	uint fileType;// 0: eth_bytes, 1: contract, 2: ipfs
    }
    
    mapping (bytes32 => File) files;

    constructor() public {
	zero.length = 20;
	zero[0] = bytes32(0);
	zero_files.length = 20;
	zero_files[0] = empty_file;
	for (uint i = 1; i < zero.length; i++) {
	    zero[i] = keccak256(abi.encodePacked(zero[i-1], zero[i-1]));
	    zero_files[i] = keccak256(abi.encodePacked(zero_files[i-1], zero_files[i-1]));
	}
    }

    //Creates file out of bytes data
    function createFileWithContents(string memory name, uint nonce, bytes32[] memory arr, uint sz) public returns (bytes32) {
	bytes32 id = keccak256(abi.encodePacked(msg.sender, nonce));
	File storage f = files[id];
	require(files[id].root == 0);
	f.fileType = 0;
	f.data = arr;
	f.name = name;
	f.bytesize = sz;
	f.codeRootSet = false;
	uint size = 0;
	uint tmp = arr.length;
	while (tmp > 1) { size++; tmp = tmp/2; }
	f.root = fileMerkle(arr, 0, size);
	return id;
    }

    function addContractFile(string memory name, uint nonce, address _address, bytes32 root, uint size) public returns (bytes32) {
	bytes32 id = keccak256(abi.encodePacked(msg.sender, nonce));
	File storage f = files[id];
	require(files[id].root == 0);

	f.name = name;
	f.contractAddress = _address;
	f.bytesize = size;
	f.root = root;
	f.codeRootSet = false;
	f.fileType = 1;

	return id;
    }
   
    // the IPFS file should have same contents and name
    function addIPFSFile(string memory name, uint size, string memory hash, bytes32 root, uint nonce) public returns (bytes32) {
	bytes32 id = keccak256(abi.encodePacked(msg.sender, nonce));
	File storage f = files[id];
	require(files[id].root == 0);
	f.bytesize = size;
	f.name = name;
	f.ipfs_hash = hash;
	f.root = root;
	f.codeRootSet = false;
	f.fileType = 2;
	return id;
    }

    function addIPFSCodeFile(string memory name, uint size, string memory hash, bytes32 root, bytes32 codeRoot, uint nonce) public returns (bytes32) {
	bytes32 id = keccak256(abi.encodePacked(msg.sender, nonce));
	require(files[id].root == 0);
	File storage f = files[id];
	f.bytesize = size;
	f.name = name;
	f.ipfs_hash = hash;
	f.root = root;
	f.codeRoot = codeRoot;
	f.codeRootSet = true;
	f.fileType = 2;
	return id;
    }

    function getCode(bytes32 id) public view returns (bytes memory) {
        return getCodeAtAddress(files[id].contractAddress);
    }

    function getCodeAtAddress(address a) internal view returns (bytes memory) {
      uint len;
      assembly {
          len := extcodesize(a)
      }
      bytes memory bs = new bytes(len);
      assembly {
          extcodecopy(a, add(bs,32), 0, len)
      }
      return bs;
    }

    function getName(bytes32 id) public view returns (string memory) {
	return files[id].name;
    }

    function getFileType(bytes32 id) public view returns (uint) {
	return files[id].fileType;
    }
   
    function getNameHash(bytes32 id) public view returns (bytes32) {
	return hashName(files[id].name);
    }
   
    function getHash(bytes32 id) public view returns (string memory) {
	return files[id].ipfs_hash;
    }

    function getByteSize(bytes32 id) public view returns (uint) {
	return files[id].bytesize;
    }

    function setByteSize(bytes32 id, uint sz) public returns (uint) {
	files[id].bytesize = sz;
    }

    function setCodeRoot(bytes32 id, bytes32 codeRoot) public returns (uint) {
	require(!files[id].codeRootSet);
	files[id].codeRoot = codeRoot;
	files[id].codeRootSet = true;
    }    

    function getData(bytes32 id) public view returns (bytes32[] memory) {
	File storage f = files[id];
	return f.data;
    }
   
    function getByteData(bytes32 id) public view returns (bytes memory) {
	File storage f = files[id];
	bytes memory res = new bytes(f.bytesize);
	for (uint i = 0; i < f.data.length; i++) {
	    bytes32 w = f.data[i];
	    for (uint j = 0; j < 32; j++) {
		byte b = byte(uint8(uint(w) >> (8*j)));
		if (i*32 + j < res.length) res[i*32 + j] = b;
	    }
	}
	return res;
    }

    function forwardData(bytes32 id, address a) public {
	File storage f = files[id];
	Consumer(a).consume(id, f.data);
    }
   
    function getRoot(bytes32 id) public view returns (bytes32) {
	File storage f = files[id];
	return f.root;
    }
    
    function getLeaf(bytes32 id, uint loc) public view returns (bytes32) {
	File storage f = files[id];
	return f.data[loc];
    }

    // Merkle methods

    function makeMerkle(bytes memory arr, uint idx, uint level) internal pure returns (bytes32) {
	if (level == 0) return idx < arr.length ? bytes32(uint(uint8(arr[idx]))) : bytes32(0);
	else return keccak256(abi.encodePacked(makeMerkle(arr, idx, level-1), makeMerkle(arr, idx+(2**(level-1)), level-1)));
    }

    function calcMerkle(bytes32[] memory arr, uint idx, uint level) internal returns (bytes32) {
	if (level == 0) return idx < arr.length ? arr[idx] : bytes32(0);
	else if (idx >= arr.length) return zero[level];
	else return keccak256(abi.encodePacked(calcMerkle(arr, idx, level-1), calcMerkle(arr, idx+(2**(level-1)), level-1)));
    }

    function fileMerkle(bytes32[] memory arr, uint idx, uint level) internal returns (bytes32) {
//	if (level == 0) return idx < arr.length ? keccak256(abi.encodePacked(bytes16(arr[idx]), uint128(arr[idx]))) : keccak256(abi.encodePacked(bytes16(0), bytes16(0)));
	if (level == 0) return idx < arr.length ? keccak256(abi.encodePacked(arr[idx])) : keccak256(abi.encodePacked(bytes16(0), bytes16(0)));
	else return keccak256(abi.encodePacked(fileMerkle(arr, idx, level-1), fileMerkle(arr, idx+(2**(level-1)), level-1)));
    }

    function calcMerkleFiles(bytes32[] memory arr, uint idx, uint level) internal returns (bytes32) {
	if (level == 0) return idx < arr.length ? arr[idx] : empty_file;
	else if (idx >= arr.length) return zero_files[level];
	else return keccak256(abi.encodePacked(calcMerkleFiles(arr, idx, level-1), calcMerkleFiles(arr, idx+(2**(level-1)), level-1)));
    }

	struct Node {
		bytes32 left;
		bytes32 right;
	}

	mapping (bytes32 => Node) nodes;

	function makeZeroNodes() internal {
	    for (uint i = 0; i < zero.length - 1; i++) {
			nodes[zero[i+1]] = Node(zero[i], zero[i]);
		}
	}

	function setNode(bytes32 root, uint idx, uint depth, bytes32 value) public returns (bytes32) {
		if (depth == 0) {
			bytes32 id = keccak256(abi.encodePacked(value));
			nodes[id] = Node(value, 0);
			return id;
		}
		Node storage n = nodes[root];
		if (idx%2 == 0) {
			bytes32 l_id = setNode(n.left, idx/2, depth-1, value);
			bytes32 id = keccak256(abi.encodePacked(l_id, n.right));
			nodes[id] = Node(l_id, n.right);
			return id;
		}
		else {
			bytes32 l_id = setNode(n.right, idx/2, depth-1, value);
			bytes32 id = keccak256(abi.encodePacked(n.left, l_id));
			nodes[id] = Node(n.left, l_id);
			return id;
		}
	}

}


contract BundleManager is FileManager {

    // Methods to build IO blocks    
    struct Bundle {
	bytes32 name_file;
	bytes32 data_file;
	bytes32 size_file;
	uint pointer;
	bytes32 codeFileId;
	bytes32 init;
	bytes32[] files;
    }

    mapping (bytes32 => Bundle) bundles;

    function makeBundle(uint num) public view returns (bytes32) {
	bytes32 id = keccak256(abi.encodePacked(msg.sender, num));
	return id;
    }

    function addToBundle(bytes32 id, bytes32 file_id) public returns (bytes32) {
	Bundle storage b = bundles[id];
	b.files.push(file_id);
    }

    function finalizeBundle(bytes32 bundleID, bytes32 codeFileID) public returns (bytes32) {
	Bundle storage b = bundles[bundleID];
	File storage f = files[codeFileID];

	b.codeFileId = codeFileID;

	bytes32[] memory res1 = new bytes32[](b.files.length);
	bytes32[] memory res2 = new bytes32[](b.files.length);
	bytes32[] memory res3 = new bytes32[](b.files.length);
       
	for (uint i = 0; i < b.files.length; i++) {
	    res1[i] = bytes32(getByteSize(b.files[i]));
	    res2[i] = hashName(getName(b.files[i]));
	    res3[i] = getRoot(b.files[i]);
	}
       
	b.init = keccak256(abi.encodePacked(f.codeRoot, calcMerkle(res1, 0, 10), calcMerkle(res2, 0, 10), calcMerkleFiles(res3, 0, 10)));

	return b.init;

    }

    function debugFinalizeBundle(bytes32 bundleID, bytes32 codeFileID) public returns (bytes32, bytes32, bytes32, bytes32, bytes32) {
	Bundle storage b = bundles[bundleID];
	File storage f = files[codeFileID];

	bytes32[] memory res1 = new bytes32[](b.files.length);
	bytes32[] memory res2 = new bytes32[](b.files.length);
	bytes32[] memory res3 = new bytes32[](b.files.length);
       
	for (uint i = 0; i < b.files.length; i++) {
	    res1[i] = bytes32(getByteSize(b.files[i]));
	    res2[i] = hashName(getName(b.files[i]));
	    res3[i] = getRoot(b.files[i]);
	}

	return (f.codeRoot,
		calcMerkle(res1, 0, 10),
		calcMerkle(res2, 0, 10),
		calcMerkleFiles(res3, 0, 10),
		keccak256(abi.encodePacked(f.codeRoot, calcMerkle(res1, 0, 10), calcMerkle(res2, 0, 10), calcMerkleFiles(res3, 0, 10)))
		);
    }
       
    function getInitHash(bytes32 bid) public view returns (bytes32) {
	Bundle storage b = bundles[bid];
	return b.init;
    }

    function getCodeFileID(bytes32 bundleID) public view returns (bytes32) {
	Bundle storage b = bundles[bundleID];
	return b.codeFileId;
    }
      
    function getFiles(bytes32 bid) public view returns (bytes32[] memory) {
	Bundle storage b = bundles[bid];
	return b.files;
    }
    
}


/**
* @title Calculate a merkle tree for the filesystem in solidity
* @author Sami MÃ¤kelÃ¤
*/
contract Filesystem is BundleManager {
    constructor() public BundleManager() {}
    function calcId(uint nonce) public view returns (bytes32) {
	return keccak256(abi.encodePacked(msg.sender, nonce));
    }

}





contract ExchangeRateOracle is Ownable {
    uint public constant priceOfCyclemUSD = 1;
    uint public TRUperUSD;
    uint public priceOfCycleTRU;

    event ExchangeRateUpdate(uint indexed TRUperUSD, address owner);

    function updateExchangeRate (uint _TRUperUSD) public onlyOwner {
        require(_TRUperUSD!= 0);
        TRUperUSD = _TRUperUSD;
        priceOfCycleTRU = TRUperUSD * priceOfCyclemUSD / 1000;
        emit ExchangeRateUpdate(TRUperUSD, owner);
    }

    function getMinDeposit (uint taskDifficulty) public view returns (uint) {
        return taskDifficulty * priceOfCycleTRU + 1;
    }
}






interface Callback {
    function solved(bytes32 taskID, bytes32[] calldata files) external;
    function cancelled(bytes32 taskID) external;
}

contract IncentiveLayer is DepositsManager, RewardsManager {

    uint private numTasks = 0;
    uint private taxMultiplier = 5;

    uint constant BASIC_TIMEOUT = 5;
    uint constant IPFS_TIMEOUT = 5;
    uint constant RUN_RATE = 100000;
    uint constant INTERPRET_RATE = 100000;

    enum CodeType {
        WAST,
        WASM,
        INTERNAL
    }

    struct VMParameters {
        uint8 stackSize;
        uint8 memorySize;
        uint8 callSize;
        uint8 globalsSize;
        uint8 tableSize;
        uint32 gasLimit;
    }

    event DepositBonded(bytes32 taskID, address account, uint amount);
    event JackpotTriggered(bytes32 taskID);
    event DepositUnbonded(bytes32 taskID, address account, uint amount);
    event SlashedDeposit(bytes32 taskID, address account, address opponent, uint amount);
    event TaskCreated(bytes32 taskID, uint minDeposit, uint blockNumber, uint reward, uint tax, CodeType codeType, bytes32 bundleId);
    event SolverSelected(bytes32 indexed taskID, address solver, bytes32 taskData, uint minDeposit, bytes32 randomBitsHash);
    event SolutionsCommitted(bytes32 taskID, uint minDeposit, CodeType codeType, bytes32 bundleId, bytes32 solutionHash0);
    event SolutionRevealed(bytes32 taskID, uint randomBits);
    // event TaskStateChange(bytes32 taskID, uint state);
    event VerificationCommitted(bytes32 taskID, address verifier, uint jackpotID, bytes32 solution, uint index);
    event SolverDepositBurned(address solver, bytes32 taskID);
    event VerificationGame(address indexed solver, uint currentChallenger); 
    event PayReward(address indexed solver, uint reward);

    event EndRevealPeriod(bytes32 taskID);
    event EndChallengePeriod(bytes32 taskID);
    event TaskFinalized(bytes32 taskID);

    enum State { TaskInitialized, SolverSelected, SolutionCommitted, ChallengesAccepted, IntentsRevealed, SolutionRevealed, TaskFinalized, TaskTimeout }
    enum Status { Uninitialized, Challenged, Unresolved, SolverWon, ChallengerWon }//For dispute resolution
    
    struct RequiredFile {
        bytes32 nameHash;
        uint fileType;
        bytes32 fileId;
    }
    
    struct Task {
        address owner;
        address selectedSolver;
        uint minDeposit;
        uint reward;
        uint tax;
        bytes32 initTaskHash;
        mapping(address => bytes32) challenges;
        State state;
        bytes32 blockhash;
        bytes32 randomBitsHash;
        mapping(address => uint) bondedDeposits;
        uint randomBits;
        uint finalityCode; // 0 => not finalized, 1 => finalized, 2 => forced error occurred
        uint jackpotID;
        uint cost;
        CodeType codeType;
	bytes32 bundleId;
        
        bool requiredCommitted;
        RequiredFile[] uploads;
        
        // uint lastBlock; // Used to check timeout
        uint timeoutBlock;
        uint challengeTimeout;
    }

    struct Solution {
        bytes32 solutionCommit; // keccak256(solutionHash0)
        bytes32 solutionHash0;
        // bytes32 solutionHash1;
        // bool solution0Correct;
        address[] solution0Challengers;
        // address[] solution1Challengers;
        address[] allChallengers;
        address currentChallenger;
        bool solverConvicted;
        bytes32 currentGame;
        
        bytes32 dataHash;
        bytes32 sizeHash;
        bytes32 nameHash;
    }

    mapping(bytes32 => Task) private tasks;
    mapping(bytes32 => Solution) private solutions;
    mapping(bytes32 => VMParameters) private vmParams;
    mapping (bytes32 => uint) challenges;    

    ExchangeRateOracle oracle;
    address disputeResolutionLayer; //using address type because in some cases it is IGameMaker, and others IDisputeResolutionLayer
    Filesystem fs;
    TRU tru;

    constructor (address payable _TRU, address _exchangeRateOracle, address _disputeResolutionLayer, address fs_addr) 
        DepositsManager(_TRU)
        RewardsManager(_TRU)
        public 
    {
        disputeResolutionLayer = _disputeResolutionLayer;
        oracle = ExchangeRateOracle(_exchangeRateOracle);
        fs = Filesystem(fs_addr);
        tru = TRU(_TRU);
    }

    function getBalance(address addr) public view returns (uint) {
        return tru.balanceOf(addr);
    }

    // @dev â€“ locks up part of the a user's deposit into a task.
    // @param taskID â€“ the task id.
    // @param account â€“ the user's address.
    // @param amount â€“ the amount of deposit to lock up.
    // @return â€“ the user's deposit bonded for the task.
    function bondDeposit(bytes32 taskID, address account, uint amount) private returns (uint) {
        Task storage task = tasks[taskID];
        require(deposits[account] >= amount);
        deposits[account] = deposits[account].sub(amount);
        task.bondedDeposits[account] = task.bondedDeposits[account].add(amount);
        emit DepositBonded(taskID, account, amount);
        return task.bondedDeposits[account];
    }

    function getJackpotReceivers(bytes32 taskID) public view returns (address[] memory) {
        Solution storage s = solutions[taskID];
        return s.allChallengers;
    }

    event ReceivedJackpot(address receiver, uint amount);

    function receiveJackpotPayment(bytes32 taskID, uint index) public {
        Solution storage s = solutions[taskID];
        Task storage t = tasks[taskID];
        require(s.allChallengers[index] == msg.sender);
        s.allChallengers[index] = address(0);

        //transfer jackpot payment	
        uint amount = t.tax.div(s.allChallengers.length);
        token.transfer(msg.sender, amount);
	
        emit ReceivedJackpot(msg.sender, amount);
    }

    // @dev â€“ unlocks a user's bonded deposits from a task.
    // @param taskID â€“ the task id.
    // @param account â€“ the user's address.
    // @return â€“ the user's deposit which was unbonded from the task.
    function unbondDeposit(bytes32 taskID) public returns (uint) {
        Task storage task = tasks[taskID];
        require(task.state == State.TaskFinalized || task.state == State.TaskTimeout);
        uint bondedDeposit = task.bondedDeposits[msg.sender];
        delete task.bondedDeposits[msg.sender];
        deposits[msg.sender] = deposits[msg.sender].add(bondedDeposit);
        emit DepositUnbonded(taskID, msg.sender, bondedDeposit);
        
        return bondedDeposit;
    }

    // @dev â€“ punishes a user by moving their bonded deposits for a task into the jackpot.
    // @param taskID â€“ the task id.
    // @param account â€“ the user's address.
    // @return â€“ the updated jackpot amount.
    function slashDeposit(bytes32 taskID, address account, address opponent) private returns (uint) {
        Task storage task = tasks[taskID];
        uint bondedDeposit = task.bondedDeposits[account];
        uint toOpponent = bondedDeposit/10;

        emit SlashedDeposit(taskID, account, opponent, bondedDeposit);
        if (bondedDeposit == 0) return 0;

        delete task.bondedDeposits[account];
        if (bondedDeposit > toOpponent + task.cost*2) {
            // BaseJackpotManager(jackpotManager).increaseJackpot(bondedDeposit - toOpponent - task.cost*2);
            deposits[task.owner] += task.cost*2;
        }
        deposits[opponent] += toOpponent;
        return bondedDeposit;
    }

    // @dev â€“ returns the user's bonded deposits for a task.
    // @param taskID â€“ the task id.
    // @param account â€“ the user's address.
    // @return â€“ the user's bonded deposits for a task.
    function getBondedDeposit(bytes32 taskID, address account) view public returns (uint) {
        return tasks[taskID].bondedDeposits[account];
    }

    function defaultParameters(bytes32 taskID) internal {
        VMParameters storage params = vmParams[taskID];
        params.stackSize = 14;
        params.memorySize = 16;
        params.globalsSize = 8;
        params.tableSize = 8;
        params.callSize = 10;
        params.gasLimit = 0;
    }

    // @dev â€“ taskGiver creates tasks to be solved.
    // @param minDeposit â€“ the minimum deposit required for engaging with a task as a solver or verifier.
    // @param reward - the payout given to solver
    // @param taskData â€“ tbd. could be hash of the wasm file on a filesystem.
    // @param numBlocks â€“ the number of blocks to adjust for task difficulty
    // @return â€“ boolean
    function createTaskAux(bytes32 initTaskHash, CodeType codeType, bytes32 bundleId, uint maxDifficulty, uint reward) internal returns (bytes32) {
        // Get minDeposit required by task
	require(maxDifficulty > 0);
        uint minDeposit = oracle.getMinDeposit(maxDifficulty);
        require(minDeposit > 0);
	require(reward > 0);
        
        bytes32 id = keccak256(abi.encodePacked(initTaskHash, codeType, bundleId, maxDifficulty, reward, numTasks));
        numTasks.add(1);

        Task storage t = tasks[id];
        t.owner = msg.sender;
        t.minDeposit = minDeposit;
        t.reward = reward;

        t.tax = minDeposit * taxMultiplier;
        t.cost = reward + t.tax;
        
        require(deposits[msg.sender] >= reward + t.tax);
        deposits[msg.sender] = deposits[msg.sender].sub(reward + t.tax);
    
        depositReward(id, reward, t.tax);
        // BaseJackpotManager(jackpotManager).increaseJackpot(t.tax);
        
        t.initTaskHash = initTaskHash;
        t.codeType = codeType;
	t.bundleId = bundleId;
	
        t.timeoutBlock = block.number + IPFS_TIMEOUT + BASIC_TIMEOUT;
        return id;
    }

    // @dev â€“ taskGiver creates tasks to be solved.
    // @param minDeposit â€“ the minimum deposit required for engaging with a task as a solver or verifier.
    // @param reward - the payout given to solver
    // @param taskData â€“ tbd. could be hash of the wasm file on a filesystem.
    // @param numBlocks â€“ the number of blocks to adjust for task difficulty
    // @return â€“ boolean
    function createTask(bytes32 initTaskHash, CodeType codeType, bytes32 bundleId, uint maxDifficulty, uint reward) public returns (bytes32) {
        bytes32 id = createTaskAux(initTaskHash, codeType, bundleId, maxDifficulty, reward);
        defaultParameters(id);
	commitRequiredFiles(id);
        
        return id;
    }

    function createTaskWithParams(bytes32 initTaskHash, CodeType codeType, bytes32 bundleId, uint maxDifficulty, uint reward, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call, uint32 limit) public returns (bytes32) {
        bytes32 id = createTaskAux(initTaskHash, codeType, bundleId, maxDifficulty, reward);
        VMParameters storage param = vmParams[id];
        require(stack > 5 && mem > 5 && globals > 5 && table > 5 && call > 5);
        require(stack < 30 && mem < 30 && globals < 30 && table < 30 && call < 30);
        param.stackSize = stack;
        param.memorySize = mem;
        param.globalsSize = globals;
        param.tableSize = table;
        param.callSize = call;
        param.gasLimit = limit;
        
        return id;
    }

    function requireFile(bytes32 id, bytes32 hash, uint fileType) public {
        Task storage t = tasks[id];
        require (!t.requiredCommitted && msg.sender == t.owner);
        t.uploads.push(RequiredFile(hash, fileType, 0));
    }
    
    function commitRequiredFiles(bytes32 id) public {
        Task storage t = tasks[id];
        require (msg.sender == t.owner);
        t.requiredCommitted = true;
        emit TaskCreated(id, t.minDeposit, t.timeoutBlock, t.reward, t.tax, t.codeType, t.bundleId);
    }
    
    function getUploadNames(bytes32 id) public view returns (bytes32[] memory) {
        RequiredFile[] storage lst = tasks[id].uploads;
        bytes32[] memory arr = new bytes32[](lst.length);
        for (uint i = 0; i < arr.length; i++) arr[i] = lst[i].nameHash;
        return arr;
    }

    function getUploadTypes(bytes32 id) public view returns (uint[] memory) {
        RequiredFile[] storage lst = tasks[id].uploads;
        uint[] memory arr = new uint[](lst.length);
        for (uint i = 0; i < arr.length; i++) arr[i] = lst[i].fileType;
        return arr;
    }
    
    // @dev â€“ solver registers for tasks, if first to register than automatically selected solver
    // 0 -> 1
    // @param taskID â€“ the task id.
    // @param randomBitsHash â€“ hash of random bits to commit to task
    // @return â€“ boolean
    function registerForTask(bytes32 taskID, bytes32 randomBitsHash) public returns(bool) {
        Task storage t = tasks[taskID];
        VMParameters storage vm = vmParams[taskID];

        require(!(t.owner == address(0x0)));
        require(t.state == State.TaskInitialized);
        require(t.selectedSolver == address(0x0));
        
        bondDeposit(taskID, msg.sender, t.minDeposit);
        t.selectedSolver = msg.sender;
        t.randomBitsHash = randomBitsHash;
        t.state = State.SolverSelected;
        t.timeoutBlock = block.number + (1+vm.gasLimit/RUN_RATE);

        // Burn task giver's taxes now that someone has claimed the task
        /*
        deposits[t.owner] = deposits[t.owner].sub(t.tax);
        token.burn(t.tax);
        */

        emit SolverSelected(taskID, msg.sender, t.initTaskHash, t.minDeposit, t.randomBitsHash);
        return true;
    }

    // @dev â€“ selected solver submits a solution to the exchange
    // 1 -> 2
    // @param taskID â€“ the task id.
    // @param solutionHash0 â€“ the hash of the solution (could be true or false solution)
    // @param solutionHash1 â€“ the hash of the solution (could be true or false solution)
    // @return â€“ boolean
    function commitSolution(bytes32 taskID, bytes32 solutionHash0) public returns (bool) {
        Task storage t = tasks[taskID];
        require(t.selectedSolver == msg.sender);
        require(t.state == State.SolverSelected);
        // require(block.number < t.taskCreationBlockNumber.add(TIMEOUT));
        Solution storage s = solutions[taskID];
        s.solutionCommit = solutionHash0;
        // s.solutionHash1 = solutionHash1;
        s.solverConvicted = false;
        t.state = State.SolutionCommitted;
        VMParameters storage vm = vmParams[taskID];
        t.timeoutBlock = block.number + BASIC_TIMEOUT + IPFS_TIMEOUT + (1+vm.gasLimit/RUN_RATE);
        t.challengeTimeout = t.timeoutBlock; // End of challenge period
        emit SolutionsCommitted(taskID, t.minDeposit, t.codeType, t.bundleId, solutionHash0);
        return true;
    }

    // @dev â€“ selected solver revealed his random bits prematurely
    // @param taskID â€“ The task id.
    // @param randomBits â€“ bits whose hash is the commited randomBitsHash of this task
    // @return â€“ boolean
    function prematureReveal(bytes32 taskID, uint originalRandomBits) public returns (bool) {
        Task storage t = tasks[taskID];
        require(t.state == State.SolverSelected);
        // require(block.number < t.taskCreationBlockNumber.add(TIMEOUT));
        require(t.randomBitsHash == keccak256(abi.encodePacked(originalRandomBits)));

        slashDeposit(taskID, t.selectedSolver, msg.sender);
        
        // Reset task data to selected another solver
        /*
        t.state = State.TaskInitialized;
        t.selectedSolver = address(0x0);
        t.timeoutBlock = block.number;
        emit TaskCreated(taskID, t.minDeposit, t.lastBlock, t.reward, 1, t.codeType, t.storageType, t.storageAddress);
        */

        cancelTask(taskID);

        return true;
    }        

    function cancelTask(bytes32 taskID) internal {
        Task storage t = tasks[taskID];
        t.state = State.TaskTimeout;
        delete t.selectedSolver;
        bool ok;
        bytes memory res;
        (ok, res) = t.owner.call(abi.encodeWithSignature("cancel(bytes32)", taskID));
    }

    function taskTimeout(bytes32 taskID) public {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        uint g_timeout = IDisputeResolutionLayer(disputeResolutionLayer).timeoutBlock(s.currentGame);
        require(block.number > g_timeout);
        require(block.number > t.timeoutBlock + BASIC_TIMEOUT);
        require(t.state != State.TaskTimeout);
        require(t.state != State.TaskFinalized);
        slashDeposit(taskID, t.selectedSolver, s.currentChallenger);
        cancelTask(taskID);
    }

    function isTaskTimeout(bytes32 taskID) public view returns (bool) {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        uint g_timeout = IDisputeResolutionLayer(disputeResolutionLayer).timeoutBlock(s.currentGame);
        if (block.number <= g_timeout) return false;
        if (t.state == State.TaskTimeout) return false;
        if (t.state == State.TaskFinalized) return false;
        if (block.number <= t.timeoutBlock + BASIC_TIMEOUT) return false;
        return true;
    }

    function solverLoses(bytes32 taskID) public returns (bool) {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        if (IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.ChallengerWon)) {
            slashDeposit(taskID, t.selectedSolver, s.currentChallenger);
            cancelTask(taskID);
            return s.currentChallenger == msg.sender;
        }
        return false;
    }

    // @dev â€“ verifier submits a challenge to the solution provided for a task
    // verifiers can call this until task giver changes state or timeout
    // @param taskID â€“ the task id.
    // @param intentHash â€“ submit hash of even or odd number to designate which solution is correct/incorrect.
    // @return â€“ boolean
    function commitChallenge(bytes32 hash) public returns (bool) {
        require(challenges[hash] == 0);
        challenges[hash] = block.number;
        return true;
    }

    function endChallengePeriod(bytes32 taskID) public returns (bool) {
        Task storage t = tasks[taskID];
        if (t.state != State.SolutionCommitted || !(t.challengeTimeout < block.number)) return false;
        
        t.state = State.ChallengesAccepted;
        emit EndChallengePeriod(taskID);
        t.timeoutBlock = block.number + BASIC_TIMEOUT;
        t.blockhash = blockhash(block.number-1);

        return true;
    }

    function endRevealPeriod(bytes32 taskID) public returns (bool) {
        Task storage t = tasks[taskID];
        if (t.state != State.ChallengesAccepted || !(t.timeoutBlock < block.number)) return false;
        
        t.state = State.IntentsRevealed;
        emit EndRevealPeriod(taskID);
        t.timeoutBlock = block.number + BASIC_TIMEOUT;

        return true;
    }

    // @dev â€“ verifiers can call this until task giver changes state or timeout
    // @param taskID â€“ the task id.
    // @param intent â€“ submit 0 to challenge solution0, 1 to challenge solution1, anything else challenges both
    // @return â€“ boolean
    function revealIntent(bytes32 taskID, bytes32 solution0) public returns (bool) {
        uint cblock = challenges[keccak256(abi.encodePacked(taskID, msg.sender, solution0))];
        Task storage t = tasks[taskID];
        require(t.state == State.ChallengesAccepted);
        require(t.challengeTimeout > cblock);
        require(cblock != 0);
        bondDeposit(taskID, msg.sender, t.minDeposit);
        if (keccak256(abi.encodePacked(solution0)) != solutions[taskID].solutionCommit) { // Intent determines which solution the verifier is betting is deemed incorrect
            solutions[taskID].solution0Challengers.push(msg.sender);
        }
        uint position = solutions[taskID].allChallengers.length;
        solutions[taskID].allChallengers.push(msg.sender);

        delete tasks[taskID].challenges[msg.sender];
        emit VerificationCommitted(taskID, msg.sender, tasks[taskID].jackpotID, solution0, position);
        return true;
    }

    // @dev â€“ solver reveals which solution they say is the correct one
    // 4 -> 5
    // @param taskID â€“ the task id.
    // @param solution0Correct â€“ determines if solution0Hash is the correct solution
    // @param originalRandomBits â€“ original random bits for sake of commitment.
    // @return â€“ boolean
    function revealSolution(bytes32 taskID, uint originalRandomBits, bytes32 codeHash, bytes32 sizeHash, bytes32 nameHash, bytes32 dataHash) public {
        Task storage t = tasks[taskID];
        require(t.randomBitsHash == keccak256(abi.encodePacked(originalRandomBits)));
        require(t.state == State.IntentsRevealed);
        require(t.selectedSolver == msg.sender);
        
        Solution storage s = solutions[taskID];

        s.nameHash = nameHash;
        s.sizeHash = sizeHash;
        s.dataHash = dataHash;

        s.solutionHash0 = keccak256(abi.encodePacked(codeHash, sizeHash, nameHash, dataHash));

        require(keccak256(abi.encodePacked(s.solutionHash0)) == s.solutionCommit);

        rewardJackpot(taskID);

        t.state = State.SolutionRevealed;
        t.randomBits = originalRandomBits;
        emit SolutionRevealed(taskID, originalRandomBits);
        t.timeoutBlock = block.number;
    }


    function rewardJackpot(bytes32 taskID) internal {
        // Task storage t = tasks[taskID];
        // Solution storage s = solutions[taskID];
        // t.jackpotID = BaseJackpotManager(jackpotManager).setJackpotReceivers(s.allChallengers);
        emit JackpotTriggered(taskID);

        // payReward(taskID, t.owner);//Still compensating solver even though solution wasn't thoroughly verified, task giver recommended to not use solution
    }

    // verifier should be responsible for calling this first
    function canRunVerificationGame(bytes32 taskID) public view returns (bool) {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        if (t.state != State.SolutionRevealed) return false;
        if (s.solution0Challengers.length == 0) return false;
        return (s.currentGame == 0 || IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon));
    }
    
    function runVerificationGame(bytes32 taskID) public {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        
        require(t.state == State.SolutionRevealed);
        require(s.currentGame == 0 || IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon));

        if (IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon)) {
            slashDeposit(taskID, s.currentChallenger, t.selectedSolver);
        }
        
        if (s.solution0Challengers.length > 0) {
            s.currentChallenger = s.solution0Challengers[s.solution0Challengers.length-1];
            verificationGame(taskID, t.selectedSolver, s.currentChallenger, s.solutionHash0);
            s.solution0Challengers.length -= 1;
        }
        // emit VerificationGame(t.selectedSolver, s.currentChallenger);
        t.timeoutBlock = block.number;
    }

    function verificationGame(bytes32 taskID, address solver, address challenger, bytes32 solutionHash) internal {
        Task storage t = tasks[taskID];
        VMParameters storage params = vmParams[taskID];
        uint size = 1;
        uint timeout = BASIC_TIMEOUT+(1+params.gasLimit/INTERPRET_RATE);
        bytes32 gameID = IGameMaker(disputeResolutionLayer).make(taskID, solver, challenger, t.initTaskHash, solutionHash, size, timeout);
        solutions[taskID].currentGame = gameID;
    }
    
    function uploadFile(bytes32 id, uint num, bytes32 file_id, bytes32[] memory name_proof, bytes32[] memory data_proof, uint file_num) public returns (bool) {
        Task storage t = tasks[id];
        Solution storage s = solutions[id];
        RequiredFile storage file = t.uploads[num];
        require(checkProof(fs.getRoot(file_id), s.dataHash, data_proof, file_num));
        require(checkProof(fs.getNameHash(file_id), s.nameHash, name_proof, file_num));
        
        file.fileId = file_id;
        return true;
    }
    
    function getLeaf(bytes32[] memory proof, uint loc) internal pure returns (uint) {
        require(proof.length >= 2);
        if (loc%2 == 0) return uint(proof[0]);
        else return uint(proof[1]);
    }
    
    function getRoot(bytes32[] memory proof, uint loc) internal pure returns (bytes32) {
        require(proof.length >= 2);
        bytes32 res = keccak256(abi.encodePacked(proof[0], proof[1]));
        for (uint i = 2; i < proof.length; i++) {
            loc = loc/2;
            if (loc%2 == 0) res = keccak256(abi.encodePacked(res, proof[i]));
            else res = keccak256(abi.encodePacked(proof[i], res));
        }
        require(loc < 2); // This should be runtime error, access over bounds
        return res;
    }
    
    function checkProof(bytes32 hash, bytes32 root, bytes32[] memory proof, uint loc) internal pure returns (bool) {
        return uint(hash) == getLeaf(proof, loc) && root == getRoot(proof, loc);
    }

    function finalizeTask(bytes32 taskID) public {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];

        require(t.state == State.SolutionRevealed);
        require(s.solution0Challengers.length == 0 && (s.currentGame == 0 || IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon)));

        if (IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon)) {
            slashDeposit(taskID, s.currentChallenger, t.selectedSolver);
        }

        bytes32[] memory files = new bytes32[](t.uploads.length);
        for (uint i = 0; i < t.uploads.length; i++) {
            require(t.uploads[i].fileId != 0);
            files[i] = t.uploads[i].fileId;
        }

        t.state = State.TaskFinalized;
        t.finalityCode = 1; // Task has been completed

        payReward(taskID, t.selectedSolver);
        bool ok;
        bytes memory res;
        (ok, res) = t.owner.call(abi.encodeWithSignature("solved(bytes32,bytes32[])", taskID, files));
        emit TaskFinalized(taskID);
        // Callback(t.owner).solved(taskID, files);
    }
    
    function isFinalized(bytes32 taskID) public view returns (bool) {
        Task storage t = tasks[taskID];
        return (t.state == State.TaskFinalized);
    }
    
    function canFinalizeTask(bytes32 taskID) public view returns (bool) {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        
        if (t.state != State.SolutionRevealed) return false;

        if (!(s.solution0Challengers.length == 0 && (s.currentGame == 0 || IDisputeResolutionLayer(disputeResolutionLayer).status(s.currentGame) == uint(Status.SolverWon)))) return false;

        for (uint i = 0; i < t.uploads.length; i++) {
           if (t.uploads[i].fileId == 0) return false;
        }
        
        return true;
    }

    function getTaskFinality(bytes32 taskID) public view returns (uint) {
        return tasks[taskID].finalityCode;
    }

    function getVMParameters(bytes32 taskID) public view returns (uint8, uint8, uint8, uint8, uint8, uint32) {
        VMParameters storage params = vmParams[taskID];
        return (params.stackSize, params.memorySize, params.globalsSize, params.tableSize, params.callSize, params.gasLimit);
    }

    function getTaskInfo(bytes32 taskID) public view returns (address, bytes32, CodeType, bytes32, bytes32) {
	Task storage t = tasks[taskID];
        return (t.owner, t.initTaskHash, t.codeType, t.bundleId, taskID);
    }

    function getSolutionInfo(bytes32 taskID) public view returns(bytes32, bytes32, bytes32, bytes32, CodeType, bytes32, address) {
        Task storage t = tasks[taskID];
        Solution storage s = solutions[taskID];
        return (taskID, s.solutionHash0, s.solutionCommit, t.initTaskHash, t.codeType, t.bundleId, t.selectedSolver);
    }

}
