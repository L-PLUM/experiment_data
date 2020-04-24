pragma solidity 0.4.24;

contract C {
    function kill() {
    // <yes> <report> solidity_deprecated_structure  sui101
        suicide(0x0);
    }
    function hashingsha3 (string s)   returns  (bytes32 hash){
     // <yes> <report> solidity_deprecated_structure  sha102
        return sha3(s);
    }
    function delegatecallSetN(address _e, uint _n) {
    // <yes> <report> solidity_deprecated_structure thr103
        if (_e != address(0)) throw;
    }
    function killer() {
        uint r;
        assembly {
            // <yes> <report> solidity_deprecated_structure  sha102
            r := sha3('','')
            // <yes> <report> solidity_deprecated_structure  sui101
            suicide(0x0)
        }
    }
    // <yes> <report> solidity_deprecated_structure con104
    function returnSenderBalance(uint a) constant returns (uint){
            return a;
    }

    function usingYears() returns(uint) {
    // <yes> <report> solidity_deprecated_structure yea105
        return 100 years;
    }
}