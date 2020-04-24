/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.3;

/**
* @title RaceToNumber
* @dev must have the password to play. Whoever calls the lucky transaction wins!
*/
contract RaceToNumber {
    bytes32 public constant passwordHash = 0xe6259607f8876d87cad42be003ee39649999430d825382960e3d25ca692d4fb0;
    uint256 public constant callsToWin = 25;
    uint256 public callCount;

    event Victory(
        address winner,
        uint payout
    );

    function callMe(string memory password) public {
        // check that user submitted the correct password
        require(
            keccak256(abi.encodePacked(password)) == passwordHash,
            "incorrect password"
        );

        // increment the call count
        callCount++;

        // if we've reached the callsToWin, user wins!
        if (callCount == callsToWin) {
            callCount = 0;
            uint payout = address(this).balance;
            emit Victory(msg.sender, payout);
            msg.sender.transfer(payout);
        }
    }

    // payable fallback so we can send in eth (the pot)
    function () external payable {}
}
