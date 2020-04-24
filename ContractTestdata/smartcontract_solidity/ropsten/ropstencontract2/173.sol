/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;


library SafeMathUintLib {
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    
    
    
    function clamp(uint256 a, uint256 min, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : ((a < min) ? min : a);
    }

    function clampMin(uint256 a, uint256 min)
    public
    pure
    returns (uint256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(uint256 a, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : a;
    }
}
