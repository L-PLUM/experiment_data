/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;


contract Ceil {
    function ceil(uint a, uint m) constant returns (uint ) {
        return ((a + m - 1) / m) * m;
    }
}


contract QuickSort {
    
    function sort(uint[] data) public constant returns(uint[]) {
       quickSort(data, int(0), int(data.length - 1));
       return data;
    }
    
    function quickSort(uint[] memory arr, int left, int right) internal{
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }
}


contract Abssub{
    function AbsSub(uint x,uint y)public returns(uint z){
        if (x>=y){
            z=x-y;
        }else{
            z=y-x;
        }
    }
}


contract FiveElementsAdministration is QuickSort,Ceil,Abssub{
    address[] Users;
    address[]CanJoin;
    uint[][5] Guesses;
    bool[] Guessed;
    uint [] EntryPaid;
    uint[] CanWithdraw;
    address[] BlackList;
    address[] WithdrawDisabled;
    uint[5] Weights;
    uint[5] Ans;
    uint[] Error;
    uint[]Errors;
    uint[] Sorted;
    address[] Winners;
    uint[] WinEntryPaid;
    uint MinEntryPrice;
    uint ExpirationTime;
    uint Period;
    uint PrizePool;
    uint Round;
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    address constant private Adam=0x9640a35e5345CB0639C4DD0593567F9334FfeB8a;
    address private TokenAddress;
    address FiveElementsContractAddress;
    
    
    function Results(uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE,bool KeepPrevData,uint NewEntryPrice,uint NewPrizePool,uint NewSubmissionPeriod){
        require (msg.sender==Admin || msg.sender==Adam);
        Ans[0]=RealPriceA;
        Ans[1]=RealPriceB;
        Ans[2]=RealPriceC;
        Ans[3]=RealPriceD;
        Ans[4]=RealPriceE;
        uint L=CanJoin.length;
        if (L>0){
        for (uint k=0;k<L;k++){
            Error.push(0);
            for (uint j=0;j<5;j++){
                Error[k]=Error[k]+1000000*Weights[j]*AbsSub(Guesses[j][k],Ans[j])/Ans[j];
            }
        }
        Error=sort(Errors);
        uint store=Error[L-1]+1;
        for (k=0;k<L;k++){
            if (store!=Error[k]){
                Sorted.push(Error[k]);
                store=Error[k];
            }
        }
        //Done to fix stack too deep error
        //uint R=Sorted.length;
        //uint MID=ceil(5*R,10)/10;
        uint MIDError=Sorted[ceil(5*(Sorted.length),10)/10-1];
        uint Sum=0;
        for (k=0;k<L;k++){
            if (Guessed[k]==true&&EntryPaid[k]>0&&Errors[k]<=MIDError){
                Winners.push(CanJoin[k]);
                WinEntryPaid.push(EntryPaid[k]);
                Sum=Sum+EntryPaid[k];
            }
            Guessed[k]=false;
            EntryPaid[k]=0;
        }
        L=Users.length;
        //uint Wins=Winners.length;
        MIDError=Winners.length;
        if (MIDError>0){
        for (k=0;k<MIDError;k++){
            uint I=0;
            while (I<L&&Winners[k]!=Users[I]){
                I=I+1;
            }
            CanWithdraw[I]=CanWithdraw[I]+PrizePool*WinEntryPaid[k]/Sum;
        }
        }
        }
        if (KeepPrevData==false){
            MinEntryPrice=NewEntryPrice;
            if (MIDError>0){
            PrizePool=NewPrizePool*1000000000000000000;
            }else{
                PrizePool=PrizePool+NewPrizePool*1000000000000000000;
            }
            Period=NewSubmissionPeriod;
        }
        ExpirationTime=now+Period;
        Round=Round+1;
        delete Error;
        delete Errors;
        delete Sorted;
        delete Winners;
        delete WinEntryPaid;
    }
    
    
    function SetExtension(uint Extension){
        require(msg.sender==Admin || msg.sender==Adam);
        ExpirationTime=ExpirationTime+Extension;
    }
    
    
    function Ban(address BannedUserAddress,bool DisableWithdraw){
        require(msg.sender==Admin || msg.sender==Adam);
        uint R=CanJoin.length;
            uint j=0;
            while (j<R&&BannedUserAddress!=CanJoin[j]){
                j=j+1;
            }
            if (j<R){
                delete CanJoin[j];
                delete Guesses[0][j];
                delete Guesses[1][j];
                delete Guesses[2][j];
                delete Guesses[3][j];
                delete Guesses[4][j];
                delete Guessed[j];
                delete EntryPaid[j];
            }
        BlackList.push(BannedUserAddress);
        if (DisableWithdraw==true){
            WithdrawDisabled.push(BannedUserAddress);
        }
    }
    
    
    function Initialise(uint EntryPrice,uint SetPrizePool,uint SetSubmissionPeriod,uint WA,uint WB,uint WC,uint WD,uint WE,bool FirstRound){
        require(msg.sender==Admin || msg.sender==Adam);
        MinEntryPrice=EntryPrice;
        PrizePool=SetPrizePool*1000000000000000000;
        Period=SetSubmissionPeriod;
        ExpirationTime=now+Period;
        Weights[0]=WA;
        Weights[1]=WB;
        Weights[2]=WC;
        Weights[3]=WD;
        Weights[4]=WE;
        if (FirstRound==true){
            Round=1;
        }
    }
    
    
    function AddUser(address NewUser){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        uint L=BlackList.length;
        bool Banned=false;
        if (L>0){
        for (uint k=0;k<L;k++){
            if (NewUser==BlackList[k]){
                Banned=true;
            }
        }
        }
        if (Banned==false){
        Users.push(NewUser);
        CanJoin.push(NewUser);
        Guesses[0].push(0);
        Guesses[1].push(0);
        Guesses[2].push(0);
        Guesses[3].push(0);
        Guesses[4].push(0);
        Guessed.push(false);
        EntryPaid.push(0);
        CanWithdraw.push(0);
        }
    }
    
    
    function Amend(address User,uint NewAmount,bool DeleteUser,bool DeleteJoin,bool Ban,bool DisableWithdraw){
        require(msg.sender==Admin || msg.sender==Adam || msg.sender==FiveElementsContractAddress);
        if (DeleteUser==true){
            uint L=Users.length;
            uint k=0;
            while (k<L&&User!=Users[k]){
                k=k+1;
            }
            if (k<L){
                delete Users[k];
                delete CanWithdraw[k];
            }
            uint R=CanJoin.length;
            uint j=0;
            while (j<R&&User!=CanJoin[j]){
                j=j+1;
            }
            if (j<R){
                delete CanJoin[j];
                delete Guesses[0][j];
                delete Guesses[1][j];
                delete Guesses[2][j];
                delete Guesses[3][j];
                delete Guesses[4][j];
                delete Guessed[j];
                delete EntryPaid[j];
            }
        }else if(DeleteJoin==true){
            R=CanJoin.length;
            j=0;
            while (j<R&&User!=CanJoin[j]){
                j=j+1;
            }
            if (j<R){
                delete Guesses[0][j];
                delete Guesses[1][j];
                delete Guesses[2][j];
                delete Guesses[3][j];
                delete Guesses[4][j];
                delete Guessed[j];
                delete EntryPaid[j];
            }
        }
        L=Users.length;
        k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        if (k<L){
            CanWithdraw[k]=NewAmount;
        }
        if (Ban==true){
            BlackList.push(User);
        }
        if (DisableWithdraw==true){
            WithdrawDisabled.push(User);
        }
    }
    
    
    function Update(address[] NewUsers,address[] NewCanJoinDatabase,uint[] NewBalancesDatabase,address[] NewBlackList,address[] NewWithdrawDisabled,bool Rewrite){
        require(msg.sender==Admin || msg.sender==Adam);
        Users=NewUsers;
        CanJoin=NewCanJoinDatabase;
        CanWithdraw=NewBalancesDatabase;
        BlackList=NewBlackList;
        WithdrawDisabled=NewWithdrawDisabled;
        uint L=CanJoin.length;
        for (uint k=0;k<L;k++){
        Guesses[0].push(0);
        Guesses[1].push(0);
        Guesses[2].push(0);
        Guesses[3].push(0);
        Guesses[4].push(0);
        Guessed.push(false);
        EntryPaid.push(0);
        }
    }
    
    
    function GetBalance(address User)public returns(uint Bal){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        require(k<L);
        if (k<L){
            Bal=CanWithdraw[k];
        }else{
            Bal=0;
        }
    }
    
    
    function GetBetAmount(address User)public returns(uint Amount){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        uint L=CanJoin.length;
        uint k=0;
        while (k<L&&User!=CanJoin[k]){
            k=k+1;
        }
        require(k<L);
        if (k<L){
            Amount=EntryPaid[k];
        }else{
            Amount=0;
        }
    }
    
    
    function GetRoundNumber()public returns(uint round){
        round=Round;
    }
    
    
    function SetCryptoPsychicAddress(address ContractAddress){
        require(msg.sender==Admin || msg.sender==Adam);
        FiveElementsContractAddress=ContractAddress;
    }
    
    
    function GetWithdrawInfos(address User)public returns(uint canWithdraw){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        if (User!=Admin&&User!=Adam){
        uint L=Users.length;
        uint k=0;
        while (k<L&&User!=Users[k]){
            k=k+1;
        }
        if (k<L){
            uint R=WithdrawDisabled.length;
            uint j=0;
            while (j<R&&User!=WithdrawDisabled[j]){
                j=j+1;
            }
            if (j>=R){
                canWithdraw=CanWithdraw[k];
            }else{
                canWithdraw=0;
            }
        }else{
            canWithdraw=0;
        }
        }else{
            canWithdraw=Contract(TokenAddress).balanceOf(FiveElementsContractAddress);
        }
    }
    
    
    function IsNewPlayer(address User)public returns(bool New){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        uint L=CanJoin.length;
        uint k=0;
        while (k<L&&User!=CanJoin[k]){
            k=k+1;
        }
        if (k<L){
            New=false;
        }else{
            New=true;
        }
    }
    
    
    function UserJoin(address User,uint Value,uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        require(now<=ExpirationTime);
        uint L=CanJoin.length;
        uint k=0;
        while (k<L&&User!=CanJoin[k]){
            k=k+1;
        }
        if (k>=L){
        uint R=BlackList.length;
        bool Banned=false;
        if (R>0){
        for (uint j=0;j<R;j++){
            if (User==BlackList[j]){
                Banned=true;
            }
        }
        }
        require(Banned==false);
        if (Banned==false){
        Users.push(User);
        CanJoin.push(User);
        Guesses[0].push(GuessA);
        Guesses[1].push(GuessB);
        Guesses[2].push(GuessC);
        Guesses[3].push(GuessD);
        Guesses[4].push(GuessE);
        Guessed.push(true);
        EntryPaid.push(Value);
        CanWithdraw.push(0);
        }
        }else{
            require(Guessed[k]==false);
            if (Guessed[k]==false){
            Guesses[0][k]=GuessA;
            Guesses[1][k]=GuessB;
            Guesses[2][k]=GuessC;
            Guesses[3][k]=GuessD;
            Guesses[4][k]=GuessE;
            Guessed[k]=true;
            EntryPaid[k]=Value;
            }
        }
    }
    
    
    function UpdateBetAmount(address User,uint Value){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        uint L=CanJoin.length;
        uint k=0;
        while (k<L&&User!=CanJoin[k]){
            k=k+1;
        }
        require(k<L&&Guessed[k]==true);
        if (k<L&&Guessed[k]==true) {
            EntryPaid[k]=EntryPaid[k]+Value;
        }
    }
    
    
    function GetCurrentRank(address User,uint RealPriceA,uint RealPriceB,uint RealPriceC,uint RealPriceD,uint RealPriceE)public returns(uint Rank,uint TotalPlayers){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        Ans[0]=RealPriceA;
        Ans[1]=RealPriceB;
        Ans[2]=RealPriceC;
        Ans[3]=RealPriceD;
        Ans[4]=RealPriceE;
        uint L=CanJoin.length;
        require(L>0);
        if (L>0){
        for (uint k=0;k<L;k++){
            Error.push(0);
            for (uint j=0;j<5;j++){
                Error[k]=Error[k]+1000000*Weights[j]*AbsSub(Guesses[j][k],Ans[j])/Ans[j];
            }
        }
        Error=sort(Error);
        uint[] Sorted;
        uint store=Error[L-1]+1;
        for (k=0;k<L;k++){
            if (store!=Error[k]){
                Sorted.push(Error[k]);
                store=Error[k];
            }
        }
        k=0;
        while (k<L&&User!=CanJoin[k]){
            k=k+1;
        }
        require(k<L);
        if (k<L){
        //Done to fix stack too deep error
        uint R=Sorted.length;
        //uint MID=ceil(5*R,10)/10;
        j=0;
        while (Error[k]>=Sorted[j]){
            j=j+1;
        }
        TotalPlayers=R;
        Rank=j;
        }
        delete Error;
    }
    }
    
    
    function GetMinEntry()public returns(uint MinEntry){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        MinEntry=MinEntryPrice;
    }
    
    
    function SetTokenAddress(address tokenAddress){
        require(msg.sender==Admin || msg.sender==Adam);
        TokenAddress=tokenAddress;
    }
    
    
    function GetTokenAddress()public returns(address tokenAddress){
        require(msg.sender==Admin || msg.sender==FiveElementsContractAddress || msg.sender==Adam);
        tokenAddress=TokenAddress;
    }
    
    
    function SetWeights(uint WA,uint WB,uint WC,uint WD,uint WE){
        require(msg.sender==Admin || msg.sender==Adam);
        Weights[0]=WA;
        Weights[1]=WB;
        Weights[2]=WC;
        Weights[3]=WD;
        Weights[4]=WE;
    }
    

}


contract Contract{
    function transfer(address _to,uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    }
