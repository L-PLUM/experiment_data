/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.20;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

    int256 constant private INT256_MIN = -2**255;
    int256 constant private INT256_MAX = 2**255-1;
    
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

    /**
    * @dev Subtracts a signed integer from an unsigned int
    */
    function sub(uint self, int b) internal pure returns (uint){
        if(b < 0){
            return add(self,abs(b));
        }else{
            return sub(self,uint(b));
        }
    }

    /**
    * @dev Subtracts an int from an int
    */
    function sub(int self, int b) internal pure returns(int){
        return self - b;
    }

    /**
    * @dev Subtracts an unsigned integer from a signed int
    */
    function sub(int self, uint b) internal pure returns (int){
        require(b <= uint(INT256_MAX));
        return sub(self,int(b));
    }

    /**
    * @dev Adds a signed integer to an unsigned int, reverts on overflow.
    */
    function add(uint self, int b) internal pure returns (uint){
        if(b <= 0){
            return sub(self, abs(b));
        }else{
            return add(self,uint(b));
        }
    }

    /**
    * @dev Adds an unsigned integer to a signed int, reverts on overflow.
    */
    function add(int self, uint b) internal pure returns (int){
        require(b < uint(INT256_MAX));
        int c = self + int(b);
        require(c > self || c > int(b));
        return c;
    }

   /**
    * @dev Returns the abs of an int as a uint
    */
    function abs(int a) internal pure returns (uint){
        return a >= 0 ? uint(a) : uint(0-a);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
contract ERC20 /*is IERC20*/ {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;

    uint256 internal _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function ERC20(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

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
        Approval(msg.sender, spender, value);
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
        Approval(from, msg.sender, _allowed[from][msg.sender]);
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
        Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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
        Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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
        Transfer(from, to, value);
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
        Transfer(address(0), account, value);
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
        Transfer(account, address(0), value);
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
        Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) public view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) public view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable;

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) public payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) public;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) public view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}

contract IManaged{

    //Event Fired when a manager is added or removed
    event ManagerChanged(address manager,bool state);
    event OwnerChanged(address owner);
    event TrustChanged(address trust);
    event ContractReplaced(address indexed replacement);
    event ContractLocked(bool indexed state);

    address internal _owner;
    address internal _trust;

    bool internal _locked = false;

    mapping(address => bool) managers;
    
    modifier trustonly(){
        require(msg.sender == _trust || msg.sender == _owner);
        _;
    }

    modifier owneronly(){
        require(msg.sender == _owner);
        _;
    }

    modifier managed(){
        require(managers[msg.sender] || msg.sender == _owner || msg.sender == _trust);
        _;
    }

    modifier locked(){
        require(_locked == true);
        _;
    }

    modifier unlocked(){
        require(_locked == false);
        _;
    }

    function setTrust(address addr) public{
        require(msg.sender == _trust || msg.sender == _owner);
        _trust = addr;
        TrustChanged(addr);
    }

    function addManager(address addr) public owneronly{
        managers[addr] = true;
        ManagerChanged(addr,true);
    }

    function removeManager(address addr) public managed{
        managers[addr] = false;
        ManagerChanged(addr,false);
    }

    function changeOwner(address _newOwner) public owneronly{
        OwnerChanged(_newOwner);
        _owner = _newOwner;
        addManager(_newOwner);
    }

    function lock() public managed{
        _locked = true;
        ContractLocked(_locked);
    }

    function unlock() public managed{
        _locked = false;
        ContractLocked(_locked);
    }

    function isLocked() public view returns (bool){
        return _locked;
    }
    //Used to kill the contract and forward funds to a replacement contract, this is owner only
    function replace(address dest) public trustonly locked{
        ContractReplaced(dest);
        selfdestruct(dest);
    }

    function sweep(uint amount, address to) public managed{
        address(to).transfer(amount);
    }

    function sweepERC20(address token, address to,  address from) public managed{
        uint allowance = 0;
        uint bal = IERC20(token).balanceOf(address(this));
        if(bal > 0){
            IERC20(token).transfer(to,bal);
        }
        if(from != address(0)){
            allowance = IERC20(token).allowance(from, address(this));
            if(allowance > 0){
                IERC20(token).transferFrom(from, to, allowance);
            }
        }
    }
    
    function sweepERC721(address token, address to, address from, uint[] ids) public managed{
        if(IERC165(token).supportsInterface(0x80ac58cd)){
            for(uint x = 0; x <= ids.length -1; x++){
                uint tokenId = ids[x];
                IERC721(token).transferFrom(from,to,tokenId);
            }
        }
    }
}

