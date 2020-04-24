/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity >=0.4.0 <0.6.0;

contract landRecords{
    address seller;
    
    struct landDetails{
       
      uint priceOfLand;
        bytes32 buyer;
        address beneficiary;
        
            }
            mapping (address => landDetails) sendMoney;
            
            constructor() public  {
                seller = msg.sender;
            }
            modifier onlyOwner()
            {
                require(msg.sender == seller);
                _;}
                
                
                
                function setDimensionsOfLand() public  onlyOwner{
                    
                    sendMoney[msg.sender].priceOfLand = 0.1 ether  ;
                    
                }
        
                function buyLand(address receiver) public payable{
                    
                    require(receiver == seller);
                    
                    require(sendMoney[receiver].priceOfLand == msg.value);
                    transferOwner(msg.sender);
                }
                function transferOwner(address _newOwner) public{
                    seller = _newOwner;
                }
}
