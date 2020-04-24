/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.5.3;

contract Operator {
    event MaxOut (address investor, uint256 times, uint256 at);
    
    uint256 public constant ONE_DAY = 86400;
    address public admin;
    uint256 public depositedAmountGross = 0;
    uint256 public paySystemCommissionTimes = 1;
    uint256 public payDailyIncomeTimes = 1;
    uint256 public lastPaySystemCommission = now;
    uint256 public lastPayDailyIncome = now;
    uint256 public contractStartAt = now;
    uint256 public lastReset = now;
    address payable public operationFund = 0xe707EF0F76172eb2ed2541Af344acb2dB092406a;
    address[] public investorAddresses;
    bytes32[] public investmentIds;
    bytes32[] public withdrawalIds;
    mapping (address => Investor) investors;
    mapping (bytes32 => Investment) public investments;
    mapping (bytes32 => Withdrawal) public withdrawals;

    uint256 public maxLevelsAddSale = 200;
    uint256 public maximumMaxOutInWeek = 4;

    struct Investment {
        bytes32 id;
        uint256 at;
        uint256 amount;
        address investor;
    }

    struct Withdrawal {
        bytes32 id;
        uint256 at;
        uint256 amount;
        address investor;
        address presentee;
        uint256 reason;
        uint256 times;
    }

    struct Investor {
        // part 1
        string email;
        address parent;
        address leftChild;
        address rightChild;
        address presenter;
        // part 2
        uint256 generation;
        uint256 depositedAmount;
        uint256 withdrewAmount;
        bool isDisabled;
        // part 3
        uint256 lastMaxOut;
        uint256 maxOutTimes;
        uint256 maxOutTimesInWeek;
        uint256 totalSell;
        uint256 sellThisMonth;
        // part 4
        uint256 rightSell;
        uint256 leftSell;
        uint256 reserveCommission;
        uint256 dailyIncomeWithrewAmount;
        // part 5
        address[] presentees;
        bytes32[] investments;
        bytes32[] withdrawals;
    }

    constructor () public { admin = msg.sender; }
    
    modifier mustBeAdmin() { require(msg.sender == admin); _; }    
    
    function () payable external { deposit(); }

    function deposit() payable public {
        require(msg.value >= 1 ether);
        Investor storage investor = investors[msg.sender];
        require(investor.generation != 0);
        require(investor.maxOutTimesInWeek < maximumMaxOutInWeek);
     
        require(investor.maxOutTimes == 0 || now - investor.lastMaxOut < ONE_DAY * 7 || investor.depositedAmount != 0);
        depositedAmountGross += msg.value;
        bytes32 id = keccak256(abi.encodePacked(block.number, now, msg.sender, msg.value));
        uint256 investmentValue = investor.depositedAmount + msg.value <= 20 ether ? msg.value : 20 ether - investor.depositedAmount;
        if (investmentValue == 0) return;
        Investment memory investment = Investment({ id: id, at: now, amount: investmentValue, investor: msg.sender });
        investments[id] = investment;
        processInvestments(id);
        investmentIds.push(id);
    }
    
    function processInvestments(bytes32 investmentId) internal {
        Investment storage investment = investments[investmentId];
        uint256 amount = investment.amount;
        Investor storage investor = investors[investment.investor];
        investor.investments.push(investmentId);
        investor.depositedAmount += amount;
        
        addSellForParents(investment.investor, amount);
        address payable presenterAddress = address(uint160(investor.presenter));
        Investor storage presenter = investors[presenterAddress];
        if (presenterAddress != address(0)) {
            presenter.totalSell += amount;
            presenter.sellThisMonth += amount;
        }
        if (presenter.depositedAmount >= 1 ether && !presenter.isDisabled) {
            sendEtherForInvestor(presenterAddress, amount / 10, 1, investment.investor, 0);
        }
    }

    function addSellForParents(address investorAddress, uint256 amount) internal {
        Investor memory investor = investors[investorAddress];
        address payable currentParentAddress = address(uint160(investor.parent));
        address currentInvestorAddress = investorAddress;
        uint256 loopCount = investor.generation - 1;
        uint256 loop = loopCount < maxLevelsAddSale ? loopCount : maxLevelsAddSale;
        for(uint256 i = 0; i < loop; i++) {
            Investor storage parent = investors[currentParentAddress];
            if (parent.leftChild == currentInvestorAddress) parent.leftSell += amount;
            else parent.rightSell += amount;
            uint256 incomeTilNow = getAllIncomeTilNow(currentParentAddress);
            if (incomeTilNow > 3 * parent.depositedAmount) {
                payDailyIncomeForInvestor(currentParentAddress, 0);
                paySystemCommissionInvestor(currentParentAddress, 0);
            }
            currentInvestorAddress = currentParentAddress;
            currentParentAddress = address(uint160(parent.parent));
        }
    }

    function sendEtherForInvestor(address payable investorAddress, uint256 value, uint256 reason, address presentee, uint256 times) internal {
        if (value == 0 || investorAddress == address(0)) return;
        Investor storage investor = investors[investorAddress];
        if (investor.reserveCommission > 0) {
            bool isPass = investor.reserveCommission >= 3 * investor.depositedAmount;
            uint256 reserveCommission = isPass ? investor.reserveCommission + value : investor.reserveCommission;
            investor.reserveCommission = 0;
            sendEtherForInvestor(investorAddress, reserveCommission, 4, address(0), 0);
            if (isPass) return;
        }
        uint256 withdrewAmount = investor.withdrewAmount;
        uint256 depositedAmount = investor.depositedAmount;
        uint256 amountToPay = value;
        if (withdrewAmount + value >= 3 * depositedAmount) {
            amountToPay = 3 * depositedAmount - withdrewAmount;
            investor.reserveCommission = value - amountToPay;
            if (reason != 2) investor.reserveCommission += getDailyIncomeForUser(investorAddress);
            if (reason != 3) investor.reserveCommission += getUnpaidSystemCommission(investorAddress);
            investor.maxOutTimes++;
            investor.maxOutTimesInWeek++;
            investor.depositedAmount = 0;
            investor.withdrewAmount = 0;
            investor.lastMaxOut = now;
            investor.dailyIncomeWithrewAmount = 0;
            emit MaxOut(investorAddress, investor.maxOutTimes, now);
        } else {
            investors[investorAddress].withdrewAmount += amountToPay;
        }
        if (amountToPay != 0) {
            investorAddress.transfer(amountToPay / 100 * 94);
            operationFund.transfer(amountToPay / 100 * 5);
            bytes32 id = keccak256(abi.encodePacked(block.difficulty, now, investorAddress, amountToPay, reason));
            Withdrawal memory withdrawal = Withdrawal({ id: id, at: now, amount: amountToPay, investor: investorAddress, presentee: presentee, times: times, reason: reason });
            withdrawals[id] = withdrawal;
            investor.withdrawals.push(id);
            withdrawalIds.push(id);
        }
    }

    function getAllIncomeTilNow(address investorAddress) internal view returns(uint256 allIncome) {
        Investor memory investor = investors[investorAddress];
        uint256 unpaidDailyIncome = getDailyIncomeForUser(investorAddress);
        uint256 withdrewAmount = investor.withdrewAmount;
        uint256 unpaidSystemCommission = getUnpaidSystemCommission(investorAddress);
        uint256 allIncomeNow = unpaidDailyIncome + withdrewAmount + unpaidSystemCommission;
        return allIncomeNow;
    }

    function putPresentee(address presenterAddress, address presenteeAddress, address parentAddress, string memory presenteeEmail, bool isLeft) public mustBeAdmin {
        Investor storage presenter = investors[presenterAddress];
        Investor storage parent = investors[parentAddress];
        if (investorAddresses.length != 0) {
            require(presenter.generation != 0);
            require(parent.generation != 0);
            if (isLeft) {
                require(parent.leftChild == address(0)); 
            } else {
                require(parent.rightChild == address(0)); 
            }
        }
        
        if (presenter.generation != 0) presenter.presentees.push(presenteeAddress);
        Investor memory investor = Investor({
            email: presenteeEmail,
            parent: parentAddress,
            leftChild: address(0),
            rightChild: address(0),
            presenter: presenterAddress,
            generation: parent.generation + 1,
            presentees: new address[](0),
            depositedAmount: 0,
            withdrewAmount: 0,
            isDisabled: false,
            lastMaxOut: now,
            maxOutTimes: 0,
            maxOutTimesInWeek: 0,
            totalSell: 0,
            sellThisMonth: 0,
            investments: new bytes32[](0),
            withdrawals: new bytes32[](0),
            rightSell: 0,
            leftSell: 0,
            reserveCommission: 0,
            dailyIncomeWithrewAmount: 0
        });
        investors[presenteeAddress] = investor;
       
        investorAddresses.push(presenteeAddress);
        if (parent.generation == 0) return;
        if (isLeft) {
            parent.leftChild = presenteeAddress;
        } else {
            parent.rightChild = presenteeAddress;
        }
    }

    function getDailyIncomeForUser(address investorAddress) internal view returns(uint256 amount) {
        Investor memory investor = investors[investorAddress];
        uint256 investmentLength = investor.investments.length;
        uint256 dailyIncome = 0;
        for (uint256 i = 0; i < investmentLength; i++) {
            Investment memory investment = investments[investor.investments[i]];
            if (investment.at < investor.lastMaxOut) continue; 
            if (now - investment.at >= ONE_DAY) {
                uint256 numberOfDay = (now - investment.at) / ONE_DAY;
                uint256 totalDailyIncome = numberOfDay * investment.amount / 100;
                dailyIncome = totalDailyIncome + dailyIncome;
            }
        }
        return dailyIncome - investor.dailyIncomeWithrewAmount;
    }
    
    function payDailyIncomeForInvestor(address payable investorAddress, uint256 times) public mustBeAdmin {
        uint256 dailyIncome = getDailyIncomeForUser(investorAddress);
        if (investors[investorAddress].isDisabled) return;
        investors[investorAddress].dailyIncomeWithrewAmount += dailyIncome;
        sendEtherForInvestor(investorAddress, dailyIncome, 2, address(0), times);
    }
    
    function payDailyIncomeByIndex(uint256 from, uint256 to) public mustBeAdmin{
        require(from >= 0 && to < investorAddresses.length);
        for(uint256 i = from; i <= to; i++) {
            payDailyIncomeForInvestor(address(uint160(investorAddresses[i])), payDailyIncomeTimes);
        }
    }

    function getUnpaidSystemCommission(address investorAddress) public view returns(uint256 unpaid) {
        Investor memory investor = investors[investorAddress];
        uint256 depositedAmount = investor.depositedAmount;
        uint256 totalSell = investor.totalSell;
        uint256 leftSell = investor.leftSell;
        uint256 rightSell = investor.rightSell;
        uint256 sellThisMonth = investor.sellThisMonth;
        uint256 sellToPaySystemCommission = rightSell < leftSell ? rightSell : leftSell;
        uint256 commission = sellToPaySystemCommission * getPercentage(depositedAmount, totalSell, sellThisMonth) / 100;
        return commission;
    }
    
    function paySystemCommissionInvestor(address payable investorAddress, uint256 times) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        if (investor.isDisabled) return;
        uint256 systemCommission = getUnpaidSystemCommission(investorAddress);
        if (paySystemCommissionTimes > 3 && times != 0) {
            investor.rightSell = 0;
            investor.leftSell = 0;
        } else if (investor.rightSell >= investor.leftSell) {
            investor.rightSell = investor.rightSell - investor.leftSell;
            investor.leftSell = 0;
        } else {
            investor.leftSell = investor.leftSell - investor.rightSell;
            investor.rightSell = 0;
        }
        if (times != 0) investor.sellThisMonth = 0;
        sendEtherForInvestor(investorAddress, systemCommission, 3, address(0), times);
    }

    function paySystemCommissionByIndex(uint256 from, uint256 to) public mustBeAdmin {
         require(from >= 0 && to < investorAddresses.length);
        // change 1 to 30
        if (now <= 30 * ONE_DAY + contractStartAt) return;
        for(uint256 i = from; i <= to; i++) {
            paySystemCommissionInvestor(address(uint160(investorAddresses[i])), paySystemCommissionTimes);
        }
    }
    
    function finishPayDailyIncome() public mustBeAdmin {
        lastPayDailyIncome = now;
        payDailyIncomeTimes++;
    }
    
    function finishPaySystemCommission() public mustBeAdmin {
        lastPaySystemCommission = now;
        paySystemCommissionTimes++;
    }
    
    function resetGame(address[] memory yesInvestors, address[] memory noInvestors) public mustBeAdmin {
        lastReset = now;
        uint256 yesInvestorsLength = yesInvestors.length;
        for (uint256 i = 0; i < yesInvestorsLength; i++) {
            address yesInvestorAddress = yesInvestors[i];
            Investor storage yesInvestor = investors[yesInvestorAddress];
            if (yesInvestor.maxOutTimes > 0 || (yesInvestor.withdrewAmount >= yesInvestor.depositedAmount && yesInvestor.withdrewAmount != 0)) {
                yesInvestor.lastMaxOut = now;
                yesInvestor.depositedAmount = 0;
                yesInvestor.withdrewAmount = 0;
                yesInvestor.dailyIncomeWithrewAmount = 0;
            }
            yesInvestor.reserveCommission = 0;
            yesInvestor.rightSell = 0;
            yesInvestor.leftSell = 0;
            yesInvestor.totalSell = 0;
            yesInvestor.sellThisMonth = 0;
        }
        uint256 noInvestorsLength = noInvestors.length;
        for (uint256 j = 0; j < noInvestorsLength; j++) {
            address noInvestorAddress = noInvestors[j];
            Investor storage noInvestor = investors[noInvestorAddress];
            if (noInvestor.maxOutTimes > 0 || (noInvestor.withdrewAmount >= noInvestor.depositedAmount && noInvestor.withdrewAmount != 0)) {
                noInvestor.isDisabled = true;
                noInvestor.reserveCommission = 0;
                noInvestor.lastMaxOut = now;
                noInvestor.depositedAmount = 0;
                noInvestor.withdrewAmount = 0;
                noInvestor.dailyIncomeWithrewAmount = 0;
            }
            noInvestor.reserveCommission = 0;
            noInvestor.rightSell = 0;
            noInvestor.leftSell = 0;
            noInvestor.totalSell = 0;
            noInvestor.sellThisMonth = 0;
        }
    }

    function stopGame(uint256 percent, uint256 from, uint256 to) mustBeAdmin public {
        require(percent <= 50);
        require(from >= 0 && to < investorAddresses.length);
        for (uint256 i = from; i <= to; i++) {
            address payable investorAddress = address(uint160(investorAddresses[i]));
            Investor storage investor = investors[investorAddress];
            if (investor.maxOutTimes > 0) continue;
            if (investor.isDisabled) continue;
            uint256 depositedAmount = investor.depositedAmount;
            uint256 withdrewAmount = investor.withdrewAmount;
            if (withdrewAmount >= depositedAmount / 2) continue;
            sendEtherForInvestor(investorAddress, depositedAmount * percent / 100 - withdrewAmount, 6, address(0), 0);
        }
    }
    
    function revivalInvestor(address investor) public mustBeAdmin { investors[investor].lastMaxOut = now; }

    function payToReachMaxOut(address payable investorAddress) public mustBeAdmin {
        uint256 unpaidSystemCommissions = getUnpaidSystemCommission(investorAddress);
        uint256 unpaidDailyIncomes = getDailyIncomeForUser(investorAddress);
        uint256 withdrewAmount = investors[investorAddress].withdrewAmount;
        uint256 depositedAmount = investors[investorAddress].depositedAmount;
        uint256 reserveCommission = investors[investorAddress].reserveCommission;
        require(depositedAmount > 0  && withdrewAmount + unpaidSystemCommissions + unpaidDailyIncomes + reserveCommission >= 3 * depositedAmount);
        investors[investorAddress].reserveCommission = 0;
        sendEtherForInvestor(investorAddress, reserveCommission, 4, address(0), 0);
        payDailyIncomeForInvestor(investorAddress, 0);
        paySystemCommissionInvestor(investorAddress, 0);
    }

    function resetMaxOutInWeek() public mustBeAdmin {
        uint256 length = investorAddresses.length;
        for (uint256 i = 0; i < length; i++) {
            address investorAddress = investorAddresses[i];
            investors[investorAddress].maxOutTimesInWeek = 0;
        }
    }
    
    function setMaximumMaxOutInWeek(uint256 maximum) public mustBeAdmin{ maximumMaxOutInWeek = maximum; }

    function disableInvestor(address investorAddress) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        investor.isDisabled = true;
    }
    
    function enableInvestor(address investorAddress) public mustBeAdmin {
        Investor storage investor = investors[investorAddress];
        investor.isDisabled = false;
    }
    
    function donate() payable public { depositedAmountGross += msg.value; }
    
    // Utils helpers
    
    function getTotalSellLevel(uint256 totalSell) internal pure returns (uint256 level){
        if (totalSell < 30 ether) return 0;
        if (totalSell < 60 ether) return 1;
        if (totalSell < 90 ether) return 2;
        if (totalSell < 120 ether) return 3;
        if (totalSell < 150 ether) return 4;
        return 5;
    }

    function getSellThisMonthLevel(uint256 sellThisMonth) internal pure returns (uint256 level){
        if (sellThisMonth < 2 ether) return 0;
        if (sellThisMonth < 4 ether) return 1;
        if (sellThisMonth < 6 ether) return 2;
        if (sellThisMonth < 8 ether) return 3;
        if (sellThisMonth < 10 ether) return 4;
        return 5;
    }
    
    function getDepositLevel(uint256 sellThisMonth) internal pure returns (uint256 level){
        if (sellThisMonth < 2 ether) return 0;
        if (sellThisMonth < 4 ether) return 1;
        if (sellThisMonth < 6 ether) return 2;
        if (sellThisMonth < 8 ether) return 3;
        if (sellThisMonth < 10 ether) return 4;
        return 5;
    }
    
    function getPercentage(uint256 depositedAmount, uint256 totalSell, uint256 sellThisMonth) internal pure returns(uint256 level) {
        uint256 totalSellLevel = getTotalSellLevel(totalSell);
        uint256 depLevel = getDepositLevel(depositedAmount);
        uint256 sellThisMonthLevel = getSellThisMonthLevel(sellThisMonth);
        uint256 min12 = totalSellLevel < depLevel ? totalSellLevel : depLevel;
        uint256 minLevel = sellThisMonthLevel < min12 ? sellThisMonthLevel : min12;
        return minLevel * 2;
    }
    
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) return 0x0;
        assembly { result := mload(add(source, 32)) }
    }
    
    // query investor helpers

    function getInvestorPart1(address investorAddress) view public returns (bytes32 email, address parent, address leftChild, address rightChild, address presenter) {
        Investor memory investor = investors[investorAddress];
        return (stringToBytes32(investor.email), investor.parent, investor.leftChild, investor.rightChild, investor.presenter);
    }
    
    function getInvestorPart2(address investorAddress) view public returns (uint256 generation, uint256 depositedAmount, uint256 withdrewAmount, bool isDisabled) {
        Investor memory investor = investors[investorAddress];
        return (investor.generation, investor.depositedAmount, investor.withdrewAmount, investor.isDisabled);
    }
    
    function getInvestorPart3(address investorAddress) view public returns (uint256 rightSell, uint256 leftSell, uint256 reserveCommission, uint256 dailyIncomeWithrewAmount) {
        Investor memory investor = investors[investorAddress];
        return (investor.rightSell, investor.leftSell, investor.reserveCommission, investor.dailyIncomeWithrewAmount);
    }
    
    function getInvestorPart4(address investorAddress) view public returns (address[] memory presentees, bytes32[] memory _investments, bytes32[] memory _withdrawals) {
        Investor memory investor = investors[investorAddress];
        return (investor.presentees, investor.investments ,investor.withdrawals);
    }
    
    function getInvestorLength() view public returns(uint256) { return investorAddresses.length; }
    
    // query investments and withdrawals helpers
    
    function getInvestmentsLength () public view returns(uint256 length) { return investmentIds.length; }
    
    function getWithdrawalsLength() public view returns(uint256 length) { return withdrawalIds.length; }
    
    // import helper

    function importInvestor(string memory email, address[] memory addresses, bool isDisabled, uint256[] memory numbers) public {
        // (parent, leftChild, rightChild, presenter, investorAddress) = addresses;
        // (generation, depositedAmount, withdrewAmount, lastMaxOut, maxOutTimes, maxOutTimesInWeek, totalSell, sellThisMonth, rightSell, leftSell, reserveCommission, dailyIncomeWithrewAmount) = numbers;
        Investor memory investor = Investor({
            email: email,
            isDisabled: isDisabled,
            parent: addresses[0],
            leftChild: addresses[1],
            rightChild: addresses[2],
            presenter: addresses[3],
            generation: numbers[0],
            presentees: new address[](0),
            depositedAmount: numbers[1],
            withdrewAmount: numbers[2],
            lastMaxOut: numbers[3],
            maxOutTimes: numbers[4],
            maxOutTimesInWeek: numbers[5],
            totalSell: numbers[6],
            sellThisMonth: numbers[7],
            investments: new bytes32[](0),
            withdrawals: new bytes32[](0),
            rightSell: numbers[8],
            leftSell: numbers[9],
            reserveCommission: numbers[10],
            dailyIncomeWithrewAmount: numbers[11]
        });
        investors[addresses[4]] = investor;
        investorAddresses.push(addresses[4]);
        if (addresses[3] == address(0)) return; 
        Investor storage presenter = investors[addresses[3]];
        presenter.presentees.push(addresses[4]);
    }
    
    function importInvestments(bytes32 id, uint256 at, uint256 amount, address investorAddress) public {
        Investment memory investment = Investment({ id: id, at: at, amount: amount, investor: investorAddress });
        investments[id] = investment;
        investmentIds.push(id);
        Investor storage investor = investors[investorAddress];
        investor.investments.push(id);
        depositedAmountGross += amount;
    }
    
    function importWithdrawals(bytes32 id, uint256 at, uint256 amount, address investorAddress, address presentee, uint256 reason, uint256 times) public {
        Withdrawal memory withdrawal = Withdrawal({ id: id, at: at, amount: amount, investor: investorAddress, presentee: presentee, times: times, reason: reason });
        withdrawals[id] = withdrawal;
        Investor storage investor = investors[investorAddress];
        investor.withdrawals.push(id);
        withdrawalIds.push(id);
    }
    
    function setInitialValue(uint256 _paySystemCommissionTimes, uint256 _payDailyIncomeTimes, uint256 _lastPaySystemCommission, uint256 _lastPayDailyIncome, uint256 _contractStartAt, uint256 _lastReset) public {
        paySystemCommissionTimes = _paySystemCommissionTimes;
        payDailyIncomeTimes = _payDailyIncomeTimes;
        lastPaySystemCommission = _lastPaySystemCommission;
        lastPayDailyIncome = _lastPayDailyIncome;
        contractStartAt = _contractStartAt;
        lastReset = _lastReset;
    }
    
    function reset() public {
        while (investorAddresses.length > 0) {
            address investorAddress = investorAddresses[investorAddresses.length - 1];
            delete investors[investorAddress];
            delete investorAddresses[investorAddresses.length - 1];
        }
        while (investmentIds.length > 0) {
            bytes32 investmentId = investmentIds[investmentIds.length - 1];
            delete investments[investmentId];
            delete investmentIds[investmentIds.length - 1];
        }
        while (withdrawalIds.length > 0) {
            bytes32 withdrawalId = withdrawalIds[withdrawalIds.length - 1];
            delete withdrawals[withdrawalId];
            delete withdrawalIds[withdrawalIds.length - 1];
        }
    }
}


