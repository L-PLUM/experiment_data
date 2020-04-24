/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

/**
Hello world!
This is an example preamble at the top of the verified source code!
It is compatible with multiline strings.
*/

pragma solidity ^0.5.8;


contract Killable {
    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    function kill() external {
        require(msg.sender == owner, "Only the owner can kill this contract");
        selfdestruct(owner);
    }
}

contract Casino is Killable {
    event Play(address payable indexed player, uint256 betSize, uint8 betNumber, uint8 winningNumber);
    event Payout(address payable winner, uint256 payout);

    function fund() external payable {}

    function bet(uint8 number) external payable {
        require(msg.value <= getMaxBet(), "Bet amount can not exceed max bet size");
        require(msg.value > 0, "A bet should be placed");

        uint8 winningNumber = generateWinningNumber();
        emit Play(msg.sender, msg.value, number, winningNumber);

        if (number == winningNumber) {
            payout(msg.sender, msg.value * 10);
        }
    }

    function getMaxBet() public view returns (uint256) {
        return address(this).balance / 100;
    }

    function generateWinningNumber() internal view returns (uint8) {
        return uint8(block.number % 10 + 1); 
    }

    function payout(address payable winner, uint256 amount) internal {
        assert(amount > 0);
        assert(amount <= address(this).balance);

        winner.transfer(amount);
        emit Payout(winner, amount);
    }
}
