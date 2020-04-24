/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;

contract FadChain {
    
    address internal  Creator;
    
    struct Event { string FadId; string Status; string Event; uint256 Date; uint256 DateStart; uint256 DateEnd; string Hash; }
    
    mapping (string => mapping (uint256 => mapping (string => Event[]))) internal Courses;
    
    string[] internal EventsList = ["Enrollment","ModulePassed","ModuleFailed","CoursePassed","CourseFailed","Survey","Certificate"];
    
    event ReportError(string inputFadId, string error);
    
    constructor() public { Creator = msg.sender; }
    
    modifier checkAdmin() { require(Creator == msg.sender); _; }

    function ActWriteStep(string memory inputCourse, uint256 inputUserId, string memory inputFadId, 
                          string memory inputEvent, string memory inputStatus, uint256 inputDate, 
                          string memory inputHash, uint256 inputDateStart, uint256 inputDateEnd)
                          public checkAdmin()  returns (bool)
    {
        Event memory eventTemp;
        eventTemp.FadId = inputFadId;
        eventTemp.Status = inputStatus;
        eventTemp.Event = inputEvent;
        eventTemp.Date = inputDate;
        
        require(bytes(inputCourse).length >0 && bytes(inputFadId).length>0 && bytes(inputEvent).length>0 && bytes(inputStatus).length>0 
                && inputDate>0 && inputUserId>0);
        
        require(Courses[inputCourse][inputUserId]["Certificate"].length==0);
        
        require(((keccak256(bytes(eventTemp.Event)) != keccak256("ModulePassed") && keccak256(bytes(eventTemp.Event)) != keccak256("ModuleFailed") && Courses[inputCourse][inputUserId][eventTemp.Event].length == 0) 
              || (keccak256(bytes(eventTemp.Event)) == keccak256("ModulePassed") || keccak256(bytes(eventTemp.Event)) == keccak256("ModuleFailed"))), string(abi.encodePacked(eventTemp.Event)));
        
        require((keccak256(bytes(eventTemp.Event)) != keccak256("Enrollment") && Courses[inputCourse][inputUserId]["Enrollment"].length == 1)
               ||(keccak256(bytes(eventTemp.Event)) == keccak256("Enrollment")));
        
        require(Courses[inputCourse][inputUserId]["CoursePassed"].length > 0  
               ||(keccak256(bytes(eventTemp.Event)) != keccak256("Survey") && keccak256(bytes(eventTemp.Event)) != keccak256("Certificate")));
        
        
        require(keccak256(bytes(eventTemp.Event)) != keccak256("Enrollment") || (eventTemp.Date<=inputDateEnd));
        
        require(keccak256(bytes(eventTemp.Event)) == keccak256("Enrollment") 
             ||(Courses[inputCourse][inputUserId]["Enrollment"][0].DateStart <= eventTemp.Date && Courses[inputCourse][inputUserId]["Enrollment"][0].DateEnd >= eventTemp.Date));
        
        require((keccak256(bytes(eventTemp.Event)) == keccak256("Enrollment") && inputDateStart > 0 && inputDateEnd > 0) || keccak256(bytes(eventTemp.Event)) != keccak256("Enrollment"));
        
        require((keccak256(bytes(eventTemp.Event)) == keccak256("Certificate") && bytes(inputHash).length > 0 ) || keccak256(bytes(eventTemp.Event)) != keccak256("Certificate"));
        
        
        emit ReportError(inputFadId, "Parametri validi");
        
        if(keccak256(bytes(eventTemp.Event)) == keccak256("Enrollment"))
        {
            eventTemp.DateStart = inputDateStart;
            eventTemp.DateEnd =  inputDateEnd;
        }
        else if(keccak256(bytes(eventTemp.Event)) == keccak256("Certificate"))
        {
            eventTemp.Hash = inputHash;
        }
        
        Courses[inputCourse][inputUserId][eventTemp.Event].push(eventTemp);
        return true;
    }
    
    function getInfo(string memory inputCourse, uint256 inputUserId, string memory inputEvent) 
    public checkAdmin() view returns (string memory)
    {
        
        require(bytes(inputCourse).length >0 && inputUserId>0, "Parametri non valorizzati");
                
        string memory EventTemp = inputEvent;
        
        string memory ret = "{";
        
        uint iTemp = (bytes(inputEvent).length>0) ? 1 : 5;
        
        for (uint k=0; k<iTemp; k++)
        {
            EventTemp = (bytes(inputEvent).length>0) ? inputEvent : EventsList[k];
            uint256 arrayLength = Courses[inputCourse][inputUserId][EventTemp].length;
            
            ret = string(abi.encodePacked(ret, '"', EventTemp, '": ['));
            
            for (uint i=0; i<arrayLength; i++)
            {
                ret = string(abi.encodePacked(ret, '{'));
                
                ret = string(abi.encodePacked(ret, '"FadId": "', Courses[inputCourse][inputUserId][EventTemp][i].FadId, '", '));
                ret = string(abi.encodePacked(ret, '"Status": "', Courses[inputCourse][inputUserId][EventTemp][i].Status, '", '));
                ret = string(abi.encodePacked(ret, '"Date": "', uint2str(Courses[inputCourse][inputUserId][EventTemp][i].Date), '"'));
                if(keccak256(bytes(EventTemp)) == keccak256("Enrollment"))
                {
                    ret = string(abi.encodePacked(ret, ', "DateStart": "', uint2str(Courses[inputCourse][inputUserId][EventTemp][i].DateStart), '"'));
                    ret = string(abi.encodePacked(ret, ', "DateEnd": "', uint2str(Courses[inputCourse][inputUserId][EventTemp][i].DateEnd), '"'));
                }
                if(keccak256(bytes(EventTemp)) == keccak256("Certificate"))
                {
                    ret = string(abi.encodePacked(ret, ', "Hash": "', Courses[inputCourse][inputUserId][EventTemp][i].Hash, '"'));
                }
                ret = string(abi.encodePacked(ret, '}'));
                
                if(i<arrayLength-1 && arrayLength>1)
                ret = string(abi.encodePacked(ret, ', '));
                
            }
            ret = string(abi.encodePacked(ret, "]"));
            
            if(k<iTemp-1 && iTemp>1)
                ret = string(abi.encodePacked(ret, ', '));
        }
        ret = string(abi.encodePacked(ret, "}"));
        
        
        return ret;
    }
    
    function kill() public checkAdmin()  returns (bool)
    {
        selfdestruct(msg.sender);
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString)
    {
        if (_i == 0) { return "0"; }
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) { bstr[k--] = byte(uint8(48 + _i % 10)); _i /= 10; }
        return string(bstr);
    }
    
}
