/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity 0.5.10; 


contract ERC20TokensContract {
    
    function transfer(address _to, uint _value) public returns (bool success);
}

/**
* @title Contract that will work ERC223 'transfer' function
* dev: see: https://github.com/ethereum/EIPs/issues/223
*/
contract ERC223ReceivingContract {
    
    address public owner;
    
    mapping (address=>uint) public tokenBalance;
    
    modifier onlyOwner() {
        require (msg.sender == owner, "Only owner can do this");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    bytes public bytesValue; 
    
    event toekensReceivedd(
            address indexed from, 
            uint value, 
            bytes indexed data
        );
    
    /**
     * @notice Standard ERC223 function that will handle incoming token transfers.
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint _value, bytes calldata _data) external returns(bool success){
        bytesValue = _data;
        emit toekensReceivedd(_from, _value, _data);
        return true; 
    }
    
    function transferTokens(address _tokenContractAddress, address _to, uint _value) external onlyOwner returns (bool success){
        
        require(tokenBalance[_tokenContractAddress]>=_value, "Not enough tokens on the balance");
        
        ERC20TokensContract erc20TokensContract = ERC20TokensContract(_tokenContractAddress);
        
        return erc20TokensContract.transfer(_to, _value);
    }
    
}