interface IELF{
    event AgentSet(uint indexed tokenId, address indexed agent);
    event MintAdded(address indexed mint);
    event MintRemoved(address indexed mint);
    event LoanCreated(address indexed dest, uint indexed tokenId, uint amount, uint fee);
    event LoanDefaulted(uint indexed tokenId, uint owed);
    event FundsAdded(address indexed source, uint indexed amount);
    event DepositReceived(address indexed source, uint indexed amount, int balance);

    function() external payable;
    function setEstate(address _estate) external;
    function setTR(address _tr) external;

    function setFee(uint p, uint q) external;
    function getFee() external view returns (uint[2] _fee);

    function setAgent(uint tokenId, address agent) external;
    function getAgent(uint tokenId) external view returns (address agent);
    function addMint(address addr) external;
    function removeMint(address addr) external;
    function isMint(address addr) external view returns (bool);
    function getPrice(uint tokenId) external view returns (uint price);

    function getCreditLimit(uint tokenId) external view returns (uint limit);
    function debit(uint tokenId, uint requested, address dest, address who) external returns (uint amount);

    function tokenBalance(uint tokenId) external view returns (int);
    function credit(uint tokenId) external payable;

    function surrender(uint tokenId) external;
    function forgive(uint tokenId) external;
    function setBalance(uint tokenId, int amount) external;
}

