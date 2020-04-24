/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.24;

// File: /rhem/contracts/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner`
     * of the contract to the sender account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the current owner
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner
     * @param newOwner The address to transfer ownership to
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

// File: contracts/RhemMultiTransfer.sol

contract RHEM {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract RhemMultiTransfer is Ownable {
    RHEM rhem;
    uint8 public limit = 170;

    event MultiTransfer(uint256 total);

    constructor(address _t) public {
        require(_t != address(0x0));
        rhem = RHEM(_t);
    }

    function changeLimit(uint8 _limit) public onlyOwner {
        limit = _limit;
    }

    function multiTransfer(address[] _beneficiaries, uint256[] _amounts) public {
        require(_beneficiaries.length <= limit);

        uint256 total = 0;
        uint8 i = 0;

        for (i; i < _beneficiaries.length; i++) {
            rhem.transferFrom(msg.sender, _beneficiaries[i], _amounts[i]);
            total += _amounts[i];
        }

        emit MultiTransfer(total);
    }
}
