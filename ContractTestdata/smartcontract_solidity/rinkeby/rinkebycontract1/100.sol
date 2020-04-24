/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.25;
 
contract PredictionMarket{
    
    mapping (address=>bool) public sysAdmins;
    address public admin=0x0;                   // the creator is also the admin
 

     // only called once while creating this contract
    constructor() public payable {        
        sysAdmins[msg.sender]=true;
        admin= msg.sender; // the contract creator is the one who can withdraw the Ethers
    }
    
    // 必須加入此函數，合約帳號才能接受 address(this).transfer(msg.value)
    // 否昨會產生錯誤錯誤錯誤
    // This function is executed whenever the contract receives plain Ether
    // (without data). Additionally, in order to receive Ether, the fallback 
    // function must be marked payable. If no such function exists, the contract 
    // cannot receive Ether through regular transactions.
    function() public payable {
    // this function enables the contract to receive funds
    }
    
    function showPlatformBalance() public view returns(uint){
        return address(this).balance;
    }
    
    // 將帳戶所有結餘轉到管理者帳戶
    // 刪除此合約
    function killAndWithdrawAllBalance(uint _currentTime) public payable{
        require(msg.sender==admin,"只有本平台管理員可執行此函數");
        
        uint bal=address(this).balance;
        admin.transfer(bal);
        selfdestruct(admin);
        
        emit killAndWithdraw(
            _currentTime,
            bal,
            address(this),
            msg.sender  
        );
    }
    
    event killAndWithdraw(
        uint selfdestructTime,
        uint contractBalance,
        address targetAddress,
        address executorAddress
    );
     
    function addToAdmin (address newAdmin) public payable{
        //Only the admin can assign and add others as an admin
        if(sysAdmins[msg.sender]==false) revert(); 
        
        sysAdmins[newAdmin]=true;
        emit event_addToAdminCompleted(msg.sender, newAdmin);
    }
    event event_addToAdminCompleted(address from, address newAdmin);
    
    // 定義事件結果類別
    // YesNo: 二選一
    // MultipleChoice: 多選一
    enum OutcomeCategory{ YesNo, MultipleChoice}
    
    // Resolved:成功產生結果並於截止日起三天內確認結果。
    // Cancelled:該預測為於截止日前取消，退回所有賭注。
    // Invalid:預測事件超過截止時間3天未決定結果，本次預測無效，退回所有押金
    enum Status{Created, InProgress, Cancelled, Resolved, Invalid}             
    
    // structure 或是function 的參數，若超過14 個bytes32 type(or 7 個string type)，在compile smart contract 的時候就會發生失敗，而不允許建立。
    // 會出現底下錯誤：Internal compiler error (/src/libsolidity/codegen/CompilerUtils.cpp:203):Stack too deep, try using less variables. 
    // 所以必須將此結構拆成兩個，並使用FutureEventID來對應
    struct FutureEvent
    {
        uint FutureEventID;                      // The id of this event
        string eventName;                        // The question of this prediction market
        uint secondaryCategoryID;                // 次類別ID
        OutcomeCategory eventOutcomeCategory;    // The category of this qeustion.
        string outcomeReference;                 // URL or facts reference
        bytes16[10] eventOutcomes;                // 4 outcome items max
        uint    winningOutcomeIndex;             // The winning outcome of this event. The result must be 'Y', 'N', '1', '2', '3' and '4'
        uint256 beginTime;                       // The Begin time of this market to bid
        uint256 endTime;                         // The Due time of this market
        string additionalInfo;                  // More detailed description     
        Status status;                           // 現有狀態
        uint totalInvestAmount;                  // 總共投注金    
        uint totalInvestCount;                   // 總共投注數量 (shares)    
        //uint cleanTime;                          // 執行清算時間
    }
   uint public FutureEventCount;                // Also functions as the index of Events list             
   // 由EventList[EventCount]可對映到FutureEvent
   mapping(uint=>FutureEvent) public FutureEventList;
  
   struct Investment{
       uint FutureEventID;                  // The specific future event
       uint InvestmentID;                   // The id of the investment
       uint investingEventOutcomeIndex;     // 0 to 3
       uint investingAmount;                // The amount of Ethers invested for specific event!
       uint investingTime;                  // The time when the user invested his or her Ethers
       address investor;                    // The investor for this investment
    }
   
  // 新增未來事件
  function addFutureEvent(string _eventName
        ,uint _secondaryCategoryID 
        ,OutcomeCategory _outcomeCategory
        ,bytes16[10] _eventOutcomes
        ,uint256 _beginTime                   
        ,uint256 _endTime           
        ,string _additionalInfo) public payable returns(uint EventCount)
        {
            FutureEventCount++;
            // 加入至FutureEvent Struct
            FutureEventList[FutureEventCount]= FutureEvent({
                FutureEventID: FutureEventCount,
                eventName: _eventName,
                secondaryCategoryID: _secondaryCategoryID,
                eventOutcomeCategory: _outcomeCategory,
                outcomeReference: "",
                eventOutcomes:_eventOutcomes,
                winningOutcomeIndex:0,               
                beginTime: _beginTime,                   
                endTime: _endTime,      
                additionalInfo:_additionalInfo,
                status:Status.Created,
                totalInvestAmount:0,
                totalInvestCount:0
                //cleanTime:0
            });
            
            // Consume no gas
            string memory prediction_outcome_items;
            if( _outcomeCategory==OutcomeCategory.YesNo){
                 prediction_outcome_items=string(abi.encodePacked(bytes32ToString(_eventOutcomes[0]),bytes32ToString(_eventOutcomes[1])));
            }else{
                
                for(uint i=0;i<10;i++){
                    if(_eventOutcomes[i].length==0)
                        continue;
                    
                    //prediction_outcome_items=string(abi.encodePacked(uintToBytes(i),
                        //prediction_outcome_items)); 
                    prediction_outcome_items = string(
                        abi.encodePacked(prediction_outcome_items,
                            uintToBytes(i),
                            bytes32ToString(_eventOutcomes[i]))
                            );
                }
            }
            
            string memory categoryName;
            if(_outcomeCategory==OutcomeCategory.YesNo){
                categoryName="YesNo";
            }else{
                categoryName="MultipleChoice";
            }
            
            address creatorAddress=msg.sender;
            
            // 將新增事件內容記錄至EventLog!
            emit add_FutureEvent(
                _eventName,
                FutureEventCount,
                _secondaryCategoryID,
                creatorAddress,
                _beginTime,
                _endTime,
                categoryName,
                prediction_outcome_items
            );
            
            return FutureEventCount;
  }
   
   event add_FutureEvent(
       string future_event_name, // 未來事件名稱
       uint indexed future_event_id,     // 未來事件ID
       uint indexed secondary_category_id, // 次類別ID
       address indexed creatorAddress,   // 事件建立者
       uint begin_time,          // 開始時間
       uint end_time,            // 結束時間
       string  outcome_category, // YesNo or MultipleChoice
       string  prediction_outcome_items // 將所有預測項目整合成單一字串
       );

   
    // EventInvestList[FutureEventID][InvestmentID]=> Investment
   // 由EventID及InvestmentID可對映到針對某事件的'投資'(押注)
   mapping(uint=>mapping(uint=>Investment)) public EventInvestList;
   
   // FutureEventID to InvestmentCounter
   // 每個FutureEvent的投注數量
   mapping(uint=>uint) public EventInvestCounter;
   
   // 投資某事件
   function addInvestment(
    uint _FutureEventID,
    //uint _investAmount,                 // 以wei為單位      
    uint _investingEventOutcomeIndex,   // 0:N, 1: Y, 2: A, 3: B, 4: C, 5: D
    uint _investingTime                 // the time when someone invest his weis 
    ) public payable{
    
        address _investorAddress=msg.sender;
        uint _investAmount=msg.value;
        
        require(address(_investorAddress).balance>= _investAmount,
            "很抱歉，您投注的金額超過您帳戶所持有的金額!"); //很抱歉，您投注的金額超過您帳戶所持有的金額!
            
        require((_FutureEventID>0 && FutureEventList[_FutureEventID].FutureEventID>0),
            "指定的事件編號不存在");

        require(_investingTime<=FutureEventList[_FutureEventID].endTime,"所選擇的事件已到期，不允許投注!");            
        
        // transfer to the contract
        if(!address(this).send(msg.value)){
            revert("fuck you");
        }
        
        FutureEvent storage  futureEvent = FutureEventList[_FutureEventID];
        uint investCount=EventInvestCounter[_FutureEventID]; // Default value=0
        investCount++;
        
        // 加入投注結果結果與金額
        EventInvestList[_FutureEventID][investCount]=Investment({
          FutureEventID: _FutureEventID,      
          InvestmentID: investCount,      
          investor:_investorAddress,        
          investingEventOutcomeIndex: _investingEventOutcomeIndex,  
          investingAmount: msg.value,    
          investingTime:_investingTime      
          
       });
       
       // 更新投注FutureEvent狀態
       futureEvent.totalInvestCount++;                  // 總投注數量
       futureEvent.totalInvestAmount+= msg.value;       // 總投注金額
       futureEvent.status=Status.InProgress;            // 狀態為執行中，尚未結束
       
       // 將投注內容寫入日日誌
       emit add_Investment(
           _FutureEventID,
           futureEvent.eventName,
           bytes32ToString(futureEvent.eventOutcomes[_investingEventOutcomeIndex]),
           uint2str(_investingEventOutcomeIndex),
           _investAmount,
           _investingTime,
           _investorAddress,
          futureEvent.totalInvestCount,
          futureEvent.totalInvestAmount
       );
       
       // 更新事件的投注數量
       EventInvestCounter[_FutureEventID]=investCount;
       
     }
   
     event add_Investment(
       uint indexed future_event_id,  // 未來事件ID
       string future_event_name,  // 未來事件名稱
       string predictOutcome,     // 預測結果
       string predictOutcomeIndex,   // 預測結果索引
       uint investingAmount,      // 投注金額
       uint investingTime,        // 投注時間
       address investorAddress,   // 投注者address
       uint totalInvestCount,     // 該事件總投注數量
       uint totalInvestAmount     // 該事件總投注金額(以wei為單位)
    );
   
   // 結算投資某事件
   function finalizeFutureEvent(uint _FutureEventID, uint _currentTime, uint _winningOutcomeIndex, string _outcomeReference) public payable{
       uint currentTime= _currentTime;
       require(msg.sender==admin, "只有平台管理員可以執行此動作。" ); // 只有平台管理員可以執行此動作
       require((_FutureEventID>0 && FutureEventList[_FutureEventID].FutureEventID>0),
            "指定的事件編號不存在!");
       require(currentTime>FutureEventList[_FutureEventID].endTime,
            "所選擇的事件還在開放投注期間，不允許結算!");
      if(FutureEventList[_FutureEventID].status==Status.Resolved){
        revert("所選擇的事件已完成結算!");
      }
      if(FutureEventList[_FutureEventID].status==Status.Invalid){
        revert("所選擇的事件無法投注!");  
      }
        
       
       FutureEvent storage futureEvent= FutureEventList[_FutureEventID];
       futureEvent.status=Status.Resolved;
       futureEvent.winningOutcomeIndex=_winningOutcomeIndex;
       futureEvent.outcomeReference=_outcomeReference;
       //futureEvent.cleanTime=currentTime;
       
       // Log the event
       emit add_finalizeFutureEvent(
           string(abi.encodePacked("事件結束時間:",currentTime)),
           string(abi.encodePacked("事件名稱:",futureEvent.eventName)),
           string(abi.encodePacked("事件結果:",bytes32ToString(futureEvent.eventOutcomes[_winningOutcomeIndex]))),
           string(abi.encodePacked("結果引用來源:",futureEvent.outcomeReference)),
           string(abi.encodePacked("總投注數量:",futureEvent.totalInvestCount)),
           string(abi.encodePacked("總投注金額:",futureEvent.totalInvestAmount))
       );
       
       // 計算押注正確結果可得到的報償
       // 平台手續費為2%
      uint fee= futureEvent.totalInvestAmount*2/100 ;
      address(this).transfer(fee);
      uint totalAmount=futureEvent.totalInvestAmount-fee;
      
       // 公式: 
       // A= totalInvestAmount
       // B= totalCorrectOutcomeInvestAmount
       // C= investAmountofSomeone
       // 某個正確投注者可分得金額為= (A-B)*(C/B)+ C= C*(A/B)
       
       // 1. 取得所有押注正確答案 Invest
       
        // 取得該事件所有的投注數量
        uint investCount= EventInvestCounter[_FutureEventID];
       
        // 取得所有InvestLine之FutureEventId為_FutureEventID之數量
        uint  totalCorrectOutcomeInvestAmount=0;
        for(uint j=1;j<=investCount;j++){
            Investment storage investment= EventInvestList[_FutureEventID][j];
            if(investment.investingEventOutcomeIndex==_winningOutcomeIndex){
                totalCorrectOutcomeInvestAmount+=investment.investingAmount;
            }
        }
        
        // 2. 每一份押注可分得金額比率. share= A/B
        //uint share= totalAmount/totalCorrectOutcomeInvestAmount;
        
         for( j=1;j<=investCount;j++){
            investment= EventInvestList[_FutureEventID][j];
            if(investment.investingEventOutcomeIndex==_winningOutcomeIndex){
                // 根據所押注金額比率匯款
                investment.investor.transfer(totalAmount*investment.investingAmount/totalCorrectOutcomeInvestAmount);
            }
        }
   }
   
   event add_finalizeFutureEvent(
        string cleanTime,
        string eventName,
        string winningOutcome,
        string outcomeReference,
        string toatlInvestCount,
        string totalInvestAmount
    );
         
  // 轉換byte1到string
   function bytes1ToString(byte _byte) internal pure returns (string){
    // string memory str = string(_bytes32);
    // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
    // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)
    // 狀態變量（在函數之外聲明的變量）默認為“ storage ”形式，並永久寫入區塊鏈
    // ；而在函數內部聲明的變量默認是“ memory ”型的，它們函數調用結束後消失。
        bytes memory bytesArray = new bytes(1);
        bytesArray[0] =_byte;
        
        return string(bytesArray);
    }  
      
   // 轉換byte32到string
   function bytes32ToString(bytes16 _bytes32) internal pure returns (string){  
    // string memory str = string(_bytes32);
    // TypeError: Explicit type conversion not allowed from "bytes32" to "string storage pointer"
    // thus we should fist convert bytes32 to bytes (to dynamically-sized byte array)
    // 狀態變量（在函數之外聲明的變量）默認為“ storage ”形式，並永久寫入區塊鏈
    // ；而在函數內部聲明的變量默認是“ memory ”型的，它們函數調用結束後消失。
    bytes memory bytesArray = new bytes(16);
    for (uint256 i; i < 16; i++) {
        bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
 
   // 取得列舉的字串名稱     
   function getFutureEventCategoryName(OutcomeCategory _outcomeCategory) internal pure returns(bytes16 name){
       
       if(_outcomeCategory==OutcomeCategory.YesNo){
           return "YesNo";
       }else{
           return "MultipleChoice";
       }
        
   }
   
   function uintToBytes(uint v) public pure returns (bytes16 ret) {
    if (v == 0) {
        ret = '0';
    }
    else {
        while (v > 0) {
            ret = bytes16(uint(ret) / (2 ** 8));
            ret |= bytes16(((v % 10) + 48) * 2 ** (8 * 31));
            v /= 10;
        }
    }
    return ret;
    }
   
   // 簡易字串相加
   function appendBytes(bytes16 a, bytes16 b, bytes16 c, bytes16 d, bytes16 e, bytes16 f, bytes16 g, bytes16 h) internal pure returns (string) {
        return string(abi.encodePacked(a, b, c, d, e,f, g, h));
   }
   function appendString(string a, string b, string c, string d, string e, string f, string g, string h) internal pure returns (string) {
        return string(abi.encodePacked(a, b, c, d, e,f, g, h));
   }
   // uint convert to string
   function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
   }
function deleteInvalidFutureEvent(uint _FutureEventID, uint _currentTime) public payable{
       uint currentTime= _currentTime;
      require(msg.sender==admin, "只有平台管理員可以執行此動作。" ); // 只有平台管理員可以執行此動作
      require((_FutureEventID>0 && FutureEventList[_FutureEventID].FutureEventID>0),
            "指定的事件編號不存在!");
      require(currentTime>FutureEventList[_FutureEventID].endTime+259200,
            "所選擇的事件尚未到終結期限，不允許清除");
      if(FutureEventList[_FutureEventID].status==Status.Invalid){
        revert("所選擇的事件已完成清除!");
      }
        
       
       FutureEvent storage futureEvent= FutureEventList[_FutureEventID];
       futureEvent.status=Status.Invalid;
       //futureEvent.cleanTime=currentTime;
       
       // Log the event
       emit add_deleteFutureEvent(
           string(abi.encodePacked("事件清除時間:",currentTime)),
           string(abi.encodePacked("事件名稱:",futureEvent.eventName))
       );
       
       // 不確定是否要抽取手續費
       // 計算押注正確結果可得到的報償
       // 平台手續費為2%
      uint fee= futureEvent.totalInvestAmount*2/100 ;
      address(this).transfer(fee);
      uint totalAmount=futureEvent.totalInvestAmount-fee;
      
       
        // 取得該事件所有的投注數量
        uint investCount= EventInvestCounter[_FutureEventID];
        
        //uint share= totalAmount/totalCorrectOutcomeInvestAmount;
         for(uint j=1;j<=investCount;j++){
             Investment storage investment= EventInvestList[_FutureEventID][j];
                // 將扣除手續費後的押注金額退回
                investment.investor.transfer(totalAmount*investment.investingAmount/futureEvent.totalInvestAmount);
            
        }
   }
   
   event add_deleteFutureEvent(
        string cleanTime,
        string eventName
    );

}
