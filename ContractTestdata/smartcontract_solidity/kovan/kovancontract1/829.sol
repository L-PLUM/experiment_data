/**
 *Submitted for verification at Etherscan.io on 2018-12-29
*/

pragma solidity ^0.4.23;
contract OldTrueUSDInterface {
    function delegateToNewContract(address _newContract) public;
    function claimOwnership() public;
    function balances() public returns(address);
    function allowances() public returns(address);
    function totalSupply() public returns(uint);
    function transferOwnership(address _newOwner) external;
}
contract NewTrueUSDInterface {
    function setTotalSupply(uint _totalSupply) public;
    function transferOwnership(address _newOwner) public;
    function claimOwnership() public;
}

contract TokenControllerInterface {
    function claimOwnership() external;
    function transferChild(address _child, address _newOwner) external;
    function requestReclaimContract(address _child) external;
    function issueClaimOwnership(address _child) external;
    function setTrueUSD(address _newTusd) external;
    function setTusdRegistry(address _Registry) external;
    function claimStorageForProxy(address _delegate,
        address _balanceSheet,
        address _alowanceSheet) external;
    function setGlobalPause(address _globalPause) external;
    function transferOwnership(address _newOwner) external;
    function owner() external returns(address);
}

/**
 */
contract UpgradeHelper {
    OldTrueUSDInterface public constant oldTrueUSD = OldTrueUSDInterface(0xf0ab9a18a22519bd8c096ef51819bb39dd2c22ac);
    NewTrueUSDInterface public constant newTrueUSD = NewTrueUSDInterface(0xb0d50c00a0b16b0415d5f71c7c1486c540eaabc1);
    TokenControllerInterface public constant tokenController = TokenControllerInterface(0x65a58437d6b26b39eac90f2255069dedf3df2489);
    address public constant registry = address(0x4e4159b40f9a171adce1f8bcea2eba0ec88acb28);
    address public constant globalPause = address(0x91c2e1b1b30c8941dea251735c8d54d157f85589);

    function upgrade() public {
        // TokenController should have end owner as it's pending owner at the end
        address endOwner = tokenController.owner();

        // Helper contract becomes the owner of controller, and both TUSD contracts
        tokenController.claimOwnership();
        newTrueUSD.claimOwnership();

        // Initialize TrueUSD totalSupply
        newTrueUSD.setTotalSupply(oldTrueUSD.totalSupply());

        // Claim storage contract from oldTrueUSD
        address balanceSheetAddress = oldTrueUSD.balances();
        address allowanceSheetAddress = oldTrueUSD.allowances();
        tokenController.requestReclaimContract(balanceSheetAddress);
        tokenController.requestReclaimContract(allowanceSheetAddress);

        // Transfer storage contract to controller then transfer it to NewTrueUSD
        tokenController.issueClaimOwnership(balanceSheetAddress);
        tokenController.issueClaimOwnership(allowanceSheetAddress);
        tokenController.transferChild(balanceSheetAddress, newTrueUSD);
        tokenController.transferChild(allowanceSheetAddress, newTrueUSD);
        
        newTrueUSD.transferOwnership(tokenController);
        tokenController.issueClaimOwnership(newTrueUSD);
        tokenController.setTrueUSD(newTrueUSD);
        tokenController.claimStorageForProxy(newTrueUSD, balanceSheetAddress, allowanceSheetAddress);

        // Configure TrueUSD
        tokenController.setTusdRegistry(registry);
        tokenController.setGlobalPause(globalPause);

        // Point oldTrueUSD delegation to NewTrueUSD
        tokenController.transferChild(oldTrueUSD, address(this));
        oldTrueUSD.claimOwnership();
        oldTrueUSD.delegateToNewContract(newTrueUSD);
        
        // Controller owns both old and new TrueUSD
        oldTrueUSD.transferOwnership(tokenController);
        tokenController.issueClaimOwnership(oldTrueUSD);
        tokenController.transferOwnership(endOwner);
    }
}