contract Querier {
    Operator public operator;
    
    function setOperator(address payable operatorAddress) public {
        operator = Operator(operatorAddress);
    }
    
    function getContractInfo() public view returns (address admin, uint256 depositedAmountGross, address operationFund, uint256 balance, uint256 paySystemCommissionTimes, uint256 maximumMaxOutInWeek) {
        depositedAmountGross = operator.depositedAmountGross();
        admin = operator.admin();
        operationFund = operator.operationFund();
        balance = address(operator).balance;
        paySystemCommissionTimes = operator.paySystemCommissionTimes();
        maximumMaxOutInWeek = operator.maximumMaxOutInWeek();
        return (admin, depositedAmountGross, operationFund, balance, paySystemCommissionTimes, maximumMaxOutInWeek);
    }

    function getContractTime () public view returns (uint256 contractStartAt, uint256 lastReset, uint256 oneDay, uint256 lastPayDailyIncome, uint256 lastPaySystemCommission) {
        return (operator.contractStartAt(), operator.lastReset(), operator.ONE_DAY(), operator.lastPayDailyIncome(), operator.lastPaySystemCommission());
    }
    
    function getListInvestorPart1() public view returns (address[] memory investors, bytes32[] memory emails, address[] memory parents, address[] memory leftChilds, address[] memory rightChilds, address[] memory presenters) {
        uint256 length = operator.getInvestorLength();
        investors = new address[] (length);
        emails = new bytes32[] (length);
        emails = new bytes32[] (length);
        parents = new address[] (length);
        leftChilds = new address[] (length);
        rightChilds = new address[] (length);
        presenters = new address[] (length);
        for (uint256 i = 0; i < length; i++) {
            address investorAddress = operator.investorAddresses(i);
            bytes32 email;
            address parent;
            address leftChild;
            address rightChild;
            address presenter;
            (email, parent, leftChild, rightChild, presenter) = operator.getInvestorPart1(investorAddress);
            investors[i] = investorAddress;
            emails[i] = email;
            parents[i] = parent;
            leftChilds[i] = leftChild;
            rightChilds[i] = rightChild;
            presenters[i] = presenter;
        }
        return (investors, emails, parents, leftChilds, rightChilds, presenters);
    }

    function getListInvestorPart2() public view returns (address[] memory investors, uint256[] memory generations, uint256[] memory depositedAmounts, uint256[] memory withdrewAmounts, bool[] memory isDisableds) {
        uint256 length = operator.getInvestorLength();
        investors = new address[] (length);
        generations = new uint256[] (length);
        depositedAmounts = new uint256[] (length);
        withdrewAmounts = new uint256[] (length);
        isDisableds = new bool[] (length);
        for (uint256 i = 0; i < length; i++) {
            address investorAddress = operator.investorAddresses(i);
            uint256 depositedAmount;
            uint256 withdrewAmount;
            bool isDisabled;
            uint256 generation;
            (generation, depositedAmount, withdrewAmount, isDisabled) = operator.getInvestorPart2(investorAddress);
            investors[i] = investorAddress;
            depositedAmounts[i] = depositedAmount;
            withdrewAmounts[i] = withdrewAmount;
            isDisableds[i] = isDisabled;
            generations[i] = generation;
        }
        return (investors, generations, depositedAmounts, withdrewAmounts, isDisableds);
    }
    
    function getListInvestorPart3() public view returns (address[] memory investors, uint256[] memory rightSells, uint256[] memory leftSells, uint256[] memory reserveCommissions, uint256[] memory dailyIncomeWithrewAmounts) {
        uint256 length = operator.getInvestorLength();
        investors = new address[] (length);
        rightSells = new uint256[] (length);
        leftSells = new uint256[] (length);
        reserveCommissions = new uint256[] (length);
        dailyIncomeWithrewAmounts = new uint256[] (length);
        for (uint256 i = 0; i < length; i++) {
            address investorAddress = operator.investorAddresses(i);
            uint256 rightSell;
            uint256 leftSell;
            uint256 reserveCommission;
            uint256 dailyIncomeWithrewAmount;
            (rightSell, leftSell, reserveCommission, dailyIncomeWithrewAmount) = operator.getInvestorPart3(investorAddress);
            investors[i] = investorAddress;
            rightSells[i] = rightSell;
            leftSells[i] = leftSell;
            reserveCommissions[i] = reserveCommission;
            dailyIncomeWithrewAmounts[i] = dailyIncomeWithrewAmount;
        }
        return (investors, rightSells, leftSells, reserveCommissions, dailyIncomeWithrewAmounts);
    }
    
    function getInvestmentById(bytes32 investmentId) public view returns (bytes32 id, uint256 at, uint256 amount, address investor) {
        return operator.investments(investmentId);
    }
    
    function getWithdrawalById(bytes32 withdrawalId) public view returns (bytes32 id, uint256 at, uint256 amount, address investor, address presentee, uint256 reason, uint256 times) {
        return operator.withdrawals(withdrawalId);
    }
    
    function getEmailByAddress(address investorAddress) public view returns (bytes32) {
        bytes32 email;
        (email,,,,) = operator.getInvestorPart1(investorAddress);
        return email;
    }
    
    function getInvestments(address investorAddress, uint256 start, uint256 end) public view returns(bytes32[] memory ids, uint256[] memory ats, uint256[] memory amounts, bytes32[] memory emails) {
        uint256 length = operator.getInvestmentsLength();
        ids = new bytes32[](length);
        ats = new uint256[](length);
        amounts = new uint256[](length);
        emails = new bytes32[](length);
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            bytes32 id = operator.investmentIds(i);
            uint256 at;
            uint256 amount;
            address investor;
            (id, at, amount, investor) = getInvestmentById(id);
            if (investorAddress != address(0) && investor != investorAddress) continue;
            if (at < start || at > end) continue;
            ids[index] = id;
            ats[index] = at;
            amounts[index] = amount;
            emails[index] = getEmailByAddress(investor);
            index++;
        }
        return (ids, ats, amounts, emails);
    }
    
    function getWithdrawals(address investorAddress, uint256 start, uint256 end) public view returns(bytes32[] memory ids, uint256[] memory ats, uint256[] memory amounts, bytes32[] memory emails, address[] memory presentees, uint256[] memory reasons, uint256[] memory times) {
        uint256 length = operator.getWithdrawalsLength();
        ids = new bytes32[](length);
        ats = new uint256[](length);
        amounts = new uint256[](length);
        emails = new bytes32[](length);
        presentees = new address[](length);
        reasons = new uint256[](length);
        times = new uint256[](length);
        putWithdrawalsPart1(investorAddress, start, end, length, ids, ats, amounts, emails);
        putWithdrawalsPart2(investorAddress, start, end, length, presentees, reasons, times);
        return (ids, ats, amounts, emails, presentees, reasons, times);
    }
    
    function putWithdrawalsPart1(address investorAddress, uint256 start, uint256 end, uint256 length, bytes32[] memory ids, uint256[] memory ats, uint256[] memory amounts, bytes32[] memory emails) internal view {
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            bytes32 id = operator.withdrawalIds(i);
            uint256 at;
            uint256 amount;
            address investor;
            (id, at, amount, investor, , , ) = getWithdrawalById(id);
            if (investorAddress != address(0) && investor != investorAddress) continue;
            if (at < start || at > end) continue;
            ids[index] = id;
            ats[index] = at;
            amounts[index] = amount;
            emails[index] = getEmailByAddress(investor);
            index++;
        }
    }
    
    function putWithdrawalsPart2(address investorAddress, uint256 start, uint256 end, uint256 length, address[] memory presentees, uint256[] memory reasons, uint256[] memory times) internal view {
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++) {
            bytes32 id = operator.withdrawalIds(i);
            uint256 reason;
            uint256 time;
            address presentee;
            address investor;
            uint256 at;
            (, at, , , presentee, reason, time) = getWithdrawalById(id);
            if (investorAddress != address(0) && investor != investorAddress) continue;
            if (at < start || at > end) continue;
            reasons[index] = reason;
            times[index] = time;
            presentees[index] = presentee;
            index++;
        }
    }
}