contract IXToken is IManaged /*,IERC20*/{

    IELF elf;       //deal with elf as a contract
    address _elf;   //elf as address
    address _estate;//estate as address
    address _tr;    //tr as address
    address _ar;    //ar as address
    address _xav;   //xav as address (xav contract this is self)

    uint fees;      //Sum total of currently collected fees
    uint _manaRate;//Exchange rate for mana from awards

    //Rational is a ratio of p / q used for rates such as interest
    struct Rational {
        uint p;
        uint q;
    }
    Rational fee;   //fee for actions such as deposits, withdrawals & transfers
    Rational rate;  //exchange rate to / from wei
    

    mapping(address => uint) lastIDate; //Last time interest was paid to address
    mapping(address => uint) intPaid;   //total interest paid to address
    mapping(address => bool) _mints;    //authorized mints for this token

    //Fired when a mint is added or removed
    event MintChange(address mint, bool state);
    //Fired whed manarate is changed
    event ManaRateChanged(uint amount);
    //Fired when an award is granted
    event Award(address user, uint amount);
    //Fired when a deposit is received
    event Deposit(address source, uint amount);
    //Fired when interest is paid
    event InterestPaid(address user, uint amount);
    //Fired when approval is given
    event Approval(address approver, address spender, uint tokens);
    //Fired when approvale has been received but not processed
    event ApprovalReceived(address token, address user, uint amount);
    //Fired when approval has been processed
    event ApprovalProcessed(address token, address user, uint amount);
    //Fired when an element from bulkTransfer has failed
    event BulkXfrFail(address source, address dest, uint amount);
    //Fired when fee has changed
    event FeeChanged(uint p, uint q);
    //Fired when the exchange rate to/from wei has changed
    event DepositRateChanged(uint p, uint q);
    
    //Only authorized mints
    modifier mintonly(){
        require(_mints[msg.sender]);
        _; 
    }

    /**
    * @dev Add a new mint
    * @param addr - Address to authorize for minting 
    */
    function addMint(address addr) public managed{
        _mints[addr] = true;
        MintChange(addr,true);
    }

    /**
    * @dev Remove a mint
    * @param addr - Address to de-authorize from minting 
    */
    function removeMint(address addr) public managed{
        _mints[addr] = false;
        MintChange(addr, false);
    }

    /**
    * @dev Determine if addr is a mint for this token
    * @param addr - Address to check
    */
    function isMint(address addr) public view returns(bool){
        return _mints[addr];
    }

    /**
    * @dev public fallback function
    * All IXTokens must be payable, 
    * in most cases they just emit 
    * Deposit(address source, uint amount);
    */
    function() public payable{
        Deposit(msg.sender, msg.value);
    }
    
    /**
    * @dev set the AwardRights contract 
    */
    function setAR(address ar) public managed{
        _ar = ar;
    }

    /**
    * @dev set the ELF contract
    */
    function setELF(address __elf) public managed{
        _elf = __elf;
        elf = IELF(_elf);
    }

    /**
    * @dev set the Estate contract  
    */
    function setEstate(address estate) public managed{
        _estate = estate;
    }

    /**
    * @dev set the TreasuryRights contract 
    */
    function setTR(address tr) public managed{
        _tr = tr;
    }

    /**
    * @dev set the XAV contract (will be this.address for XAV itself)
    */
    function setXAV(address xav) public managed{
        _xav = xav;
    }

    /**
    * @dev set the manaRate which is from AR contracts 
    */
    function setManaRate(uint __rate) public managed{
        _manaRate = __rate;
        ManaRateChanged(_manaRate);
    }

    /**
    * @dev set the exchange rate to / from wei (or XAV) 
    */
    function setRate(uint _p, uint _q) public;

    /**
    * @dev Most actions charge a fee, this sets the fee
    */
    function setFee(uint _p, uint _q) public;

    /**
    * @dev get the current fee 
    */
    function getFee() public returns (uint[2] _fee);

    /**
    * @dev transfer funds, overrides ERC20 transfer 
    */
    function transfer(address to, uint256 value) public returns (bool status);

    /**
    * @dev get the interest paid so far to address user, this is in tokens
    */
    function getInterestPaid(address user) public view returns (uint paid);

    /**
    * @dev collect any interest due on behalf of user 
    */
    function collectInterest(address user) public returns(uint interest);

    /**
    * @dev calculate the fee applied to value, feeAmt is in tokens
    */
    function calcFee(uint value) public view returns (uint feeAmt);

    /**
    * @dev calculate interest owed to user, interest is in tokens 
    */
    function calcInterest(address user) public view returns(uint interest);

    /**
    * @dev AwardMana to a user, must be AR contract, this is called from 
    */
    function awardMana(uint amount, address user) public;

    /**
    * @dev Mint new tokens 
    */
    function mint(uint amount) public payable;

    /**
    * @dev burn existing tokens 
    */
    function burn(uint amount) public;
    
    /**
    * @dev deposit wei on behalf of _to, returns the tokens created 
    */
    function depositTo(address _to) public payable returns (uint tokens);

    /**
    * @dev All IXTokens implement approveAndCall semantics from ERC20
    */
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success);
    
    /**
    * @dev All IXTokens implement approveAndCall.receiveApproval semantics from ERC20
    */
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
    
    /**
    * @dev withdraw tokens as XAV, unless this is XAV contract in which case we get wei
    * If dest is a contract this function will call depositTo on dest, otherwise must be a normal address 
    */
    function withdraw(uint amount, address dest, address _user) public;

    /**
    * @dev shortcut for withdraw(uint amount, address dest, address _user)
    * Use when using a normal address for withdrawal in order to save some gas
    */
    function withdraw(uint amount, address user) public;

    /**
    * @dev convenience function to let you know how many tokens for wei 
    */
    function weiToTokens(uint w) public view returns (uint tokens);

    /**
    * @dev convenience function to let you know how many wei each token is worth
    */
    function tokensToWei(uint tokens) public view returns (uint w);

    /**
    * @dev called when this token is added as a agent for an Estate in Elf 
    */
    function onAgencyAdded(uint tokenId) public;

    /**
    * @dev called when this token is removed as an agent for an Estate in Elf 
    */
    function onAgencyRemoved(uint tokenId) public;

    /**
    * @dev this permits fee free bulk transfers by outside parties, in order to facilitate mass adoption by third party payment processors 
    */
    function bulkTransfer(address[] sources, address[] dest, uint[] amounts) public returns (address last);
}

contract IXAV {
    function mint(uint amount) public;
    function burn(uint amount) public;
    function withdraw(uint amount, address dest, address _user) public;
    function depositTo(address _to) public payable returns (uint tokens);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) public view returns (uint256);
}

