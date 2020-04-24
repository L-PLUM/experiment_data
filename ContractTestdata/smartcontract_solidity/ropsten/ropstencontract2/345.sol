/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity 0.4.18;

interface KyberNetworkInterface {
    function enabled() public view returns(bool);
}

contract KyberNetworkProxy {
    KyberNetworkInterface public kyberNetworkContract;
    
    function KyberNetworkProxy() public {}
    
    function maxGasPrice() public pure returns(uint) {
        return 50;
    }
    
    function setNetworkContract(KyberNetworkInterface _kyberNetworkContract) public {
        kyberNetworkContract = _kyberNetworkContract;
    }
    
    function isContractEnabled() public view returns (bool) {
        return kyberNetworkContract.enabled();
    }
}
