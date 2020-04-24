/**
 *Submitted for verification at Etherscan.io on 2019-02-06
*/

pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
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

// File: contracts/IWrappedFiat.sol

/**
 * Reserves backed coin contract interface
 *
 * NB!: It is not for public trading, and it is not ERC20 compatible
 *
 */
interface IWrappedFiat {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address guy, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function allowance(address src, address guy) external view returns (uint);
    function move(address src, address dst, uint amount) external;
}

// File: contracts/WrappedFiat.sol

/**
 * Reserves backed coin contract
 */
contract WrappedFiat is Ownable, IWrappedFiat {
    using SafeMath for uint256;

    uint8 public constant decimals = 18;
    string public accountName;

    uint256 totalBalance;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) approvals;

    constructor(string memory accountName_) public {
        accountName = accountName_;
    }

    function balanceOf(address who) external view returns (uint256) {
        return balances[who];
    }

    function totalSupply() external view returns (uint256) {
        return totalBalance;
    }

    function allowance(address src, address guy) external view returns (uint256) {
        return approvals[src][guy];
    }

    function approve(address guy, uint amount) external returns (bool) {
        approvals[msg.sender][guy] = amount;
        emit Approval(msg.sender, guy, amount);
        return true;
    }

    function transfer(address dst, uint amount) external returns (bool) {
        return transferFromInternal(msg.sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        return transferFromInternal(src, dst, amount);
    }

    function move(address src, address dst, uint amount) external {
        transferFromInternal(src, dst, amount);
    }

    function mint(uint256 amount, address recipient) external onlyOwner {
        require(recipient != address(this), "cannot mint token for contract itself");
        balances[recipient] = balances[recipient].add(amount);
        totalBalance = totalBalance.add(amount);
        emit Mint(recipient, amount);
    }

    function transferFromInternal(address src, address dst, uint amount) internal returns (bool) {
        require(amount <= balances[src], "Not enough balance");

        if (src != msg.sender) {
            approvals[src][msg.sender] = approvals[src][msg.sender].sub(amount);
        }

        balances[src] = balances[src].sub(amount);

        if (dst != address(this)) {
            balances[dst] = balances[dst].add(amount);
            emit Transfer(src, dst, amount);
        } else {
            // burn tokens that transfered to the contract itself
            totalBalance = totalBalance.sub(amount);
            emit Burn(msg.sender, amount);
        }
        return true;
    }

    event Approval(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Mint(address indexed recipient, uint256 amount);
    event Burn(address indexed from, uint256 amount);
}
