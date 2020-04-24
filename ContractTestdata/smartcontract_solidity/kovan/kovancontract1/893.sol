/**
 *Submitted for verification at Etherscan.io on 2018-12-18
*/

pragma solidity ^0.4.24;

/*
 * SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {
    /*
    * Integer multiplication of two numbers.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    /*
    * Integer addition of two numbers.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    /*
    * Integer division of two numbers.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
}

/*
 * The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /*
     * The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
   constructor() internal{
        owner = msg.sender;
    }

    /*
     * Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /*
     * Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

/*
 * Token - interface for interacting with the Token contract
 */
interface Token {
    function transfer(address _to, uint256 _value) external;
    function  transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external constant returns (uint256 balance);
}

contract Crowdsale is Ownable  {

    using SafeMath for uint256;
    Token token;
    uint256 public creationTime  ;
    uint256 public expectedAmount;
    uint256 public raisedAmount ;
    uint256 public raisedEther;
    uint256 public endDate ;
    uint256[3] public token_price;
    uint256[3] public initial_value;
    uint256[2] public sale;
    uint256[3] public total_token;
    event BoughtTokens(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        // Check if sale is active
        require(isActive());
        _;
    }


    /*
     * Constructor function
     * Initializes Crowdsale with Token Address
     */

   constructor(address _tokenAddress) public {
        require(_tokenAddress != address(0));
        token = Token(_tokenAddress);
    }

    function setSalePrice(uint256[3] prices) public {
        require(!isActive());
        token_price = prices;
    }

    function getSalePrice() public constant returns(uint256[3]){
        return token_price;
    }

    function setTimestamp( uint256 create, uint256 end,uint256[2] time) public {
        require(!isActive());
        creationTime = create;
        endDate=end;
        sale=time;
    }

     function setTokenLimit(uint256 expectedGoal, uint256[3] tokenSale) public{
        require(!isActive());
        expectedAmount =expectedGoal;
        total_token = tokenSale;
        initial_value = tokenSale;
    }

    function initial_value() public constant returns (uint256[3]){

        return (initial_value);
    }

    /*
    * Checks whether the ico is active and reached target date
    */
    function isActive() public constant returns (bool) {

          return (
        block.timestamp >= creationTime && // Must be after the START date
        block.timestamp <= endDate && // Must be before the end date
        tokensAvailable(block.timestamp) > 0 &&
        token_price[0]!= 0// Tokens should be available
        );
    }


    /**
    * Checks whether the target amount is reached
    */
    function goalReached() public constant returns (bool) {
        return ((raisedAmount >= expectedAmount)&&(expectedAmount !=0));
    }

    function timestamp() public constant returns (uint256 ,uint256,uint256[2]){

        return (creationTime,endDate,sale);
    }

    /*
    * Function that sells available tokens
    */
    function buyTokens(uint256 tokens) whenSaleIsActive public payable  {
        // Calculate tokens to sell
        require(tokensAvailable(block.timestamp) >= tokens);
        uint256 current_sale = get_current_details();
        require(msg.value >= (tokens * token_price[current_sale]));
        emit BoughtTokens(msg.sender, tokens);
        // Increment raised amount
        raisedAmount = raisedAmount.add(tokens);
        raisedEther = raisedEther.add(tokens * token_price[current_sale]);
        // Send tokens to buyer
        token.transfer(msg.sender,tokens);
        owner.transfer(tokens * token_price[current_sale]);
        current_tokens(tokens);
    }

    function getRaisedEther() public constant returns(uint256){
        return raisedEther;
    }
    /*
     * returns the number of tokens allocated to this contract
     */
    function tokensAvailable(uint256 time) public constant returns (uint256) {
        if(time >= sale[0])
            return (time>=sale[1]?total_token[2]:total_token[1]);
        return total_token[0];
    }


 function current_tokens(uint256 tokens) public payable returns (uint256) {
        if(block.timestamp >= sale[0]){
            if(block.timestamp >= sale[1]){
                total_token[2] -= tokens;
                return total_token[2];
            }
            else {
                total_token[1] -= tokens;
                return total_token[1];
            }
        }
        total_token[0]-= tokens ;
        return total_token[0];
    }


    function get_current_details() whenSaleIsActive public constant returns(uint256 current_sale){
        if(block.timestamp >= sale[0]){
            if(block.timestamp >= sale[1]){
                return  2;
            }
            else {
                return 1;
            }
        }
          return 0;
    }

    /*
     * returns the number of tokens purchased by an address
     */
    function tokenbalanceOf(address from) public constant returns (uint256) {
        return token.balanceOf(from)/(10**uint256(18));
    }


    /*
    * Transfer all the token back to owner
    */
    function drain()  private onlyOwner {
        require(!isActive());
        // Transfer tokens back to owner
        uint256 balance = token.balanceOf(this);
        require(balance > 0);
        owner.transfer(address(this).balance);
        token.transfer(owner, balance);
    }
    /*
    * Returns array of number of tokens remaining in each sale in the order of private, pre-sale, public
    */
    function sale_remain_token() public constant returns(uint256[3],uint256 ){
        return (total_token,expectedAmount);
    }
}
