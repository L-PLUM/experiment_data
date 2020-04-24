/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.4;

// ----------------------------------------------------------------------------
// 'lendgeralpha' PRIVATE token contract
//
// Deployed to : 0x22d42c525fd2ca0045bed51577af7e9f6053a156
// Symbol      : LNGR
// Name        : Lendger Alpha Token
// Total supply: Gazillion
// Decimals    : 18
//
// Enjoy.
//
// (c) by Moritz Neto & Daniel Bar with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// reverts in case of error
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// Address that creates the contract is initial owner
// Owner can transfer ownership and create/remove admins
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;
    address payable public newOwner;

    mapping(address => bool) administrators;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    event AdminCreated(address admin);
    event AdminRemoved(address admin);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == owner || administrators[msg.sender]);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address newAdmin) public onlyOwner {
        emit AdminCreated(newAdmin);
        administrators[newAdmin] = true;
    }

    function removeAdmin(address oldAdmin) public onlyOwner {
        emit AdminRemoved(oldAdmin);
        administrators[oldAdmin] = false;
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract lendgeralphaToken is ERC20Interface, Owned, SafeMath {
    string public constant symbol = "LNGR";
    string public constant name = "lendgeralpha";
    uint8 public constant decimals = 18;
    uint public _totalSupply;   // current number of tokens issue
    uint public startDate;
    uint public endDate;        // cannot purchase tokens after this date
    uint public constant hardCap = 1000000000000000000000000000;        // cannon issue more than this many tokens
    uint public payoutSize = 100000000000000;     // send ether to owner whenever the contract has this much ether
    uint public exchangeRate = 50;   // tokensPurchased = exchangeRate * etherSpent
    uint public constant privateTokens = 200000000000000000000000000;  // number of tokens the owner starts with
    bool public paused = true;         // when true, the only transfers allowed are to/from the owner address

    uint[3] public tierCaps = [10000000000000000, 30000000000000000, 1000000000000000000000000000];
    uint[3] public tierBonusNumerator = [12, 11, 10];
    uint[3] public tierBonusDenominator = [10, 10, 10];
    uint public currentTier = 0;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) registered;

    event FundsCollected(address owner, uint value);
    event PurchaseRefunded(address investor, uint refund);
    event AddressRegistered(address user, address admin);
    event AddressRevoked(address user, address admin);
    event NewExchangeRate(uint rate, address admin);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        startDate = now;
        endDate = now + 8 weeks;
        registered[owner] = true;
        balances[owner] = privateTokens;
        _totalSupply = privateTokens;
    }


    // ------------------------------------------------------------------------
    // Total supply
    // Tokens issued - tokens burnt
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Pause transferring
    // when paused, only transfers to/from the owner are allowed
    // ------------------------------------------------------------------------
    function pauseTransfers() public onlyOwner {
        paused = true;
    }


    // ------------------------------------------------------------------------
    // Unpause transferring
    // when paused, only transfers to/from the owner are allowed
    // ------------------------------------------------------------------------
    function unpauseTransfers() public onlyOwner {
        paused = false;
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool) {
        require(!paused || msg.sender == owner || to == owner);
        require(registered[to]);
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    //
    // not concerned about an approval double-spend attack anyway, because the
    // only address that should be approved is our STO address
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool) {
        require(registered[spender]);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool) {
        require(!paused || from == owner || to == owner);
        require(registered[to]);
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool) {
        require(registered[spender]);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token admin can authorize an address to purchase tokens
    // Will be registered automatically after completing KYC
    // ------------------------------------------------------------------------
    function registerAddress(address investor) public onlyAdmin returns (bool) {
        emit AddressRegistered(investor, msg.sender);
        registered[investor] = true;
        return true;
    }


    // ------------------------------------------------------------------------
    // Token admin can revoke KYC for an address
    // ------------------------------------------------------------------------
    function revokeRegistration(address investor) public onlyAdmin returns (bool) {
        emit AddressRevoked(investor, msg.sender);
        registered[investor] = false;
        return true;
    }

    // ------------------------------------------------------------------------
    // Check if an account is registered
    // ------------------------------------------------------------------------
    function isRegistered(address investor) public view returns (bool) {
        return registered[investor];
    }


    // ------------------------------------------------------------------------
    // Token admin can change the exchange rate
    // tokensPurchased = exchangeRate * etherSpent
    // ------------------------------------------------------------------------
    function setExchangeRate(uint value) public onlyAdmin {
        emit NewExchangeRate(value, msg.sender);
        exchangeRate = value;
    }


    // ------------------------------------------------------------------------
    // Token owner can gift tokens
    // recipient must be registered
    // cannot exceed hardCap
    // allows for sales to occur off-chain
    // ------------------------------------------------------------------------
    function giftTokens(address recipient, uint value) public onlyOwner returns (bool) {
        require(registered[recipient]);
        uint newSupply = safeAdd(_totalSupply, value);
        require(newSupply <= hardCap);
        balances[recipient] = safeAdd(balances[recipient], value);
        _totalSupply = newSupply;
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can collect funds at any point
    // ------------------------------------------------------------------------
    function collectFunds() public onlyOwner returns (bool) {
        return sendFunds(address(this).balance);
    }

    // ------------------------------------------------------------------------
    // Send all collected funds to Token Owner
    // ------------------------------------------------------------------------
    function sendFunds(uint etherToTransfer) private returns (bool) {
        emit FundsCollected(owner, etherToTransfer);
        owner.transfer(etherToTransfer);
        return true;
    }


    // ------------------------------------------------------------------------
    // Set the threshold for automatically sending funds to owner
    // ------------------------------------------------------------------------
    function setPayoutSize(uint value) public onlyOwner returns (bool) {
        payoutSize = value;
        return true;
    }


    // ------------------------------------------------------------------------
    // Purchase tokens up to the end of the current tier
    // If the current tier is exceeded, increment tier
    // and return the remaining ether
    // ------------------------------------------------------------------------
    function purchaseTokens(uint ethToSpend, uint tier, uint currentSupply) private returns (uint ethRemaining, uint tokensBought, bool hitCap) {
        uint tokens = safeMul(ethToSpend, exchangeRate);
        tokens = safeMul(tokens, tierBonusNumerator[tier]) / tierBonusDenominator[tier];
        uint newSupply = safeAdd(currentSupply, tokens);
        uint refund = 0;
        if (newSupply > tierCaps[tier]) {
            tokens = safeSub(tierCaps[tier], currentSupply);
            uint spent = safeMul(tokens, tierBonusDenominator[tier]) / tierBonusNumerator[tier] / exchangeRate;
            refund = safeSub(ethToSpend, spent);
            newSupply = tierCaps[tier];
            ++currentTier;
            return (refund, tokens, true);
        }
        return (refund, tokens, false);
    }


    // ------------------------------------------------------------------------
    // exchangeRate LNGR Tokens per 1 ETH
    // only active before endDate
    // only accept money from registered addresses
    // if purchase exceeds hardcap, refund excess ether
    // if contract now exceeds payoutSize, send funds to owner
    // ------------------------------------------------------------------------
    function () external payable {
        require(now >= startDate && now <= endDate);
        require(registered[msg.sender]);
        require(_totalSupply < hardCap);

        uint etherStore = address(this).balance;

        uint tier = currentTier;
        uint newTier = tier;
        uint newSupply = _totalSupply;
        uint ethRemaining = msg.value;
        uint tokensBought = 0;
        uint totalTokensBought = 0;
        bool hitCap = false;
        while (ethRemaining > 0 && newSupply < hardCap) {
            (ethRemaining, tokensBought, hitCap) = purchaseTokens(ethRemaining, newTier, newSupply);
            if (hitCap) {
                ++newTier;
            }
            totalTokensBought = safeAdd(totalTokensBought, tokensBought);
            newSupply = safeAdd(newSupply, tokensBought);
        }

        if (currentTier > tier) {
            currentTier = newTier;
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], totalTokensBought);
        _totalSupply = newSupply;
        
        
        emit Transfer(address(0), msg.sender, totalTokensBought);

        if (ethRemaining > 0) {
            emit PurchaseRefunded(msg.sender, ethRemaining);
            etherStore = safeSub(etherStore, ethRemaining);
            msg.sender.transfer(ethRemaining);
        }

        if (etherStore >= payoutSize) {
            sendFunds(etherStore);
        }

    }



    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
