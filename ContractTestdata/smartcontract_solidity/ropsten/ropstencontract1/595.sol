/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.3;

contract WFT8 {

	// token attributes
	string public constant name = "W. Fund Test #8";
	string public constant symbol = "WFT8";
	uint8 public constant decimals = 18; 
	// address of contract creator
	address contractCreator;
	// address of additional contract operator
	address staffRole;
	// variable used to disable/enable transfers
	bool contractTransfers = false;
	
	
	// events
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
	event Transfer(address indexed from, address indexed to, uint tokens);
	event SetReinvestmentPreference(address indexed caller, address indexed receiver, uint8 percentage);
	event Burn(address indexed from, uint256 value);
	event Freeze(address indexed recipient, string  reason);
	event Unfreeze(address indexed recipient, string reason);		
	
	struct Account 
	{
		uint256 cash;
		uint8 reinvestmentPreference; //%0 reinvestment as default
		bool frozen;
	}
	
	mapping(address => Account) balances;
	mapping(address => mapping (address => uint256)) allowed;
	
	uint256 totalSupply_;
	using SafeMath for uint256;

	constructor() public {  
		totalSupply_ = 5000000 * 10 ** uint256(decimals);
		balances[msg.sender].cash = totalSupply_ ;        
		contractCreator = msg.sender;
		staffRole = msg.sender;
		contractTransfers=false;
	}
	
	/**
	 * Get Total Supply     
	 */
	
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}
	
	/**
	 * balanceOf
	 * Get balance of an address
	 * @param tokenOwner address owner of tokens
	 */
	
	function balanceOf(address tokenOwner) public view returns (uint) {
		return balances[tokenOwner].cash;
	}
	
	/**
	 * SetReinvestmentPreference
	 *
	 * Set reinvestment preference of a wallet. 
	 * Can be called by the contract creator or by the token owner
	 *
	 * @param recipient address that will have the preference changed
	 * @param percentage reinvestment preference, can be 0, 50 or 100
	 */
	
	function setReinvestmentPreference(address recipient, uint8 percentage ) public returns (bool){		
		require( balances[recipient].cash > 0 , "Recipient balance should be greater than zero.");
		require( msg.sender == recipient || msg.sender == contractCreator || msg.sender == staffRole, "You are not allowed to call this function." );
		require( percentage == 0 || percentage == 50 || percentage == 100, "Please specify only 0, 50, 100 as a reinvestment preference." );
		balances[recipient].reinvestmentPreference = percentage;
		emit SetReinvestmentPreference(msg.sender, recipient, percentage);
		return true;
	}
	
	/**
	* Assign Delegate
	*
	* Assign as Delegate an address
	* 
	*/
	
	function assignStaffRole( address staffrole ) public returns (bool) {
		require( msg.sender == contractCreator, "You are not allowed to call this function.");		
		staffRole = staffrole;
		return true;	
	}

	/**
	* Revoke Staff Role
	*
	* Revoke Staff Role
	* 
	*/
	
	function revokeStaffRole() public returns (bool) {
		require( msg.sender == contractCreator, "You are not allowed to call this function.");		
		staffRole = contractCreator;
		return true;	
	}	
	
	/**
	 * reinvestmentPreferenceOf
	 *
	 * Return reinvestment preference of an address.
	 *
	 * @param tokenOwner address that own tokens
	 */
	
	function reinvestmentPreferenceOf(address tokenOwner) public view returns (uint8) {
		return balances[tokenOwner].reinvestmentPreference;
	}
	
	/**
	 * Transfer tokens
	 *
	 * Send `numTokens` tokens to `receiver` from your account
	 *
	 * @param receiver The address of the recipient
	 * @param numTokens the amount to send
	 */
	
	function transfer(address receiver, uint numTokens) public returns (bool) 
	{
		// contract transfers should be enabled (contract owner can always transfer tokens)
		require(contractTransfers==true||msg.sender==contractCreator,"You are not allowed to transfer tokens.");
		require(numTokens <= balances[msg.sender].cash, "You don't have so many tokens." );
		require(balances[msg.sender].frozen == false && balances[receiver].frozen == false, "either sender or receiver accounts are frozen.");
		balances[msg.sender].cash = balances[msg.sender].cash.sub(numTokens);
		balances[receiver].cash = balances[receiver].cash.add(numTokens);        
		emit Transfer(msg.sender, receiver, numTokens);
		return true;
	}

	function approve(address delegate, uint numTokens) public returns (bool) {
		allowed[msg.sender][delegate] = numTokens;
		emit Approval(msg.sender, delegate, numTokens);
		return true;
	}
	
	function allowance(address owner, address delegate) public view returns (uint) {
		return allowed[owner][delegate];
	}
		
	/**
	 * Transfer tokens from other address
	 *
	 * Send `numTokens` tokens to `buyer` in behalf of `owner`
	 *
	 * @param owner The address of the sender
	 * @param buyer The address of the recipient
	 * @param numTokens the amount to send
	 */
	 
	function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {		
		// contract transfers should be enabled (contract owner and delegate can always transfer tokens)	
		require(contractTransfers==true||msg.sender==contractCreator,"You are not allowed to transfer tokens.");
		require(numTokens <= balances[owner].cash, "seller doesn't have so many tokens.");    
		require(numTokens <= allowed[owner][msg.sender], "seller don't have rights to sell so many tokens.");
		require(balances[owner].frozen == false && balances[buyer].frozen == false, "either sender or receiver accounts are frozen.");
		balances[owner].cash = balances[owner].cash.sub(numTokens);
		allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
		balances[buyer].cash = balances[buyer].cash.add(numTokens);
		emit Transfer(owner, buyer, numTokens);
		return true;
	}
	
	/**
	 * Destroy tokens
	 *
	 * Remove `numTokens` tokens from the system irreversibly
	 * Only owner creator can call it and for creator wallet only.
	 *
	 * @param numTokens the amount of money to burn
	 */
	 
	function burn(uint256 numTokens) public returns (bool success) {
		require( msg.sender == contractCreator, "You are not allowed to call this function." );
		require(balances[msg.sender].cash >= numTokens, "You do not own so many tokens");
		balances[msg.sender].cash = balances[msg.sender].cash.sub(numTokens);				        
		totalSupply_ -= numTokens;
		emit Burn(msg.sender, numTokens);
		return true;
	}
		
	/**
	 * Freeze account
	 *
	 * Mark an account so he cannot transfer or be transfered tokens.
	 * Can be called only by contract Owner.
	 *
	 * @param recipient address that is frozen.
	 * @param reason Reason for Freeze
	 */
	
	function freeze(address recipient, string memory reason) public returns (bool success) {					
		require( msg.sender == contractCreator, "You are not allowed to call this function." );
		balances[recipient].frozen = true;		
		emit Freeze(recipient,reason);
		return true;
	}
	
	/**
	 * Unfreeze account
	 *
	 * Unfreeze an account
	 *
	 * @param recipient address that is unfrozen;
	 * @param reason Reason for Unfreeze
	 */

	function unfreeze(address recipient, string memory reason) public returns (bool success) {
		require( msg.sender == contractCreator, "You are not allowed to call this function." );
		balances[recipient].frozen = false;
		emit Unfreeze(recipient,reason);
		return true;
	}
	
	/**
	 * isFrozen
	 *
	 * Return if an address is frozen
	 *
	 * @param tokenOwner address
	 */
	
	function isFrozen(address tokenOwner) public view returns (bool) {
		return balances[tokenOwner].frozen;
	}
	
	/*
	* freezeContractTransfers
	* 
	* Freeze Contract Transfers	
	*/
	
	function setContractTransfers( bool flag ) public returns (bool success)
	{
		require( msg.sender == contractCreator, "You are not allowed to call this function." );
		contractTransfers = flag;
		return true;
	}	
}

library SafeMath { 
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
	  assert(b <= a);
	  return a - b;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
	  uint256 c = a + b;
	  assert(c >= a);
	  return c;
	}
}
