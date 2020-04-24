/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.10;

library SafeMath256 {

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
   require( b<= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
  
}

contract Ownable {


  address owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   constructor() public {
    owner = msg.sender;
  }

// function to check whether the given address is either Wallet address or Contract Address

  function isContract(address _addr) internal view returns(bool){
     uint256 length;
     assembly{
      length := extcodesize(_addr)
     }
     if(length > 0){
       return true;
    }
    else {
      return false;
    }

  }

  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

  
  function transferOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false);
    owner = newOwner;

    emit OwnershipTransferred(owner,newOwner);

  }


}

// Mandatory basic functions according to ERC20 standard
contract ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
  

}

contract StandarERC20 is ERC20{
  using SafeMath256 for uint256; 
     
     mapping (address => uint256) balance;
     mapping (address => mapping (address=>uint256)) allowed;


     uint256  totalSupply_; 
     
      event Transfer(address indexed from,address indexed to,uint256 value);
      event Approval(address indexed owner,address indexed spender,uint256 value);


    function totalSupply() public view returns (uint256){
      return totalSupply_;
    }

     function balanceOf(address _walletAddress) public view returns (uint256){
        return balance[_walletAddress]; 
     }


     function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
        }

     function transfer(address _to, uint256 _value) public returns (bool){
        require(_value <= balance[msg.sender]);
        require(_to != address(0));

        balance[msg.sender] = balance[msg.sender].sub(_value);
        balance[_to] = balance[_to].add(_value);
        emit Transfer(msg.sender,_to,_value);
        
        return true;

     }

     function approve(address _spender, uint256 _value)
            public returns (bool){
            allowed[msg.sender][_spender] = _value;

            emit Approval(msg.sender, _spender, _value);
            return true;
            }

      function transferFrom(address _from, address _to, uint256 _value)
            public returns (bool){
               require(_value <= balance[_from]);
               require(_value <= allowed[_from][msg.sender]); 
               require(_to != address(0));

              balance[_from] = balance[_from].sub(_value);
              balance[_to] = balance[_to].add(_value);
              allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
              emit Transfer(_from, _to, _value);
              return true;
      }

}

contract ShuttleOne is StandarERC20, Ownable {
  using SafeMath256 for uint256;
  string public name = "ShuttleOne";
  string public symbol = "XSE"; 
  uint256 public decimals = 18;


  constructor() public {
    totalSupply_ = 230000000 ether;
    balance[msg.sender] = 230000000 ether;
    emit Transfer(address(this),msg.sender,230000000 ether);
  }

  function ChangeSymbol(string memory newSymbol) public onlyOwner returns(bool) {
      symbol = newSymbol;
  } 
  

}
