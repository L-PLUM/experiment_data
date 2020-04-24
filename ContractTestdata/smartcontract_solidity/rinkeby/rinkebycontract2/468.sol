/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

/**
 *Submitted for verification at Etherscan.io on 2017-12-14
 */

pragma solidity ^0.4.15;

/**
 * @title Safe math operations that throw error on overflow.
 *
 * Credit: Taking ideas from FirstBlood token
 */
library SafeMath {

    /**
     * @dev Safely add two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x+y.
     */
    function add(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    /**
     * @dev Safely substract two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x-y.
     */
    function sub(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    /**
     * @dev Safely multiply two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x*y.
     */
    function mul(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z/x == y));
        return z;
    }

    /**
     * @dev Parse a floating point number from String to uint, e.g. "250.56" to "25056"
     */
    function parse(string s)
    internal constant
    returns (uint256)
    {
    bytes memory b = bytes(s);
    uint result = 0;
    for (uint i = 0; i < b.length; i++) {
        if (b[i] >= 48 && b[i] <= 57) {
            result = result * 10 + (uint(b[i]) - 48);
        }
    }
    return result;
}
}

/**
 * @title The abstract ERC-20 Token Standard definition.
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract Token {
    /// @dev Returns the total token supply.
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /// @dev MUST trigger when tokens are transferred, including zero value transfers.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @dev MUST trigger on any successful call to approve(address _spender, uint256 _value).
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Default implementation of the ERC-20 Token Standard.
 */
contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

    /**
     * @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event.
     * @dev The function SHOULD throw if the _from account balance does not have enough tokens to spend.
     *
     * @dev A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transfer(address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
            balances[_to] = SafeMath.add(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
     *
     * @dev The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf.
     * @dev This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in
     * @dev sub-currencies. The function SHOULD throw unless the _from account has deliberately authorized the sender of
     * @dev the message via some mechanism.
     *
     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.
     *
     * @param _from The sender of the tokens.
     * @param _to The receiver of the tokens.
     * @param _value The amount of tokens to send.
     * @return True on success, false otherwise.
     */
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[_to] = SafeMath.add(balances[_to], _value);
            balances[_from] = SafeMath.sub(balances[_from], _value);
            allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns the account balance of another account with address _owner.
     *
     * @param _owner The address of the account to check.
     * @return The account balance.
     */
    function balanceOf(address _owner)
    public constant
    returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount.
     * @dev If this function is called again it overwrites the current allowance with _value.
     *
     * @dev NOTE: To prevent attack vectors like the one described in [1] and discussed in [2], clients
     * @dev SHOULD make sure to create user interfaces in such a way that they set the allowance first
     * @dev to 0 before setting it to another value for the same spender. THOUGH The contract itself
     * @dev shouldn't enforce it, to allow backwards compatilibilty with contracts deployed before.
     * @dev [1] https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
     * @dev [2] https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     * @return True on success, false otherwise.
     */
    function approve(address _spender, uint256 _value)
    public
    onlyPayloadSize(2)
    returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Returns the amount which _spender is still allowed to withdraw from _owner.
     *
     * @param _owner The address of the sender.
     * @param _spender The address of the receiver.
     * @return The allowed withdrawal amount.
     */
    function allowance(address _owner, address _spender)
    public constant
    onlyPayloadSize(2)
    returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}


/**
 * @title The EVNToken Token contract.
 *
 * Credit: Taking ideas from BAT token and NET token
 */
 /*is StandardToken */
contract EVNToken is StandardToken {

    // Token metadata
    string public constant name = "miniEnigma";
    string public constant symbol = "ENG";
    uint256 public constant decimals = 18;

  

    /**
     * @dev Create a new EVNToken contract.
     *
     *  _fundingStartBlock The starting block of the fundraiser (has to be in the future).
     *  _fundingEndBlock The end block of the fundraiser (has to be after _fundingStartBlock).
     *  _roundTwoBlock The block that changes the discount rate to 20% (has to be between _fundingStartBlock and _roundThreeBlock).
     *  _roundThreeBlock The block that changes the discount rate to 10% (has to be between _roundTwoBlock and _roundFourBlock).
     *  _roundFourBlock The block that changes the discount rate to 0% (has to be between _roundThreeBlock and _fundingEndBlock).
     *  _admin1 The first admin account that owns this contract.
     *  _admin2 The second admin account that owns this contract.
     *  _tokenVendor The account that creates tokens for credit card / fiat contributers.
     */
    function EVNToken()
    {
        balances[msg.sender] = 1000;        
    }


    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transfer(address _to, uint256 _value)
    public
    onlyPayloadSize(2)
    returns (bool success)
    {
        bool result = super.transfer(_to, _value);

        return result;
    }

    // Overridden method to check for end of fundraising before allowing transfer of tokens
    function transferFrom(address _from, address _to, uint256 _value)
    public

    onlyPayloadSize(3)
    returns (bool success)
    {
        bool result = super.transferFrom(_from, _to, _value);
        return result;
    }

    // Allow for easier balance checking
    function getBalanceOf(address _owner)
    constant
    returns (uint256 _balance)
    {
        return balances[_owner];
    }
}
