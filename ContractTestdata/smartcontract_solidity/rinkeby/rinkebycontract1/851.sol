/**
 *Submitted for verification at Etherscan.io on 2019-02-06
*/

pragma solidity ^0.4.24;

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

contract HomesCoin is ERC20Interface {

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    
    address owner;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;
    
    


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "HOM";
        name = "HomesCoin";
        decimals = 18;
        _totalSupply = 1000000 * 10**uint(decimals);
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(owner, address(0), _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(to!=address(0));
        require(tokens<=balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to!=address(0));
        require(balances[from]>=tokens);
        require(allowed[from][msg.sender]>=tokens);
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () external payable {
        revert();
    }
    
    function mint(address target, uint amt) public{
        require(msg.sender==owner);
        balances[target] += amt;
        emit Transfer(target, address(0), amt);
    }
    function burn(uint amt) public{
        require(msg.sender==owner);
        require(balances[owner]>=amt);
        balances[owner]-=amt;
    }
    
    function destroy() public {
        require(msg.sender==owner);
        selfdestruct(msg.sender);
    }
    
    event HomeSaleEvent(uint64 houseid, uint8 day, uint8 month, uint16 year, uint64 price100, string source);
    
    mapping(uint64=>string) public addresses;
    mapping(uint64=>uint32) public sqfts;
    mapping(uint64=>uint8) public bedrooms;
    mapping(uint64=>uint8) public bathrooms;
    mapping(uint64=>uint8) public house_type;
    mapping(uint64=>uint16) public year_built;
    mapping(uint64=>uint32) public lot_size;
    mapping(uint64=>uint64) public parcel_num;
    mapping(uint64=>uint32) public zipcode;
    
    uint64 public num_houses = 0;
    
    function makeEvent(uint64 houseid, uint8 day, uint8 month, uint16 year, uint64 price100, string memory source) public{
        require(msg.sender==owner);
        emit HomeSaleEvent(houseid,day,month,year, price100, source);
    }
    function addHouse(string memory adr, uint32 sqft, uint8 bedroom,uint8 bathroom,uint8 h_type, uint16 yr_built, uint32 lotsize, uint64 parcel, uint32 zip) public{
        require(msg.sender==owner);
        addresses[num_houses] = adr;
        sqfts[num_houses]=sqft;
        bedrooms[num_houses]=bedroom;
        bathrooms[num_houses]=bathroom;
        house_type[num_houses]=h_type;
        year_built[num_houses]=yr_built;
        lot_size[num_houses] = lotsize;
        parcel_num[num_houses] = parcel;
        zipcode[num_houses] = zip;
        num_houses++;
    }
    function resetHouseParams(uint64 num_house, uint32 sqft, uint8 bedroom,uint8 bathroom,uint8 h_type, uint16 yr_built, uint32 lotsize, uint64 parcel, uint32 zip) public{
        require(msg.sender==owner);
        sqfts[num_house]=sqft;
        bedrooms[num_house]=bedroom;
        bathrooms[num_house]=bathroom;
        house_type[num_house]=h_type;
        year_built[num_house]=yr_built;
        lot_size[num_house] = lotsize;
        parcel_num[num_house] = parcel;
        zipcode[num_house] = zip;
    }
}
