/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/// @title Base contract defining common error codes.
/// @author Lawrence Forman ([email protected])
contract Errors {

	string internal constant ERROR_MAX_HEIGHT = "MAX_HEIGHT";
	string internal constant ERROR_ALREADY = "ALREADY";
	string internal constant ERROR_INSUFFICIENT = "INSUFFICIENT";
	string internal constant ERROR_RESTRICTED = "RESTRICTED";
	string internal constant ERROR_UNINITIALIZED = "UNINITIALIZED";
	string internal constant ERROR_TIME_TRAVEL = "TIME_TRAVEL";
	string internal constant ERROR_INVALID = "INVALID";
	string internal constant ERROR_NOT_FOUND = "NOT_FOUND";
	string internal constant ERROR_GAS = "GAS";
	string internal constant ERROR_TRANSFER_FAILED = "TRANSFER_FAILED";
}

/// @title Base for contracts that don't want to hold ether.
/// @author Lawrence Forman ([email protected])
/// @dev Reverts in the fallback function.
contract Nonpayable is Errors {

	/// @dev Revert in the fallback function to prevent accidental
	/// transfer of funds to this contract.
	function() external payable {
		revert(ERROR_INVALID);
	}
}

/// @title Public interface for the Upcity Market contract.
/// @author Lawrence Forman ([email protected])
contract IMarket {

	uint8 internal constant NUM_RESOURCES = 3;

	function getPrices()
		external view returns (uint256[NUM_RESOURCES] memory prices);
	function getSupplies()
		external view returns (uint256[NUM_RESOURCES] memory supplies);
	function getBalances(address who)
		external view returns (uint256[NUM_RESOURCES] memory balances);
	function getSupply(address token) external view returns (uint256 supply);
	function getBalance(address token, address who)
		external view returns (uint256 balance);
	function proxyTransfer(
		address from, address to, uint256 amount)
		external;
	function transfer(
		address from, address to, uint256[NUM_RESOURCES] calldata amounts)
		external;
	function mint(address to, uint256[NUM_RESOURCES] calldata amounts)
		external;
	function stash(address from, uint256[NUM_RESOURCES] calldata amounts)
		external;
	function buy(uint256[NUM_RESOURCES] calldata amounts, address to)
		external payable returns (uint256[NUM_RESOURCES] memory bought);
	function sell(uint256[NUM_RESOURCES] calldata amounts, address payable to)
		external returns (uint256 value);
}

/// @title ERC20 token "proxy" contract for upcity resources.
/// @author lawrence forman ([email protected])
/// @dev Most logic is deferred to the UpcityMarket contract instance,
/// which maintians the balances and supply of each token. The only real
/// responsibility of this contract is to manage spending allowances.
contract UpcityResourceTokenProxy is
		IERC20,
		Nonpayable {

	using SafeMath for uint256;

	uint8 private constant NUM_RESOURCES = 3;

	string public name;
	string public symbol;
	uint8 public constant decimals = 18;
	/// @dev The UpcityMarket contract.
	IMarket private _market;
	/// @dev Spending allowances for each spender for a wallet.
	/// The mapping order is wallet -> spender -> allowance.
	mapping(address=>mapping(address=>uint256)) private _allowances;

	/// @dev Creates the contract.
	/// @param _name Token name
	/// @param _symbol Token symbol
	/// @param market The market address.
	constructor(
			string memory _name,
			string memory _symbol,
			address market)
			public {

		name = _name;
		symbol = _symbol;
		_market = IMarket(market);
	}

	/// @dev Get the current supply of tokens.
	/// @return The current supply of tokens (in wei).
	function totalSupply() external view returns (uint256) {
		// Query the market.
		return _market.getSupply(address(this));
	}

	/// @dev Get the token balance of an address.
	/// @param who The address that owns the tokens.
	/// @return The balance of an address (in wei).
	function balanceOf(address who) external view returns (uint256) {
		// Query the market.
		return _market.getBalance(address(this), who);
	}

	/// @dev Get the spending allowance for a spender and owner pair.
	/// @param owner The address that owns the tokens.
	/// @param spender The address that has been given an allowance to spend
	/// from `owner`.
	/// @return The remaining spending allowance (in wei).
	function allowance(address owner, address spender)
			external view returns (uint256) {

		return _allowances[owner][spender];
	}

	/// @dev Grant an allowance to `spender` from the caller's wallet.
	/// This allowance will be reduced every time a successful
	/// transferFrom() occurs.
	/// @param spender The wallet's spender.
	/// @param value The allowance amount.
	function approve(address spender, uint256 value) external returns (bool) {
		// Overwrite the previous allowance.
		_allowances[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}

	/// @dev Transfer tokens from the caller's wallet.
	/// Reverts if the caller does not have the funds to cover the transfer.
	/// @param to The recipient.
	/// @param amt The number of tokens to send (in wei)
	function transfer(address to, uint256 amt) external returns (bool) {
		// Let the market handle it. This call should revert on failure.
		_transfer(msg.sender, to, amt);
		return true;
	}

	/// @dev Transfer tokens from a wallet.
	/// Reverts if the `from` does not have the funds to cover the transfer
	/// or the caller does not have enough allowance.
	/// @param from The wallet to spend tokens from.
	/// @param to The recipient.
	/// @param amt The number of tokens to send (in wei)
	function transferFrom(address from, address to, uint256 amt)
			external returns (bool) {

		// Ensure that the spender has enough allowance.
		uint256 remaining = _allowances[from][msg.sender];
		require(remaining >= amt, ERROR_INSUFFICIENT);
		// Reduce the allowance.
		_allowances[from][msg.sender] = remaining - amt;
		_transfer(from, to, amt);
		return true;
	}

	/// @dev Perform an unchecked transfer between addresses.
	/// @param from The sender address.
	/// @param to The receiver address/
	/// @param amt The amount of tokens to transfer, in wei.
	function _transfer(address from, address to, uint256 amt)
			private {

		require(to != address(0x0) && to != address(this), ERROR_INVALID);
		// This should revert if the balances are insufficient.
		_market.proxyTransfer(from, to, amt);
		emit Transfer(from, to, amt);
	}
}
