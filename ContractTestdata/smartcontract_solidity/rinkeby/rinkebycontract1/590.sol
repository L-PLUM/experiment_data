/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;

contract ERC20 {
    // Basic token features: book of balances and transfer
    uint public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    function transfer(address to, uint tokens) public returns (bool success);

    // Advanced features: An account can approve another account to spend its funds
    mapping(address => mapping (address => uint256)) public allowance;
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Lending {
    // Global Variables
    mapping (address => uint) balances; // Either investor or borrower => balance

    mapping (address => Investor) public investors; // Investor public key => Investor
    mapping (address => Borrower) public borrowers; // Borrower public key => Borrower
    // address[] investorArray;
    // address[] borrowerArray;
    
    //Global counters, always increment
    uint numApplications;
    uint numLoans;

    
    ERC20 public token;

    mapping (uint => LoanApplication) public applications;
    mapping (uint => Loan) public loans;

    mapping(address => bool) hasOngoingLoan;
    mapping(address => bool) hasOngoingApplication;
    mapping(address => bool) hasOngoingInvestment;
    
    constructor(
        ERC20 tokenAddress
        ) public {
            token = ERC20(tokenAddress);
            numLoans = 1;
            numApplications = 1;
        }

    // Structs
    struct Investor{
        address investor_public_key;
        string name;
        bool EXISTS;
    }
    struct Borrower{
        address borrower_public_key;
        string name;
        bool EXISTS;
    }
    struct LoanApplication{
        //For traversal and indexing
        bool openApp;
        uint applicationId;

        address borrower;
        uint duration; // In months
        uint credit_amount; // Loan amount
        //uint interest_rate; //From form
        string otherData; // Encoded string with delimiters (~)

    }
    struct Loan{

        //For traversal and indexing
        bool openLoan;
        uint loanId;

        address borrower;
        address investor;
        uint interest_rate;
        uint duration;
        uint principal_amount;
        uint original_amount;
        uint amount_paid;
        uint startTime;
        uint monthlyCheckpoint;
        uint appId;

    }
    // Methods
    function createInvestor(string name) public{
		require (investors[msg.sender].EXISTS != true);
		require (borrowers[msg.sender].EXISTS != true);
        Investor memory investor;
        investor.name = name;
        investor.investor_public_key = msg.sender;
        investor.EXISTS = true;
        investors[msg.sender] = investor;
        hasOngoingInvestment[msg.sender] = false;
        balances[msg.sender] = 0; // Init balance

    }
    function createBorrower(string name) public{
		require (investors[msg.sender].EXISTS != true);
		require (borrowers[msg.sender].EXISTS != true);
        Borrower memory borrower;
        borrower.name = name;
        borrower.borrower_public_key = msg.sender;
        borrower.EXISTS = true;
        borrowers[msg.sender] = borrower;
        // borrowerArray[borrowerArray.length] = borrower.borrower_public_key;
        hasOngoingLoan[msg.sender] = false;
        hasOngoingApplication[msg.sender] = false;
        balances[msg.sender] = 0; // Init balance
    }
    function viewBalance() public view returns (uint){
        return balances[msg.sender];
    }
    function deposit(uint amount) public {
		require(token.transferFrom(msg.sender, this, amount), "Payment failed. Has customer given allowance?");
        balances[msg.sender] += amount;
    }
    function withdraw(uint amount) public returns (uint) {
        require(amount <= balances[msg.sender]);
		token.transfer(msg.sender, amount);
        balances[msg.sender] -= amount;
        return amount;
    }
    function transfer(address giver, address taker, uint amount) public{
        require(balances[giver] >= amount);
        balances[giver] -= amount;
        balances[taker] += amount;
    }
    function createApplication(uint duration, uint credit_amount, string otherData) public{

        require(hasOngoingLoan[msg.sender] == false);
        require(hasOngoingApplication[msg.sender] == false);
        require(isBorrower(msg.sender));
        applications[numApplications] = LoanApplication(true, numApplications, msg.sender, duration, credit_amount, otherData);
        // app.duration = duration;
        // app.interest_rate = interest_rate;
        // app.credit_amount = credit_amount;
        // app.otherData = otherData;
        // app.applicationId = numApplications;
        // app.borrower = msg.sender;
        // app.openApp = true;

        // current_applications[msg.sender] = app;
        numApplications += 1;
        hasOngoingApplication[msg.sender] = true;
    }
    function grantLoan(uint appId, uint interest_rate) public{
		//Interest rate here is simplified as fixed token amount to be paid back monthly
		//in addition to the principal amount
		
        //Check sufficient balance
        require(balances[msg.sender] >= applications[appId].credit_amount);
        //require(hasOngoingInvestment[msg.sender] == false);

        // Take from sender and give to reciever
        balances[msg.sender] -= applications[appId].credit_amount;
        balances[applications[appId].borrower] += applications[appId].credit_amount;

        // Populate loan object
        loans[numLoans] = Loan(true, numLoans, applications[appId].borrower, msg.sender, interest_rate, applications[appId].duration,
        applications[appId].credit_amount, applications[appId].credit_amount, 0, now,0, appId);
        numLoans += 1;

        applications[appId].openApp = false;
        hasOngoingLoan[applications[appId].borrower] = true;
        hasOngoingInvestment[msg.sender] = true;


    }
    function repayLoan(uint amount, address borrower) public{
        //First check if the payer has enough money
        require(balances[msg.sender] >= amount);

        //Find the loan
        uint id_ = 0;
        for(uint i=1; i<=numLoans; i++)
        {
                if(loans[i].borrower == borrower && loans[i].openLoan == true)
                {
                    id_ = i;
                    break;
                }
        }
        Loan storage loan = loans[id_];
        //Loan found

        //Require that a loan is ongoing
        require(loan.openLoan == true);

        //Get some params fromt the loan
        uint principal = loan.principal_amount;
        uint interest = loan.interest_rate;
        uint amountWithInterest = principal + interest;

        //Payable Amount should not exceed the amountWithInterest
		if(amount > amountWithInterest){
			amount = amountWithInterest;
		}

        //Payable amount should be at least equal to monthly interest
        require(amount>=interest);

        // Update balance for interest first
        balances[msg.sender] -= interest;
        balances[loan.investor] += interest;

        amount -= interest;
        loan.amount_paid += interest;

        // Extra payment after interest is paid
        if(amount>0)
        {
            loan.principal_amount -= amount;
            loan.amount_paid += amount;

            balances[msg.sender] -= amount;
            balances[loan.investor] += amount;
        }

        if(loan.principal_amount == 0)
        {
            loans[id_].openLoan = false;
            hasOngoingLoan[msg.sender] = false;
            hasOngoingApplication[msg.sender] = false;
            hasOngoingApplication[loan.investor] = false;
            hasOngoingLoan[loan.investor] = false;
        }
    }
    function ifApplicationOpen(uint index) public view returns (bool){
        LoanApplication memory app = applications[index];
        if(app.openApp) return true; else return false;
    }
    function ifLoanOpen(uint index) public view returns (bool){
        Loan memory loan = loans[index];
        if (loan.openLoan == true) return true; else return false;
    }
    function getApplicationData(uint index) public view returns (uint[], string, address){
        string memory otherData = applications[index].otherData;
        uint[] memory numericalData = new uint[](4);
        numericalData[0] = index;
        numericalData[1] = applications[index].duration;
        numericalData[2] = applications[index].credit_amount;

        address borrower = applications[index].borrower;
        return (numericalData, otherData, borrower);
        // numericalData format = [index, duration, amount, interestrate]
    }
    function getAllApplicationsData(address borrower) public view returns (uint[]){
        // get list of all applications by borrower, fixed length array for demo only
        uint[] memory ids = new uint[](10);
        uint index_ = 0;
        for(uint i=1; i<=numApplications; i++)
        {
                if(applications[i].borrower == borrower)
                {
                    ids[index_] = i;
                    index_ += 1;
                }
        }
        
        return (ids);
        // numericalData format = [index, duration, amount, interestrate]
    }
    
    function getOpenApplicationData(address borrower) public view returns (uint[], string, address){
        uint id_ = 0;
        for(uint i=1; i<=numApplications; i++)
        {
                if(applications[i].borrower == borrower && applications[i].openApp == true)
                {
                    id_ = i;
                    break;
                }
        }
        string memory otherData = applications[id_].otherData;
        uint[] memory numericalData = new uint[](4);
        numericalData[0] = id_;
        numericalData[1] = applications[id_].duration;
        numericalData[2] = applications[id_].credit_amount;

        return (numericalData, otherData, borrower);
        // numericalData format = [index, duration, amount, interestrate]
    }
    function getLoanData(uint index) public view returns (uint[], address, address){
        uint[] memory numericalData = new uint[](9);
        numericalData[0] = index;
        numericalData[1] = loans[index].interest_rate;
        numericalData[2] = loans[index].duration;
        numericalData[3] = loans[index].principal_amount;
        numericalData[4] = loans[index].original_amount;
        numericalData[5] = loans[index].amount_paid;
        numericalData[6] = loans[index].startTime;
        numericalData[7] = loans[index].monthlyCheckpoint;
        numericalData[8] = loans[index].appId;

        return (numericalData, loans[index].borrower, loans[index].investor);
        // numericalData format = [index, interestrate, duration, p_amnt, o_amnt, paid_amnt, starttime, app_index]
    }
    function getAllLoansData(address borrower) public view returns (uint[], address){
        // get list of all applications by borrower
        uint[] memory ids = new uint[](10);
        uint index_ = 0;
        for(uint i=1; i<=numLoans; i++)
        {
                if(loans[i].borrower == borrower)
                {
                    ids[index_] = i;
                    index_ += 1;
                }
        }
        
        return (ids, borrower);
        // numericalData format = [index, interestrate, duration, p_amnt, o_amnt, paid_amnt, starttime, app_index]
    }
    function getOpenLoanData(address borrower) public view returns (uint[], address, address){
        uint id_ = 0;
        for(uint i=1; i<=numLoans; i++)
        {
                if(loans[i].borrower == borrower && loans[i].openLoan == true)
                {
                    id_ = i;
                    break;
                }
        }

        uint[] memory numericalData = new uint[](9);
        numericalData[0] = id_;
        numericalData[1] = loans[id_].interest_rate;
        numericalData[2] = loans[id_].duration;
        numericalData[3] = loans[id_].principal_amount;
        numericalData[4] = loans[id_].original_amount;
        numericalData[5] = loans[id_].amount_paid;
        numericalData[6] = loans[id_].startTime;
        numericalData[7] = loans[id_].monthlyCheckpoint;
        numericalData[8] = loans[id_].appId;

        return (numericalData, borrower, loans[id_].investor);
        // numericalData format = [index, interestrate, duration, p_amnt, o_amnt, paid_amnt, starttime, app_index]
    }
    function getNumApplications() public view returns (uint) { return numApplications;}
    function getNumLoans() public view  returns (uint){ return numLoans;}
    function isInvestor(address account) public view  returns (bool) {return investors[account].EXISTS;}
    function isBorrower(address account) public view  returns (bool) {return borrowers[account].EXISTS;}
    function getTime() public view returns (uint){return now;}
}
