/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.4.25;

contract First {
    using SafeMath for uint;
    uint public bet = 1 ether / 100;
    uint public percentRaise = 15;
    address public player = 0x9e15340fa1e0a5aA9eCd6F5d0A0A786D66E16899;
    address admin = 0x9e15340fa1e0a5aA9eCd6F5d0A0A786D66E16899;

    function() external payable {
        require(msg.value >= bet.mul(percentRaise).div(100).add(bet), 'Wrong ETH value');

        uint profit = msg.value.sub(bet);

        player.transfer(profit.mul(2).div(3).add(bet));
        admin.transfer(profit.mul(1).div(3));

        player = msg.sender;
        bet = msg.value;
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
