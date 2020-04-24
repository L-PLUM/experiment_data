/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.4.18;

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

contract Distributor is Ownable {
    ERC20Interface token;

    address public constant tokenAddress = 0x3942713bdbb9993ee9142ea4b286a0adb1269327;
    uint256 public constant amount = 100e18;
    address[] public arr = [
        0x98752cb375997293d84d82306ca07a549ccbc82f,
        0x854674cd485483889b15bf38182e905874d9ce00
    ];

    function Distributor () public {
        token = ERC20Interface(tokenAddress);
    }

    function batchTransfer () public onlyOwner {
        for (uint i = 0; i < arr.length; i++) {
            token.transfer(arr[i], amount);
        }
    }

}
