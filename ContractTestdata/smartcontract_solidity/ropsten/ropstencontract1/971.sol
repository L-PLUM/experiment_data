/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;

	contract owned {

		constructor() public { owner = msg.sender; }
		address owner;

		// This contract only defines a modifier but does not use
		// it: it will be used in derived contracts.
		// The function body is inserted where the special symbol
		// `_;` in the definition of a modifier appears.
		// This means that if the owner calls this function, the
		// function is executed and otherwise, an exception is
		// thrown.
		
		modifier onlyOwner {
			require(
				msg.sender == owner,
				"Only owner can call this function."
			);
			_;
		}
	}

	contract WFT5 is owned {

		// token attributes
		string public constant name = "W. Fund Test #5";
		string public constant symbol = "WFT5";
		uint8 public constant decimals = 18; 
		address contractCreator;
		
		// events
		event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
		event Transfer(address indexed from, address indexed to, uint tokens);
		event SetReinvestmentPreference(address indexed caller, address indexed receiver, uint8 percentage);
		event Burn(address indexed from, uint256 value);
		event Freeze(address indexed recipient, string reason);
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
			require( msg.sender == recipient || msg.sender == contractCreator, "Only address owner and contract creator can call this function." );
			require( percentage == 0 || percentage == 50 || percentage == 100, "Please specify only 0, 50, 100 as a reinvestment preference." );
			balances[recipient].reinvestmentPreference = percentage;
			emit SetReinvestmentPreference(msg.sender, recipient, percentage);
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
		
		function transfer(address receiver, uint numTokens) public returns (bool) {
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
		 
		function burn(uint256 numTokens) public onlyOwner returns (bool success) {
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
		
		function freeze(address recipient, string memory reason) public onlyOwner returns (bool success) {		
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

		function unfreeze(address recipient, string memory reason) public onlyOwner returns (bool success) {
			
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
