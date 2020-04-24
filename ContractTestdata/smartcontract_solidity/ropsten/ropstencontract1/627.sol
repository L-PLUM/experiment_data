/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;


contract SafeMath {
    
    function safeAdd(uint256 a , uint256 b)public pure returns(uint256){
        uint256 c = a +b;
        assert(c >=a && c >=b );
        return c;
    } 
    
    function safeSub(uint256 a, uint256 b)public pure returns(uint256){
        assert(a >= b);
        return a - b;
    }
    
    function safeMul(uint256 a, uint256 b)public pure returns(uint256){
        uint256 c = a *b;
        assert( a==0 || b == c/a);
        return c;
    }
    
    function safeDiv(uint256 a, uint256 b)public pure returns(uint256){
        assert(b>0);
        uint256 c = a / b;
        assert(a == c*b + a%b);
        return c;
    }
    
}

contract SM is SafeMath{
    //ERC 20
    //transfer, transferFrom, balanceOf,,approve, allowance, totalSupply;name, symbol, decimals;
     
      string public name;
      string public symbol;
      uint8 public decimals;
      uint256 public totalSupply;
      address public owner;
      
      mapping(address=>uint256) public balanceOf;
      mapping(address=>uint256) public freezeOf;
      mapping(address=>mapping(address=>uint256)) public allowance;
      
      
      constructor(string _name, string _symbol, uint256 _total, uint8 _decimals )public{
          name = _name;
          symbol = _symbol;
          decimals = _decimals;
          totalSupply = _total*10**18; 
          owner = msg.sender;
          balanceOf[msg.sender] = totalSupply;
      }
      
      
     /* function name()public view returns(string){
          return name;
      }
      */
      
      event Transfer(address _from, address _to, uint _val);
      
      event Approve(address _from, address _to, uint _val);
      
      event Freeze(address _to, uint256 _val);
      
      event Unfreeze(address _to, uint256 _val);
      
      event Burn(address _from, uint256 _val);
      
    /*  
      function balanceOf(address _addr)public returns(uint){
          
      }
      
      function totalSupply() public returns(uint){
          
      }*/
      
      function transfer(address _to, uint256 _val) public returns(bool){
          
           assert(_to != 0x0);
           assert(_val>0);
           assert(balanceOf[msg.sender] < balanceOf[msg.sender]+_val);
           assert(balanceOf[msg.sender] > _val);
           
           balanceOf[msg.sender] = SafeMath.safeDiv(balanceOf[msg.sender] , _val);
           balanceOf[_to] = SafeMath.safeAdd(balanceOf[msg.sender], _val);
           emit Transfer(msg.sender, _to, _val);
           return true;
      }
      
      
      function transferFrom(address _from, address _to, uint256 _val)public returns(bool){
          assert(_from != 0x0 && _to!=0x0);
          assert(_val >0 );
          assert(balanceOf[_from] > _val);
          assert(balanceOf[_to] < balanceOf[_to] + _val);
          assert(allowance[_from][msg.sender] > _val);
          
          balanceOf[_from] = SafeMath.safeDiv(balanceOf[_from], _val);
          balanceOf[_to] = SafeMath.safeDiv(balanceOf[_to], _val);
          allowance[_from][msg.sender] =SafeMath.safeDiv(allowance[_from][msg.sender], _val);
          emit Transfer(_from, _to, _val);
          return true;

      }
      
      function approve(address _spender, uint256 _val)public returns(bool){
          assert(_val >0);
          assert(_spender != 0x0);
          assert(balanceOf[msg.sender] > _val);  //balance not enough ,so do not approve this
          
          allowance[msg.sender][_spender] = _val;
          emit Approve(msg.sender, _spender, _val);  
          return true;
      }
      
      
      function burn(uint256 _val) public returns(bool){
          assert(_val>0);
          assert(balanceOf[msg.sender] > _val);
          
          balanceOf[msg.sender] = SafeMath.safeDiv(balanceOf[msg.sender], _val);
          totalSupply = SafeMath.safeDiv(totalSupply, _val);
          emit Burn(msg.sender, _val);
          return true;
      }
     
     function freeze(uint256 _val)public returns(bool){
         assert(_val >0);
         assert(balanceOf[msg.sender] > _val);
         assert(freezeOf[msg.sender] < freezeOf[msg.sender] + _val);
         
         balanceOf[msg.sender] = SafeMath.safeDiv(balanceOf[msg.sender], _val);
         
         freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _val);
         emit Freeze(msg.sender, _val);
         return true;
     }
      
     function unfreeze(uint256 _val)public returns(bool){
         assert(_val >0);
         assert(freezeOf[msg.sender] > _val);
         assert(balanceOf[msg.sender] < balanceOf[msg.sender] + _val);
         
         balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _val);
         freezeOf[msg.sender] = SafeMath.safeDiv(freezeOf[msg.sender], _val);
         emit Unfreeze(msg.sender, _val);
         return true;
     }
     
     function withdrawEther(uint256 _val)public {
         assert(owner == msg.sender);
         assert(_val >0);
         owner.transfer(_val);
     } 
     
     function ()payable public{
         
     }
    
}
