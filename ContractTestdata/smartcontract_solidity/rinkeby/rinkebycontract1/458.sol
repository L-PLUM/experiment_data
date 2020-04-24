/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity >=0.4.22 <0.6.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract RWToken is ERC20Interface {

    string public name;
    string public symbol;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint8 public decimals = 18;
    uint256 public _totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public _balanceOf;
    mapping (address => mapping (address => uint256)) public _allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor( ) public {
        _totalSupply = 10000000 * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        _balanceOf[msg.sender] = _totalSupply;                // Give the creator all initial tokens
        name = "RWToken";                                   // Set the name for display purposes
        symbol = "RWT";                               // Set the symbol for display purposes
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance){
        return _balanceOf[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return _allowance[tokenOwner][spender];
    }

    function transfer(address to, uint tokens) public returns (bool success){
        // Previne transferencia para endereço 0x0.
        require(to != address(0x0), "Não é possível envia tokens para esse endereço.");
        require(_balanceOf[msg.sender] >= tokens, "Não há saldo suficiente.");
        // Check for overflows
        require(_balanceOf[to] + tokens >= _balanceOf[to], "Operação inválida.");

        uint previousBalance = _balanceOf[msg.sender] + _balanceOf[to];

        _balanceOf[msg.sender] -= tokens;
        _balanceOf[to] += tokens;
        emit Transfer(msg.sender, to, tokens);

        assert(_balanceOf[msg.sender] + _balanceOf[to] == previousBalance);

        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success){
        _allowance[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require(tokens <= _allowance[from][msg.sender], "Operação inválida.");     // Check allowance
        _allowance[from][msg.sender] -= tokens;
        transfer(to, tokens);
        return true;
    }

}
