/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity 0.5.3;
pragma experimental ABIEncoderV2;

contract FadAlbaniaChain {
    
    address internal  Creator;
    
    struct Event { string FadId; string Status; string Event; uint256 Date; uint256 DateStart; uint256 DateEnd; string Hash; }
    
    mapping (uint256 => mapping (uint256 => mapping (string => Event[]))) internal Courses;
    
    string[] internal StatusList = ["Registration","EndModule","EndCourse","Survey","Certificate"];
    
    constructor() public { Creator = msg.sender; }
    
    modifier checkAdmin() { require(Creator == msg.sender); _; }

    function ActWriteStep(uint256 inputCourseId, uint256 inputUserId, string memory inputFadId, 
                          string memory inputEvent, string memory inputStatus, uint256 inputDate, 
                          string memory inputHash, uint256 inputDateStart, uint256 inputDateEnd)
                          public checkAdmin()  returns (bool)
    {
        Event memory eventTemp;
        eventTemp.FadId = inputFadId;
        eventTemp.Status = inputStatus;
        eventTemp.Event = inputEvent;
        eventTemp.Date = inputDate;
        
        //Passa se i parametri sono tutti valorizzati
        require(bytes(inputFadId).length>0 && bytes(inputEvent).length>0 && bytes(inputStatus).length>0 
                && inputDate>0 && inputCourseId>0 && inputUserId>0, "Parametri non valorizzati");
        
         //Passa se sei in tutte le fasi tranne EndModule se l'array corrispondente è vuoto
        require((keccak256(bytes(eventTemp.Event)) != keccak256("EndModule") && Courses[inputCourseId][inputUserId][eventTemp.Event].length == 0) 
               || (keccak256(bytes(eventTemp.Event)) == keccak256("EndModule")), string(abi.encodePacked(eventTemp.Event, "L'evento risulta già valorizzato")));
               
        //Passa se non hai ancora ottenuto il certificato
        require(Courses[inputCourseId][inputUserId]["Certificate"].length==0, "Certificato già ottenuto");
        
        //Passa se la fase è Registration e la registrazione non è stata ancora fatta
        //Oppure se la fase non è Registration e la registrazione è già stata fatta
        require((keccak256(bytes(eventTemp.Event)) != keccak256("Registration") && Courses[inputCourseId][inputUserId]["Registration"].length == 1)
               ||(keccak256(bytes(eventTemp.Event)) == keccak256("Registration")), "Registrazione non ancora avvenuta");
        
        //Passa se non sei in fase registrazione oppure la data operazione è <= alla data fine corso
        require(keccak256(bytes(eventTemp.Event)) != keccak256("Registration") || (eventTemp.Date<=inputDateEnd), "Data operazione maggiore della data fine corso");
        
        //Passa se il corso è superato oppure se non siamo in fase survey o certificate
        require((Courses[inputCourseId][inputUserId]["EndCourse"].length > 0 && keccak256(bytes(Courses[inputCourseId][inputUserId]["EndCourse"][0].Status)) == keccak256("Passed")) 
               ||(keccak256(bytes(eventTemp.Event)) != keccak256("Survey") && keccak256(bytes(eventTemp.Event)) != keccak256("Certificate")), "Corso non superato");
        
        //Passa se sei in fase Registration oppure la data operazione è compresa tra Data inizio e data fine corso
        require(keccak256(bytes(eventTemp.Event)) == keccak256("Registration") 
             ||(Courses[inputCourseId][inputUserId]["Registration"][0].DateStart <= eventTemp.Date && Courses[inputCourseId][inputUserId]["Registration"][0].DateEnd >= eventTemp.Date), "Data operazione non compresa tra data di inizio e fine corso");
        
        //Passa se sei in fase di Registration e sono presenti le date inizio e fine corso
        require((keccak256(bytes(eventTemp.Event)) == keccak256("Registration") && inputDateStart > 0 && inputDateEnd > 0) || keccak256(bytes(eventTemp.Event)) != keccak256("Registration"), "Data inizio o fine corso non inserita");
        
        //Passa se non sei in fase Certificate oppure se l'HASH è valorizzato
        require((keccak256(bytes(eventTemp.Event)) == keccak256("Certificate") && bytes(inputHash).length > 0 ) || keccak256(bytes(eventTemp.Event)) != keccak256("Certificate"),"Hash non inserito");
        
        
        if(keccak256(bytes(eventTemp.Event)) == keccak256("Registration"))
        {
            eventTemp.DateStart = inputDateStart;
            eventTemp.DateEnd =  inputDateEnd;
        }
        else if(keccak256(bytes(eventTemp.Event)) == keccak256("Certificate"))
        {
            eventTemp.Hash = inputHash;
        }
        
        Courses[inputCourseId][inputUserId][eventTemp.Event].push(eventTemp);
        
        return true;
    }
    
    function getInfo(uint256 inputCourseId, uint256 inputUserId, string memory inputEvent) 
    public checkAdmin() view returns (string memory)
    {
        
        require(inputCourseId>0 && inputUserId>0, "Parametri non valorizzati");
                
        string memory EventTemp = inputEvent;
        
        string memory ret = "{";
        
        uint iTemp = (bytes(inputEvent).length>0) ? 1 : 5;
        
        for (uint k=0; k<iTemp; k++)
        {
            EventTemp = (bytes(inputEvent).length>0) ? inputEvent : StatusList[k];
            uint256 arrayLength = Courses[inputCourseId][inputUserId][EventTemp].length;
            
            ret = string(abi.encodePacked(ret, '"', EventTemp, '": ['));
            
            for (uint i=0; i<arrayLength; i++)
            {
                ret = string(abi.encodePacked(ret, '{'));
                
                ret = string(abi.encodePacked(ret, '"FadId": "', Courses[inputCourseId][inputUserId][EventTemp][i].FadId, '", '));
                ret = string(abi.encodePacked(ret, '"Status": "', Courses[inputCourseId][inputUserId][EventTemp][i].Status, '", '));
                ret = string(abi.encodePacked(ret, '"Date": "', uint2str(Courses[inputCourseId][inputUserId][EventTemp][i].Date), '"'));
                if(keccak256(bytes(EventTemp)) == keccak256("Registration"))
                {
                    ret = string(abi.encodePacked(ret, ', "DateStart": "', uint2str(Courses[inputCourseId][inputUserId][EventTemp][i].DateStart), '"'));
                    ret = string(abi.encodePacked(ret, ', "DateEnd": "', uint2str(Courses[inputCourseId][inputUserId][EventTemp][i].DateEnd), '"'));
                }
                if(keccak256(bytes(EventTemp)) == keccak256("Certificate"))
                {
                    ret = string(abi.encodePacked(ret, ', "Hash": "', Courses[inputCourseId][inputUserId][EventTemp][i].Hash, '"'));
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
}