contract IEstate is IManaged, IERC721, IERC721Metadata, IERC721Enumerable{

    //Set the elf contract to enable surrenders, trustonly
    function setELF(address elf) public;

    //Mint a new token, managed
    function mint(address addr) public payable returns (uint);
    
    //Burn a token, managed
    function burn(uint tokenID) public payable returns (bool);
    
    //Tokens held by owner
    function tokensOfOwner(address owner) public view returns (uint256[]);

    //Called by the ELF contract when a token has been surrendered by its owner
    //This transfers the token to the ELF contract with no intervention by the user other than initiating it
    function surrendered(uint tokenId) public;

    //Trasfer a tokenId to an address
    function transfer(uint tokenId, address to) public;

}

/**
* Functions related to treasury rights
*/
contract ITR /* is ERC20, IManaged*/{
    //This will mint to the designated agent for the Estate token tokenId, if unset will throw
    function mint(uint tokenId) public returns (uint minted);
    //Burn a TR from an account that has given permission to msg.sender
    function burnFrom(address account, uint amount) public;
    //Set the token used for Estates (breaks a circular dependency), this is manager only
    function setEstate(address estate) public;

    //Function to determine if an Estate can mint a TR and if so, how many
    function canMint(uint tokenId) public view returns (uint avail);
}

interface IApproveAndCallFallBack{
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}

