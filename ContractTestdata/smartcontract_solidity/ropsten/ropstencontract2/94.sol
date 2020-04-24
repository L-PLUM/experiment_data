/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.4.15;

contract ERC20Interface {
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

}
contract BatchTransfer{
    address public owner;
    function BatchTransfer() public{
        owner=msg.sender;
    }
    
    function changeOwner(address _newOwner) onlyOwner{
        require(_newOwner!=0x0);
        owner=_newOwner;
    }
    
    function multiTransferToken(address _tokenAddr,address[] dests,uint256[] values) onlyOwner{
        ERC20Interface T = ERC20Interface(_tokenAddr);
        
        require(dests.length == values.length);
        
        for(uint256 i=0;i<dests.length;i++){
            T.transfer(dests[i], values[i]);
        }
        
    }
    
    function multiTransferEther(address[] _addresses,uint256[] _amounts) onlyOwner{
        require(_addresses.length==_amounts.length);
        
        for(uint256 i=0;i<_addresses.length;i++){
            _addresses[i].transfer(_amounts[i]);
            
        }
    }
    
    /*
     *  Modifiers
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
}
