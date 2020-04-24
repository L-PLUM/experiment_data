/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.4.25;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract WhitelistToken_interface{
    function getAllowedAmountTokens(address userAddress) public view returns(uint);
}


contract Withdrawable is Ownable {
    using SafeMath for uint256;

    event Withdraw(address indexed to, uint256 amount);

    function _withdrawal(address _to, uint256 _amount) internal {
        require(_amount > 0);
        require(_to.send(_amount));
        emit Withdraw(_to, _amount);
    }
}

contract ICOCrowdsale is Withdrawable {
    using SafeMath for uint256;

    uint256 public max_token_sale = 1200000000;
    uint256 public tokenBuyPrice = 0.00486080 * (10 ** 18); // ETH - WEI

    uint256 public token_decimals = 0;
    WhitelistToken_interface public whitelist = WhitelistToken_interface(address(0));

    address public exchangeAddress = address(0);
    bool public useAutoExchange = true;
    uint public minAmount4Tokens2AutoExchange = 10;

    // 1 - limited by total token amount
    // 2 - limited by total eth amount
    uint public user_limit_type = 2;
    uint public total_max_tokens_per_user = 9090909;  // <-- need to be removed, I don't see it used anywhere!
    uint public total_max_eth_per_user = 50000 * (10 ** 18); // ETH - WEI  // we keep as a failsafe

    bool public IS_SALE_OPEN = false;

    struct PhaseParams{
        string NAME;
        bool IS_STARTED;
        bool IS_FINISHED;
    }
    PhaseParams[] public phases;
    uint256 constant PHASES_COUNT = 3;

    uint256 private _total_token_sale = 0;
    function total_token_sale() public view returns (uint256) {
        return _total_token_sale;
    }

    struct InvestmentBookRow{
        uint blocknumber;
        uint timestamp;
        uint256 weiAmount;
        uint256 rate;
        uint256 tokenAmount;

        address contributor;

        uint256 wlAllowedTokens;
        address exchangeAddress;
        bool exchanged;

    }

    struct Investor{
        uint id;
        bool exists;
        address contributor_address;
        uint txsn;
        uint256[] investment;

        // 0 - default limit
        // 1 - limited by total token amount
        // 2 - limited by total eth amount
        uint limitType;
        uint max_token_amount;
        uint max_eth_amount;

        uint totalETHAmount;
        uint totalTokenAmount;
    }

    
    mapping(address => Investor) public investorBook;
    address[] public investors;
    InvestmentBookRow[] public investment;


    constructor() public{
        // 0 - first
        PhaseParams memory phaseFirst;
        phaseFirst.NAME = "Initialize";
        phaseFirst.IS_STARTED = false;
        phaseFirst.IS_FINISHED = false;
        phases.push(phaseFirst);

        // 1 - second
        PhaseParams memory phaseSecond;
        phaseSecond.NAME = "Sale";
        phaseSecond.IS_STARTED = false;
        phaseSecond.IS_FINISHED = false;
        phases.push(phaseSecond);

        // 3 - last
        PhaseParams memory phaseSeventh;
        phaseSeventh.NAME = "Finalize";
        phaseSeventh.IS_STARTED = false;
        phaseSeventh.IS_FINISHED = false;
        phases.push(phaseSeventh);
        
        assert(PHASES_COUNT == phases.length);

        phases[0].IS_STARTED = true;
    }


    //
    // ####################################
    //

    function withdrawal(address _to) public onlyOwner{
        super._withdrawal(_to, address(this).balance);
    }

    //
    // ####################################
    //

    // private sale method
    function buyTokens(address _beneficiary) public payable {

        uint i = getCurrentPhaseIndex();
        require(i == 1); // is Sale

        require(IS_SALE_OPEN);

        require(msg.sender == _beneficiary);
        
        require(msg.value > 0);
        
        //calculate tokens amount from ETH amount by tokenPrice
        uint256 amount = msg.value.div(tokenBuyPrice); // 0 - tokn's decimals

        // if need, initialize user in contribution book
        initContributor(_beneficiary);
        // check sale by current limits
        require(checkSaleContributorLimits(_beneficiary, amount, msg.value));

        require(amount > 0);
        require(max_token_sale >= total_token_sale().add(amount));

        uint256 allowedAmount = whitelist.getAllowedAmountTokens(msg.sender);
        // require(allowedAmount >= amount);
        require(allowedAmount > 0); // check existing contributor in whitelist

        bool _isAutoExchange = useAutoExchange && amount > minAmount4Tokens2AutoExchange;

        if(_isAutoExchange){
            require(exchangeAddress != address(0));
            super._withdrawal(exchangeAddress, msg.value);
        }

        addRowToInvestorsBook(_beneficiary, msg.value, tokenBuyPrice, amount, allowedAmount, _isAutoExchange);

        _total_token_sale = total_token_sale().add(amount);

        investorBook[_beneficiary].totalTokenAmount = investorBook[_beneficiary].totalTokenAmount.add(amount);
        investorBook[_beneficiary].totalETHAmount = investorBook[_beneficiary].totalETHAmount.add(msg.value);
    }

    // private sale method (auto call)
    function() public payable {
        buyTokens(msg.sender);
    }

    //
    // ####################################
    //

    function checkSaleContributorLimits(address _contributor_address, uint256 _LKDamount, uint256 _weiETHamout) public view returns(bool){
        bool status = true;
        if(investorBook[_contributor_address].exists){
            if(investorBook[_contributor_address].limitType == 0){  // user's standard check limits with current data
                if(user_limit_type == 1){  //limited by total token amount
                    status = status && _LKDamount.add(investorBook[_contributor_address].totalTokenAmount) <= total_max_tokens_per_user;
                }else if(user_limit_type == 2){  //limited by total eth amount
                    status = status && _weiETHamout.add(investorBook[_contributor_address].totalETHAmount) <= total_max_eth_per_user;
                }
            } else if(investorBook[_contributor_address].limitType == 1){ //limited by user's total token amount
                status = status && _LKDamount.add(investorBook[_contributor_address].totalTokenAmount) <= investorBook[_contributor_address].max_token_amount;
            } else if(investorBook[_contributor_address].limitType == 2){ //limited by user's total eth amount
                status = status && _weiETHamout.add(investorBook[_contributor_address].totalETHAmount) <= investorBook[_contributor_address].max_eth_amount;
            }
        }else{
            // standard check limits
            if(user_limit_type == 1){  //limited by total token amount
                status = status && _LKDamount <= total_max_tokens_per_user;
            }else if(user_limit_type == 2){  //limited by total eth amount
                status = status && _weiETHamout <= total_max_eth_per_user;
            }
        }
        return status;
    }

    function setContributorLimits(address _contributor_address, uint _limitType, uint256 _maxLKDamount, uint256 _maxWeiETHamout) public onlyOwner{
        require(_limitType >= 0 || _limitType <= 2);
        
        initContributor(_contributor_address);

        if(_limitType == 0){
            require(_maxWeiETHamout == 0);
            require(_maxLKDamount == 0);
        } else if(_limitType == 1){
            require(_maxLKDamount > 0);
            require(_maxWeiETHamout == 0);

            require(_maxLKDamount >= investorBook[_contributor_address].totalTokenAmount);

        } else if(_limitType == 2){
            require(_maxLKDamount == 0);
            require(_maxWeiETHamout > 0);

            require(_maxWeiETHamout >= investorBook[_contributor_address].totalETHAmount);
        }

        investorBook[_contributor_address].limitType = _limitType;
        investorBook[_contributor_address].max_token_amount = _maxLKDamount;
        investorBook[_contributor_address].max_eth_amount = _maxWeiETHamout;
    }

    function getRealInvestmentIndexFromInvestorBook(address _contributor_address, uint256 _investindex) public view returns(uint256){
        return investorBook[_contributor_address].investment[_investindex];
    }

    function initContributor(address _contributor_address) internal{
        if(!investorBook[_contributor_address].exists){

            Investor memory investordata;

            investordata.id = investors.push(_contributor_address) - 1;
            investordata.exists = true;
            investordata.contributor_address = _contributor_address;
            investordata.txsn = 0;

            investordata.limitType = 0;
            investordata.max_token_amount = 0;
            investordata.max_eth_amount = 0;

            investordata.totalETHAmount = 0;
            investordata.totalTokenAmount = 0;

            investorBook[_contributor_address] = investordata;
        }
    }

    function addRowToInvestorsBook(address _contributor_address, uint256 _weiAmount, uint256 _tokenBuyPrice, uint256 _tokenAmount, uint256 _allowedAmount, bool _exchanged) internal{

        InvestmentBookRow memory row;
        
        row.blocknumber = block.number;
        row.timestamp = block.timestamp;
        row.weiAmount = _weiAmount;
        row.rate = _tokenBuyPrice;
        row.tokenAmount = _tokenAmount;

        row.contributor = _contributor_address;

        row.wlAllowedTokens = _allowedAmount;
        row.exchangeAddress = exchangeAddress;
        row.exchanged = _exchanged;

        uint256 l = investorBook[_contributor_address].investment.push(investment.push(row)-1);
        investorBook[_contributor_address].txsn = l;
    }

    function setWhitelist(address _whitelist) public onlyOwner {
        uint i = getCurrentPhaseIndex();
        require( i == 0); // is Initialize

        whitelist = WhitelistToken_interface(_whitelist);
    }

    function setTokenPrice(uint256 newPriceInWEI) public onlyOwner {
        tokenBuyPrice = newPriceInWEI;
    }

    function setExchangeAddress(address _exchangeAddress) public onlyOwner{
        exchangeAddress = _exchangeAddress;
    }

    function setUserLimitType(uint _type) public onlyOwner{
        require(_type >= 1 || _type <= 2);
        user_limit_type = _type;
    }

    function setTotalMaxTokensPerUser(uint _new_max_tokens_per_user) public onlyOwner{
        total_max_tokens_per_user = _new_max_tokens_per_user;
    }

    function setTotalMaxETHPerUser(uint _new_max_eth_per_user) public onlyOwner{
        total_max_eth_per_user = _new_max_eth_per_user;
    }

    function setUseAutoExchange(bool _useAutoExchange) public onlyOwner{
        useAutoExchange = _useAutoExchange;
    }

    function setMaxTokenSale(uint256 _max_token_sale) public onlyOwner{
        require(_max_token_sale >= total_token_sale());
        max_token_sale = _max_token_sale;
    }

    function setMinAmount4Tokens2AutoExchange(uint _newminimum) public onlyOwner{
        minAmount4Tokens2AutoExchange = _newminimum;
    }

    function openSale() public onlyOwner{
        require(!IS_SALE_OPEN);

        uint i = getCurrentPhaseIndex();
        require(i == 1); // is Sale

        IS_SALE_OPEN = true;
    }

    function closeSale() public onlyOwner{
        require(IS_SALE_OPEN);
        IS_SALE_OPEN = false;
    }

    //
    // ####################################
    //

    function finalizeCrowdsale() internal{
        uint i = getCurrentPhaseIndex();
        require((i+1) == PHASES_COUNT); // last pharse is Finalize - on close pharse

        if(IS_SALE_OPEN){
            closeSale();
        }
    }

    //
    // ####################################
    //


    function startNextPhase() public onlyOwner{
        uint i = getCurrentPhaseIndex();
        require((i+1) <= PHASES_COUNT);
        require(phases[i].IS_FINISHED);
        phases[i+1].IS_STARTED = true;

        if(i+1 == 1){ // is Sale
            if(useAutoExchange){
                require(exchangeAddress != address(0));
            }
            openSale();
        }
    }

    function finishCurrentPhase() public onlyOwner{
        uint i = getCurrentPhaseIndex();
        phases[i].IS_FINISHED = true;

        if (i == 0){ // is Initialize
            require(whitelist != WhitelistToken_interface(address(0)));
        } else if(i == 1){ // is Sale
            closeSale();
        }else if ((i+1) == PHASES_COUNT){ // is Finalize
            finalizeCrowdsale();
        }
    }

    
    function PHASE() public view returns(string){
        uint i = getCurrentPhaseIndex();
        return phases[i].NAME;
    }


    function getCurrentPhaseIndex() public view returns (uint){
        uint current_phase = 0;
        for (uint i = 0; i < PHASES_COUNT; i++)
        {
            if (phases[i].IS_STARTED) {
                current_phase = i;
            }

        }
        return current_phase;
    }

}
