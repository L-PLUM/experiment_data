/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity 0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
	constructor (address owner) internal {
		_owner = owner;
		emit OwnershipTransferred(address(0), _owner);
	}

	/**
	 * @return the address of the owner.
	 */
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(isOwner());
		_;
	}

	/**
	 * @return true if `msg.sender` is the owner of the contract.
	 */
	function isOwner() public view returns (bool) {
		return msg.sender == _owner;
	}

	/**
	 * @dev Allows the current owner to relinquish control of the contract.
	 * @notice Renouncing to ownership will leave the contract without an owner.
	 * It will not be possible to call the functions with the `onlyOwner`
	 * modifier anymore.
	 */
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Allows the current owner to transfer control of the contract to a newOwner.
	 * @param newOwner The address to transfer ownership to.
	 */
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	 * @dev Transfers control of the contract to a newOwner.
	 * @param newOwner The address to transfer ownership to.
	 */
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0));
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

/**
 * @title IContractStorage
 * @dev Interface for interacting with ContractStorage contract
 */
interface IContractStorage {
	function getBool(bytes32 _key) external view returns (bool);
	function getAddress(bytes32 _key) external view returns (address);
	function getUint(bytes32 _key) external view returns (uint256);

	function setBool(bytes32 _key, bool val) external;
	function setAddress(bytes32 _key, address val) external;
	function setUint(bytes32 _key, uint256 val) external;

	function delBool(bytes32 _key) external;
	function delAddress(bytes32 _key) external;
	function delUint(bytes32 _key) external;

	function pushAddress(bytes32 key, address val) external returns (uint256);
	function getAddressTable(bytes32 key) external view returns (address[] memory);
	function getAddressFromTable(bytes32 key, uint256 index) external view returns (address);
	function setAddressInTable(bytes32 key, uint256 index, address val) external;
	function getAddressTableLength(bytes32 key) external view returns (uint256);
	function delLastAddressInTable(bytes32 key) external returns (uint256);

	function key(string calldata name) external view returns (bytes32);
	function key(uint256 index,string calldata name) external view returns (bytes32);
	function key(address adr,string calldata name) external view returns (bytes32);

	function registerName(string calldata name) external;
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
	function transfer(address to, uint256 value) external returns (bool);

	function approve(address spender, uint256 value) external returns (bool);

	function transferFrom(address from, address to, uint256 value) external returns (bool);

	function totalSupply() external view returns (uint256);

