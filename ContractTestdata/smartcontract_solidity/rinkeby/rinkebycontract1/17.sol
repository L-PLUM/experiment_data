/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity^0.5.1;

contract BoshToken {
    string public name = "BoshToken";
    string public symbol = "BOSH";
    uint8 public decimals = 9;
    string public standard = "Bosh Token v1.0";
    address public tokenOwner = 0x2E23fcf48E3f8Fcf3aBD03654E4dB657F00D5285;
    uint256 public tokenPrice = 680000000000000; // in wei = $0.1
    uint256 public totalSupply = 5000000000;
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address =>uint256)) public allowance;

    constructor () public {
        balanceOf[tokenOwner] = totalSupply;
    }

    // Transfer
    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // approve
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // allowence
        allowance[msg.sender][_spender] = _value;
        // Approve event
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transferfrom
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        
        require(_value <= allowance[_from][msg.sender]);
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        
        return true;
    } 
}
