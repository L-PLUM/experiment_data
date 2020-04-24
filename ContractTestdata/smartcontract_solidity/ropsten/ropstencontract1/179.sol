/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.4.18;


contract KYC {
    function keyCertificateValidUntil(address) public view returns(uint) {
        return now;
    }
}


contract BillOfExchange {

    string constant public BILL_OF_EXCHANGE = "bill of exchange"; // because law requires it
    
    string public  currency = "USD";
    
    uint   public  billValue = 123; // 123 USD
    
    string public  personWhoPayName = "Bank Leumi";
    address public personWhoPayAddress; // bank leumi bank
    
    uint public    timeOfPayment = now;
    
    string public  placeWherePaymentIsMade = "London";
    
    string public  placeWhereBillWasIssued = "Tel Aviv";
    uint   public  timeOfCreation;
    
    string public  personWhoIssuedTheBillName = "Viktor";
    address public personWhoIssuedTheBillAddress; // address of victor
    
    
    // Erc20 stuff
    mapping(address=>uint) public balanceOf;
    uint public totalSupply = 0;
    
    // internal fields
    bool public acceptedByPersonWhoIssued = false;    
    bool public acceptedByPersonWhoPaied = false;
    
    KYC public kycContract;
    
    address public factory;
    
    function BillOfExchange() public {
        factory = msg.sender;
    }

    function setParamsPart1(string  _currency,
                            uint    _billValue,
                            string  _personWhoPayName,
                            address _personWhoPayAddress,
                            uint    _timeOfPayment) public {
    
        require(msg.sender == factory);
    
        timeOfCreation = now;
        
        currency = _currency;
        billValue = _billValue;
        personWhoPayName = _personWhoPayName;
        personWhoPayAddress = _personWhoPayAddress;
        timeOfPayment = _timeOfPayment;
    }

    function setParamsPart2(string  _placeWherePaymentIsMade,
                            string  _placeWhereBillWasIssued,
                            string  _personWhoIssuedTheBillName,
                            address _personWhoIssuedTheBillAddress,
                            uint    _totalSupply,
                            KYC     _kyc) public {
        require(msg.sender == factory);                                
                                
        placeWherePaymentIsMade = _placeWherePaymentIsMade;
        placeWhereBillWasIssued = _placeWhereBillWasIssued;
        personWhoIssuedTheBillName = _personWhoIssuedTheBillName;
        personWhoIssuedTheBillAddress = _personWhoIssuedTheBillAddress;                                
        totalSupply = _totalSupply;
        kycContract = _kyc;
    }
    
    function issueToken() public {
        require(msg.sender == factory);
        
        balanceOf[personWhoIssuedTheBillAddress] = totalSupply;
        Transfer(address(0), personWhoIssuedTheBillAddress, totalSupply);
    }


    /*
    function BillOfExchange(string  _currency,
                            uint    _billValue,
                            string  _personWhoPayName,
                            address _personWhoPayAddress,
                            uint    _timeOfPayment,
                            string  _placeWherePAymentIsMade,
                            string  _placeWhereBillWasIssued,
                            string  _personWhoIssuedTheBillName,
                            address _personWhoIssuedTheBillAddress,
                            uint    _totalSupply,
                            BillOfExchangeFactoryInterface _billFactory,
                            KYC     _kyc) public {
    
        timeOfCreation = now;
        
        currency = _currency;
        billValue = _billValue;
        personWhoPayName = _personWhoPayName;
        personWhoPayAddress = _personWhoPayAddress;
        timeOfPayment = _timeOfPayment;
        placeWherePaymentIsMade = _placeWherePAymentIsMade;
        placeWhereBillWasIssued = _placeWhereBillWasIssued;
        personWhoIssuedTheBillName = _personWhoIssuedTheBillName;
        personWhoIssuedTheBillAddress = _personWhoIssuedTheBillAddress;                                
        totalSupply = _totalSupply;
        kycContract = _kyc;
        _billFactory.listBill(this);
    }*/
    

    function acceptByPayer() public {
        require(msg.sender == personWhoPayAddress);
        
        acceptedByPersonWhoPaied = true;
    }
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    function transfer(address to, uint amount) public returns(bool) {
        require(balanceOf[msg.sender] >= amount);
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        Transfer(msg.sender, to, amount);
    }
    
    event Redeem(address user, bool payerAccept);
    function redeem(uint amount) public {
        require(kycContract.keyCertificateValidUntil(msg.sender) >= now);
        require(balanceOf[msg.sender] >= amount);
        
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        
        Transfer(msg.sender, address(0), amount);
        
        Redeem(msg.sender, acceptedByPersonWhoPaied);
    }
}

/*
1. The term 'bill of exchange' inserted in the body of the instrument and expressed in the language employed in drawing up the instrument;
2. An unconditional order to pay a determinate sum of money;
3. The name of the person who is to pay (drawee); * bank leumi
4. A statement of the time of payment;
5. A statement of the place where payment is to be made;
6. The name of the person to whom or to whose order payment is to be made; * supplier
7. A statement of the date and of the place where the bill is issued;
8. The signature of the person who issues the bill (drawer). - implict   intel
*/

contract BillOfExchangeFactory {
    BillOfExchange[] public bills;
    KYC              public kycContract;
    
    function getNumBills() public view returns(uint) {
        return bills.length;
    }
    
    function listBill(BillOfExchange bill) public {
        bills.push(bill);
    }
    
    struct Bill {
        string  _currency;
        uint    _billValue;
        string  _personWhoPayName;
        address _personWhoPayAddress;
        uint    _timeOfPayment;
        string  _placeWherePaymentIsMade;
        string  _placeWhereBillWasIssued;
        string  _personWhoIssuedTheBillName;
        address _personWhoIssuedTheBillAddress;
        uint    _totalSupply;        
    }
    
    function createInternal(BillOfExchange billContract, Bill memory bill) internal {
        billContract.setParamsPart1(bill._currency,
                                    bill._billValue,
                                    bill._personWhoPayName,
                                    bill._personWhoPayAddress,
                                    bill._timeOfPayment);
                                    
        billContract.setParamsPart2(bill._placeWherePaymentIsMade,
                                    bill._placeWhereBillWasIssued,
                                    bill._personWhoIssuedTheBillName,
                                    bill._personWhoIssuedTheBillAddress,
                                    bill._totalSupply,
                                    kycContract);

        billContract.issueToken();
                                    
        bills.push(billContract);
    }
    
    function create(string  _currency,
                    uint    _billValue,
                    string  _personWhoPayName,
                    address _personWhoPayAddress,
                    uint    _timeOfPayment,
                    string  _placeWherePAymentIsMade,
                    string  _placeWhereBillWasIssued,
                    string  _personWhoIssuedTheBillName,
                    address _personWhoIssuedTheBillAddress,
                    uint    _totalSupply) public {
    
            Bill memory bill = Bill(
                            _currency,
                            _billValue,
                            _personWhoPayName,
                            _personWhoPayAddress,
                            _timeOfPayment,
                            _placeWherePAymentIsMade,
                            _placeWhereBillWasIssued,
                            _personWhoIssuedTheBillName,
                            _personWhoIssuedTheBillAddress,
                            _totalSupply                
            );
            
            BillOfExchange billContract = new BillOfExchange();
            
            createInternal(billContract, bill);
    }
}
