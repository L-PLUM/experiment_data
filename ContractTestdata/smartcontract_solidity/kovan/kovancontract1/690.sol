/**
 *Submitted for verification at Etherscan.io on 2019-01-14
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
    function gov() external view returns (IERC20);  // Governance token

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
    function tab(bytes32 cup) external returns (uint);
    function ink(bytes32 cup) external view returns (uint);
}

// File: contracts/MakerDaoGateway.sol

contract MakerDaoGateway is Pausable {
    using SafeMath for uint;

    ISaiTub public saiTub;

    mapping(bytes32 => address) public cdpOwner;
    mapping(address => bytes32[]) public cdpsByOwner;

    // TODO: check indexed fields
    event CdpOpened(address indexed owner, bytes32 cdpId);
    event CollateralSupplied(address indexed owner, bytes32 cdpId, uint wethAmount, uint pethAmount);
    event DaiBorrowed(address indexed owner, bytes32 cdpId, uint amount);
    event DaiRepaid(address indexed owner, bytes32 cdpId, uint amount);
    event CollateralReturned(address indexed owner, bytes32 cdpId, uint wethAmount, uint pethAmount);


    constructor(ISaiTub _saiTub) public {
        saiTub = _saiTub;
    }

    function cdpsByOwnerLength(address owner) public view returns (uint) {
        return cdpsByOwner[owner].length;
    }

    function () public payable {
        // For unwrapping WETH only
    }
    
    // SUPPLY AND BORROW
    
    // specify cdpId if you want to use existing CDP, or pass 0 if you need to create a new one 
    function supplyEthAndBorrowDai(bytes32 cdpId, uint daiAmount) external payable {
        bytes32 id = supplyEth(cdpId);
        borrowDai(id, daiAmount);
    }

    // specify cdpId if you want to use existing CDP, or pass 0 if you need to create a new one 
    function supplyWethAndBorrowDai(bytes32 cdpId, uint wethAmount, uint daiAmount) external payable {
        bytes32 id = supplyWeth(cdpId, wethAmount);
        borrowDai(id, daiAmount);
    }

    // ETH amount should be > 0.005 for new CDPs
    // returns id of actual cdp (existing or a new one)
    function supplyEth(bytes32 cdpId) public payable returns (bytes32) {
        if (msg.value > 0) {
            saiTub.gem().deposit.value(msg.value)();
            return _supply(cdpId, msg.value);
        }

        return cdpId;
    }

    // WETH amount should be > 0.005 for new CDPs
    // don't forget to approve WETH before supplying
    // returns id of actual cdp (existing or a new one)
    function supplyWeth(bytes32 cdpId, uint wethAmount) public returns (bytes32) {
        if (wethAmount > 0) {
            saiTub.gem().transferFrom(msg.sender, this, wethAmount);
            return _supply(cdpId, wethAmount);
        }

        return cdpId;
    }


    function _supply(bytes32 cdpId, uint wethAmount) internal returns (bytes32 id) {
        id = cdpId;
        if (id == 0) {
            id = createCdp();
        } else {
            require(cdpOwner[id] == msg.sender, "CDP belongs to a different address");
        }

        if (saiTub.gem().allowance(this, saiTub) != uint(-1)) {
            saiTub.gem().approve(saiTub, uint(-1));
        }

        uint pethAmount = pethForWeth(wethAmount);
        
        saiTub.join(pethAmount);

        if (saiTub.skr().allowance(this, saiTub) != uint(-1)) {
            saiTub.skr().approve(saiTub, uint(-1));
        }

        saiTub.lock(id, pethAmount);
        emit CollateralSupplied(msg.sender, id, wethAmount, pethAmount);
    }
    
    function createCdp() internal returns (bytes32 cdpId) {
        cdpId = saiTub.open();
        
        cdpOwner[cdpId] = msg.sender;
        cdpsByOwner[msg.sender].push(cdpId);
        
        emit CdpOpened(msg.sender, cdpId);
    }

    function borrowDai(bytes32 cdpId, uint daiAmount) public {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");
        if (daiAmount > 0) {
            saiTub.draw(cdpId, daiAmount);
            
            saiTub.sai().transfer(msg.sender, daiAmount);
            
            emit DaiBorrowed(msg.sender, cdpId, daiAmount);
        }
    }

    // REPAY AND RETURN

    // don't forget to approve DAI before repaying
    function repayDaiAndReturnEth(bytes32 cdpId, uint daiAmount, uint ethAmount) external {
        repayDai(cdpId, daiAmount);
        returnEth(cdpId, ethAmount);
    }

    // don't forget to approve DAI before repaying
    // pass -1 to daiAmount to repay all outstanding debt
    // pass -1 to wethAmount to return all collateral
    function repayDaiAndReturnWeth(bytes32 cdpId, uint daiAmount, uint wethAmount) external {
        repayDai(cdpId, daiAmount);
        returnWeth(cdpId, wethAmount);
    }

    // don't forget to approve DAI before repaying
    function repayDai(bytes32 cdpId, uint daiAmount) public {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");
        if (daiAmount > 0) {
            
            uint amount = daiAmount;
            if (daiAmount == uint(-1)) {
                amount = saiTub.tab(cdpId);
            }

            if (saiTub.sai().allowance(this, saiTub) != uint(-1)) {
                saiTub.sai().approve(saiTub, uint(-1));
            }
            if (saiTub.gov().allowance(this, saiTub) != uint(-1)) {
                saiTub.gov().approve(saiTub, uint(-1));
            }

            //TODO: handle gov fee
            saiTub.sai().transferFrom(msg.sender, this, amount);
            
            saiTub.wipe(cdpId, amount);

            emit DaiRepaid(msg.sender, cdpId, amount);
        }
    }

    function returnEth(bytes32 cdpId, uint ethAmount) public {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");
        if (ethAmount > 0) {
            uint effectiveWethAmount = _return(cdpId, ethAmount);
            saiTub.gem().withdraw(effectiveWethAmount);
            msg.sender.transfer(effectiveWethAmount);
        }
    }

    function returnWeth(bytes32 cdpId, uint wethAmount) public {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");
        if (wethAmount > 0){
            uint effectiveWethAmount = _return(cdpId, wethAmount);
            saiTub.gem().transfer(msg.sender, effectiveWethAmount);
        }
    }
    
    function _return(bytes32 cdpId, uint wethAmount) internal returns (uint effectiveWethAmount) {
        require(cdpOwner[cdpId] == msg.sender, "CDP belongs to a different address");

        uint pethAmount;
        
        if (wethAmount == uint(-1)){
            pethAmount = saiTub.ink(cdpId);
        } else {
            pethAmount = pethForWeth(wethAmount);
        }

        saiTub.free(cdpId, pethAmount);

        if (saiTub.skr().allowance(this, saiTub) != uint(-1)) {
            saiTub.skr().approve(saiTub, uint(-1));
        }
        
        saiTub.exit(pethAmount);
        
        effectiveWethAmount = wethForPeth(pethAmount);

        emit CollateralReturned(msg.sender, cdpId, effectiveWethAmount, pethAmount);
    }

    function transferCdp(bytes32 cdpId, address nextOwner) external {
        //TODO
    }

    function migrateCdp(bytes32 cdpId) external {
        //TODO
    }
    
    // Just for testing purpuses
    function withdrawMkr(uint mkrAmount) external onlyPauser {
        saiTub.gov().transfer(msg.sender, mkrAmount);
    }

    function pethForWeth(uint wethAmount) public view returns (uint) {
        return rdiv(wethAmount, saiTub.per());
    }

    function wethForPeth(uint pethAmount) public view returns (uint) {
        return rmul(pethAmount, saiTub.per());
    }

    uint constant internal RAY = 10 ** 27;
    
    // more info about ray math: https://github.com/dapphub/ds-math
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = x.mul(RAY).add(y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x.mul(y).add(RAY / 2) / RAY;
    }
}
