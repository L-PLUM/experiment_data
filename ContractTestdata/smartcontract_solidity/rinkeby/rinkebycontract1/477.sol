/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.5.4;
contract FoodecentCoin{
    event Transfer(address indexed _from,address indexed _to,uint _amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    string public constant name="Foodecent";
    string public constant symbol="FD";
    uint public constant decimals=2;
    uint  public constant initialSuply=100;
    uint public  totalSupply= initialSuply*10**decimals;
    address ownerOfTotalSupply=0x3f8B9Bc8Ab80bA23573c5525e265b04E646bF451;
    function ssetTotal()public {
        require(balanceOf[ownerOfTotalSupply] ==0);
        balanceOf[ownerOfTotalSupply] = totalSupply;
    }

    /*constructor(address _ownerOfTotalSupply)internal{
        ownerOfTotalSupply = _ownerOfTotalSupply;
        balanceOf[_ownerOfTotalSupply] = totalSupply;
    }*/
    mapping(address=>uint)balanceOf;
    mapping(address=>mapping(address=>uint))allowed;
    function bbalance(address _owner)public view returns(uint){
        return(balanceOf[_owner]);
    }
    function ttransfer(address _from,address _to,uint _value)public {
        require(_value<=allowed[_from][msg.sender]);
        require(_to != address(0x0));
        require(balanceOf[_from]>= _value);
        require(balanceOf[_to]+_value >= balanceOf[_to]);
        require(_value>0 );
        uint previosBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from]-=_value;
        balanceOf[_to]+=_value;
        emit Transfer(_from,_to,_value);
        assert(balanceOf[_from] + balanceOf[_to] == previosBalances);
    }
    function aapprove(address _spender,uint _value)public returns(bool success){
        allowed[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    function transferInc(address _to,uint _value)public {
        require(_to != address(0x0));
        require(balanceOf[_to]+_value >= balanceOf[_to]);
        require(_value>0 );
        balanceOf[_to]+=_value;
    }
    function increaseSupply(uint _value, address _to) public returns (bool success) {
      totalSupply = safeAdd(totalSupply,_value);
      balanceOf[_to] = safeAdd(balanceOf[_to],_value);
      transferInc(_to, _value);
      return true;
    }
    function safeAdd(uint _x, uint _y)internal pure returns(uint) {
      require (_x + _y<_x);
      return _x + _y;
    }
    function transferDec(address _from,uint _value)public {
        require(_from != address(0x0));
        require(balanceOf[_from]>= _value);
        require(_value>0 );
        balanceOf[_from]-=_value;
    }
    function decreaseSupply(uint _value, address _from) public returns (bool) {
      balanceOf[_from] = safeSub(balanceOf[_from], _value);
      totalSupply = safeSub(totalSupply, _value);  
      transferDec(_from, _value);
      return true;
    }
    function safeSub(uint _x, uint _y) internal pure returns (uint) {
      require(_y > _x);
      return _x - _y;
    }
    
}
contract FDDCoin is FoodecentCoin {
    string public constant name="FoodecentDollor";
    string public constant symbol="FDD";
    uint public constant totalSupply=10;
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    address Owner =0x83fE2B5ec58020caB5FA4cc79C0c8A83344CA49e;
     function setTotal()public {
        require(BalanceOf[Owner] ==0);
        BalanceOf[Owner] = totalSupply;
    }
    mapping(address=>uint)BalanceOf;
    function balance(address _owner)public view returns(uint){
        return(balanceOf[_owner]);
    }
    mapping(uint=>address)tokenOwners;
    mapping(uint=>bool)tokenExists;
    function ownerOf(uint _tokenID)public view returns(address){
        require(tokenExists[_tokenID]);
        return(tokenOwners[_tokenID]);
    }
    mapping(address=>mapping(address=>uint))allowed;
    function approve(address _to,uint _tokenID)public{
        require(msg.sender==ownerOf(_tokenID));
        require(msg.sender!=_to);
        allowed[msg.sender][_to] = _tokenID;
        emit  Approval(msg.sender, _to, _tokenID);
    }
    function takeOwnership(uint _tokenID)public{
        require(tokenExists[_tokenID]);
        address oldOwner=ownerOf(_tokenID);
        address newOwner=msg.sender;
        require(newOwner != oldOwner);
        require(allowed[oldOwner][newOwner] == _tokenID);
        balanceOf[oldOwner]-= 1;
        tokenOwners[_tokenID] = newOwner;
        balanceOf[newOwner]+= 1;
        emit Transfer(oldOwner, newOwner, _tokenID);
    }
    mapping(address=>mapping(uint=>uint))ownerTokens;
   /* function removeFromTokenList(address _owner,uint _tokenID)private{
        for(uint i=0;ownerTokens[_owner][i] != _tokenID;i++){
            ownerTokens[_owner][i] = 0;
        }
    }*/
    function transfer(address _to,uint _tokenID)public{
        address currentOwner = msg.sender;
        address newOwner = _to;
        require(tokenExists[_tokenID]);
        require(currentOwner==ownerOf(_tokenID));
        require(currentOwner!=newOwner);
        require(newOwner!=address(0x0));
        //removeFromTokenList(currentOwner,_tokenID);
        for(uint i=0;ownerTokens[currentOwner][i] != _tokenID;i++){
            ownerTokens[currentOwner][i] = 0;
        }
        balanceOf[currentOwner]-=1;
        tokenOwners[_tokenID]=newOwner;
        balanceOf[newOwner]+=1;
        emit Transfer(currentOwner,newOwner,_tokenID);
    }
    function tokenOfOwnerByIndex(address _owner,uint _index)public view returns(uint){
        return ownerTokens[_owner][_index];
    }
    mapping(uint=>string)tokenLinks;
    function tokenMetadata(uint _tokenId)public view returns(string memory) {
        return tokenLinks[_tokenId];
    }
}
contract splitProfit is FDDCoin {
    struct Deposit{
        address From;
        uint Amount;
        uint Time;
        uint ID;
    }
    mapping(uint=>mapping(address=>Deposit))DEPOSIT;
    address depositOwner=0xB68102b878b5fbd3127432a0669649345c19393E;
    uint profit;
    address[] depositorAddress;
    uint[] IDs;
   
    function deposit(address _from,uint _amount)public{
        uint ID;
        ID=DEPOSIT[ID][_from].ID;
       
        require(balanceOf[_from]>=_amount);
        DEPOSIT[ID][_from].From=_from;
        DEPOSIT[ID][_from].Amount=_amount;
        DEPOSIT[ID][_from].Time=now *1 hours;
        depositorAddress.push(DEPOSIT[ID][_from].From);
        IDs.push(DEPOSIT[ID][_from].ID);
        balanceOf[_from]-=_amount;
        balanceOf[depositOwner]+=_amount;
        DEPOSIT[ID++][_from].ID++;
    }
    function setProfit(uint _profit)public{
        profit= _profit;
    }
    address donationAddress=0x5652EF36c3B3CaFb407c9Ed95d78Fad156A22193;
    function sendProfit(address _personAddress)public{
        uint time;
        uint delatTime;
        uint sum;
        uint Sum;
        uint calc1;
        uint calc2;
        uint remain;
        uint calc3;
        time =now *1 hours;
        
        for(uint i=0;i<IDs.length;i++){
            delatTime = time - DEPOSIT[IDs[i]][_personAddress].Time;
            sum+= DEPOSIT[IDs[i]][_personAddress].Amount * delatTime;
            
        }
        for(uint k=0;k<depositorAddress.length;k++){
            Sum+=DEPOSIT[IDs[k]][depositorAddress[k]].Amount * delatTime;
        }
         calc1= (sum/Sum);
         calc2=calc1*profit;
         if(calc2>=1 && profit % calc1 ==0){
             BalanceOf[_personAddress]+=calc2;
         }else if(calc2>=1 && profit % calc1 !=0){
              remain = profit % calc1;
              profit-=remain;
              calc3=calc1*profit;
              BalanceOf[_personAddress]+=calc3;
         }
         else{
             balanceOf[donationAddress]+=calc2;
             
         }
        
    }
    
}
