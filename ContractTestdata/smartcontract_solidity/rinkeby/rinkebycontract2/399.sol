/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity >=0.4.22 <0.6.0;

contract Register{
    struct Administrators{
        address ownerAdr;
        string ownerName;
        bytes32 password;
    }
    address public owner;
    uint AdministratorsNum = 0;
    address[] addrList;
    mapping(string=>bool) registerPool;
    mapping(string => Administrators) userPool;
    
     constructor () public {
        owner = msg.sender;
    }
    //注册
     function login(string memory username, string memory password) view public returns (bool) {
        return userPool[username].password == keccak256( abi.encode(password));
    }
    //注册检测
    function checkRegister(address addr,string memory username) view public returns (bool) {
	    
		for(uint i = 0; i < addrList.length; ++i){
            if(addrList[i] == addr||registerPool[username]==true)
                return true;
		}
        return false;
    }
    
	// 用户注册
    function register(address  addr, string  memory username, string memory password) public {
        require(!(msg.sender!=owner));
            
        require(!checkRegister(addr,username));
        
            
		userPool[username] = Administrators(addr, username, keccak256( abi.encode(password)));
		addrList.push(addr);
		registerPool[username]=true;
		++AdministratorsNum;
    }
    // 更新密码
    function updatePassword(string memory username, string memory newPwd) public {
		require(msg.sender != owner);
        // keccak256加密
		userPool[username].password = keccak256( abi.encode(newPwd));
    }
    
    function addMsg(string memory username,string memory ID,string memory violateRecord,uint lowPoint,string memory AdministratorName) public{
        require(msg.sender!=owner) ;
        AddorSearch addmsg = new AddorSearch();
        addmsg.addMsg(username,ID,violateRecord,lowPoint, AdministratorName);
    }
    
}


contract AddorSearch{
    struct Msg{
    string userName;
    string ID;
    string violateRecord;
    uint lowPoint;
    string AdministratorName;
    }
    Msg[] violateRecords;
    uint totalMsg=0;
    
    function addMsg(string memory username,string memory ID,string memory violateRecord,uint lowPoint,string memory AdministratorName ) public{
        violateRecords.push(Msg(username,ID,violateRecord,lowPoint,AdministratorName));
    }
    function returnTotal() view public returns (uint) {
        return violateRecords.length;
    }
    function getuserName(uint id) view public returns (string memory){
       return violateRecords[id].userName;
    }
    function getID(uint id) view public returns (string memory){
        return violateRecords[id].ID;
    }
    function getviolateRecord(uint id) view public returns (string memory){
        return violateRecords[id].violateRecord;
    }
    function getlowPoint(uint id) view public returns (uint){
        return violateRecords[id].lowPoint;
    }
    function getAdministrator(uint id) view public returns (string memory){
        return violateRecords[id].AdministratorName;
    }

    
}
