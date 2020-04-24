/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity >= 0.5.0;

contract Helpers {
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) revert("Safe Add is not safe");
        return a + b;
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) revert("Safe Sub is not safe");
        return a - b;
    } 

    function parseInt(string memory s) pure internal returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
}

contract WinChance is Helpers {
    address private owner;
    uint256 public betAmount;
    uint256 public firstWinnerAmount;
    uint256 public secondWinnerAmount;
    uint256 public thirdWinnerAmount;
    uint256 public fourthWinnerAmount;
    uint256 public maxPendingPayouts;   
    uint256 private _rngCounter;
    uint256 private _randNum; 
    uint256 queryId = 0;
    bool public payoutsPaused; 
    bool public gamePaused;

    struct GameStats {
        uint256 totalAmount;
        uint256 totalWinAmount;
        uint256 totalPlayed;
        uint256 totalWinCount;
        uint256 totalLoseCount;
    }

    GameStats public gameStats;
    
    struct Player {
        uint8 playCount;
        uint8 winCount;
        uint8 loseCount;
        uint256 totalAmount;
        uint256 totalWinAmount;
    }

    mapping (address => Player) public players;   //TODO: make this private for production           
    mapping (address => uint256) playerPendingWithdrawals;

    modifier onlyOwner() {
        require(msg.sender == owner,"only owner can call this function.");
        _;
    }

    event LogResult(uint256 indexed BetID, address indexed PlayerAddress,uint256 RandomResult,uint256 BetValue,uint256 WinValue,uint8 indexed Status);
    event LogOwnerTransfer(address indexed SentToAddress, uint256 AmountTransferred);
    event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint256 RefundValue);
    event LogInfo(string message);

    constructor() public {
        _rngCounter = 1;
        queryId = 1;
        owner = msg.sender;  
        betAmount = 100000000000000000;   //0.1 ether

        firstWinnerAmount = 400000000000000000;
        secondWinnerAmount = 300000000000000000;
        thirdWinnerAmount = 200000000000000000;
        fourthWinnerAmount = 100000000000000000;              
    }   

    modifier payoutsAreActive {
        if(payoutsPaused == true) revert("payouts are currently paused.");
        _;
    }    

    modifier gameIsActive {
        if(gamePaused == true) revert("game is not active right now.");
        _;
    } 

    modifier validateBet {
        if(msg.value < betAmount) revert("bet is not valid");
        if(address(this).balance + firstWinnerAmount <= firstWinnerAmount) revert("insufficent contract balance");
        if((maxPendingPayouts + firstWinnerAmount)  >= (address(this).balance + firstWinnerAmount)) revert("contract balance is lower than pending payouts.");
        _;
    } 

     //Generates a random number from 1 to 10 based on the last block hash
    function Random(address sender) internal returns (uint256 randomNumber) {
        uint seed;
        _rngCounter *= 2;
        seed = now - _rngCounter;
        _randNum = (uint(keccak256(abi.encodePacked(blockhash(block.number - 1), seed,queryId,sender)))%10 + 1);
            
        return _randNum;
    }

    function MakeMeAWinner() public payable gameIsActive payoutsAreActive validateBet{
        queryId++;        

        uint256 randomNumber = Random(msg.sender);

        players[msg.sender].playCount++;
        players[msg.sender].totalAmount += msg.value;
        gameStats.totalPlayed++;
        gameStats.totalAmount += msg.value; 

        uint256 winAmount = 0;
        if(randomNumber == 1)
        {
            winAmount = firstWinnerAmount;
            maxPendingPayouts = safeAdd(maxPendingPayouts, firstWinnerAmount); 
        }            
        else if(randomNumber == 2)
        {
            winAmount = secondWinnerAmount;
            maxPendingPayouts = safeAdd(maxPendingPayouts, secondWinnerAmount); 
        }
        else if(randomNumber == 3)
        {
            winAmount = thirdWinnerAmount;
            maxPendingPayouts = safeAdd(maxPendingPayouts, thirdWinnerAmount); 
        }
        else if(randomNumber == 4)
        {
            winAmount = fourthWinnerAmount;
            maxPendingPayouts = safeAdd(maxPendingPayouts, fourthWinnerAmount); 
        }
        
        if(winAmount == 0)
        {          
            /*
            * no win            
            *  safe adjust contractBalance           
            */
            //contractBalance = safeAdd(contractBalance, (playerTempBetValue[_queryId]));
            players[msg.sender].loseCount++;                       
            gameStats.totalLoseCount++;
            emit LogResult(queryId,msg.sender,randomNumber,msg.value,0,0);
            return;
        } 

        players[msg.sender].winCount ++;
        players[msg.sender].totalWinAmount += winAmount;
        gameStats.totalWinAmount += winAmount;
        gameStats.totalWinCount++;
                
         emit LogResult(queryId,msg.sender,randomNumber,msg.value,winAmount,1);

         /*
        * send win - external call to an untrusted contract
        * if send fails map reward value to playerPendingWithdrawals[address]
        * for withdrawal later via playerWithdrawPendingTransactions
        */
        if(!msg.sender.send(winAmount)){
            emit LogResult(queryId,msg.sender,randomNumber,msg.value,winAmount,2);
            /* if send failed let player withdraw via playerWithdrawPendingTransactions */
            playerPendingWithdrawals[msg.sender] = safeAdd(playerPendingWithdrawals[msg.sender], winAmount);                               
        }
        else
        {
            maxPendingPayouts = safeSub(maxPendingPayouts, winAmount); 
        }
        return;               
    }
    
    function SetBetAmount (uint256 _betAmount) public onlyOwner 
    {
        betAmount = _betAmount;
    }

    function SetWinAmount (uint256 _firstWinnerAmount,uint256 _secondWinnerAmount,uint256 _thirdWinnerAmount,uint256 _fourthWinnerAmount) public onlyOwner 
    {
        firstWinnerAmount = _firstWinnerAmount;
        secondWinnerAmount = _secondWinnerAmount;
        thirdWinnerAmount = _thirdWinnerAmount;
        fourthWinnerAmount = _fourthWinnerAmount;
    }

    /* only owner address can set emergency pause #1 */
    function ownerPauseGame(bool newStatus) public onlyOwner
    {
        gamePaused = newStatus;
    }

    /* only owner address can set emergency pause #2 */
    function ownerPausePayouts(bool newPayoutStatus) public onlyOwner
    {
        payoutsPaused = newPayoutStatus;
    } 

    function playerWithdrawPendingTransactions() public payoutsAreActive returns (bool)
    {
        uint withdrawAmount = playerPendingWithdrawals[msg.sender];
        playerPendingWithdrawals[msg.sender] = 0;
        /* external call to untrusted contract */
        if (msg.sender.send(withdrawAmount)) {
            return true;
        } else {
            /* if send failed revert playerPendingWithdrawals[msg.sender] = 0; */
            /* player can try to withdraw again later */
            playerPendingWithdrawals[msg.sender] = withdrawAmount;
            return false;
        }
    }   

    /* only owner address can transfer ether */
    function ownerTransferEther(address payable sendTo, uint amount) public onlyOwner
    {        
        /* safely update contract balance when sending out funds*/
        //contractBalance = safeSub(contractBalance, amount);	        
        if(!sendTo.send(amount)) revert("owner transfer ether failed.");
        emit LogOwnerTransfer(sendTo, amount); 
    }

    //Add ether to contract by owner
    function ChargeContract () external payable onlyOwner      
    {
        /* safely update contract balance */
        //contractBalance = safeAdd(contractBalance, msg.value); 
    } 
}
