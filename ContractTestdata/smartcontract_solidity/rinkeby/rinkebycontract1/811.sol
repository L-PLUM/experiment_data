/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.25;

contract WETH9 {

    uint256 public constant MAX_MINT_AMOUNT = 10**27;
    uint256 public constant MAX_MINT_AMOUNT_REQUEST = 10**23;

    string public name     = "WETH test roboDEX token";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed _owner, address indexed _spender, uint _value);
    event  Transfer(address indexed _from, address indexed _to, uint _value);
    event  Deposit(address indexed _owner, uint _value);
    event  Withdrawal(address indexed _owner, uint _value);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    uint internal _totalSupply;

    function() public payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return safeAdd(this.balance, _totalSupply);
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }

    /// @dev Mints new tokens for sender
    /// @param _value Amount of tokens to mint
    function mint(uint256 _value) external {
        require(
            _value <= MAX_MINT_AMOUNT,
            "VALUE_TOO_LARGE"
        );
        require(
            _value <= MAX_MINT_AMOUNT,
            "VALUE_TOO_LARGE"
        );
        balanceOf[msg.sender] = safeAdd(_value, balanceOf[msg.sender]);
        _totalSupply = safeAdd(_totalSupply, _value);
        Transfer(address(0), msg.sender, _value);
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(
            c >= a,
            "UINT256_OVERFLOW"
        );
        return c;
    }
}
