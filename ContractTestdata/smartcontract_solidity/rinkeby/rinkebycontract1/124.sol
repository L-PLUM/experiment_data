/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

contract CappedMath2 {

    uint constant private UINT_MAX = 2**256 - 1;

    uint public result = 0;
    
    function test(uint _a, uint _b) external {
        result = mulCap(_a, _b);
    }
    


    function mulCap(uint _a, uint _b) internal pure returns (uint) {
        return  _a * _b > UINT_MAX ? UINT_MAX :  _a * _b;
    }

}
