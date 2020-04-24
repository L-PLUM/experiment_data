/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223Interface {
    uint public totalSupply;

    function balanceOf(address who) public view returns (uint);

    function transfer(address to, uint value) public;

    function transfer(address to, uint value, bytes memory data) public;

    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

// * https://mcashdice.com/ - fair games that pay Midas Cash (the first Tomochain's TRC-20 tokens) - 100% decentralized
//
// * Mcashdice's Bank Roller smart contract, deployed at 0x06cb17247e413c11113ad5f2a0f36f223387ed89 (Ropsten testnet).
//
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.
//
// * Refer to https://github.com/tomodice/contracts/whitepaper.pdf for detailed description and proofs.
contract BankRoller {
    uint constant MAXIMUM_NUM_DEPOSITORS = 100;

    // For bank rollers
    uint public softCapDeposit;
    uint public hardCapDeposit;
    uint public totalDeposit;
    uint public minCapIndividualDeposit;
    mapping(address => uint) public individualDeposit;
    mapping(address => uint) public maxCapIndividualDeposit;
    uint public numDepositors;
    address[MAXIMUM_NUM_DEPOSITORS] public depositors;

    // Events for bank roller topup and withdraw
    event AddDepositor(address indexed depositor);
    event RemoveDepositor(address indexed depositor);
    event BankRollerTopUp(address indexed from, uint256 value);
    event BankRollerWithdraw(address indexed from, uint8 withdrawPercent, uint256 value);

    // Each bet is deducted [houseEdgePermille]‰ in favour of the house, but no less than some minimum.
    // The lower bound is dictated by gas costs of the settleBet transaction, providing headroom for up to 10 Gwei prices.
    uint public houseEdgePermille; // Per-mille = per-thousand
    uint public houseEdgeMinimumAmount;

    uint public bankRollerRewardPermille;
    uint public founderRewardPermille;
    uint public donationPermille;

    // Admin account (TomoTRC20Dice contract).
    address public admin;

    // Founder account.
    address public founderRewardReceiver;

    // Account to receive donation.
    address public donationReceiver;

    // Mapping from wallet address to its.
    mapping(address => address) affiliates;

    // Commissions for referrer (5 levels) - in percent from sub's winning amount.
    uint8[] public referCommissionPermille = [10, 6, 4, 2, 1]; // 1.0%, 0.6%, 0.4%, 0.2%, 0.1%

    // Events that are issued to make statistic recovery easier.
    event Payment(address indexed beneficiary, uint amount);

    event SendDonation(address indexed beneficiary, uint amount);
    event SendFounderReward(address indexed beneficiary, uint amount);
    event SendBankRollerReward(address indexed beneficiary, uint amount);
    event AffiliatePayment(uint8 level, address indexed referrer, address indexed gambler, uint successLogAmount, uint commission);

    // These events are emitted in placeBet to record affiliate in the logs.
    event Affiliate(address indexed referrer, address indexed gambler);

    // The address of trc20 token supported for this game.
    address public trc20Token;

    // Standard contract ownership transfer.
    address payable public owner;
    address payable private nextOwner;

    // Constructor
    constructor (address _trc20Token, uint _houseEdgePermille, uint _houseEdgeMinimumAmount,
        uint _donationPermille, uint _founderRewardPermille, uint _bankRollerRewardPermille,
        uint _softCapDeposit, uint _hardCapDeposit, uint _minCapIndividualDeposit) public {
        owner = msg.sender;
        trc20Token = _trc20Token;
        setHouseEdgeSettings(_houseEdgePermille, _houseEdgeMinimumAmount);
        setRewardSettings(_donationPermille, _founderRewardPermille, _bankRollerRewardPermille);
        setDepositSettings(_softCapDeposit, _hardCapDeposit, _minCapIndividualDeposit);
        numDepositors = 0;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "OnlyAdmin methods called by non-admin.");
        _;
    }

    // Standard modifier on methods invokable only by contract owner and admin.
    modifier onlyOwnerOrAdmin {
        require(msg.sender == owner || msg.sender == admin, "OnlyOwnerOrAdmin methods called by non-owner/admin.");
        _;
    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    function assignAffiliate(address from, address affWallet) public onlyOwnerOrAdmin {
        if (affiliates[from] == address(0)) {
            if (affWallet != address(0)) {
                affiliates[from] = affWallet;
                emit Affiliate(affWallet, from);
            } else if (founderRewardReceiver != address(0)) {
                affiliates[from] = founderRewardReceiver;
                emit Affiliate(founderRewardReceiver, from);
            }
        }
    }

    // Change admin account.
    function setAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

    // Change the address to receive donation.
    function setDonationReceiver(address newDonationReceiver) external onlyOwner {
        donationReceiver = newDonationReceiver;
    }

    // Change the address to receive founder reward.
    function setFounderRewardReceiver(address newFounderRewardReceiver) external onlyOwner {
        founderRewardReceiver = newFounderRewardReceiver;
    }

    // Change house edge settings
    function setHouseEdgeSettings(uint _houseEdgePermille, uint _houseEdgeMinimumAmount) public onlyOwner {
        require(_houseEdgePermille > 0, "houseEdgePermille should not be equal to zero.");
        require(_houseEdgePermille <= 100, "houseEdgePermille should not be over than 10%.");
        require(_houseEdgeMinimumAmount >= 0.001 ether, "houseEdgeMinimumAmount should be at least 0.001 tomo.");
        houseEdgePermille = _houseEdgePermille;
        houseEdgeMinimumAmount = _houseEdgeMinimumAmount;
    }

    // Change donation setting. Set this to zero will disable donation.
    function setRewardSettings(uint _donationPermille, uint _founderRewardPermille, uint _bankRollerRewardPermille) public onlyOwner {
        require(_donationPermille <= 50, "donationPermille should not be over than 5%.");
        require(_founderRewardPermille <= 20, "founderRewardPermille should not be over than 2%.");
        require(_bankRollerRewardPermille <= 20, "bankRollerRewardPermille should not be over than 2%.");
        donationPermille = _donationPermille;
        founderRewardPermille = _founderRewardPermille;
        bankRollerRewardPermille = _bankRollerRewardPermille;
    }

    // Change refer commissions. Setting one level to zero will disable that level.
    function setReferCommissionPermille(uint8[] memory _referCommissionPermille) public onlyOwner {
        require(_referCommissionPermille.length == 5, "referCommissionPermille should have 5 elements");
        referCommissionPermille = _referCommissionPermille;
    }

    // Not allow to top up Tomo
    function() external payable {
        revert();
    }

    function balance() public view returns (uint256 _balance) {
        _balance = ERC223Interface(trc20Token).balanceOf(address(this));
    }

    function transferToken(address beneficiary, uint amount) public onlyOwnerOrAdmin {
        ERC223Interface(trc20Token).transfer(beneficiary, amount);
    }

    // Change deposit settings for bank-rollers.
    function setDepositSettings(uint _softCapDeposit, uint _hardCapDeposit, uint _minCapIndividualDeposit) public onlyOwner {
        require(_softCapDeposit >= 1000 ether, "softCapDeposit should be at least 1000 token.");
        require(_hardCapDeposit >= 10000 ether, "hardCapDeposit should be at least 10000 token.");
        require(_softCapDeposit <= _hardCapDeposit, "softCapDeposit should be less than or equal to hardCapDeposit.");
        require(_minCapIndividualDeposit >= 10 ether, "minCapIndividualDeposit should be at least 10 token.");
        softCapDeposit = _softCapDeposit;
        hardCapDeposit = _hardCapDeposit;
        minCapIndividualDeposit = _minCapIndividualDeposit;
    }

    // Set max cap deposit for this individual. Setting this to zero reject the investment.
    function setMaxCapIndividualDeposit(address bankRoller, uint maxCap) external onlyOwner {
        maxCapIndividualDeposit[bankRoller] = maxCap;
    }

    function bankRollerBalance(address bankRoller) public view returns (uint256 _balance) {
        uint deposit = individualDeposit[bankRoller];
        if (deposit == 0) {
            _balance = 0;
        } else {
            uint contractBalance = ERC223Interface(trc20Token).balanceOf(address(this));
            require((contractBalance * deposit) / deposit == contractBalance, "Multiply operation is not safe");
            _balance = contractBalance * deposit / totalDeposit;
            _balance = 0;
        }
    }

    // To deposit from whitelisted bank-rollers (with positive max cap).
    function bankRollerDeposit(address from, uint value) internal {
        require(maxCapIndividualDeposit[from] >= minCapIndividualDeposit, "This address is not allowed to deposit");
        require(individualDeposit[from] + value <= maxCapIndividualDeposit[from], "Total deposit will be exceeded the max cap");
        require(totalDeposit + value <= hardCapDeposit, "The hard cap exceeded");
        require(totalDeposit + value >= totalDeposit, "Add operation is not safe");
        if (individualDeposit[from] == 0) {
            addDepositor(from);
        }
        totalDeposit += value;
        individualDeposit[from] += value;
        emit BankRollerTopUp(from, value);
    }

    // To withdraw from positive balance bank-rollers.
    function bankRollerWithdraw(uint8 withdrawPercent) public {
        address to = msg.sender;
        require(withdrawPercent >= 1, "withdrawPercent should not be less than 1%");
        require(withdrawPercent <= 100, "withdrawPercent should not be over 100%");
        uint currentDeposit = individualDeposit[to];
        require(currentDeposit > 0, "This address has zero balance");
        uint subValue = currentDeposit * withdrawPercent / 100;
        require(currentDeposit >= subValue, "This address does not have enough balance");
        require(withdrawPercent == 100 || currentDeposit >= subValue + minCapIndividualDeposit, "Need to withdraw completely or the left should be at least minCapIndividualDeposit");
        uint contractBalance = ERC223Interface(trc20Token).balanceOf(address(this));
        require((contractBalance * currentDeposit) / currentDeposit == contractBalance, "Multiply operation is not safe");
        if (withdrawPercent == 100) {
            removeDepositor(msg.sender);
        }
        uint withdrawAmount = contractBalance * currentDeposit / totalDeposit;
        totalDeposit = totalDeposit - subValue;
        individualDeposit[to] = currentDeposit - subValue;
        ERC223Interface(trc20Token).transfer(to, withdrawAmount);
        emit BankRollerWithdraw(to, withdrawPercent, withdrawAmount);
    }

    // Helper routine to process the payment.
    function sendFunds(address beneficiary, uint amount, uint successLogAmount, uint houseEdge) public onlyAdmin {
        transferToken(beneficiary, amount);
        emit Payment(beneficiary, successLogAmount);

        // Send donation
        if (donationPermille > 0 && donationReceiver != address(0)) {
            uint donationAmount = houseEdge * donationPermille / houseEdgePermille;
            transferToken(donationReceiver, donationAmount);
            emit SendDonation(donationReceiver, donationAmount);
        }

        // Send founder reward
        if (founderRewardPermille > 0 && founderRewardReceiver != address(0)) {
            uint founderRewardAmount = houseEdge * founderRewardPermille / houseEdgePermille;
            transferToken(founderRewardReceiver, founderRewardAmount);
            emit SendFounderReward(founderRewardReceiver, founderRewardAmount);
        }

        // Send bank-roller rewards
        if (bankRollerRewardPermille > 0 && numDepositors > 0) {
            uint bankRollerRewardAmount = houseEdge * bankRollerRewardPermille / houseEdgePermille;
            for (uint i = 0; i < numDepositors; i++) {
                address depositor = depositors[i];
                if (depositor != address(0)) {
                    uint individualReward = bankRollerRewardAmount * individualDeposit[depositor] / totalDeposit;
                    if (individualReward >= 1000) {// not sending dust
                        transferToken(depositor, individualReward);
                        emit SendBankRollerReward(depositor, individualReward);
                    }
                }
            }
        }

        // Send affiliate commissions
        address prevBeneficiary2 = address(0);
        address prevBeneficiary = address(0);
        if (successLogAmount >= 1000) {
            for (uint8 level = 1; level <= 5; level++) {
                address referrer = affiliates[beneficiary];
                if (referrer == address(0) || referrer == beneficiary || referrer == prevBeneficiary || referrer == prevBeneficiary2) {
                    break;
                }
                uint commission = successLogAmount * referCommissionPermille[level - 1] / 1000;
                if (commission == 0) {
                    break;
                }
                transferToken(referrer, commission);
                emit AffiliatePayment(level, referrer, beneficiary, successLogAmount, commission);
                prevBeneficiary2 = prevBeneficiary;
                prevBeneficiary = beneficiary;
                beneficiary = referrer;
            }
        }
    }

    function addDepositor(address depositor) internal {
        require(numDepositors < MAXIMUM_NUM_DEPOSITORS, "Number of depositor exceeds limit");
        depositors[numDepositors] = depositor;
        numDepositors = numDepositors + 1;
        emit AddDepositor(depositor);
    }

    function removeDepositor(address depositor) internal {
        for (uint16 i = 0; i < numDepositors; i++) {
            if (depositors[i] == depositor) {
                for (uint16 j = i; j + 1 < numDepositors; j++) {
                    depositors[j] = depositors[j + 1];
                }
                depositors[numDepositors - 1] = address(0);
                emit RemoveDepositor(depositor);
                break;
            }
        }
    }

    event ApprovalReceived(address indexed from, uint256 value, bytes data);
    event TokenFallback(address indexed from, uint256 value, bytes data);
    event CustomFallback(address indexed from, uint256 value, bytes data);

    // https://www.ethereum.org/token
    // function in contract 'tokenRecipient'
    function receiveApproval(address from, uint256 value, bytes memory data) public {
        emit ApprovalReceived(from, value, data);
    }

    // ERC223
    // function in contract 'ContractReceiver'
    function tokenFallback(address from, uint value, bytes memory data) public {
        bankRollerDeposit(from, value);
        emit TokenFallback(from, value, data);
    }

    // ERC223
    function customFallback(address from, uint value, bytes memory data) public {
        emit CustomFallback(from, value, data);
    }
}
