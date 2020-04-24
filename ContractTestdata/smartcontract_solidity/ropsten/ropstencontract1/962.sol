/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

/**
 * Main contract (Token contract) for Blockcoach Community
 * 
 * Author: Evan Liu ([email protected])
 * Release version: 0.2.0
 * Last revision date: 2019-02-11
 */
pragma solidity >=0.4.22 <0.6.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
 * @title Congress interface
 */
contract CongressInterface {
    /* check if there is still enough budget approved by the congress.
     * this function should be idempotent.
     */
    function isBudgetApproved(uint256 amount) public view returns (bool);

    /* consume the approved budget, i.e. deduct the number.
     */
    function consumeBudget(uint256 amount) public;

    /* check if the specified new owner has been approved by the congress.
     * this function should be idempotent.
     */
    function isOwnerApproved(address newOwner) public view returns (bool);

    /* check if the specified new congress has been approved by the congress.
     * this function should be idempotent.
     */
    function isCongressApproved(address newCongress) public view returns (bool);
}

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

contract owned {
    address public owner;
    address public newOwner;
    CongressInterface public congress;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    event CongressUpgraded(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "only owner can do it");
        _;
    }

    // owner can change(upgrade) new congress, but requires congress's approval
    function changeCongress(address newCongress) onlyOwner public {
        if (address(congress) != address(0)) {
            require(congress.isCongressApproved(newCongress) == true, "congress approval required");
        }

        emit CongressUpgraded(address(congress), newCongress);
        congress = CongressInterface(newCongress);
    }

    // anyone can try to change president but requires congress's approval
    function changeOwner(address _newOwner) public {
        require(address(congress) != address(0), "non-empty congress required");
        require(congress.isOwnerApproved(_newOwner) == true, "congress approval required");
        newOwner = _newOwner;
    }
    
    // double confirm
    function acceptOwnership() public {
        require(msg.sender == newOwner, "only approved owner can accept");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract BCSToken is owned {
    using SafeMath for uint;

    // Public variables of the token
    string public name = "Blockcoach Community Shell";
    string public symbol = "BCS";
    uint8 public decimals = 18;
    uint public totalSupply = 0; // Starting from ZERO.

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    constructor() public {
        // initialize 1 tokens for cold start
        totalSupply = 1 * 10 ** uint(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0), "no receiver");
        // Check if the sender has enough
        require(balanceOf[_from] >= _value, "not enough funds");
        // Check for overflows
        require(balanceOf[_to].add(_value) >= balanceOf[_to], "receiver overflows");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens to multiple receivers.
     */
    function multiTransfer(address[] memory destinations, uint[] memory tokens) public returns (bool success) {
        require(destinations.length > 0, "no receiver");
        require(destinations.length < 128, "too many receivers");
        require(destinations.length == tokens.length, "receivers<=>amount not match");
        uint8 i = 0;
        uint totalTokensToTransfer = 0;
        for (i = 0; i < destinations.length; i++){
            require(tokens[i] > 0, "cannot send 0 amount");
            totalTokensToTransfer = totalTokensToTransfer.add(tokens[i]);
        }
        require(balanceOf[msg.sender] > totalTokensToTransfer, "not enough funds");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalTokensToTransfer);
        for (i = 0; i < destinations.length; i++){
            balanceOf[destinations[i]] = balanceOf[destinations[i]].add(tokens[i]);
            emit Transfer(msg.sender, destinations[i], tokens[i]);
        }
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "not enough funds approved");     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "not enough funds");   // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "not enough funds");                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender], "not enough funds approved");    // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    /** @notice Create `mintedAmount` tokens and send it to `target`
     *  @param target the address to receive the minted tokens
     *  @param mintedAmount the amount of tokens it will receive
     *
     * only owner can initiate the mint, but requires congress to approve the budget
     */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        require(address(congress) != address(0), "setup a congress first");
        require(congress.isBudgetApproved(mintedAmount) == true, "not enough budget");

        if (target == address(0)) {
            target = msg.sender;
        }

        congress.consumeBudget(mintedAmount); //deduct first.

        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), address(target), mintedAmount);
    }
    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) onlyOwner public returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    
}
