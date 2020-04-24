/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;


contract Ceil {
    function ceil(uint a, uint m) constant returns (uint );
}


contract QuickSort {
    function sort(uint[] data) public constant returns(uint[]);
    function quickSort(uint[] memory arr, int left, int right) internal;
}


contract Abssub{
    function AbsSub(uint x,uint y)public returns(uint z);
}


contract FiveElements{
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    address constant private Tummy=0x820090F4D39a9585a327cc39ba483f8fE7a9DA84;
    address constant private Willy=0xA4757a60d41Ff94652104e4BCdB2936591c74d1D;
    address constant private Nicky=0x89473CD97F49E6d991B68e880f4162e2CBaC3561;
    address constant private Artem=0xA7e8AFa092FAa27F06942480D28edE6fE73E5F88;
    address constant private Adam=0x9640a35e5345CB0639C4DD0593567F9334FfeB8a;
    address constant private FiveElementsAdministrationAddress=0xccC267069f02ac5E1ff2CBac9304eC02888443AF;
    address private TokenAddress;
    
    
    function Join(uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE) public payable{
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        uint Min=FEA.GetMinEntry();
        if (msg.sender==Admin || msg.sender==Tummy || msg.sender==Willy || msg.sender==Nicky || msg.sender==Artem || msg.sender==Adam){
        }else{
            require(msg.value>=Min);
        }
        Admin.transfer(msg.value/2);
        Adam.transfer(msg.value/2);
        FEA.UserJoin(msg.sender,msg.value,GuessA,GuessB,GuessC,GuessD,GuessE);
    }
    
    
    function BetMore() public payable{
        require(msg.value>0);
        Admin.transfer(msg.value/2);
        Adam.transfer(msg.value/2);
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        FEA.UpdateBetAmount(msg.sender,msg.value);
    }
    
    
    function WithdrawAll(){
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        uint canWithdraw=FEA.GetWithdrawInfos(msg.sender);
        TokenAddress=FEA.GetTokenAddress();
        uint Bal=Contract(TokenAddress).balanceOf(address(this));
        require (canWithdraw>0&&Bal>=canWithdraw);
        FEA.Amend(msg.sender,0,false,false,false,false);
        Contract(TokenAddress).transfer(msg.sender,canWithdraw);
    }
    
    
    function WithdrawAmount(uint Amount){
        FiveElementsAdministration FEA=FiveElementsAdministration(FiveElementsAdministrationAddress);
        uint canWithdraw=FEA.GetWithdrawInfos(msg.sender);
        TokenAddress=FEA.GetTokenAddress();
        uint Bal=Contract(TokenAddress).balanceOf(address(this));
        require (canWithdraw>=Amount*1000000000000000000&&Amount>0&&Bal>=Amount*1000000000000000000);
        FEA.Amend(msg.sender,canWithdraw-Amount*1000000000000000000,false,false,false,false);
        Contract(TokenAddress).transfer(msg.sender,Amount*1000000000000000000);
    }
    

}


contract FiveElementsAdministration is QuickSort,Ceil,Abssub{
    function GetBalance(address User)public returns(uint Bal);
    function GetWithdrawInfos(address User)public returns(uint canWithdraw);
    function UserJoin(address User,uint Value,uint GuessA,uint GuessB,uint GuessC,uint GuessD,uint GuessE);
    function UpdateBetAmount(address User,uint Value);
    function GetMinEntry()public returns(uint MinEntry);
    function Amend(address User,uint NewAmount,bool DeleteUser,bool DeleteJoin,bool Ban,bool DisableWithdraw);
    function GetTokenAddress()public returns(address TokenAddress);
}


contract Contract{
    function transfer(address _to,uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}
