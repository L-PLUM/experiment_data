/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;

/**
* @title RaceToNumber
* @dev must have the password to play. Whoever calls the lucky transaction wins!
*/
contract RaceToNumber {
    bytes32 public constant passwordHash = 0xef05e6b321fff64b3ef522cecdf22d536b9d50a971206daa8c42df8eec956e12;
    uint256 public constant callsToWin = 10;
    uint256 public callCount;

    event Victory(
        address winner,
        uint256 payout
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
            uint256 payout = address(this).balance;
            emit Victory(msg.sender, payout);
            msg.sender.transfer(payout);
        }
    }

    // payable fallback so we can send in eth (the pot)
    function () external payable {}
}
