/**
 *Submitted for verification at Etherscan.io on 2018-12-30
*/

pragma solidity 0.5.1;

// File: contracts/ERC223/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns(address payable) {
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
    function isOwner() public view returns(bool) {
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
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/HasNoEtherNoToken.sol

/**
 * @title HasNoEtherNoToken
 * @dev The HasNoEtherNoToken contracts secure users from ether sending to contract address.
 * Also this contract provide functionality of Ownable contract.
 **/
contract HasNoEtherNoToken is Ownable {
    /**
   * @dev Constructor that rejects incoming Ether
   * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
   * leave out payable, then Solidity will allow inheriting contracts to implement a payable
   * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
   * we could use assembly to access msg.value.
   */
    constructor() public payable {
        require(msg.value == 0, "Ether sending is forbidden");
    }
    /**
     * @dev Disallows direct send by settings a default function without the `payable` flag.
     */
    function() external {
    }

    /**
     * @dev Transfer all Ether held by the contract to the owner.
     */
    function reclaimEther() external onlyOwner {
        require(owner().send(address(this).balance));
    }
    /**
        * @dev Reject all ERC223 compatible tokens
        * @param from_ address The address that is transferring the tokens
        * @param value_ uint256 the amount of the specified token
        * @param data_ Bytes The data passed from the caller.
        */
    function tokenFallback(address from_, uint256 value_, bytes calldata data_) external pure {
        from_;
        value_;
        data_;
        revert("Token sending is forbidden");
    }
}

// File: contracts/MasterRole.sol

/**
 * @title MasterRole
 * @dev The MasterRole contract allow to add restrictions to some
 * functionality by assigning addresses to a Masters role.
 **/
contract MasterRole is HasNoEtherNoToken{
    mapping(address => bool) masters;

    event MasterAdded(address indexed _address);
    event MasterRemoved(address indexed _address);

    /**
     * @dev Throws if called by any _address that is not master.
     */
    modifier onlyMaster() {
        require(isMaster(msg.sender), "Sender doesn't has Master role");
        _;
    }

    /**
     * @dev The MasterRole constructor add the contract creator to masters list.
     */
    constructor() internal {
        addMaster(msg.sender);
    }

    /**
     * @dev Allows to check is _address in master list.
     * @param _address The address to check.
     * @return true if _address is assigned to Master role.
     */
    function isMaster(address _address) public view returns (bool) {
        require(_address != address(0x0), "Null address was sent.");
        return masters[_address];
    }

    /**
     * @dev Deleting msg.sender from masters list.
     */
    function renounceMaster() public onlyMaster {
        masters[msg.sender] = false;
        emit MasterRemoved(msg.sender);
    }

    /**
     * @dev Add _address to masters.
     * @param _address The address to add in masters list.
     */
    function addMaster(address _address) public onlyOwner {
        require(!isMaster(_address), "Address is already Master!");
        masters[_address] = true;
        emit MasterAdded(_address);
    }

    /**
     * @dev Delete _address from masters.
     * @param _address The address to delete from masters list.
     */
    function removeMaster(address _address) public onlyOwner {
        require(isMaster(_address), "Address is not Master!");
        masters[_address] = false;
        emit MasterRemoved(_address);
    }

}

// File: contracts/ERC223/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

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

// File: contracts/ERC223/SafeMath.sol

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

// File: contracts/ERC223/IERC223.sol

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */

interface IERC223 {
    function balanceOf(address who) external view returns (uint);

    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function decimals() external view returns (uint8 _decimals);
    function totalSupply() external view returns (uint256 _supply);

    function transfer(address to, uint value) external returns (bool ok);
    function transfer(address to, uint value, bytes calldata data) external returns (bool ok);
    function transfer(address to, uint value, bytes calldata data, string calldata custom_fallback) external returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

// File: contracts/ERC223/IERC223Receiver.sol

contract IERC223Receiver {
    /**
    * @notice ERC223 Token fallback
    * @param _from address incoming token
    * @param _amount incoming amount
    **/
    function tokenFallback(address _from, uint _amount, bytes calldata _data) external ;
}

// File: contracts/ERC223/ERC223.sol

contract ERC223 is IERC20, IERC223 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

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
    function allowance(
        address owner,
        address spender
    )
    public
    view
    returns (uint256)
    {
        return _allowed[owner][spender];
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
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    public
    returns (bool)
    {
        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
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
        require(value <= _balances[from]);
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
        require(account != address(0x0));
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
        require(account != address(0x0));
        require(value <= _balances[account]);

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            value);
        _burn(account, value);
    }

    // Function to access name of token .
    function name() public view returns (string memory) {
        return _name;
    }
    // Function to access symbol of token .
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    // Function to access decimals of token .
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data, string memory _custom_fallback) public returns (bool success) {
        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            _balances[msg.sender] = balanceOf(msg.sender).sub(_value);
            _balances[_to] = balanceOf(_to).add(_value);
            (bool result, bytes memory data) = _to.call.value(0)(abi.encodeWithSignature(_custom_fallback, msg.sender, _value, _data));
            require(result);
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {

        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) public returns (bool success) {

        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }

    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        _balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        _balances[_to] = balanceOf(_to).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    //function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        _balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        _balances[_to] = balanceOf(_to).add(_value);
        IERC223Receiver receiver = IERC223Receiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


}

// File: contracts/ERC223/Roles.sol

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

// File: contracts/ERC223/PauserRole.sol

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

// File: contracts/ERC223/Pausable.sol

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

// File: contracts/ERC223/ERC223Pausable.sol

/**
* ERC223 token by Dexaran based on ERC20Pausable by openzeppelin
*
* https://github.com/Dexaran/ERC223-token-standard
*/

contract ERC223Pausable is ERC223, Pausable {

    function transfer(
        address to,
        uint256 value
    )
    public
    whenNotPaused
    returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    public
    whenNotPaused
    returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function approve(
        address spender,
        uint256 value
    )
    public
    whenNotPaused
    returns (bool)
    {
        return super.approve(spender, value);
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    )
    public
    whenNotPaused
    returns (bool success)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
    public
    whenNotPaused
    returns (bool success)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }



}

