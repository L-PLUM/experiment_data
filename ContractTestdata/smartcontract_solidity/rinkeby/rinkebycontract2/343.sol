/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^0.4.21;


// Open Zeppelin library for preventing overflows and underflows.
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0.
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold.
        return c;
    }

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


// ERC20 Token interface.
interface IERC20 {
    function totalSupply() public constant returns (uint256 totalSupply);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


// Contract onwer restrictions.
contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}


contract VOGenPoints is IERC20, Owned {
    // Overlay of the Safemath library on uint256 datatype
    using SafeMath for uint256;

    // Restrinct the usage of a function to a user
    modifier onlyUser {
        require(!containsOrg(msg.sender));
        _;
    }

    // Restrict the usage of a function to an org
    modifier onlyOrg {
        require(containsOrg(msg.sender));
        _;
    }

    // Contract variables.
    uint public constant INITIAL_SUPPLY =  1000000000000;                // Initial supply of tokens: 1.000.000.000.000
    uint public _totalSupply =  0;                                      // Total amount of tokens
    address public owner;                                               // Address of the contract owner
    address[] public orgs;                                             // Array of organisation addresses

    // Cryptocurrency characteristics.
    string public constant symbol = "VOG";                              // Cryprocurrency symbol
    string public constant name = "VOGen Coin";                          // Cryptocurrency name
    uint8 public constant decimals = 18;                                // Standard number for Eth Token
    uint256 public constant RATE = 1000000000000000000;                 // 1 ETH = 10^18 VOG;

    // Map definions.
    mapping (address => uint256) public balances;                       // Map [User,Amount]
    mapping (address => bool) public orgsMap;                          // Map [Org,Official]
    mapping (address => mapping (address => uint256)) public allowed;   // Map [User,[OtherUser,Amount]]

    // Events definition.
    // This notify clients about the transfer.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Constructor, set the contract sender/deployer as owner.
    function VOGenPoints() public {
        // Check for the null address.
        require(msg.sender != 0x00);
        // Update total supply with decimals.
        _totalSupply = INITIAL_SUPPLY * 10 ** uint256(decimals);
        // Give an initial supply to the contract creator.
        balances[msg.sender] = _totalSupply;
        // Who deploys the contract is the owner.
        owner = msg.sender;
        // Add owner in orgs Array.
        orgs.push(owner);
        // add owner in orgsMap.
        orgsMap[owner] = true;
    }

    /******************************************************************************
     * Fallback function, a function with no name that gets called.                *
     * whenever you do not actually pass a function name.                         *
     * This allow people to just send money directly to the contract address.     *
     ******************************************************************************/
    function () public payable {
        // People will send money directly to the contract address.
    }

    /*****************************************************************************
    * Check if an organisation exists.                                                    *
    ******************************************************************************/
    function containsOrg(address _org) public view returns (bool) {
        return orgsMap[_org];
    }

    /*****************************************************************************
    * Perform a VOGen token generation.                                           *
    ******************************************************************************/
    function createTokens() public payable onlyOwner {
        // Check if the amount trasfered is greather than 0.
        require(msg.value > 0);
        // Check if the sender address is 0.
        require(msg.sender != 0x00);
        // Create tokens from Ether multiplying for 10^18
        uint256 tokens = msg.value.mul(RATE);
        // Add tokens to the buyer account.
        balances[msg.sender] = balances[msg.sender].add(tokens);
        // Total supply number increased by the new token creation.
        _totalSupply = _totalSupply.add(tokens);
        // Transfer the amount to the owner, auto rollback if the transaction fails.
        owner.transfer(msg.value);
    }

    /*****************************************************************************
    * Return the total supply of the token.                                      *
    *                                                                            *
    *                                                                            *
    * Return the value of the variable `_totalSupply`.                           *
    ******************************************************************************/
    function totalSupply() public constant returns (uint256 totalSupply) {
        // Value of the contract variable
        return _totalSupply;
    }

    /*****************************************************************************
    * Return the balance of an account.                                          *
    *                                                                            *
    * Return the amount of money of the `_account`.                              *
    *                                                                            *
    * @param _account the address of the account of which I want the balance.    *
    ******************************************************************************/
    function balanceOf(address _account) public constant returns (uint256 balance) {
        return balances[_account];
    }

    /*****************************************************************************
    * Transfer tokens from sender to receiver.                                   *
    *                                                                            *
    * Send `_value` tokens from the msg.sender to the `_to` address.             *
    *                                                                            *
    * @param _to the address of the receiver.                                    *
    * @param _value the amount of points to send.                                *
    ******************************************************************************/
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _value = _value * 10 ** uint256(decimals);
        // Check if the sender has enough.
        require(balances[msg.sender] >= _value);
        // Check if the amount trasfered is greather than 0.
        require(_value > 0);
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check for overflows.
        require(balances[_to] + _value > balances[_to]);
        // Check for underflows.
        require(balances[msg.sender] - _value < balances[msg.sender]);
        // Save for the future assertion.
        uint previousBalances = balances[msg.sender].add(balances[_to]);
        // Subtract the token amount from the sender.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // Add the token amount to the recipient.
        balances[_to] = balances[_to].add(_value);
        // Emit the Transfer event.
        emit Transfer(msg.sender, _to, _value);
        // Asserts are used to use static analysis to find bugs in code. They should never fail.
        assert(balances[msg.sender].add(balances[_to]) == previousBalances);
        return true;
    }

    /*****************************************************************************
    * Get the most important token informations                                  *
    ******************************************************************************/
    function getSummary() public view returns (uint, address, string, string, uint8, uint256) {
        uint exponent = 10 ** uint(decimals);
        uint256 tokenUnits = _totalSupply / exponent;
        return(
            tokenUnits,
            owner,
            symbol,
            name,
            decimals,
            RATE
        );
    }

    /*****************************************************************************
    * Add a new org to the collection of official orgs                         *
    ******************************************************************************/
    function addOrg(address _newOrg) public onlyOwner returns (bool) {
        // Add organisation in orgs Array
        orgs.push(_newOrg);
        // Add organisation in orgsMap
        orgsMap[_newOrg] = true;
        return true;
    }

    /*****************************************************************************
    * Returns the number of the official orgs                                   *
    ******************************************************************************/
    function getOrgsCount() public view returns (uint) {
        return orgs.length;
    }
}
