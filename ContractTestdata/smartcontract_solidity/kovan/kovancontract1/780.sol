/**
 *Submitted for verification at Etherscan.io on 2019-01-07
*/

pragma solidity ^0.4.25;

contract UniFaucet{
    
    address owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    address[] private Admins;
    
    modifier onlyOwner(){
        if(msg.sender == owner)
        _;
    }
    
    event Withdrawal(address actor, address dest, uint256 amount);
    event Deposit(address from, uint256 amount);
    
    modifier onlyAdmin(){
        bool  flag = false;
         
        if(msg.sender == owner){
            flag = true;
        }else{
            for(uint256 i; i < Admins.length; i++){
                if(Admins[i] == msg.sender)
                    flag = true;
            }
        }
        if(flag)
            _;
    }
    
    function () payable public{
        emit Deposit(msg.sender, msg.value);
    }
    
    function getFunds() view public returns(uint256){
        return  address(this).balance;
    }
    
    function withdrawFund(address _receiver, uint256 _amount)  public onlyAdmin returns(bool){
        if(address(this).balance < _amount || _amount < 1 ){
            revert();
        }
        _receiver.transfer(_amount);    
        emit Withdrawal(msg.sender,_receiver, _amount);
        return true;
        
    }
    
    function addAdmin(address _addr) public onlyOwner{
        for(uint256 i; i < Admins.length; i++){
            if(Admins[i] == _addr) 
                revert();
        }
        Admins.push(_addr);
    } 
    
    
    function removeAdmin(address _addr) public onlyOwner{
        
        bool isExists = false;
        
        uint indx = 0;
        
        for(uint i = 0; i < Admins.length ; i++){
            if(Admins[i] == _addr){
                indx = i;
                isExists = true;
                break;
            }
        }
        
        if(isExists == false)
            revert();
            
        remove(indx);
    }
    
    
    function remove(uint index) internal {
        if (index >= Admins.length) return;

        for (uint i = index; i<Admins.length-1; i++){
            Admins[i] = Admins[i+1];
        }
        delete Admins[Admins.length-1];
        Admins.length--;
    }
    
    
    function getAdministratorList() view public onlyOwner returns(address[]){
        return Admins;
    }
    
}
