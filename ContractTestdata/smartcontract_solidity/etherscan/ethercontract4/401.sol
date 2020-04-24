pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract EtherGoldToken is CappedToken {

    string public name = "ETHER GOLD";
    string public symbol = "0XG";
    uint8 public decimals = 18;

    constructor(
        uint256 _cap
        )
        public
        CappedToken( _cap ) {
    }
}