// File: contracts\StableToken.sol

/**
 * @title StableToken
 * @dev This StableToken is ERC223 top level contract.
 **/

contract StableToken is MasterRole, ERC223Pausable {
    mapping(address => bool) public whitelist;
    mapping(string => bool) private transactions;

    event Burn(address indexed owner, uint256 value, string transactionId);
    event Mint(address indexed owner, uint256 value, string transactionId);
    event ToggledWhiteListed(address indexed to, bool onList);

    /**
     * @dev Throws if address not on whitelist.
     */
    modifier onlyOnWhiteList(address _address) {
        require(isWhiteListed(_address), "Address is not on white list!");
        _;
    }

    /**
     * @dev Throws if transactionId was sent by server.
     */
    modifier onlyUniqueTransaction(string memory transactionId) {
        require(isUsedTransactionId(transactionId), "Transaction ID is not unique!");
        _;
    }

    constructor() public {
        _name = "STA token";
        _symbol = "EVERUSD";
        _decimals = 2;
    }

    /**
     * @dev Allows to mint token.
     * @param to The receiver's address.
     * @param value The amount that will be send.
     * @param transactionId The unique id that was created off-chain
     * to avoid double minting.
     * @return true if success.
     */
    function mint(address to, uint256 value, string memory transactionId) public onlyMaster onlyOnWhiteList(to) returns (bool) {
        _mint(to, value);
        emit Mint(to, value, transactionId);
        return addTransaction(transactionId);
    }

    /**
     * @dev Allows to burn token.
     * @param from The account whose tokens will be burnt..
     * @param value The amount that will be send.
     * @param transactionId The unique id that was created off-chain
     * to avoid double burning.
     * @return true if success.
     */
    function burn(address from, uint256 value, string memory transactionId) public onlyMaster onlyOnWhiteList(from) returns (bool) {
        _burn(from, value);
        emit Burn(from, value, transactionId);
        return addTransaction(transactionId);
    }

    /**
     * @dev Allows to check is _address in whitelist.
     * @param _address The _address to check.
     * @return true if _address on whitelist.
     */
    function isWhiteListed(address _address) public view returns (bool){
        return whitelist[_address];
    }

    /**
     * @dev Allows to check is transactionId was used before.
     * @param transactionId The transactionId to check.
     * @return true if transactionId was used.
     */
    function isUsedTransactionId(string memory transactionId) public view returns (bool){
        return transactions[transactionId];
    }

    /**
     * @dev Allows to change _address state in whitelist.
     * @param _to The address whose status will be changed.
     * @param _onList The new state in whitelist.
     */
    function toggleWhiteListed(address _to, bool _onList) public onlyMaster {
        require(_to != address(0x0), "Null address was sent.");
        if (whitelist[_to] != _onList) {
            whitelist[_to] = _onList;
            emit ToggledWhiteListed(_to, _onList);
        } else {
            revert("Account already has the same permission!");
        }
    }

    /**
     * @dev Allows to mark transactionId as used.
     * @param transactionId The address whose status will be changed.
     * @return true if success
     */
    function addTransaction(string memory transactionId) private returns (bool){
        require(!transactions[transactionId], "Transaction was used!");
        transactions[transactionId] = true;
        return true;
    }

}
