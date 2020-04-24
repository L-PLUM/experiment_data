/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.24;

contract MeeChat {
    
    uint constant MIN_AMOUNT = 0.01 ether;
    uint constant MAX_AMOUNT = 1000000 ether;
    
    address public owner;
    
    uint internal redpack_id_ = 0;
    
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    
    struct Redpack {
        uint redpack_id;
        address sender;
        address[] receiver;
        uint8 num_total;
        uint8 num_left;
        uint amount_total;    // amount in wei.
        uint amount_left;    // amount in wei.
        string memo;
        uint64 ttl;
        uint8 status;
        uint create_time;
        uint update_time;
    }
    
    mapping (uint => Redpack) public redpacks;
    
    constructor() public {
        owner = msg.sender;
    }
    
    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
    
    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    function () public payable {
    }
    
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        sendFunds(beneficiary, withdrawAmount);
    }
    
    // Helper routine to process the payment.
    function sendFunds(address beneficiary, uint amount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, amount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }
    
    function sendRedpack(uint8 num, string memo) external payable {
        Redpack storage redpack = redpacks[redpack_id_];
        
        require(redpack.sender == address(0), "redpack should be in a 'clean' status");
        require(num >= 1 && num <= 100, "redpack number must >= 1 and <= 100");
        require(bytes(memo).length <= 64, "memo must less than 64 bytes");
        require(msg.value >= MIN_AMOUNT && msg.value <= MAX_AMOUNT, "Redpack quantity must >= 0.01 ether and <= 100 ether");
        
        redpack.redpack_id = redpack_id_;
        redpack.sender = msg.sender;
        redpack.num_total = redpack.num_left = num;
        redpack.amount_total = msg.value;
        redpack.amount_left = msg.value;
        redpack.memo = memo;
        redpack.ttl = 5 * 60;
        redpack.status = 0;
        redpack.create_time = redpack.update_time = now;
        
        redpack_id_++;
    }
    
    function returnRedpack(uint id) external onlyOwner {
        Redpack storage redpack = redpacks[id];
        require(redpack.sender != address(0) && redpack.status == 0, "redpack status error");
        require(now >= redpack.create_time + redpack.ttl, "redpack not expired");
        
        uint amount = 0;
        if (redpack.num_left == redpack.num_total) {
            amount = redpack.amount_total;
        } else {
            amount = redpack.amount_left - redpack.amount_total * 2 / 100;
        }
        
        redpack.status = 2;
        redpack.update_time = now;
        
        if (amount > 0) {
            sendFunds(redpack.sender, amount);
        }
    }
    
    function grabRedpack(uint id, address player, uint amount) external onlyOwner {
        Redpack storage redpack = redpacks[id];
        
        require(redpack.sender != address(0) && redpack.status == 0, "redpack status error");
        require(now <= redpack.create_time + redpack.ttl, "redpack expired");
        require(redpack.num_left > 0, "not enough redpack number");
        require(redpack.amount_left >= amount, "not enough quantity in the redpack");
        require(amount > 0, "invalid quantity");
        
        for (uint i = 0; i < redpack.receiver.length; i++) {
            require(redpack.receiver[i] != player, "player has already grab this redpack");
        }
        
        if (--redpack.num_left == 0) {
            redpack.status = 1;
        }
        redpack.amount_left -= amount;
        redpack.receiver.push(player);
        
        sendFunds(player, amount);
    }
    
    function kill() external onlyOwner {
        selfdestruct(owner);
    }
}
