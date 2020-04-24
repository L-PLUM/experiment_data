/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.3;


contract TestContract{

    address payable public administrator;
    
    address payable public admin_assist;

    string public keep_str = "Empty.";
    
    uint public constant ETH_PERCENT = 10 ** 16;
   
    uint public fee = ETH_PERCENT * 2;
    
    event GetString(address addr1);
    
    event SetString(address addr2);
    
    event MulValues(address addr3);

    event MulValuesFree(address addr4);
    
    event SetAdminAssist(address addr5);
    
    event GetAdminAssist(address addr6);
 
    event SetStringFree(address addr7); 
    
    modifier onlyAdministrator() {
        require(msg.sender == administrator);
        _;
    }


    constructor() payable public {
        administrator = msg.sender;
    }    
    
    function () payable external  {
        // donator = msg.sender;
        // amount = msg.value;
    }

    function setFee(uint newPercentFee) public onlyAdministrator returns (bool) {
        fee = ETH_PERCENT * newPercentFee;
        return true;
    }

    function setFeeInWei(uint newFeeWei) public onlyAdministrator returns (bool) {
        fee = newFeeWei;
        return true;
    }

    function sendETHTo(address payable addrTo, uint _amount) public returns (bool) {
        require(msg.sender == administrator && address(this).balance >= _amount);

        if (!addrTo.send(_amount)) {
            return false;
        }
        
        return true;
    }

    function getAdminAssist() public onlyAdministrator returns (address payable) {
        emit GetAdminAssist(msg.sender);
        return admin_assist;
    }

    function setAdminAssist(address payable addr) public onlyAdministrator returns (bool) {
        admin_assist = addr;
        
        emit SetAdminAssist(msg.sender);
        return true;
    }

    function mulValues(uint amount1, uint amount2) payable public returns (uint) {
        require(msg.value >= fee);
    
        emit MulValues(msg.sender);
        
        return amount1 * amount2;
    }

    function mulValuesFree(uint amount1, uint amount2) public returns (uint) {
    
        emit MulValuesFree(msg.sender);
        
        return amount1 * amount2;
    }

    function getString() public returns (string memory) {

        emit GetString(msg.sender);
        
        return keep_str;
    }

    function setString(string memory str) payable public returns (string memory) {
        require(msg.value >= fee);
        
        keep_str = str;

        emit SetString(msg.sender);
        
        return keep_str;
    }    

    function setStringFree(string memory str) public returns (string memory) {
        keep_str = str;

        emit SetStringFree(msg.sender);
        
        return keep_str;
    }  

}
