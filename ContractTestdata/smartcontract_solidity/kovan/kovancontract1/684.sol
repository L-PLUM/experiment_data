/**
 *Submitted for verification at Etherscan.io on 2019-01-14
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/Authorizable.sol

contract Authorizable is Ownable {
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    modifier onlyAuthorized() {
        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    function addAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            !authorized[target],
            "TARGET_ALREADY_AUTHORIZED"
        );

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    function removeAuthorizedAddress(address target)
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );

        delete authorized[target];
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
    external
    onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );
        require(
            index < authorities.length,
            "INDEX_OUT_OF_BOUNDS"
        );
        require(
            authorities[index] == target,
            "AUTHORIZED_ADDRESS_MISMATCH"
        );

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.length -= 1;
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    function getAuthorizedAddresses()
    external
    view
    returns (address[] memory)
    {
        return authorities;
    }
}

// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint private constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint private constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint private reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE);
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

// File: contracts/Bank.sol

contract Bank is Authorizable, ReentrancyGuard {

    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool);

    function getAvailable(address token, address user, bytes memory data) public view returns (uint256);

    function balanceOf(address token, address user) public view returns (uint256);

    function deposit(address token, address user, uint256 amount, bytes data) external payable;

    function withdraw(address token, uint256 amount, bytes data) external;

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bool fromDeposit,
        bool toDeposit
    )
    external;
}

// File: contracts/ERC20Bank.sol

interface WETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract ERC20Bank is Bank {

    mapping (address => bool) public wethAddresses;
    mapping (address => mapping (address => uint256)) public deposits;

    event SetWETH(address addr, bool autoWrap);
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);

    function() public payable { }

    function setWETH(address addr, bool autoWrap) public onlyOwner {
        wethAddresses[addr] = autoWrap;
        emit SetWETH(addr, autoWrap);
    }

    function hasDeposit(address token, address user, uint256 amount, bytes memory data) public view returns (bool) {
        if (wethAddresses[token]) {
            return amount <= deposits[0][user];
        }
        return amount <= deposits[token][user];
    }

    function getAvailable(address token, address user, bytes memory data) public view returns (uint256) {
        if (token == address(0)) {
            return deposits[0][user];
        }
        return SafeMath.add(ERC20(token).allowance(user, this), balanceOf(token, user));
    }

    function balanceOf(address token, address user) public view returns (uint256) {
        if (wethAddresses[token]) {
            return deposits[0][user];
        }
        return deposits[token][user];
    }

    function deposit(address token, address user, uint256 amount, bytes data) external nonReentrant payable {
        if (token == address(0)) {
            require(amount == msg.value, "UNMATCHED_DEPOSIT_AMOUNT");
            deposits[0][user] = SafeMath.add(deposits[0][user], msg.value);
            emit Deposit(0, user, msg.value, deposits[0][user]);
        } else {
            // Token should be approved in order to transfer
            require(ERC20(token).transferFrom(msg.sender, this, amount), "FAILED_DEPOSIT_TOKEN");
            if (wethAddresses[token]) {
                // Auto unwrap to ETH
                WETH(token).withdraw(amount);
                deposits[0][user] = SafeMath.add(deposits[0][user], amount);
            } else {
                deposits[token][user] = SafeMath.add(deposits[token][user], amount);
            }
            emit Deposit(token, user, amount, deposits[token][user]);
        }
    }

    function withdraw(address token, uint256 amount, bytes data) external nonReentrant {
        require(hasDeposit(token, msg.sender, amount, ""), "INSUFFICIENT_DEPOSIT");
        if (token == address(0)) {
            deposits[0][msg.sender] = SafeMath.sub(deposits[0][msg.sender], amount);
            require(msg.sender.call.value(amount)(), "FAILED_SEND_ETH");
            emit Withdraw(0, msg.sender, amount, deposits[0][msg.sender]);
        } else {
            if (wethAddresses[token]) {
                // Auto wrap to WETH
                WETH(token).deposit.value(amount)();
                deposits[0][msg.sender] = SafeMath.sub(deposits[0][msg.sender], amount);
            } else {
                deposits[token][msg.sender] = SafeMath.sub(deposits[token][msg.sender], amount);
            }
            require(ERC20(token).transfer(msg.sender, amount), "FAILED_WITHDRAW_TOKEN");
            emit Withdraw(token, msg.sender, amount, deposits[token][msg.sender]);
        }
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bool fromDeposit,
        bool toDeposit
    )
    external
    onlyAuthorized
    nonReentrant
    {
        if (amount == 0 || from == to) {
            return;
        }
        if (fromDeposit) {
            require(hasDeposit(token, from, amount, ""));
            address actualToken = token;
            if (toDeposit) {
                // Deposit to deposit
                if (wethAddresses[token]) {
                    actualToken = address(0);
                }
                deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                deposits[actualToken][to] = SafeMath.add(deposits[actualToken][to], amount);
            } else {
                // Deposit to wallet
                if (token == address(0)) {
                    deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                    require(to.send(amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                } else {
                    if (wethAddresses[token]) {
                        // Auto wrap to WETH
                        WETH(token).deposit.value(amount)();
                        actualToken = address(0);
                    }
                    deposits[actualToken][from] = SafeMath.sub(deposits[actualToken][from], amount);
                    require(ERC20(token).transfer(to, amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                }
            }
        } else {
            if (toDeposit) {
                // Wallet to deposit
                require(ERC20(token).transferFrom(from, this, amount), "FAILED_TRANSFER_FROM_WALLET_TO_DEPOSIT");
                deposits[token][to] = SafeMath.add(deposits[token][to], amount);
            } else {
                // Wallet to wallet
                require(ERC20(token).transferFrom(from, to, amount), "FAILED_TRANSFER_FROM_WALLET_TO_WALLET");
            }
        }
    }
}
