/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity >0.4.99 <0.6.0;


contract Charity{
        
        address payable public _from;
        mapping (address => uint) public balances;
        bool public _hasDonated=false;
        //uint count;
        address[] public userAddresses;
        
        struct user{
            uint256 count;
        }
        mapping (address => user) public rewards;
        
        event UpdateStatus(string _msg);
        event UserStatus(string _msg, address user, uint amount);
        
         constructor() public{
            _from=msg.sender;
        }
        modifier ifClient(){
            if (msg.sender!=_from){
                revert() ;
            }
            _;
        }
        
    function transfer(address payable client ,uint amount) public payable{
        require(msg.sender==_from);
        address(client).transfer(amount);
        emit UserStatus("User donated",msg.sender,msg.value);
        
        _from=msg.sender;
        uint x=rewards[_from].count;
        rewards[_from].count=x+1;
       
        balances[msg.sender] -= amount;
        balances[client] += amount;
        _hasDonated=true;
        userAddresses.push(msg.sender);
         if(msg.value > 100){
                 rewards[_from].count=x+2;
                emit UpdateStatus("Transfered > 100");
            }
    }

    function GetCount() external view returns (uint){
        return rewards[_from].count;
    }
    
    function GetBalance() external view returns (uint){
        return address(_from).balance;
    }
    
    function GetFlag() external view returns(bool){
        return _hasDonated;
    }
    function getAllUsers() external view returns (address[] memory) {
     return userAddresses;
}
    
}
