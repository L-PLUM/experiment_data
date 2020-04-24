/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.5.0 <0.7.0;


// basede on https://solidity.readthedocs.io/en/latest/introduction-to-smart-contracts.html#index-1
contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    string private x = "abc";
    mapping (address => uint) public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() public {
        minter = msg.sender;
    }

    function getBalance (address account) public view returns (uint) {
        return balances[account];
    }
    
    function changeOwner (address owner) public {
        minter = owner;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        require(balances[msg.sender] - amount >= 0 , "Insufficient balance.");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