	function balanceOf(address who) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ITuneTraderExchange
 */
interface ITuneTraderExchange {
	function terminatePosition(bool closedOrCancelled) external;
}

/**
 * @title TTPositionManager
 */
contract TTPositionManager {
	uint256 public cost;
	uint256 public volume;
	uint256 public created;

	enum Position { Buy, Sell }
	Position public position;

	IERC20 public token;

	address payable owner;
	address public tokenExchange;
	address public tokenReceiver;

	event PositionClosed();
	event PositionCancelled();
	event ReceivedPayment(uint256 weiAmount, address from);
	event ReceivedTokens(uint256 tokenAmount, address tokenOwner, address from);

	/**
	 * @dev TTPositionManager Constructor
	 */
	constructor (address _token, uint256 _volume, bool _isBuyPosition, uint256 _cost, address payable _owner) public payable {
		require(_isBuyPosition == false || msg.value == _cost, "TTPositionManager: the buying positions must include some ETH in the msg");

		owner = _owner;
		token = IERC20(_token);
		volume = _volume;
		position = _isBuyPosition ? Position.Buy : Position.Sell;
		cost = _cost;
		created = block.timestamp;
		tokenExchange = msg.sender;
	}

	// -----------------------------------------
	// SETTERS
	// -----------------------------------------

	function buyTokens() external payable {
		require(position == Position.Sell, "buyTokens: you can buy tokens only from selling positions");
		require(token.balanceOf(address(this)) == volume, "buyTokens: tokens must be already transfered");
		require(msg.value == cost, "buyTokens: you must send exact amount of ETH to buy tokens");

		token.transfer(msg.sender, volume);
		owner.transfer(msg.value);

		emit ReceivedPayment(msg.value, msg.sender);
		emit PositionClosed();

		_removeFromExchange();
	}

	function tokenFallback(address payable _tokenSender, uint256 _value) external {
		require(msg.sender == address(token), "tokenFallback: tokens can be accepted only from designated token contract");

		uint256 balance = token.balanceOf(address(this));
		require(balance == volume, "tokenFallback: contract only accepts exact token amount equal to volume");

		if (position == Position.Buy) {
			require(address(this).balance == cost, "tokenFallback: ETH to buy tokens must be already transfered to the contract");

			// transfering the funds to the seller and to the buyer
			token.transfer(owner, volume);
			_tokenSender.transfer(cost);

			emit PositionClosed();
			emit ReceivedTokens(balance, _tokenSender, msg.sender);

			_removeFromExchange();
		} else {
			emit ReceivedTokens(balance, _tokenSender, msg.sender);
		}
	}

	function cancelPosition() external {
		require(msg.sender == owner, "cancelPosition: only the owner can call this method");

		uint256 balance = token.balanceOf(address(this));
		if (position == Position.Buy) {
			//buyig position. we have to send ETHEREUM back to the owner.
			//the question is what to do when by any chance there are tokens from token contract on this position.
			// We send it to Token Exchange Contract for manual action to be taken.
			if (balance > 0) {
				token.transfer(tokenExchange, balance);
			}
		} else {
			//this is the "Sell" position, sending back all tokens to the owner.
			token.transfer(owner, balance);
		}

		ITuneTraderExchange(tokenExchange).terminatePosition(false);

		emit PositionCancelled();

		selfdestruct(owner);
	}

	// -----------------------------------------
	// INTERNAL
	// -----------------------------------------

	function _removeFromExchange() private {
		ITuneTraderExchange(tokenExchange).terminatePosition(true);
		selfdestruct(owner);
	}

	// -----------------------------------------
	// GETTERS
	// -----------------------------------------

	function getPositionData() external view returns (
		address _token,
		uint256 _volume,
		bool _buyPosition,
		uint256 _created,
		uint256 _cost,
		address payable _customer,
		address _managerAddress,
		bool _active,
		uint256 _tokenBalance,
		uint256 _weiBalance
	) {
		bool active;
		uint256 weiBalance = address(this).balance;
		uint256 tokenBalance = token.balanceOf(address(this));

		if (position == Position.Buy) {
			// this a position when somebody wants to buy tokens. They have to send ETH to make it happen.
			active = weiBalance >= cost ? true : false;
		} else {
			// this is a position when somebody wants to sell tokens.
			active = tokenBalance >= volume ? true : false;
		}

		return (
			address(token),
			volume,
			position == Position.Buy,
			created,
			cost,
			owner,
			address(this),
			active,
			tokenBalance,
			weiBalance
		);
	}
}

/**
 * @title TuneTraderExchange
 */
contract TuneTraderExchange is Ownable {
	// for creating an position user need to pay a fee
    uint256 public fee;

	// the admin can change fee after 30 days after the last change date
    uint256 public lastFeeChangedAt;
    uint256 private constant delayForChangeFee = 30 days;

	// the admin can disable fees for creating token and ico
	bool public feeEnabled;

	// the address of created positions
	address[] public positionsAddresses;

	mapping (address => bool) public positionExist;
	mapping (address => uint256) public positionIndex;

	IContractStorage public DS;

	event ReceivedTokens(uint256 volume, address tokenSender, address tokenAddress);
	event NewPosition(address token, uint256 volume, bool buySell, uint256 cost, address owner);
	event PositionClosed(address indexed position);
	event PositionCancelled(address indexed position);

	/**
	 * @dev TuneTraderExchange Constructor
	 */
	constructor (IContractStorage _storage, uint256 _fee) public Ownable(msg.sender) {
		require(_fee != 0, "TuneTraderExchange: the fee should be bigger then 0");

		fee = _fee;
		feeEnabled = true;

		DS = _storage;
		DS.registerName("positions");
		DS.registerName("positionExist");
		DS.registerName("positionIndex");
	}

	// -----------------------------------------
	// SETTERS
	// -----------------------------------------

	function addPosition(address token, uint256 volume, bool isBuyPosition, uint256 cost) public payable {
		// if the feeEnabled is disabled we gonna use 0 fee for calculation
		uint256 _fee = feeEnabled ? fee : 0;

		if (isBuyPosition == false) {
			require(msg.value == _fee, "addPosition: for creationg a positions user must pay a fee");
		} else {
			require(msg.value == cost + _fee, "addPosition: the buying positions must include some ETH in the msg plus fee");
		}

		address manager = address((new TTPositionManager).value(msg.value - _fee)(token, volume, isBuyPosition, cost, msg.sender));
		uint256 index = DS.pushAddress(DS.key("positions"), manager);
		DS.setBool(DS.key(manager, "positionExist"), true);
		DS.setUint(DS.key(manager, "positionIndex"), index);

		emit NewPosition(token, volume, isBuyPosition, cost, msg.sender);
	}

	function terminatePosition(bool closedOrCancelled) external {
		require((DS.getBool(DS.key(msg.sender, "positionExist")) == true), "terminatePosition: Position must exist on the list");

		uint256 index = DS.getUint(DS.key(msg.sender, "positionIndex"));
		uint256 maxIndex = getPositionsCount() - 1;

		if (index < maxIndex) {
			address miAddr = DS.getAddressFromTable(DS.key("positions"), maxIndex);
			DS.setUint(DS.key(miAddr, "positionIndex"), index);
			DS.setAddressInTable(DS.key("positions"), index, miAddr);
		}

		DS.delLastAddressInTable(DS.key("positions"));
		DS.delUint(DS.key(msg.sender, "positionIndex"));
		DS.delBool(DS.key(msg.sender, "positionExist"));

		if (closedOrCancelled == true) {
			emit PositionClosed(msg.sender);
		} else {
			emit PositionCancelled(msg.sender);
		}
	}

    function withdrawEth(uint256 weiAmount, address payable receiver) external onlyOwner {
        receiver.transfer(weiAmount);
    }

	function changeFee(uint256 _newFee) external onlyOwner {
        require(block.timestamp >= lastFeeChangedAt + delayForChangeFee, "changeFee: the owner can't change the fee now");
        require(_validateFeeChanging(fee, _newFee), "changeFee: the new fee should be bigger from old fee max in 1 percent");

        fee = _newFee;
        lastFeeChangedAt = block.timestamp;
    }

	function disableFee() external onlyOwner {
	    feeEnabled = !feeEnabled;
	}

	// -----------------------------------------
	// INTERNAL
	// -----------------------------------------

	function _validateFeeChanging(uint256 oldFee, uint256 newFee) private pure returns (bool) {
        uint256 onePercentOfOldFee = oldFee / 100;
        return (oldFee + onePercentOfOldFee >= newFee);
	}

	// -----------------------------------------
	// GETTERS
	// -----------------------------------------

	function getPositions() public view returns (address[] memory) {
		return DS.getAddressTable(DS.key("positions"));
	}

	function getPositionsCount() public view returns (uint256) {
		return DS.getAddressTable(DS.key("positions")).length;
	}

	function tokenFallback(address _tokenSender, uint256 _value) public {
		emit ReceivedTokens(_value, _tokenSender, msg.sender);
	}
}
