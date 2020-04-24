/**
 *Submitted for verification at Etherscan.io on 2019-02-22
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

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/access_control/AuthorizedAddresses.sol

contract AuthorizedAddresses is Ownable {

    mapping(address => bool) authorizedAddresses;

    constructor() Ownable() public {
        authorizedAddresses[owner()] = true;
    }

    function authorizeAddress(address a) public {
        require(authorizedAddresses[msg.sender]);
        authorizedAddresses[a] = true;
    }

    function unauthorizeAddress(address a) public {
        require(authorizedAddresses[msg.sender]);
        authorizedAddresses[a] = false;
    }

    function isAddressAuthorized(address a) public view returns (bool) {
        return authorizedAddresses[a];
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/base/Authorizable.sol

contract Authorizable {

    AuthorizedAddresses authorizedAddress;

    constructor(address authorizedAddressesAddress) public {
        authorizedAddress = AuthorizedAddresses(authorizedAddressesAddress);
    }

    modifier isAuthorized() {
        require(authorizedAddress.isAddressAuthorized(msg.sender));
        _;
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/lib/DigmToken.sol

contract DigmToken is ERC20, Ownable {

    string public name = "DIGM";
    string public symbol = "DIGM";
    uint8 public decimals = 18;

    constructor() Ownable() public {
    }

    function burn(uint amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function mint(uint amount) public onlyOwner {
        _mint(msg.sender, amount);
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/voting/IVoting.sol

interface IVoting {
    function balanceUpdate(address, uint) external;
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/treasury/Treasury.sol

contract Treasury is Authorizable {
    using SafeMath for uint;

    IVoting voting;
    DigmToken public digm;
    mapping(address => uint) private currentBalances;
    mapping(address => uint) private systemBalances;

    constructor(address digmAddress, address auth) Authorizable(auth) public {
        digm = DigmToken(digmAddress);
    }

    function deposit(uint amount) public {
        _deposit(msg.sender, amount);
    }

    function contractDeposit(address account, uint amount) isAuthorized public {
        _deposit(account, amount);
    }

    function withdraw(uint amount) public {
        _withdraw(msg.sender, amount);
    }

    function contractWithdraw(address account, uint amount) isAuthorized public {
        _withdraw(account, amount);
    }

    function claimTokens(address account, uint amount) isAuthorized public {
        if(getCurrentBalance(account) < amount) {
          updateBalance(account, amount);
        }

        require(digm.transfer(msg.sender, amount));
        setCurrentBalance(account, getCurrentBalance(account).sub(amount));
    }

    function releaseTokens(address account, uint amount) isAuthorized public {
        require(digm.transferFrom(msg.sender, address(this), amount));
        setCurrentBalance(account, getCurrentBalance(account).add(amount));
    }

    function updateBalance(address account, uint amount) isAuthorized public {
        uint currentBalance = getCurrentBalance(account);
        if(currentBalance > amount) {
            uint amountToWithdraw = currentBalance.sub(amount);
            _withdraw(account, amountToWithdraw);
        } else if (currentBalance < amount) {
            uint amountToDeposit = amount.sub(currentBalance);
            _deposit(account, amountToDeposit);
        }
    }

    function adjustBalance(address account, int amount) isAuthorized public {
        if(amount < 0) {
            _withdraw(account, uint(amount * -1));
        } else if (amount > 0) {
            _deposit(account, uint(amount));
        }
    }

    function systemBalance(address account) public view returns (uint)  {
        return getSystemBalance(account);
    }

    function currentBalance(address account) public view returns (uint)  {
        return getCurrentBalance(account);
    }

    function setVoting(address _votingAddress) public isAuthorized {
        voting = IVoting(_votingAddress);
    }

//  INTERNAL
    function _deposit(address account, uint amount) internal {
        require(digm.transferFrom(account, address(this), amount));
        setSystemBalance(account, getSystemBalance(account).add(amount));
        setCurrentBalance(account, getCurrentBalance(account).add(amount));
    }

    function _withdraw(address account, uint amount) internal {
        require(getCurrentBalance(account) >= amount);
        require(digm.transfer(account, amount));
        setSystemBalance(account, getSystemBalance(account).sub(amount));
        setCurrentBalance(account, getCurrentBalance(account).sub(amount));
        voting.balanceUpdate(account, getSystemBalance(account));
    }

    function getSystemBalance(address account) internal view returns (uint) {
        return systemBalances[account];
    }

    function setSystemBalance(address account, uint amount) internal {
        systemBalances[account] = amount;
    }

    function getCurrentBalance(address account) internal view returns (uint) {
        return currentBalances[account];
    }

    function setCurrentBalance(address account, uint amount) internal {
        currentBalances[account] = amount;
    }
}

// File: /Users/freydal/IdeaProjects/ParadigmContracts/internal/contracts/event/EventEmitter.sol

contract EventEmitter is Authorizable {

    event ParadigmEvent(string eventType, bytes32[] data);

    constructor(address auth) Authorizable(auth) public {
    }

    function emitEvent(string calldata eventType, bytes32[] calldata data) external isAuthorized {
        emit ParadigmEvent(eventType, data);
    }
}

// File: contracts/voting/Voting.sol

contract Voting is IVoting {

    DigmToken private token;
    Treasury private treasury;
    EventEmitter private emitter;
    uint public nextPollId = 1;
    mapping(uint => Poll) polls;
    mapping(address => uint[]) userUnrevealedPolls;

    struct Poll {
        uint id;
        address creator;
        uint commitEndBlock;
        uint revealEndBlock;
        mapping(uint => uint) voteValues;
        mapping(address => bool) didCommit;
        mapping(address => bool) didReveal;
        mapping(address => Vote) votes;
        address[] voters;
    }

    struct Vote {
        address voter;
        bytes32 hiddenVote;
        uint salt;
        uint voteOption;
    }

    constructor(address treasuryAddress, address _emitterAddress) public {
        emitter = EventEmitter(_emitterAddress);
        treasury = Treasury(treasuryAddress);
        token = treasury.digm();
    }

    function createPoll(uint _commitEndBlock, uint _revealEndBlock) public returns (uint) {

        require(_commitEndBlock < _revealEndBlock);

        Poll memory p;
        p.id = nextPollId;
        p.creator = msg.sender;
        p.commitEndBlock = _commitEndBlock;
        p.revealEndBlock = _revealEndBlock;

        polls[nextPollId] = p;
        nextPollId++;

        bytes32[] memory data = new bytes32[](2);
        data[0] = bytes32(uint(p.creator));
        data[1] = bytes32(p.id);
        //TODO: emit commit end and reveal end
        emitter.emitEvent('PollCreated', data);

        return p.id;
    }

    function commitVote(uint _pollId, bytes32 _vote) public {
        Poll storage p = polls[_pollId];
        Vote memory v;

        require(block.number <= p.commitEndBlock);
        require(!p.didCommit[msg.sender]);
        require(treasury.systemBalance(msg.sender) >= 1 ether); //TODO: should pull tokens in?

        v.voter = msg.sender;
        v.hiddenVote = _vote;

        p.voters.push(msg.sender);
        p.didCommit[msg.sender] = true;
        p.votes[msg.sender] = v;
        userUnrevealedPolls[msg.sender].push(_pollId);
    }

    function revealVote(uint _pollId, uint _vote, uint _voteSalt) public {
        Poll storage p = polls[_pollId];

        require(block.number > p.commitEndBlock);
        require(block.number <= p.revealEndBlock);
        require(p.didCommit[msg.sender]);
        require(!p.didReveal[msg.sender]);
        require(treasury.systemBalance(msg.sender) >= 1 ether);

        Vote storage v = p.votes[msg.sender];

        bytes32 exposedVote = keccak256(abi.encodePacked(_vote, _voteSalt));
        require(v.hiddenVote == exposedVote);

        v.salt = _voteSalt;
        v.voteOption = _vote;
        p.didReveal[msg.sender] = true;
        p.voteValues[_vote]++;
        removePendingVote(msg.sender, _pollId);
    }

    function balanceUpdate(address user, uint newBalance) public {
//        removePendingVotesAbove(user, newBalance);
        uint[] memory userPolls = userUnrevealedPolls[user];
        for (uint i = 0; i < userPolls.length; i++) {
            Vote memory v = polls[userPolls[i]].votes[user];
            if(1 ether > newBalance) {// TODO: NYI if(v.tokensCommited > value)
                removePendingVote(user, userPolls[i]);
            }
        }
    }

    //INTERNAL

    function removePendingVote(address user, uint _pollId) internal {
        uint[] storage userPolls = userUnrevealedPolls[user];
        if(userPolls.length > 0) {
            for (uint i=0; i < userPolls.length; i++)
                if (userPolls[i] == _pollId) {
                    delete polls[userPolls[i]].votes[user];
                    polls[userPolls[i]].didCommit[user] = false;
                    userPolls[i] = userPolls[userPolls.length - 1];
                    userPolls.length--;
                    break;
                }
        }
    }

}
