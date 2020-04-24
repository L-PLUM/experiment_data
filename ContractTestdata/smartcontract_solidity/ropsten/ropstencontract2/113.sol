pragma solidity ^0.5.0;


import "./ERC20.sol";
import "./ERC20Detailed.sol";

/// @author The SocialChains.io Team
/// @title An ERC-20 standard complaint token associated with the SocialChains.io project.
contract Token is ERC20, ERC20Detailed {
    
    uint public constant ALLOCATION_FOR_FOUNDERS          =  50000000;
    uint public constant ALLOCATION_FOR_COMMUNITY         = 550000000;
    uint public constant ALLOCATION_FOR_EMPLOYEES         =  50000000; 
    uint public constant ALLOCATION_FOR_MARKETING         = 100000000;
    uint public constant ALLOCATION_FOR_FUNDRAISING       = 100000000; 
    uint public constant ALLOCATION_FOR_LOAN_PAYMENTS     = 100000000;      
    uint public constant ALLOCATION_FOR_SCHOLARSHIP_FUNDS =  50000000; 
    
    address public constant ACCOUNT_OF_FOUNDERS          = 0xaD6BA4B75348fb3B147BFD082e99EBF1FA14d927;
    address public constant ACCOUNT_OF_COMMUNITY         = 0x7887268a2ea17C2adb96817e48a13F477C1cf3a3;
    address public constant ACCOUNT_OF_EMPLOYEES         = 0x5ECa706E9ADd14CDff4345dB063B7e43DcF60070;
    address public constant ACCOUNT_OF_MARKETING         = 0x1036921D629e5009fc921EcF0E544240038a50d9;
    address public constant ACCOUNT_OF_FUNDRAISING       = 0x1F31a7A28452351ef506E2B2F504af01BBBb147C;
    address public constant ACCOUNT_OF_LOAN_PAYMENTS     = 0x3f3bB4b1CC22bAc570057044B362Dc01A67E4e4A;
    address public constant ACCOUNT_OF_SCHOLARSHIP_FUNDS = 0x8E52966dB40027C0bD46f4606BF0D75C0cFba873;
    
    
    constructor() public ERC20Detailed("SONA", "SONA", 18) { 
        _mint(ACCOUNT_OF_FOUNDERS,          ALLOCATION_FOR_FOUNDERS          * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_COMMUNITY,         ALLOCATION_FOR_COMMUNITY         * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_EMPLOYEES,         ALLOCATION_FOR_EMPLOYEES         * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_MARKETING,         ALLOCATION_FOR_MARKETING         * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_FUNDRAISING,       ALLOCATION_FOR_FUNDRAISING       * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_LOAN_PAYMENTS,     ALLOCATION_FOR_LOAN_PAYMENTS     * (10 ** uint256(decimals())));
        _mint(ACCOUNT_OF_SCHOLARSHIP_FUNDS, ALLOCATION_FOR_SCHOLARSHIP_FUNDS * (10 ** uint256(decimals())));
    }
}
