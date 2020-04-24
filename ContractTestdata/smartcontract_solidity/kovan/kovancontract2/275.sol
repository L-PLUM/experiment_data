/**
 *Submitted for verification at Etherscan.io on 2019-07-19
*/

pragma solidity ^0.5.10;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20{
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 */
contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
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
        require(msg.sender == _owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        address __previousOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(__previousOwner, newOwner);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev Withdraw Ether
     * @param to The address of the receiver
     * @param amount uint256
     */
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0));

        uint256 balance = address(this).balance;

        require(balance >= amount);
        to.transfer(amount);
    }
}


/**
 * @title Voken Engine Fund
 */
contract VokenEngineFund is Ownable {
    using SafeMath for uint256;

    IERC20 public VOKEN;
    uint256 private _vokenFreezed;

    mapping (address => uint256) private _mappingVokenFreezed;
    mapping (address => uint256) private _mappingVokenRelease;
    mapping (address => uint256) private _mappingVokenReleased;
    mapping (address => uint256) private _mappingReleaseTimestamp;

    /**
     * @dev constructor
     */
    constructor () public {
        VOKEN = IERC20(0x759a8f76a36B89c70df23f057f23E3359aac74D6);
    }

    /**
     * @dev Withdraw VOKEN
     */
    function () external payable {
        assert(_mappingReleaseTimestamp[msg.sender] > 0);
        
        uint256 __amount = _getVokenToBeReleased(msg.sender);
        if (__amount >= 0) {
            VOKEN.transfer(msg.sender, __amount);
        }
    }

    /**
     * @dev VOKEN Freezed Amount
     */
    function vokenFreezed() public view returns (uint256) {
        return _vokenFreezed;
    }

    /**
     * @dev VOKEN Freezed Amount setter
     */
    function setVokenFreezed(uint256 value) external onlyOwner {
        _vokenFreezed = value;
    }

    /**
     * @dev Get VOKEN to be released by an address.
     */
    function _getVokenToBeReleased(address account) internal view returns (uint256) {
        if (_mappingReleaseTimestamp[account] > 0) {

            uint256 __passed = now.sub(_mappingReleaseTimestamp[account]);
            if (__passed > 0) {
                uint256 __passedDays = __passed.div(1 minutes);
                if (__passedDays >= 30) {
                    return _mappingVokenRelease[account].sub(_mappingVokenReleased[account]);
                }
                
                return _mappingVokenRelease[account].mul(__passedDays).div(30).sub(_mappingVokenReleased[account]);
            }
        }

        return 0;
    }

    /**
     * @dev Confirm data for addresses.
     */
    function confirm(address[] memory accounts, uint256[] memory freezedAmounts, uint256[] memory timestamps, uint256[] memory releaseAmounts) public onlyOwner {
        assert(accounts.length == freezedAmounts.length);
        assert(accounts.length == timestamps.length);
        
        for (uint256 i = 0; i < accounts.length; i++) {
            _mappingVokenFreezed[accounts[i]] = freezedAmounts[i];
            _mappingVokenRelease[accounts[i]] = releaseAmounts[i];
            _mappingReleaseTimestamp[accounts[i]] = timestamps[i];
        }
    }

    /**
     * @dev Query data for an address.
     */
    function query(address account) public view returns (uint256 freezed,
                                                         uint256 release,
                                                         uint256 released,
                                                         uint256 releaseTimestamp,
                                                         uint256 toBeReleased) {
        freezed = _mappingVokenFreezed[account];
        release = _mappingVokenRelease[account];
        released = _mappingVokenReleased[account];
        releaseTimestamp = _mappingReleaseTimestamp[account];
        toBeReleased = _getVokenToBeReleased(account);
    }
}
