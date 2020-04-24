/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'PittCoin' token contract
//
// Deployed to      : 0x94d546081A2C829B4a0d8617922a210b078e593e
// Symbol           : H2P
// Name             : PittCoin
// Total supply     : 100000000
// Decimals         : 8
//
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract PittCoinBeta01{
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    struct Question {
        uint256 questionHash;
    }

    Question[] public questions;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event asked(uint qid);
    event answered(uint256 qid);
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint256) userToQuestion;
    mapping(uint256 => bool) questionToAnswered;
    mapping(uint256 => uint256) idToQuestion;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "H2PBeta1";
        name = "PittCoinBeta1";
        decimals = 0;
        _totalSupply = 100000000000000000000000000;
        balances[0x94d546081A2C829B4a0d8617922a210b078e593e] = _totalSupply;
        emit Transfer(address(0), 0x5A86f0cafD4ef3ba4f0344C138afcC84bd1ED222, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint256 totalSupply) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function ask(string questionText) public returns (uint256){
        uint256 questionHash = generateQuestionHash(questionText);
        uint256 qid = questions.push(Question(questionHash));
        transfer(address(0), 1);
        emit asked(qid);
        return qid;
    }

    function generateQuestionHash(string text) private view returns(uint256 hash){
        return uint256(keccak256(abi.encodePacked(text)));
    }
    
    function answer(uint256 questionID) private returns (uint256 qid){
        questionToAnswered[questionID] = true;
        transfer(msg.sender, 1);
        emit answered(questionID);
    }



}
