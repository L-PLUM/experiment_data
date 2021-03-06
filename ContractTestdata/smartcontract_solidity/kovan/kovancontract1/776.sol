/**
 *Submitted for verification at Etherscan.io on 2019-01-07
*/

pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : [email protected]
// released under Apache 2.0 licence
// input  /Users/daveappleton/Documents/Virgil/docSamples/barShop/barShop.sol
// flattened :  Monday, 07-Jan-19 18:14:18 UTC
contract RhombusClient {
    address public owner = msg.sender;
    address public RhombusOracle;
    uint    public RhombusNonce;
    
    event rhombusRequest(uint nonce, uint ID);

    event RhombusUint(uint nonce, uint ID, uint firstVar);
    event RhombusDoubleUint(uint nonce, uint ID, uint firstVar, uint secondVar);
    event RhombusAddrDoubleUint(uint nonce, uint ID, address firstVar, uint secondVar, uint thirdVar);
    event RhombusAddrTripleUint(uint nonce, uint ID, address firstVar, uint secondVar, uint thirdVar, uint fourthVar);
    
    modifier onlyOwner {
        require(msg.sender == owner, "Unauthorised");
        _;
    }

    modifier onlyRhombus {
        require(msg.sender == RhombusOracle, "Not a Rhombus Address");
        _;
    }

    function emitRequest(uint ID) internal {
        emit rhombusRequest(RhombusNonce, ID);
        RhombusNonce++;
    }
    
    function emitUint(uint ID, uint var1) internal {
        emit RhombusUint(RhombusNonce, ID, var1);
        RhombusNonce++;
    }

    function emitDoubleUint(uint ID, uint var1, uint var2) internal {
        emit RhombusDoubleUint(RhombusNonce, ID, var1, var2);
        RhombusNonce++;
    }
    
    function emitAddrDoubleUint(uint ID, address var1, uint var2, uint var3) internal {
        emit RhombusAddrDoubleUint(RhombusNonce, ID, var1, var2, var3);
        RhombusNonce++;
    }
    
    function emitAddrTripleUint(uint ID, address var1, uint var2, uint var3, uint var4) internal {
        emit RhombusAddrTripleUint(RhombusNonce, ID, var1, var2, var3, var4);
        RhombusNonce++;
    }

    function setRhombus(address rhombus) public onlyOwner {
        RhombusOracle = rhombus;
    }

}
contract GoldBarStub {

    mapping(bytes32 => uint) public _allocatedBar;    

    function mintWithBarData(
        address to,
        uint    barSize,
        uint    mintedDate,
        string  serialNumber
      )
        public returns (bool);
}

contract BarShop is RhombusClient {
    
    enum states{NotActive,Requested,Active,Accepted,Expired}
    address public helloGold;
    GoldBarStub public token;

    string[] public bar100;
    string[] public bar1000;
    uint     public index100;
    uint     public index1000;

    uint orderNumber;
    
    struct quotation {
        uint barSize;           // bar size. Currently we only have 100g and 1kg bars
        uint price;             // price (in ether) of the bar - set by the oracle in makeOffer
        string serialNumber; // the serial numbers of the bars once allocated
        states state;           // state of the transaction
        uint expiry;            // expiry date for the offer to be accepted
    }

    mapping (address =>quotation[]) public quotes;
    mapping(bytes32 => uint) public _allocatedBar;    

    
    event OfferMade(address client, uint quoteIndex, uint price );
    event OfferAccepted(address client, uint quoteIndex, uint barSize, uint price );

    modifier onlyHelloGold {
        require(msg.sender == helloGold, "Not a HelloGold Address");
        _;
    }

    constructor(GoldBarStub token_) public {
        token = token_;
    }

    // Josephine Q Public (the client) sends 0.1 ether to get a quotation
    // pushQuote does the storing and communication with Rhombus
    //
    function requestQuotation(uint barSize) public payable {
        require(msg.value >= 100 finney,"0.1 ether deposit required");
        require(barSize == 100 || barSize == 1000,"currently only supporting 100g and 1kg bars");
        pushQuote(msg.sender,barSize); 
    }

    // Once a RFQ is received, the Rhombus oracle calculates the bar price with fees and deducting the deposit. 
    // This causes the RFQ to be updated with the price and expiry time of the quote
    // An event is sent which the client should be tracking to allow them to accept it before expiry
    //
    function makeOffer(address client, uint quoteIndex, uint price) public onlyRhombus {
        require(quoteIndex < quotes[client].length,"invalid quote");
        require(quotes[client][quoteIndex].state == states.Requested,"This quote is in the wrong state");
        quotes[client][quoteIndex].state = states.Active;
        quotes[client][quoteIndex].price = price;
        quotes[client][quoteIndex].expiry = now + 20 minutes;
        emit OfferMade(client,quoteIndex, price);
    }

    // Once the client has detected the OfferMade event, she has until the expiry time to accept the offer by sending the payment amount
    // and supplying the relevent information. This updates the record (proof of purchase) but the bar tokens are not minted until they 
    // are allocated in the vault
    // 
    function acceptOffer(uint quoteIndex) public payable {
        require(quoteIndex < quotes[msg.sender].length,"invalid quote");
        quotation storage q = quotes[msg.sender][quoteIndex];
        require(msg.value >= q.price, "Insufficient value sent");
        require(q.state == states.Active, "This quotation is not open");
        require(q.expiry >= now, "This quotation has expired");
        q.state = states.Accepted;
        q.serialNumber = nextSerialNumber(q.barSize);
        token.mintWithBarData(msg.sender,now,q.barSize,q.serialNumber);
        emit OfferAccepted(msg.sender,quoteIndex,q.barSize, q.price);
    }
    
    // Append the RFQ to this client's RFQ list
    // ask Rhombus Library to emit event identifying client, which RFQ and its details.
    //
    function pushQuote(address client, uint barSize) internal {
        quotation memory q;
        uint quoteIndex = quotes[client].length;
        q.barSize = barSize;
        q.state = states.Requested;
        quotes[client].push(q);
        emitAddrDoubleUint(0, client, quoteIndex, barSize); // only one oracle
    }
    
    function nextSerialNumber(uint barSize) private returns (string serial) {
        if (barSize == 100) {
            require(index100 < bar100.length,"No bars allocated");
            serial = bar100[index100];
            index100++;
            return;
        }
        require (barSize == 1000, "only 100g and 1kg bars supported");
        require(index1000 < bar1000.length,"No bars allocated");
        serial = bar1000[index1000];
        index1000++;
    }

    function addBar(string serial, uint barSize) public onlyOwner {
        bytes32 hash = keccak256(bytes(serial));
        require(token._allocatedBar(hash) == 0,"Bar already in use");
        require(_allocatedBar[hash] == 0,"Bar already in stock");
        _allocatedBar[hash] = barSize;
        if (barSize == 100) {
            bar100.push(serial);
            return;
        }
        require (barSize == 1000, "only 100g and 1kg bars supported");
        bar1000.push(serial);
    }
}
