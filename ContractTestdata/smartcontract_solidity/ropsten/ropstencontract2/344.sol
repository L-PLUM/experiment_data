/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity 0.5.10;
interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
}

contract KyberNetwork {
    bool public isEnabled = true;
    
    KyberNetworkProxyInterface public kyberProxyContract;
    
    constructor() public {}
    
    function setKyberNetworkProxy(KyberNetworkProxyInterface _kyberProxyContract) public {
        kyberProxyContract = _kyberProxyContract;
    }
    
    function getMaxPrice() public view returns (uint) {
        return kyberProxyContract.maxGasPrice();
    }
    
    function enabled() public view returns(bool) {
        return isEnabled;
    }
}
