/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity ^0.4.24;

contract PeterBebe {

    struct Pago{
        address user;
        uint256 value;
        uint256 date;
        string razon;
        bool statusPay;
    }

    address public owner;
    address public sraRosa;
    uint256 public EntryPrice = 300000000000000000;
    string public razon;
    uint256 now2 = now + 3 minutes;
    
    bool public stopped = false;
    mapping (address => Pago) public Pagos;
    address[] public pagos;

    constructor() public{
        owner = msg.sender;
        sraRosa = msg.sender;
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

    function setRetiro() onlysraRosa isRunning public returns (bool success){
      	sraRosa.transfer(address(this).balance);
        return true;
    }

    function Pay(string _razon) payable isRunning validAddress public {
        require(owner != msg.sender);
        uint256 value = msg.value;
        if( value >= EntryPrice ){
            Pagos[msg.sender].user = msg.sender;
            Pagos[msg.sender].value = value;
            Pagos[msg.sender].statusPay = true;
            Pagos[msg.sender].date = now;
            Pagos[msg.sender].razon = _razon;
            pagos.push(msg.sender);
            emit PagoEvent(msg.sender, value, now, razon);
        } else {
            revert();
        }
    }
  
    function getBalance() view public returns (uint256 balance){
        return address(this).balance;
    }
  
    event PagoEvent(address indexed _user, uint256 indexed _value, uint256 indexed _date, string _razon);
}
