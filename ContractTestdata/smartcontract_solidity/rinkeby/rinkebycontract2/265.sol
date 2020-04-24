/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
contract FiatContract is Ownable{
    struct Fiat {
        uint ETH;
        uint HBWALLET;
        uint TUSD;
        uint USDT;
        uint BST;
        uint updateAtBlock;
    }
    // price * 1000
    mapping(uint => Fiat) public fiats;

    address public sender;

    constructor () public {
        sender = msg.sender;
        // 0 => USD;
        fiats[0] = Fiat(300, 10, 1, 1, 1, block.number);
    }
    modifier onlySender() {
        require(msg.sender == sender);
        _;
    }
    function ETH(uint _id) public view returns (uint) {
        return fiats[_id].ETH;
    }
    function HBWALLET(uint _id) public view returns (uint) {
        return fiats[_id].HBWALLET;
    }
    function TUSD(uint _id) public view returns (uint) {
        return fiats[_id].TUSD;
    }
    function USDT(uint _id) public view returns (uint) {
        return fiats[_id].USDT;
    }
    function BST(uint _id) public view returns (uint) {
        return fiats[_id].BST;
    }
    function updateAtBlock(uint _id) public  view returns (uint) {
        return fiats[_id].updateAtBlock;
    }
    function update(uint _ETH, uint _HBWALLET, uint _TUSD, uint _USDT, uint _BST) onlySender public {
        fiats[0] = Fiat(_ETH, _HBWALLET, _TUSD, _USDT, _BST, block.number);
    }

    // change sender address
    function changeSender(address _sender) onlyOwner public {
        sender = _sender;
    }

}
