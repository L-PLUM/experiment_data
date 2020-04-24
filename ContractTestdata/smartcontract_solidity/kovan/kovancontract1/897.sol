/**
 *Submitted for verification at Etherscan.io on 2018-12-18
*/

pragma solidity ^0.4.25;


contract SmartSnake {
    //Address of old Multiplier
    address constant private FATHER = 0xf7EE772303eb576D1aa3d17D5454f79a69F80bEf;
    //Address for tech expences
    address constant private TECH = 0xf7EE772303eb576D1aa3d17D5454f79a69F80bEf;
    //Address for promo expences
    address constant private PROMO = 0xf7EE772303eb576D1aa3d17D5454f79a69F80bEf;
    //Percent for first multiplier donation
    uint constant public FATHER_PERCENT = 1;
    uint constant public TECH_PERCENT = 2;
    uint constant public PROMO_PERCENT = 2;
    uint constant public PRIZE_PERCENT = 2;
    uint constant public MAX_INVESTMENT = 10 ether;
    uint constant public MIN_INVESTMENT_FOR_PRIZE = 0.05 ether;
    uint constant public MAX_IDLE_TIME = 20 minutes; //Maximum time the deposit should remain the last to receive prize

    //How many percent for your deposit to be multiplied
    //Depends on number of deposits from specified address at this stage
    //The more deposits the higher the multiplier
    uint8[] MULTIPLIERS = [
        111, //For first deposit made at this stage
        113, //For second
        117, //For third
        121, //For forth
        125, //For fifth
        130, //For sixth
        135, //For seventh
        141  //For eighth and on
    ];

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint128 deposit;   //The deposit amount
        uint128 expect;    //How much we should pay out (initially it is 111%-141% of deposit)
        address referal;   //Referal address
        uint128 time;
    }

    struct DepositCount {
        int128 stage;
        uint128 count;
    }

    struct LastDepositInfo {
        uint128 index;
        uint128 time;
    }

    Deposit[] private queue;  //The queue
    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    uint public currentQueueSize = 0; //The current size of queue (may be less than queue.length)
    LastDepositInfo public lastDepositInfo; //The time last deposit made at

    uint public prizeAmount = 0; //Prize amount accumulated for the last depositor
    int public stage = 0; //Number of contract runs
    mapping(address => DepositCount) public depositsMade; //The number of deposits of different depositors

    constructor() public{
        //Initialize array to save gas to first depositor
        //Remember - actual queue length is stored in currentQueueSize!
        queue.push(Deposit(address(0x1),0,1,0, uint128(now)));
    }

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        //Prevent cheating with high gas prices. Money from first multiplier are allowed to enter with any gas price
        //because they do not enter the queue
        require(msg.sender == FATHER || tx.gasprice <= 50000000000 wei, "Gas price is too high! Do not cheat!");

        //If money are from first multiplier, just add them to the balance
        //All these money will be distributed to current investors
        if(msg.value > 0 && msg.sender != FATHER){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= MAX_INVESTMENT, "The investment is too much!"); //Do not allow too big investments to stabilize payouts

            checkAndUpdateStage();

            //No new deposits 20 minutes before next restart, you should withdraw the prize
            require(getStageStartTime(stage+1) >= now + MAX_IDLE_TIME);

            address ref = bytesToAddress(msg.data);
            addDeposit(msg.sender, msg.value, ref);

            //Pay to first investors in line
            pay();
        }else if(msg.value == 0){
            withdrawPrize();
        }
    }

    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue
    //depending on balance and gas left
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint balance = address(this).balance;
        uint128 money = 0;
        if(balance > prizeAmount) //The opposite is impossible, however the check will not do any harm
            money = uint128(balance - prizeAmount);

        //We will do cycle on the queue
        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.transfer(dep.expect);
                money -= dep.expect;            //update money left

                //this investor is fully paid, so remove him
                delete queue[i];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.transfer(money); 
                dep.expect -= money;       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex = i; //Update the index of the current first investor
    }

    function addDeposit(address depositor, uint value, address referal) private {
        //Count the number of the deposit at this stage
        DepositCount storage c = depositsMade[depositor];
        if(c.stage != stage){
            c.stage = int128(stage);
            c.count = 0;
        }

        //If you are applying for the prize you should invest more than minimal amount
        //Otherwize it doesn't count
        if(value >= MIN_INVESTMENT_FOR_PRIZE)
            lastDepositInfo = LastDepositInfo(uint128(currentQueueSize), uint128(now));

        //Compute the multiplier percent for this depositor
        uint multiplier = getDepositorMultiplier(depositor);
        //Add the investor into the queue. Mark that he expects to receive 111%-141% of deposit back
        push(depositor, value, value*multiplier/100, referal);

        //Increment number of deposits the depositors made this round
        c.count++;

        //Save money for prize and father multiplier
        prizeAmount += value*(FATHER_PERCENT + PRIZE_PERCENT)/100;

        //Send small part to tech support
        uint support = value*TECH_PERCENT/100;
        TECH.transfer(support);
        uint adv = value*PROMO_PERCENT/100;
        PROMO.transfer(adv);

    }

    function checkAndUpdateStage() private{
        int _stage = getCurrentStageByTime();

        require(_stage >= stage, "We should only go forward in time");

        if(_stage != stage){
            proceedToNewStage(_stage);
        }
    }

    function proceedToNewStage(int _stage) private {
        //Clean queue info
        //The prize amount on the balance is left the same if not withdrawn
        stage = _stage;
        currentQueueSize = 0; //Instead of deleting queue just reset its length (gas economy)
        currentReceiverIndex = 0;
        delete lastDepositInfo;
    }

    function withdrawPrize() private {
        //You can withdraw prize only if the last deposit was more than MAX_IDLE_TIME ago
        require(lastDepositInfo.time > 0 && lastDepositInfo.time <= now - MAX_IDLE_TIME, "The last depositor is not confirmed yet");
        //Last depositor will receive prize only if it has not been fully paid
        require(currentReceiverIndex <= lastDepositInfo.index, "The last depositor should still be in queue");

        uint balance = address(this).balance;
        if(prizeAmount > balance) //Impossible but better check it
            prizeAmount = balance;

        //Send donation to the first multiplier for it to spin faster
        //It already contains all the sum, so we must split for father and last depositor only
        uint donation = prizeAmount*FATHER_PERCENT/(FATHER_PERCENT + PRIZE_PERCENT);
        if(donation > 10 ether) //The father contract accepts up to 10 ether
            donation = 10 ether;

        //If the .call fails then ether will just stay on the contract to be distributed to
        //the queue at the next stage
        require(gasleft() >= 300000, "We need gas for the father contract");
        //FATHER.call.value(donation).gas(250000)();

        uint prize = prizeAmount - donation;
        queue[lastDepositInfo.index].depositor.transfer(prize);

        prizeAmount = 0;
        proceedToNewStage(stage + 1);
    }

    //Pushes investor to the queue
    function push(address depositor, uint deposit, uint expect, address referal) private {
        //Add the investor into the queue
        Deposit memory dep = Deposit(depositor, uint128(deposit), uint128(expect), referal, uint128(now));
        assert(currentQueueSize <= queue.length); //Assert queue size is not corrupted
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

    //Get the deposit info by its index
    //You can get deposit index from
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect, address referal, uint128 time){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect, dep.referal, dep.time);
    }

    //Get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }
    
    
    function getReferalsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }
    
    
    function getDepositsPosition(address depositor) public view returns (uint) {
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
               return i;
        }
    }

    

    //Get all deposits (index, deposit, expect) of a specific investor
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }
    
    
    
    
    //Get all deposits (index, deposit, expect) of a specific investor
    function getAllDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
               
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                
            }
        }
    }

    //Get current queue size
    function getQueueLength() public view returns (uint) {
        return currentQueueSize - currentReceiverIndex;
    }

    function balanceETH() public view returns(uint) {
      return address(this).balance;
    }

    //Get current depositors multiplier percent at this stage
    function getDepositorMultiplier(address depositor) public view returns (uint) {
        DepositCount storage c = depositsMade[depositor];
        uint count = 0;
        if(c.stage == getCurrentStageByTime())
            count = c.count;
        if(count < MULTIPLIERS.length)
            return MULTIPLIERS[count];

        return MULTIPLIERS[MULTIPLIERS.length - 1];
    }

    function getCurrentStageByTime() public view returns (int) {
        return int(now - 17 hours) / 1 days - 17844; //Start is 09/11/2018 20:00 GMT+3
    }

    function getStageStartTime(int _stage) public pure returns (uint) {
        return 17 hours + uint(_stage + 17844)*1 days;
    }

    function getCurrentCandidateForPrize() public view returns (address addr, int timeLeft){
        //prevent exception, just return 0 for absent candidate
        if(currentReceiverIndex <= lastDepositInfo.index && lastDepositInfo.index < currentQueueSize){
            Deposit storage d = queue[lastDepositInfo.index];
            addr = d.depositor;
            timeLeft = int(lastDepositInfo.time + MAX_IDLE_TIME) - int(now);
        }
    }
    

	function bytesToAddress(bytes bys) private pure returns (address addr) {
		assembly {
			addr := mload(add(bys, 20))
		}
	}

}
