/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.24;
contract UmepaTrafficPoint {
    event NewWalletRegistered(uint _id);
    address private govtWallet = 0x1eb0FaA33b84751F186D2A271276b025D4F6516C;
    mapping (uint => address) private idToWallet;
    
    //string[] private fineReasons = ["JumpTheLight", "Helmets"];
    //mapping (string => uint) private fineAmountMapping;
    
    constructor() public payable{
    //     //fineAmountMapping["JumpTheLight"] = 10;
    //     //fineAmountMapping["Helmets"] = 20;
     }
    
   // function UmepaTrafficPoint() public payable { }
    
    // function () public payable {
//
   // }
    
    function registerNewWallet(uint _id) external {
        idToWallet[_id] = msg.sender;
        emit NewWalletRegistered(_id);
    }
    
    /*
    For test only
    */
    function getWalletAddress(uint _id) view public returns (address) {
        return idToWallet[_id];
    }
    
    function getWalletBalance(uint _id) view external returns (uint) {
        return getWalletAddress(_id).balance;
    }
    
    function fineMoney(string _reason) external payable{
        
        uint fineAmount = 0;
        
        if(keccak256("JumpTheLight") == keccak256(_reason)){
            fineAmount = 10;
        }else if(keccak256("Helmets") == keccak256(_reason)){
            fineAmount = 20;
        }
        
        //uint fineAmount = fineAmountMapping[_reason];
        
        //require(fineAmount > 0);
        //require(msg.sender.balance>=fineAmount);
        
        govtWallet.transfer(fineAmount);
    }
}
