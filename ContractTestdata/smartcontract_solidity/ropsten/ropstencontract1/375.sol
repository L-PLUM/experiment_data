/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * 
 * Contract from zeppelin-solidity/contracts/ownership/Ownable.sol';
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


contract KortekaasCoin is Ownable {

    bytes3 public symbol = "KTY";   // The symbol for KortekaasCoin

    mapping(address=>uint) public balances;     // mapping to keep track of all balances
    address public minter;     // address of the owner/minter

    mapping(address=>mapping(address=>uint)) public allowances;    // mapping for keeping track of allowances

    event Mint(address to, uint amount);    // event for notifying about mints
    event Transfer(address from, address to, uint amount);      // event for notifying about transfers
    event AllowanceIncrease(address from, address to, uint amount);     // event for notifying about allowance increase
    event AllowanceDecrease(address from, address to, uint amount);     // event for notifying about allowance decrease
    event AllowanceSpent(address owner, address spender, address receiver, uint amount);    // event for notifying about allowance spending

    constructor (uint _supply) public {
        minter = msg.sender;
        balances[minter] = _supply;
    }

    function getMyCoin () public payable returns (bool) {
        require(msg.value > 0, "You need to transfer funds to get MyCoin");
        require(balances[minter] > msg.value, "Too bad, the minter does not have enough funds for you to get KTY");
        if (balances[msg.sender] + msg.value > balances[msg.sender]) {
            balances[minter] -= msg.value;
            balances[msg.sender] += msg.value;
            emit Mint(msg.sender, msg.value);
            return true;
        } else {
            return false;
        }
    }

    function transfer (address _to, uint _amount) public returns (bool) {
        require(balances[msg.sender] > _amount, "You need to have more funds in your account than `_amount`!");
        if (balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function increaseAllowance(address _to, uint _amount) public returns (bool) {
        require(balances[msg.sender] > _amount, "You need to have more funds in your account than `_amount`!");
        if (allowances[msg.sender][_to] + _amount > allowances[msg.sender][_to]) {
            balances[msg.sender] -= _amount;
            allowances[msg.sender][_to] += _amount;
            emit AllowanceIncrease(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function decreaseAllowance(address _from, uint _amount) public returns (bool) {
        require(allowances[msg.sender][_from] > _amount, "You need to have more allowance for `_from` than `_amount`!");
        if (balances[msg.sender] + _amount > balances[msg.sender]) {
            allowances[msg.sender][_from] -= _amount;
            balances[msg.sender] += _amount;
            emit AllowanceIncrease(msg.sender, _from, _amount);
            return true;
        } else {
            return false;
        }
    }

    function spendAllowance(address _owner, address _to, uint _amount) public returns (bool) {
        require (allowances[_owner][msg.sender] > _amount, "You need to be allowed to spend more funds than `_amount`!");
        if (balances[_to] + _amount > balances[_to]) {
            allowances[_owner][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit AllowanceSpent(_owner, msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function getAllowance(address _from) public view returns (uint) {
        return allowances[_from][msg.sender];
    }

    function getProfit() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}
