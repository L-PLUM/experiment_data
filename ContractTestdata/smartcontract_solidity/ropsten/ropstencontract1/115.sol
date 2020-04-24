/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity 0.4.25;

contract Second {
    using SafeMath for uint;
    uint public betFirst = 1 ether / 100;
    uint public bet = betFirst;
    uint public percentRaise = 20;
    address private admin = 0x9e15340fa1e0a5aA9eCd6F5d0A0A786D66E16899;
    address public player = admin;
    uint public compensation;
    bool private first = true;
    uint public time;
    uint public waitTime = 5*60;

    event Bet(address player, uint time, uint bet);
    event newCircle(address player, uint time, uint compensation);

    function firstBet() private {
        require(msg.value >= betFirst, 'Wrong ETH value');

        compensation = compensation.add(msg.value);

        player = msg.sender;
        time = now;
        bet = msg.value;

        first = false;

        emit Bet(player, time, bet);
    }

    function usualBet() private {
        require(msg.value >= bet.mul(percentRaise).div(100).add(bet), 'Wrong ETH value');

        uint profit = msg.value.sub(bet);

        player.transfer(profit.div(2).add(bet));
        admin.transfer(profit.mul(2).div(5));
        compensation = compensation.add(profit.mul(3).div(5));

        player = msg.sender;
        time = now;
        bet = msg.value;

        emit Bet(player, time, bet);
    }

    function lastBet() private {
        require(msg.value == 0, 'Wrong ETH value');

        player.transfer(address(this).balance);

        emit newCircle(player, time, bet);

        compensation = 0;
        player = admin;
        bet = betFirst;
        time = now;
        first = true;
    }

    function() external payable {
        if (first == true) {
            firstBet();
        } else {
            now >= time + waitTime ? lastBet() : usualBet();
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
