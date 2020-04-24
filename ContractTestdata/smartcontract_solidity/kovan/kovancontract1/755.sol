/**
 *Submitted for verification at Etherscan.io on 2019-01-09
*/

pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: contracts/interfaces/IWrappedEther.sol

contract IWrappedEther is IERC20 {
    function deposit() external payable;
    function withdraw(uint amount) external;
}

// File: contracts/interfaces/ISaiTub.sol

interface ISaiTub {
    function sai() external view returns (IERC20);  // Stablecoin
    function sin() external view returns (IERC20);  // Debt (negative sai)
    function skr() external view returns (IERC20);  // Abstracted collateral
    function gem() external view returns (IWrappedEther);  // Underlying collateral

    function open() external returns (bytes32 cup);
    function join(uint wad) external;
    function exit(uint wad) external;
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function per() external view returns (uint ray);
    function lad(bytes32 cup) external view returns (address);
}

// File: contracts/MakerDaoGateway.sol

contract MakerDaoGateway is Pausable {
    using SafeMath for uint;

    ISaiTub public saiTube;
    IWrappedEther public wrappedEther;
    IERC20 public pooledEther;
    IERC20 public dai;

    mapping (bytes32 => address) public cdpOwner;
    mapping (address => bytes32[]) public cdpsByOwner;

    // TODO: check indexed fields
    event CdpOpened(address indexed owner, bytes32 cdpId);
    event CollateralSupplied(address indexed owner, bytes32 cdpId, uint wethAmount, uint pethAmount);
    event DaiBorrowed(address indexed owner, bytes32 cdpId, uint amount);


    constructor(ISaiTub _saiTube) public {
        saiTube = _saiTube;
        wrappedEther = saiTube.gem();
        pooledEther = saiTube.skr();
        dai = saiTube.sai();

        approveERC20();
    }

    function cdpByOwnerLength(address owner) view public returns (uint) {
        return cdpsByOwner[owner].length;
    }
    
    // SUPPLY AND BORROW

    function supplyAndBorrow(bytes32 cdpId, uint daiAmount, address beneficiary) external payable {
        bytes32 id = cdpId; //TO FIX
        if (msg.value > 0) {
            id = supplyEth(cdpId);
        }
        if (daiAmount > 0) {
            borrowDai(id, daiAmount, beneficiary);
        }
    }
    
    // ETH amount should be > 0.005
    function supplyEth(bytes32 cdpId) public payable returns (bytes32) {
        wrappedEther.deposit.value(msg.value)();
        return supply(cdpId, msg.value);
    }

    // WETH amount should be > 0.005
    // don't forget to approve before supplying
    function supplyWeth(bytes32 cdpId, uint wethAmount) public returns (bytes32) {
        wrappedEther.transferFrom(msg.sender, this, wethAmount);
        return supply(cdpId, wethAmount);
    }

    function pethPEReth(uint ethNum) public view returns (uint rPETH) {
        rPETH = (ethNum.mul(10 ** 27)).div(saiTube.per());
    }

    function supply(bytes32 cdpId, uint wethAmount) internal returns (bytes32) {
        uint pethAmount = pethPEReth(wethAmount); //TODO adjust acording to the rate;
        saiTube.join(pethAmount);

        assert(pooledEther.balanceOf(this) >= pethAmount);

        bytes32 id = cdpId;
        if(id == 0) {
            id = saiTube.open();
            cdpOwner[id] = msg.sender;
            cdpsByOwner[msg.sender].push(id);
            emit CdpOpened(msg.sender, id);
        } else {
            require(cdpOwner[id] == msg.sender, "CDP belongs to a different address");
        }

        saiTube.lock(id, pethAmount);
        emit CollateralSupplied(msg.sender, id, wethAmount, pethAmount);

        return id;
    }

    // TODO: handle beneficiary address
    function borrowDai(bytes32 cdpId, uint daiAmount, address beneficiary) public {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");
        
        saiTube.draw(cdpId, daiAmount);
        dai.transfer(msg.sender, daiAmount);
        emit DaiBorrowed(msg.sender, cdpId, daiAmount);
    }

    // REPAY AND RETURN
    
    function repayAndReturn(bytes32 cdpId, uint daiAmount, uint ethAmount) external {
        if (daiAmount > 0) {
            repayDai(cdpId, daiAmount);
        }
        if (ethAmount > 0) {
            returnEth(cdpId, ethAmount);
        }
    }

    function repayDai(bytes32 cdpId, uint daiAmount) public {
        
    }

    function returnEth(bytes32 cdpId, uint ethAmount) public {
        
    }

    function returnWeth(bytes32 cdpId, uint wethAmount) public {
        
    }

    function transferCdp(bytes32 cdpId, address nextOwner) external {

    }

    function migrateCdp(bytes32 cdpId) external {
        
    }

    function approveERC20() public {
        wrappedEther.approve(saiTube, 2**256 - 1);
        pooledEther.approve(saiTube, 2**256 - 1);
        // IERC20 mkrTkn = IERC20(getAddress("mkr"));
        // mkrTkn.approve(cdpAddr, 2**256 - 1);
        // IERC20 daiTkn = IERC20(getAddress("dai"));
        // daiTkn.approve(cdpAddr, 2**256 - 1);
    }

}
