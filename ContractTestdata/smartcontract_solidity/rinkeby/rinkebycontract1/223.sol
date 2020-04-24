/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.1; 

contract MediChain {

struct Hosp { 
    
string hospName;
string hospLocAddress; 
uint id;

}

struct Patient { 
    
string patientName;
uint id;
uint hospId;
}



mapping (uint => Hosp) hosp; 
mapping (uint => Patient) patients;

uint[] public hospIds; 
uint[] public patientIds;

uint _patientAutoId=0;
uint _hospAutoId=0;

string[] pName;


Patient[] Patients;



function setHosp( string memory _hospName, string memory _hospLocAddress) public {
    
    _hospAutoId+=1;
    
    hosp[_hospAutoId].hospName=_hospName;
    hosp[_hospAutoId].hospLocAddress=_hospLocAddress;
    hosp[_hospAutoId].id=_hospAutoId;
    
    hospIds.push(_hospAutoId); 

} 

 function setPatient( uint _hospId, string memory _patientName) public {
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].patientName=_patientName;
    patients[_patientAutoId].hospId=_hospId;
    patients[_patientAutoId].id=_patientAutoId;
    
    patientIds.push(_patientAutoId); 

}

function getPatient(uint _id) view public returns(string memory,uint,uint){
    
    return (patients[_id].patientName,patients[_id].hospId,patients[_id].id);
    
}

function getHospitals() view public returns(uint[] memory){ 
    
return hospIds; 
    
}


function getHospital(uint _id) view public returns(string memory,string memory){ 
    
return (hosp[_id].hospName,hosp[_id].hospLocAddress); 

} 


function getHospitalCount() view public returns(uint) { 
    
return hospIds.length;

} 


 function compareIds(uint id1, uint id2) public pure returns(bool)
   {
       if(id1==id2) {
     return true;
     
   }else{
       
    return false;
       
   }
 }

}
