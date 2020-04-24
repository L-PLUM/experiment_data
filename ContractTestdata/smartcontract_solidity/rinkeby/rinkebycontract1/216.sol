/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.1; 
pragma experimental ABIEncoderV2;

contract MediChain {

struct Hosp { 
    
string hospName;
string hospLocAddress; 
uint id;

}

struct Patient { 
    
string patientName;
uint id;
uint[] hospId;
uint[] doctorId;

}


struct Doctor{
    
string doctorName;
uint id;
uint hospId;

}



mapping (uint => Hosp) hosp; 
mapping (uint => Patient) patients;
mapping (uint => Doctor) doctors;

uint[] public hospIds; 
uint[] public patientIds;
uint[] public doctIds;

uint _patientAutoId=0;
uint _hospAutoId=0;
uint _doctsAutoId=0;

string[] pName;

Patient[] patientDropDown;
Hosp[] hospDropDown;
Doctor[] docsDropDown;



//set patient
 function setPatient( uint _hospId, string memory _patientName,uint _doctId) public {
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].patientName=_patientName;
    patients[_patientAutoId].hospId.push(_hospId);
    patients[_patientAutoId].id=_patientAutoId;
    patients[_patientAutoId].doctorId.push(_doctId);
    
    patientIds.push(_patientAutoId); 

}

function addDoctorHospitalByPatient(uint _patientId,uint _doctId, uint _hospId) public {
    
    patients[_patientId].doctorId.push(_doctId);
    patients[_patientId].hospId.push(_hospId);
    
}


//get single patient (id,patientNam,hospID)
function getPatient(uint _id) view public returns(Patient memory p){
    
    return patients[_id];
    
}


}
