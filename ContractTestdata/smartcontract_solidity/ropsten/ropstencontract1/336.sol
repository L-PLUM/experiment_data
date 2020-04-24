/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.4;
contract Secret {
    int x = 10;
    int n;
    int z;
    int q;
    constructor() public {
        n = 0;
        z = f(2);
        q = x + f(2);
    }
    function f(int m) private returns (int u) {
        x = n + 5;
        if (n % 3 == 0) {
            return g();
        } else {
            return f(m + 1);
        }
    }
    function g() private view returns (int y) {
        return n + x;
    }
    function getSecret() public view returns (int o) {
        return q + x;
    }
    function() external {
        revert();
    }
}
