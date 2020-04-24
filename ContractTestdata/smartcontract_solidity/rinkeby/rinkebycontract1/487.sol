/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity >= 0.4.16;



contract SpeedPropTokenData
{
    // This creates an array with all balances
    string  public name;
    string  public symbol;
    uint256 public _totalSupply;
    uint8   public decimals = 0;  

    mapping (address => uint256) public  balanceOf;
    mapping (address => mapping (address => uint256)) public _allowance;
    address owner;

    event TransferToken(address _from, address _to, string _msg);
    event AllowanceSet(address _holder,address _spender, uint256 _value);
	event ContractDeactivated(string _msg);
	event ContractNotDeactivated(string _msg);

	
	
    constructor (string _name, string _symbol,uint256 _totalSupplyValue) public payable
    {
        name=_name;
        symbol = _symbol;
        _totalSupply = _totalSupplyValue;
        owner = msg.sender;
        balanceOf[owner] = _totalSupply;
    }
    
    function _transfer(address _from, address _to, uint _value) public 
    {
        require(_to != address(0x0));                                   // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);                            // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);             // Check for overflows
        uint previousBalances = balanceOf[_from] + balanceOf[_to];      // Save this for an assertion in the future
        balanceOf[_from] -= _value;                                     // Subtract from the sender
        balanceOf[_to] += _value;                                       // Add the same to the recipient

        emit TransferToken( _from, _to, "transfer done!");
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // Asserts are used to use static analysis to find bugs in your code. They should never fail
    }
    
    function getBalance(address _to) public view returns (uint)
    {
        return balanceOf[_to];
    }
    function getName() public view returns (string memory )
    {
        return name;
    }
    function getSymbol() public view returns (string memory )
    {
        return symbol;
    }
    function getTotalSupply() public view returns (uint )
    {
        return _totalSupply;
    }
    function _getAllowanc(address _holder,address _spender) public view returns (uint )
    {
        return _allowance[_holder][_spender];
    }
      
    
    function _setAllowance(address _holder,address _spender, uint256 _value) public
    {
        _allowance[_holder][_spender] = _value;
        emit AllowanceSet(_holder,_spender,_value);
    }

	function deactivateIt() public payable {
			emit ContractDeactivated("The contract is being deactivated...");
			selfdestruct(owner);
    }
    

}
