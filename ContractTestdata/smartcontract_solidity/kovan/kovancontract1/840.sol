/**
 *Submitted for verification at Etherscan.io on 2018-12-27
*/

pragma solidity ^0.4.2;

contract PeerCash {
	string public name = "Peer Cash";
	string public symbol = "PRC";
	string public standard = "Peer Cash v1.0";
    uint256 public totalSupply;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    // approve
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    

    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    
    function PeerCash (uint256 _initialSupply) public {
    	balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }

    // Transfer
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    // Deligated Transfer
    function approve(address _spender, uint256 _value) public returns (bool success) {
          // allowance
          allowance[msg.sender][_spender] = _value;

          // approve event
          Approval(msg.sender, _spender, _value);
        return true;
        
    }
    
    // transferFrom
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        // Require _from has enough tokens
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        // Change the balance
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        // update the allowance
        allowance[_from][msg.sender] -= _value;
        // Transfer event
        Transfer(_from, _to, _value);
        // return a boolean
        return true;
    }
}
