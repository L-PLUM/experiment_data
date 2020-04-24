/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

contract CappedMath1 {

    uint constant private UINT_MAX = 2**256 - 1;
   
    uint public result = 0;
    
    function test(uint _a, uint _b) external {
        result = mulCap(_a, _b);
    }
    


    function mulCap(uint _a, uint _b) internal pure returns (uint) {

        // Gas optimization: this is cheaper than requiring '_a' not being zero, but the

        // benefit is lost if '_b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (_a == 0)

            return 0;



        uint c = _a * _b;

        return c / _a == _b ? c : UINT_MAX;

    }
    
}
