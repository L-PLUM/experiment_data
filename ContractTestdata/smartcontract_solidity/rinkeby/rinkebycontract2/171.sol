/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.4.26;
    
    library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
  
        uint256 c = a * b;
        require(c / a == b);
 
        return c;
    }
 
    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
 
        return c;
    }
 
    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
 
        return c;
    }
 
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
 
        return c;
    }
 
    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

 
    contract token {
       
     
            string public name;
            string public symbol;
            uint256 public decimals = 18;  
            uint256 public _totalSupply; 
     
 
        function totalSupply() constant returns (uint256 supply) {
            return _totalSupply;
        }
 
     
 
        function approve(address _spender, uint256 _value) returns (bool success) {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
        
 
        function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
        }
 
        mapping(address => uint256) public  balanceOf;         
        mapping(address => uint256) public distBalances;    
        mapping(address => uint256) public distTimes;        
        mapping(address => bool) public lockAddrs;           
        mapping(address => mapping (address => uint256)) allowed;
 
 
        address public founder;
        uint256 public distributed = 0;
 
        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
        
        
 
    function token(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        founder = msg.sender;
        
        _totalSupply = initialSupply * 10 ** uint256(decimals); 
        //balanceOf[msg.sender] = totalSupply;   
    
        name = tokenName;
        symbol = tokenSymbol;
    }
 

        function distribute(uint256 _amount, address[] _to) {
            if (msg.sender!=founder) revert();
            if (SafeMath.add(distributed,_amount) > _totalSupply) revert();
            
            for(uint i=0;i<_to.length;i++){
                
                if (distBalances[_to[i]]>0){
                    if(_to[i]!=founder){
                        revert();
                    }
                }
                distributed= SafeMath.add(distributed, _amount);
                balanceOf[_to[i]] =SafeMath.add(balanceOf[_to[i]],_amount);
                distBalances[_to[i]] =SafeMath.add(distBalances[_to[i]], _amount);
                distTimes[_to[i]]=SafeMath.add(now,1 hours);
            }
        }
        
     
        function lockAddr(address user) returns (bool success) {
            if (msg.sender != founder) revert();
            lockAddrs[user]=true;
            return true;
        }
        
      
        function unLockAddr(address user) returns (bool success) {
            if (msg.sender != founder) revert();
            lockAddrs[user]=false;
            return true;
        }
 

        function transfer(address _to, uint256 _value) public {
 
            require(lockAddrs[msg.sender]==false);
            require(balanceOf[msg.sender] >= _value);
            require(SafeMath.add(balanceOf[_to],_value) > balanceOf[_to]);
          
            uint _freeAmount = freeAmount(msg.sender);
            require (_freeAmount > _value);

            balanceOf[msg.sender]=SafeMath.sub(balanceOf[msg.sender], _value);
            balanceOf[_to]=SafeMath.add(balanceOf[_to], _value);
            Transfer(msg.sender, _to, _value);
        }
       
        
        function getDate() constant returns (uint256 date) {
            return now;
        }
      
       function unLockAmount(address user) constant returns (uint256 amount) {
 
            uint monthDiff;
            if(now<distTimes[user]){
             
                monthDiff= 4-(distTimes[user]-now) / (15 minutes);
                if(monthDiff==0){
                    return  distBalances[user]/10;
                }else if(monthDiff>0 && monthDiff<4){
                    return  distBalances[user]/10+distBalances[user]/100*90/4*monthDiff;
                }else{
                    return distBalances[user];
                }
            }else{
           
                return distBalances[user];
            }
        }
 
 
        function freeAmount(address user) constant internal returns (uint256 amount) {
          
            if (user == founder) {
                return balanceOf[user];
            }
 
            uint monthDiff;
            if(now<distTimes[user]){
               
                monthDiff= 4-(distTimes[user]-now) / (15 minutes);
                if(monthDiff==0){
                    return  distBalances[user]/10+balanceOf[user]-distBalances[user];
                }else if(monthDiff>0 && monthDiff<4){
                    return  distBalances[user]/10+distBalances[user]/100*90/4*monthDiff+balanceOf[user]-distBalances[user];
                }else{
                    return distBalances[user]+balanceOf[user]-distBalances[user];
                }
            }else{
               
                return distBalances[user]+balanceOf[user]-distBalances[user];
            }
        }
 
      
        function changeFounder(address newFounder) {
            if (msg.sender!=founder) revert();
            founder = newFounder; 
        }
 
   
        function transferFrom(address _from, address _to, uint256 _value) {
         
            require(lockAddrs[_from]==false);
            require(balanceOf[_from] >= _value);
            require(allowed[_from][msg.sender] >= _value);
            require(balanceOf[_to] + _value > balanceOf[_to]);
          
            uint _freeAmount = freeAmount(_from);
            require (_freeAmount > _value);
            
            balanceOf[_to]=SafeMath.add(balanceOf[_to],_value);
            balanceOf[_from]=SafeMath.sub(balanceOf[_from],_value);
            allowed[_from][msg.sender]=SafeMath.sub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);

        }
 
        function() payable {
            if (!founder.call.value(msg.value)()) revert(); 
        }
    }
