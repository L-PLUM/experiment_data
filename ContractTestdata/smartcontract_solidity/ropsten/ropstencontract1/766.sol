/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity 0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ERC20Interface {
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract SpnLockupAngel is Ownable {
    using SafeMath for uint256;
    ERC20Interface token;

    address public constant _tokenAddress = 0x62dadb2baf1b09a8030a4ece885eb12c7e874ba5;
    address public constant _wallet = 0x364a0355017d81f51445b0179b5e1a21bc24a6d4;
    uint256 public constant _lockupDate = 1546646400;
    uint256 public initLockupAmt = 40000000e18;
    uint256 public difftest;

    function SpnLockupAngel () public {
        token = ERC20Interface(_tokenAddress);
    }

    function setLockupAmt(uint256 _amt) public onlyOwner {
        initLockupAmt = _amt;
    }

    function withdraw() public onlyOwner {
        uint256 currBalance = token.balanceOf(this);
        uint256 currLocking = getCurrLocking();

        require(currBalance > currLocking);

        token.transfer(_wallet, currBalance-currLocking);
    }

    function getCurrLocking()
        public
		view
        returns (uint256)
	{
        uint256 diff = (now - _lockupDate) / 2592000;
        difftest = diff;
        uint256 partition = 24;

        if (diff >= partition) 
            return 0;
        else
            return initLockupAmt.mul(partition-diff).div(partition);
    }
}
