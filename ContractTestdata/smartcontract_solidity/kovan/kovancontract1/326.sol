/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.25;

 library SafeMath256 {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if(a==0 || b==0)
        return 0;  
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b>0);
    uint256 c = a / b;
    return c;
  }

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


  string [] ownerName;  
  mapping (address=>bool) owners;
  mapping (address=>uint256) ownerToProfile;
  address owner;

// all events will be saved as log files
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AddOwner(address newOwner,string name);
  event RemoveOwner(address owner);
  /**
   * @dev Ownable constructor , initializes sender’s account and 
   * set as owner according to default value according to contract
   *
   */



   constructor() public {
    owner = msg.sender;
    owners[msg.sender] = true;
    uint256 idx = ownerName.push("ICOINIZE CO.,LTD.");
    ownerToProfile[msg.sender] = idx;

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


  
  function transferOwnership(address newOwner,string newOwnerName) public onlyOwner{
    require(isContract(newOwner) == false);
    uint256 idx;
    if(ownerToProfile[newOwner] == 0)
    {
    	idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }


    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

  modifier onlyOwners(){
    require(owners[msg.sender] == true);
    _;
  }
  
  function addOwner(address newOwner,string newOwnerName) public onlyOwners{
    require(owners[newOwner] == false);
    require(newOwner != msg.sender);
    if(ownerToProfile[newOwner] == 0)
    {
    	uint256 idx = ownerName.push(newOwnerName);
    	ownerToProfile[newOwner] = idx;
    }
    owners[newOwner] = true;
    emit AddOwner(newOwner,newOwnerName);
  }


  function removeOwner(address _owner) public onlyOwners{
    require(_owner != msg.sender);  // can't remove your self
    owners[_owner] = false;
    emit RemoveOwner(_owner);
  }


  function isOwner(address _owner) public view returns(bool){
    return owners[_owner];
  }


  function getOwnerName(address ownerAddr) public view returns(string){
  	require(ownerToProfile[ownerAddr] > 0);

  	return ownerName[ownerToProfile[ownerAddr] - 1];
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
// Contral summary invest in thai bath
contract LimiteInvest{
    mapping (address=>uint256) sumInvests;
    
    
    
}

contract  WhiteList{
    function getMaxInvest(address _addr) external view returns(uint256);
    function haveWhitelist(address _addr) external view returns(uint256);
}


contract ATOKEN is StandarERC20, Ownable,LimiteInvest {
    
  uint256 public version = 200;
  using SafeMath256 for uint256;
  string public name = "ATOKEN";
  string public symbol = "ATK"; 
  uint256 public decimals = 18;

  uint256 public pricePerToken = 3125000000000000;

  uint256 public hardcap = 10000000 ether;
  uint256 public softcap =  2000000 ether;

  uint256 public endSellDate;
  
  uint256 constant _1Token = 1 ether; // if not 18 digit want to change
  uint256 constant _1ETH = 1 ether;
  
  bool public closeICO;
  

  event PayICO(address indexed _addr,uint256 thaiBaht, uint256 _eth,uint256 _toeknBuy);
  event SOSTrans(address indexed _from,address indexed _to,uint256 token);
  
  WhiteList  whiteList;
    
  constructor() public {
      endSellDate = uint256(now) + 365 days;
      whiteList = WhiteList(0xA925fF1696581A3FF947699cdB3745B7B2c2E5c3);
  }
  
  
    function transfer(address _to, uint256 _value) public returns (bool){
        require(closeICO == true);
        return super.transfer(_to,_value);
    }
  
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(closeICO == true);
        return super.transferFrom(_from,_to,_value);
    }
  
  
  function setEndSellDate(uint256  date) onlyOwners public{
      require(date > now);
      endSellDate = date;
  }

  function setTokenPrice(uint256  ethPerToken) onlyOwners public{
      require(pricePerToken == 0);
      pricePerToken = ethPerToken;
  }

// in case forgot private key
  function sosTransfer(address _from,address _to) onlyOwners public{
      require(closeICO == false);
      balance[_to] = balance[_from];
      sumInvests[_to] = sumInvests[_from];
      
      sumInvests[_from] = 0;
      balance[_from] = 0;
      emit Transfer(_from,_to,balance[_to]);
      
  }
  
  // fix point to get 18 digit multi with 4 digit thaibaht
  function mulThaiBathFixMath(uint256 ethTotal,uint256 thaibaht) pure internal returns(uint256){
      uint256 totalThaiBaht;
       
      totalThaiBaht = thaibaht * (ethTotal / _1ETH);
      totalThaiBaht += ((ethTotal % _1ETH) * thaibaht) / _1ETH;
      
      return totalThaiBaht;
      
  }
  
  function currentInvest(address _addr) public view returns(uint256){
      return sumInvests[_addr];
  }
  
  function maxInvestUser(address _addr) public view returns(uint256){
      return whiteList.getMaxInvest(_addr);
  }
  
  
// ทศนิยม 4 ตำแหน่งว่าราคากี่บาท
  function payICO(uint256 ethPrice) payable public returns(bool){  
		
		require(msg.value >= pricePerToken);
		require(whiteList.haveWhitelist(msg.sender) > 0);
		
		uint256 maxInvest = whiteList.getMaxInvest(msg.sender);
		uint256 curInvest = sumInvests[msg.sender];
		uint256 newInvest;
		uint256 tokenBuy = msg.value / pricePerToken;
		
		newInvest = mulThaiBathFixMath(tokenBuy * pricePerToken,ethPrice);
		require(newInvest + curInvest <= maxInvest);
		tokenBuy = tokenBuy * _1Token;
		require(tokenBuy + totalSupply_ <= hardcap);
		
		sumInvests[msg.sender] += newInvest;
        totalSupply_ += tokenBuy;
        balance[msg.sender] += tokenBuy;
        
        emit Transfer(address(0),msg.sender,tokenBuy);

        return true;
	}
	
  function transferFund(uint256 ethFund) onlyOwners public {
      require (ethFund <= address(this).balance);
      msg.sender.transfer(ethFund);
  }
	
  function closeICO() public returns(bool){
      require(closeICO == false);
      if(totalSupply_ == hardcap){
         closeICO = true;
         return true;
      }
      
      if(now >= endSellDate)
      {
         closeICO = true;
         return true;
      }
      
      return false;
      
      
  }
  
  function refundICO(address _addr) public returns(bool){
      require(closeICO == true);
      require(totalSupply_ < softcap);
      require(msg.sender == _addr || owners[msg.sender] == true);
      uint256 token = balance[msg.sender];
      token = token / _1Token;
      msg.sender.transfer(token * pricePerToken);
      return true;
  }

}
