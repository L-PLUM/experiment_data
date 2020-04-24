/**
 *Submitted for verification at Etherscan.io on 2018-12-18
*/

pragma solidity ^0.4.24;

contract Token {

    /// @return total amount of tokens
    function totalSupply()public pure returns (uint256 ) {}

    /// @return The balance
    function balanceOf(address ) public constant returns (uint256 ) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @return Whether the transfer was successful or not
    function transfer(address , uint256 )public  returns (bool ) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @return Whether the transfer was successful or not
    function transferFrom(address , address , uint256 ) public returns (bool ) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @return Whether the approval was successful or not
    function approve(address , uint256 )public returns (bool ) {}

    /// @return Amount of remaining tokens allowed to spent
    function allowance(address , address ) public constant returns (uint256 ) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        uint256 _value = value  * 10 ** uint256(18);
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        balance = balances[_owner];
        return balance;
    }

    function approve(address _spender, uint256 _value)public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      remaining=allowed[_owner][_spender];
      return ;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}


//name this contract whatever you'd like
contract ERC20Token is StandardToken {

    function () public{
        //if ether is sent to this address, send it back.
        return;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals=18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

//
// CHANGE THESE VALUES FOR YOUR TOKEN
//

//make sure this function name matches the contract name above. So if you're token is called TutorialToken, make sure the //contract name above is also TutorialToken instead of ERC20Token

     constructor(

        ) public{            // Give the creator all initial tokens (100000 for example)
        totalSupply = 1000000000 * 10 ** uint256(decimals);                        // Update total supply (100000 for example)
        balances[msg.sender] = totalSupply;  
        name = " Cost Token";                                   // Set the name for display purposes                           // Amount of decimals for display purposes
        symbol = "Cost";                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { return false; }
        return true;
    }
}
