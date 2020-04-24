/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.4.24;

/**
 * @title SNTXInterface
 * @dev Simpler version of SNTX interface
 */

contract SNTXInterface {
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title Ownable
 * @dev Simpler version of Ownable
*/
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }



  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


 
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
* @title SNTX token
* @dev Basic version of StandardToken, with no allowances.
*/
contract SNTXToken is SNTXInterface, Ownable {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
   
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    uint256 public totalSupply;
    uint256 public tokenDecimal = 1000000000000000000;
    uint256 public IEOCampaign = 3400000000 * tokenDecimal;
    uint256 public TransactionRewards = 1360000000 * tokenDecimal;
    uint256 public AdvisorsTeam = 680000000 * tokenDecimal;
    uint256 public TechnicalTeam = 680000000 * tokenDecimal;
    uint256 public FounderMemberTeam = 680000000 * tokenDecimal;

    constructor() public {
        totalSupply = 6800000000 * tokenDecimal;
        balances[msg.sender] = totalSupply;           
        name = "Sentexchange Token";                                   
        decimals = 18;                            
        symbol = "SNTX";                               
    }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); 
        return true;
    }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value); 
        return true;
    }
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function () public payable {
		balances[msg.sender] += msg.value;
	}
}