contract XToken is IXToken, ERC20{
    using Address for address;
    using SafeMath for uint;

    function XToken(string memory name, string memory symbol, uint8 decimals) public 
        ERC20(name,symbol,decimals){
        _owner = msg.sender;
        _mints[msg.sender] = true;
        managers[msg.sender] = true;
        fee.p = 1;
        fee.q = 1000;
        rate.p = 1;
        rate.q = 1 ether;
    }

    function setRate(uint _p, uint _q) public managed{
        rate.p = _p;
        rate.q = _q;
        DepositRateChanged(rate.p,rate.q);
    }

    function setFee(uint _p, uint _q) public managed{
        require(_p < _q);
        _setFee(_p, _q);
    }

    function _setFee(uint _p, uint _q) internal{
        fee.p = _p;
        fee.q = _q;
        FeeChanged(fee.p,fee.q);
    }

    function getFee() public returns (uint[2] _fee){
        _fee[0] = fee.p;
        _fee[1] = fee.q;
    }

    function transfer(address to, uint256 value) public returns (bool status) {
        collectInterest(msg.sender);
        uint feeAmt = calcFee(value);
        if(_balances[msg.sender] >= value + feeAmt){
            super.transfer(to, value);
            collectInterest(to);
            if(feeAmt > 0){
                _burn(msg.sender, feeAmt);
                _burn(to, feeAmt);
                fees += feeAmt;
            }
            status = true;
        }
        adjustBalanceSheet();
        return status;
    }


    function getInterestPaid(address user) public view returns (uint paid){
        return intPaid[user];
    }

    function collectInterest(address user) public returns(uint interest){
        interest = calcInterest(user);
        if(interest > 0){
            lastIDate[user] = now;
            if(fees > interest){
                fees = fees.sub(interest);
            }
            _mint(user,interest);
            intPaid[user] = intPaid[user].add(interest);
            InterestPaid(user, interest);
        }
    }

    function calcFee(uint value) public view returns (uint feeAmt){
        feeAmt = value * fee.p / fee.q;
        return feeAmt;
    }

    function calcInterest(address user) public view returns(uint interest){
        uint minBal = fee.q;
        uint bal = _balances[user];
        uint elapsed = (now - lastIDate[user]) / (1 days);
            
        if(elapsed > 0 && fees > 0 && (bal > minBal) && _totalSupply > 0){
            interest = fees * bal / _totalSupply;
            interest = interest == 0 ? 1 : interest;
            interest = interest > fees ? fees : interest;
        }
        return interest;
    }

    function awardMana(uint amount, address user) public mintonly{
        require(msg.sender == _ar);
        uint total = amount * _manaRate;
        _mint(user,total);
    }

    function mint(uint amount) public payable{
        if(!isMint(msg.sender)){
            require(weiToTokens(msg.value) >= amount);
        }
        _mint(msg.sender, amount);
        adjustBalanceSheet();

    }

    function burn(uint amount) public{
        _burn(msg.sender, amount);
    }
    
    function depositTo(address _to) public payable returns (uint tokens){
        Deposit(msg.sender, msg.value);
        tokens = weiToTokens(msg.value);
        if(_to != address(this) && tokens > 0){
            _mint(_to, tokens);
            adjustBalanceSheet();
        }
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success){
        require(_balances[msg.sender] >= tokens);
        _allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        IApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function withdraw(uint amount, address dest, address _user) public unlocked{
        uint feeAmt = calcFee(amount);
        if(_balances[msg.sender] >= amount + feeAmt){
            burn(amount - feeAmt);
            burn(feeAmt);
            uint total = tokensToWei(amount - feeAmt);
            if(dest.isContract()){
                IXAV(_xav).withdraw(total, dest, _user);
            }else{
                ERC20(_xav).transfer(dest,total);
            }
            fees += feeAmt;
        }
        adjustBalanceSheet();
    }

    function withdraw(uint amount, address user) public unlocked{
        withdraw(amount,user,user);
    }

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public{
        tokens = ERC20(token).allowance(from,address(this));
        require(tokens > 0);
        ApprovalReceived(token, from, tokens);
        require(ERC20(token).transferFrom(from, address(this), tokens));
        if(token == _xav){
            uint qty = weiToTokens(tokens);
            if(qty > 0){
                _mint(from,qty);
                ApprovalProcessed(token, from, tokens);
            }
            adjustBalanceSheet();
        }
    }

    function adjustBalanceSheet() internal{

        uint ctrBal = ERC20(_xav).balanceOf(address(this));
        uint ctrExpected = tokensToWei(totalSupply());
        
        if(ctrExpected > ctrBal){
            uint shortFall = ctrExpected - ctrBal;
            IXAV(_xav).mint(shortFall);
        }

        if(ctrBal > ctrExpected){
            uint overage = ctrBal - ctrExpected;
            IXAV(_xav).withdraw(overage, address(this),address(this));
            //Send overage to elf as ETH
            if(overage <= address(this).balance){
                _elf.send(overage); //We can't afford for this to fail and jam the contract
            } 
        }

        if(address(this).balance > 0){ 
            _xav.send(address(this).balance); //We can't afford for this to fail and jam the contract
        }
        adjustFees();
    }

    function adjustFees() internal{
        uint q = fee.q;
        uint weiBal = _xav.balance;

        if(weiBal >= ERC20(_xav).totalSupply()){
            //Excess wei, lower fees
            q = fee.q < 1000 ? fee.q + 1 : fee.q;
        }else{
            //Short on wei, increase fees
            q = fee.q > 20 ? fee.q - 1 : fee.q;
        }
        //Set fee if changed
        if(fee.q != q){
            _setFee(fee.p, q);
        }
    }

    function weiToTokens(uint w) public view returns (uint tokens){
        tokens = w * rate.p / rate.q;
    }

    function tokensToWei(uint tokens) public view returns (uint w){
        w = tokens * rate.q / rate.p;
    }

    function onAgencyAdded(uint tokenId) public{
        require(elf.getAgent(tokenId) == address(this));
        uint limit = elf.getCreditLimit(tokenId);
        require(limit > 0);
        address owner = IEstate(_estate).ownerOf(tokenId);
        require(ITR(_tr).canMint(tokenId) > 0 || ERC20(_tr).balanceOf(address(this)) >= 1);
        if(ITR(_tr).canMint(tokenId) > 0){
            ITR(_tr).mint(tokenId);
        }
        ERC20(_tr).approve(_elf,1);
        elf.debit(tokenId, limit, address(this), owner);
    }

    function onAgencyRemoved(uint tokenId) public{
        require(tokenId == tokenId);
    }

    function bulkTransfer(address[] sources, address[] dest, uint[] amounts) public returns (address last){
        uint x = 0;
        for(x = 0; x <= sources.length -1; x++){
            if(msg.gas > 42000){
                uint allowance = _allowed[sources[x]][msg.sender];
                uint balance = _balances[sources[x]];
                if(balance >= allowance && allowance >= amounts[x]){
                    last = sources[x];
                    transferFrom(last, dest[x], amounts[x]);
                }else{
                    BulkXfrFail(sources[x], dest[x], amounts[x]);
                }
            }else{
                break;
            }
        }
    }
}
