/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.2;



contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
 
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 
contract ZentaToken is ERC20Interface{
    string public name = "Zenta";
    string public symbol = "ZENTA";
    uint public decimals = 18;
    
    uint public supply;
    address public founder;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) allowed;
    
    //allowed[0x1111....][0x22222...] = 100;
    
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 
 
    constructor() public{
        supply = 260514201 * 10 ** decimals;
        founder = msg.sender;
        balances[founder] = supply;
    }
    
    
    function allowance(address tokenOwner, address spender) view public returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    
    //approve allowance
    function approve(address spender, uint tokens) public returns(bool){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    //transfer tokens from the  owner account to the account that calls the function
    function transferFrom(address from, address to, uint tokens) public returns(bool){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        
        balances[from] -= tokens;
        balances[to] += tokens;
        
        
        allowed[from][to] -= tokens;
        
        return true;
    }
    
    function totalSupply() public view returns (uint){
        return supply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance){
         return balances[tokenOwner];
     }
     
     
    function transfer(address to, uint tokens) public returns (bool success){
         require(balances[msg.sender] >= tokens && tokens > 0);
         
         balances[to] += tokens;
         balances[msg.sender] -= tokens;
         emit Transfer(msg.sender, to, tokens);
         return true;
     }
}
 
 
contract ZentachainICO is ZentaToken{
    address public admin;
    
    
    
    address payable public deposit;
    
    //token price in wei: 1ZENTA = 0.000423 ETHER, 1 ETHER = 2400 Zenta
    uint tokenPrice = 2400;
    
    //65000 Ether in wei
    uint public hardCap = 65000000000000000000000;
    
    uint public raisedAmount;
    
    uint public saleStart = now;
    uint public saleEnd = now + 2629700; //one moths
    uint public coinTradeStart = now; //transferable in two week after salesEnd only on Main net avable
    
    uint public maxInvestment = 50000000000000000000;
    uint public minInvestment = 10000000000000000;
    
    enum State { beforeStart, running, afterEnd, halted}
    State public icoState;
    
    
    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    
    event Invest(address investor, uint value, uint tokens);
    
    
    
    constructor(address payable _deposit) public{
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }
    
    //emergency stop
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
    
    //restart 
    function unhalt() public onlyAdmin{
        icoState = State.running;
    }
    


    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }
    
    
    
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }
    
    
    function invest() payable public returns(bool){
        //invest only in running
        icoState = getCurrentState();
        require(icoState == State.running);
        
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        
        uint tokens = msg.value * tokenPrice;
        
        //hardCap not reached
        require(raisedAmount + msg.value <= hardCap);
        
        raisedAmount += msg.value;
        
        //add tokens to investor balance from founder balance
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        
        deposit.transfer(msg.value);//transfer eth to the deposit address
        
        //emit event
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
        
 
    }
    
    
    function () payable external{
        invest();
    }
    
    
    
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 50000000;
        
    }
    
    
    function transfer(address to, uint value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transfer(to, value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transferFrom(_from, _to, _value);
    }
    
}
