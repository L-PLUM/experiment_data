/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^ 0.5.0;

contract FICO_test {
    
    
    
    address owner;
    uint public menbership_array_length;
    uint public address_array_length ;
    address payable Referrer;
    
    uint public test;
    
    
    
    
    constructor()public{   
     owner = msg.sender; 
    }
    
    
    // menber_info是使用者的資料結構
    struct menber_info {
        string user_name;//使用者名稱
        address user_address;//使用者地址
        uint token_count;//使用者投資ETH枚數
        string class; //使用者的階級
        uint profit_proportion; //銷售方案的傭金比例
    }
    
    
    menber_info[]public menbership_array; //將menber_info存放到陣列
    address[]public address_array;//將地址存入陣列
    mapping(address=>menber_info)public menbership;//將menber_info存放在mapping，利用address找尋相對應的會員資料
    mapping(address=>uint)public crypto_menber_info;//將地址加密之後存放在mapping
    
    
    
    function Set_menber (string memory name, uint value)public {
        
        uint crypto_info = uint (keccak256(abi.encodePacked(msg.sender)));
        
        if (crypto_info != crypto_menber_info[msg.sender]){
            
        crypto_menber_info[msg.sender] = crypto_info;
        menbership[msg.sender] = menber_info(name,msg.sender,value,name,value);
        
        menbership_array.push(menbership[msg.sender]);
        address_array.push(msg.sender);  
        
        menbership_array_length = menbership_array.length;
        address_array_length = address_array.length;
        
        
        }else {
            revert("這組公鑰已經投過投過了");
        }
    
    }
    
    
    
    function project_01(address payable refferrer)public payable{
        refferrer.transfer(msg.value/67);
        
        
    } 
  
      
    
      
  }
