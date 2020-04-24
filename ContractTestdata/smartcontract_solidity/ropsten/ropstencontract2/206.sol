/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;
pragma experimental ABIEncoderV2;


library DriipSettlementTypesLib {
    
    
    
    enum SettlementRole {Origin, Target}

    struct SettlementParty {
        uint256 nonce;
        address wallet;
        bool done;
        uint256 doneBlockNumber;
    }

    struct Settlement {
        string settledKind;
        bytes32 settledHash;
        SettlementParty origin;
        SettlementParty target;
    }
}
