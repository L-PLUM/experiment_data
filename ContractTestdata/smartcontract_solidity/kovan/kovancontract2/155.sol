/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity >=0.5.0;

contract SideToken {

    uint8   public decimals = 18;
    string  public name;
    string  public symbol;
    uint256 public totalSupply;

    address public manager;
    address owner;

    modifier ownable {
        require(msg.sender == owner);
        _;
    }

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    function setManager(address _newmanager) public ownable {
        require(_newmanager != address(0));

        if(_newmanager != manager) {
            manager = _newmanager;
        }
    }

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "math-sub-underflow");
    }

    constructor(string memory _symbol, string memory _name, address _manager) public {
        symbol = _symbol;
        name = _name;
        manager = _manager;
        owner = msg.sender;
    }

    // --- Token ---
    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) public returns (bool)
    {
        require(balanceOf[src] >= wad, "insufficient-balance");
        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= wad, "insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);

        if(dst == manager) {
            balanceOf[dst]  = sub(balanceOf[dst], wad);
            totalSupply     = sub(totalSupply, wad);
        }
        emit Transfer(src, dst, wad);
        return true;
    }
    function approve(address usr, uint wad) public returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }
}
