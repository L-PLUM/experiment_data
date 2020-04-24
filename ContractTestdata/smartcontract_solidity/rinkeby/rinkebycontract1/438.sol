/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.25;

/** KPI is 100k target selling period is 45 days*/

/** Reach 100k before 45 days -> payoff immediately through `claim` function */

/** Trunk payment period when reach partial KPI
    0 -> 15 date reach >=25k -> 1/3 Fee
    15 -> 30 date reach >=25k -> 1/3 Fee
    45  reach >=25k -> 1/3 Fee
        
    Remaining ETH will refund to Triip through `refund` function
*/

contract TriipInvestorsServices {

    event Payoff(address _seller, uint _amount, uint _kpi);
    
    event Refund(address _buyer, uint _amount);

    event Claim(address _sender, uint _counting, uint _buyerWalletBalance);

    enum PaidStage {
        NONE,
        FIRST_PAYMENT,
        SECOND_PAYMENT,
        FINAL_PAYMENT
    }

    uint public KPI_25k = 25;
    uint public KPI_50k = 50;
    uint public KPI_100k = 100;    
    
    address public buyer; // Triip Protocol wallet use for refunding
    address public seller; // NCriptBit
    address public buyerWallet; // Triip Protocol's raising ETH wallet
    
    uint public start = 0;
    uint public end = 0;
    bool public isEnd = false;    

    uint decimals = 18;
    uint unit = 10 ** decimals;
    // uint paymentAmount = 82 * unit; // equals to 10,000 USD upfront
    // uint targetSellingAmount = 820 * unit; // equals to 100,000 USD upfront
    
    uint paymentAmount = 1 * unit; // equals to 10,000 USD upfront
    uint targetSellingAmount = 10 * unit; // equals to 100,000 USD upfront

    uint claimCounting = 0;

    PaidStage public paidStage = PaidStage.NONE;

    uint public balance;

    constructor(address _buyer, address _seller, address _buyerWallet) public {

        seller = _seller;
        buyer = _buyer;
        buyerWallet = _buyerWallet;
        
    }

    modifier whenNotEnd() {
        require(!isEnd, "This contract should not be end") ;
        _;
    }

    function confirmPurchase() public payable {
        
        require(start == 0);
        
        require(msg.value == paymentAmount, "Not equal payment amount");
        
        start = now;
        
        // end = start + ( 45 * 1 days );
        end = start + ( 15 * 1 minutes );
        
        balance += msg.value;
    }

    function contractEthBalance() public view returns (uint) {

        return balance;
    }

    function buyerWalletBalance() public view returns (uint) {
        
        return address(buyerWallet).balance;

        // for testing
        // return address(buyerWallet).balance - 100 ether;
    }
    
    function claim() public whenNotEnd returns (uint) {

        claimCounting = claimCounting + 1;

        uint payoffAmount = 0;

        emit Claim(msg.sender, claimCounting, buyerWalletBalance());
        
        if ( buyerWalletBalance() >= targetSellingAmount ) {
            
            payoffAmount = balance;

            seller.transfer(payoffAmount);
            
            paidStage = PaidStage.FINAL_PAYMENT;

            balance = 0;
            
            endContract();

            emit Payoff(seller, payoffAmount, KPI_100k);

        }
        else {
            
            claimByKPI();

        }
        
        if(now >= end) {
            refund();    
        }
        
        
        return payoffAmount;
    }

    function claimByKPI() private {

        uint payoffAmount = 0;

        if( buyerWalletBalance() >= (targetSellingAmount * KPI_25k / 100) 
            // ad-hoc testing
            && now >= (start + (5 * 1 minutes) )
            // && now >= (start + (15 * 1 days) )
            && paidStage == PaidStage.NONE ) {
          
              payoffAmount = balance * 33 / 100;

              balance = balance - payoffAmount;
              
              seller.transfer(payoffAmount);

              emit Payoff(seller, payoffAmount, KPI_25k );

              paidStage = PaidStage.FIRST_PAYMENT;
            
        } 
        
        if ( buyerWalletBalance() >= (targetSellingAmount * KPI_50k / 100) 
            // ad-hoc test
            && now >= (start + ( 10 * 1 minutes) )
            // && now >= (start + ( 30 * 1 days) )
            ) {

            uint paidPercent = 0;
            
            if ( paidStage == PaidStage.NONE) {
                paidPercent = 66;
            }
            
            if( paidStage == PaidStage.FIRST_PAYMENT) {
                paidPercent = 33;
            }
            
            payoffAmount = balance * paidPercent / 100;
            
            balance = balance - payoffAmount;
            
            seller.transfer(paymentAmount);
            
            emit Payoff(seller, payoffAmount, KPI_50k);
            
            paidStage = PaidStage.SECOND_PAYMENT;
        }

        if(
            // ad-hoc test
            now >= (start + (15 * 1 minutes) )
            // now >= (start + (45 * 1 days) )
            ) {
            endContract();
        }
    }

    function endContract() private {
        
        isEnd = true;
        
    }
    
    function refund() public returns (uint) {
        
        require(now >= end);
        
        // refund remaining balance
        uint refundAmount = address(this).balance;
        
        buyer.transfer(refundAmount);
        
        emit Refund(buyer, refundAmount);
        
        return refundAmount;
    }
}
