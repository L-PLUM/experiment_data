/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.4.18;


contract KYC {
    function keyCertificateValidUntil(address) public view returns(uint) {
        return now;
    }
}

interface BillOfExchangeFactoryInterface {
    function listBill(address bill) public;
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
    }
    

    function acceptByIssuer() public {
        require(msg.sender == personWhoIssuedTheBillAddress);
        acceptedByPersonWhoIssued = true;
    }
    
    function acceptByPayer() public {
        require(acceptedByPersonWhoIssued);
        require(msg.sender == personWhoPayAddress);
        
        acceptedByPersonWhoPaied = true;
        
        balanceOf[personWhoIssuedTheBillAddress] = totalSupply;
        
        Transfer(address(0), totalSupply);
    }
    
    event Transfer(address to, uint amount);
    function transfer(address to, uint amount) public returns(bool) {
        require(acceptedByPersonWhoPaied);
        require(balanceOf[msg.sender] >= amount);
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        
        Transfer(to, amount);
    }
    
    event Redeem(address user);
    function redeem(uint amount) public {
        require(kycContract.keyCertificateValidUntil(msg.sender) >= now);
        require(balanceOf[msg.sender] >= amount);
        
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        
        Redeem(msg.sender);
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
    
    function getNumBills() public view returns(uint) {
        return bills.length;
    }
    
    function listBill(BillOfExchange bill) public {
        bills.push(bill);
    }
}
