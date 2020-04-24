/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

contract ERC20 {
    // Basic token features: book of balances and transfer
    uint public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    function transfer(address to, uint tokens) public returns (bool success);
    
    // Advanced features: An account can approve another account to spend its funds
    mapping(address => mapping (address => uint256)) public allowance;
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract FishTHB is ERC20 {
    // metadata for wallets
    string public constant name = "Fish Stablecoin Baht";
    string public constant symbol = "FTHB";
    uint8 public constant decimals = 2;

    function mint(address to, uint256 value) public {
        require(totalSupply + value > totalSupply, "Overflow");
        balanceOf[to] += value;
        emit Transfer(0, to, value);
        totalSupply += value;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Not enough tokens");
        require(value > 0, "Zero transfer");
        require(balanceOf[to] + value > balanceOf[to], "Overflow");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowance[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }    
    
    function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(balanceOf[from] >= value, "Not enough tokens");
        require(value > 0, "Zero transfer");
        require(balanceOf[to] + value > balanceOf[to], "Overflow");
        require(allowance[from][msg.sender] >= value, "Not enough allowance");
        balanceOf[from] -= value;
        allowance[from][msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}
