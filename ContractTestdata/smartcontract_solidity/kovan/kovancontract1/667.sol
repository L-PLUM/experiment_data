/**
 *Submitted for verification at Etherscan.io on 2019-01-15
*/

pragma solidity 0.5.0;

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
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: lib/ds-math/src/math.sol

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
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
    function mat() external view returns (uint);    // Liquidation ratio
    function tax() external view returns (uint);    // Stability fee
}

// File: contracts/MakerDaoGateway.sol

contract MakerDaoGateway is Pausable, DSMath {

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
    
    function systemParameters() public view returns (uint liquidationRatio, uint annualStabilityFee) {
        liquidationRatio = saiTub.mat();
        annualStabilityFee = rpow(saiTub.tax(), 365 days);
    }

    function () external payable {
        // For unwrapping WETH
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
            saiTub.gem().transferFrom(msg.sender, address(this), wethAmount);
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

        if (saiTub.gem().allowance(address(this), address(saiTub)) != uint(-1)) {
            saiTub.gem().approve(address(saiTub), uint(-1));
        }

        uint pethAmount = pethForWeth(wethAmount);
        
        saiTub.join(pethAmount);

        if (saiTub.skr().allowance(address(this), address(saiTub)) != uint(-1)) {
            saiTub.skr().approve(address(saiTub), uint(-1));
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

            if (saiTub.sai().allowance(address(this), address(saiTub)) != uint(-1)) {
                saiTub.sai().approve(address(saiTub), uint(-1));
            }
            if (saiTub.gov().allowance(address(this), address(saiTub)) != uint(-1)) {
                saiTub.gov().approve(address(saiTub), uint(-1));
            }

            //TODO: handle gov fee
            saiTub.sai().transferFrom(msg.sender, address(this), amount);
            
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

        if (saiTub.skr().allowance(address(this), address(saiTub)) != uint(-1)) {
            saiTub.skr().approve(address(saiTub), uint(-1));
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
}
