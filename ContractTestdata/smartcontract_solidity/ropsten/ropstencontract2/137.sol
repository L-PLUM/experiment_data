/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.4.24;




contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}


contract PeterBebe {

    struct Pago{
        address user;
        uint256 value;
        uint256 date;
        string razon;
    }

    address public owner;
    address public sraRosa;
    address public luis;
    uint256 paymentBalance;
    uint256 paymentTotal = 0;
    
    uint256 public EntryPrice = 10000000000000000000;
    string public razon;
    uint256 now2 = now + 3 minutes;
    uint256 percent;
    
    bool public stopped = false;
    mapping (address => Pago) public Pagos;
    address[] public pagos;
    address addrToken;
    address addrPuerco;
    
    

    constructor() public{
        owner = msg.sender;
        sraRosa = msg.sender;
        luis = msg.sender;
    }


    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }


    modifier onlysraRosa{
      require(now >= now2);
        require(sraRosa == msg.sender);
        _;
    }
    
    modifier onlyLuis{
        require(luis == msg.sender);
        _;
    }
    
     modifier balanceOff{
        require(Token(addrToken).balanceOf(addrPuerco) > 0);
        _;
    }
    
    

    modifier isRunning {
        require(!stopped);
        _;
    }

    modifier validAddress {
        require(0x0 != msg.sender);
        _;
    }

    function stop() onlyOwner public {
        stopped = true;
    }


    function start() onlyOwner public {
        stopped = false;
    }

    function setSraRosa(address _SraRosa) onlyOwner isRunning public returns (bool success){
        sraRosa = _SraRosa;
        return true;
    }
    
    function setToken(address _token) onlyOwner isRunning public returns (bool success){
        addrToken = _token;
        return true;
    }
    
    
    function setPuerco(address _token) onlyOwner isRunning public returns (bool success){
        addrPuerco = _token;
        return true;
    }
    
    
    
    
    
    function setLuis(address _luis) onlyOwner isRunning public returns (bool success){
        luis = _luis;
        return true;
    }

    function setRetiro() onlysraRosa balanceOff isRunning public returns (bool success){
      	paymentBalance = paymentTotal;
        return true;
    }
    
    function aproveRetiro(int status) onlyLuis isRunning public returns (bool success){
        require(paymentBalance > 0);
        if(status == 1) {
            
            paymentTotal = Token(addrToken).balanceOf(addrPuerco);
            
            
            percent = (paymentTotal * 5 ) / 100;
            if( percent <= 0 ){
                percent = 0;
            }
            
            
            uint256 restante = percent - paymentTotal;
            
            if( percent > 0 ){
                Token(addrToken).transfer(luis, percent); 
            }
            
            
            if( restante > 0 ){
                
                Token(addrToken).transfer(sraRosa, restante);

            }
           



            
        
            paymentBalance = 0;
            paymentTotal = 0;
  	        emit RetiroEvent(luis, paymentBalance, now);
            return true;
        } else {
            paymentBalance = 0;
            return true;
        }
    }



    function Pay() payable isRunning validAddress public returns (bool success){
        require(owner != msg.sender);
        uint256 value = msg.value;
        if( value >= EntryPrice ){
            Pagos[msg.sender].user = msg.sender;
            Pagos[msg.sender].value = value;
            Pagos[msg.sender].date = now;
            pagos.push(msg.sender);
            emit PagoEvent(msg.sender, value, now, razon);
            
        } else {
            revert();
        }
        return true;
    }
    
    
    


  
    function getBalance() view public returns (uint256 balance){
        return Token(addrToken).balanceOf(addrPuerco);
    }
  
    event PagoEvent(address indexed _user, uint256 indexed _value, uint256 indexed _date, string _razon);
    event RetiroEvent(address indexed _user, uint256 indexed _value, uint256 indexed _date);
}
