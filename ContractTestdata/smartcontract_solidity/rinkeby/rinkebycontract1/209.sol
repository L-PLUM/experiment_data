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
uint[] hospId;

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
 function setPatient( uint _hospId, string memory _patientName,uint _doctId) public returns(string memory){
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].patientName=_patientName;
    patients[_patientAutoId].hospId.push(_hospId);
    patients[_patientAutoId].id=_patientAutoId;
    patients[_patientAutoId].doctorId.push(_doctId);
    
    patientIds.push(_patientAutoId); 
    
    
    return "Patient added successfully...!";

}

function addDoctorHospitalByPatient(uint _patientId,uint _doctId, uint _hospId) public returns(string memory) {
    
    patients[_patientId].doctorId.push(_doctId);
    patients[_patientId].hospId.push(_hospId);
    
    
        return "Doctor and Hospital added successfully...!";

}


//set Doctor

function setDoctor(uint _hospId, string memory _doctName) public returns(string memory) {
    
    _doctsAutoId+=1;
    
    doctors[_doctsAutoId].doctorName=_doctName;
    doctors[_doctsAutoId].hospId.push(_hospId);
    doctors[_doctsAutoId].id=_doctsAutoId;
    
    doctIds.push(_doctsAutoId); 
    
    
            return "Doctor added successfully...!";

    

}


function addHospitalByDoctor(uint _doctorId, uint _hospId) public returns(string memory){
    
    doctors[_doctorId].hospId.push(_hospId);
    
     return "Hospital added successfully...!";


}




//set hospital
function setHosp( string memory _hospName, string memory _hospLocAddress) public returns(string memory) {
    
    _hospAutoId+=1;
    
    hosp[_hospAutoId].hospName=_hospName;
    hosp[_hospAutoId].hospLocAddress=_hospLocAddress;
    hosp[_hospAutoId].id=_hospAutoId;
    
    hospIds.push(_hospAutoId); 
    
    
     return "Hospital added successfully...!";

} 


//get single patient (id,patientNam,hospID)
function getPatient(uint _id) view public returns(Patient memory p){
    
    return patients[_id];
    
}

//get single hospital (hospName,hospAddress,hospID)
function getHospital(uint _id) view public returns(Hosp memory hosppps){ 
    
return hosp[_id]; 

} 

//get single doctor  (doctorName,doctId,hospId)

function getDoctor(uint _id) view public returns(Doctor memory dco){ 
    
return doctors[_id]; 

} 



//get all Doctors by hosp id
function getDoctorsByPid(uint _id) public returns(uint[] memory doccId){
    
        return patients[_id].doctorId;           
      
  

}

//get All Hsopitals

function getAllHospitals() public returns(Hosp[] memory hosps){
    
      delete hospDropDown;
        
     for(uint i =1; i<=hospIds.length; i++){
         
            hospDropDown.push(hosp[i]);

       }
     
       if(hospDropDown.length<=0){
           
                  revert('hospitals not found');

       }else{
                    
                return hospDropDown;           
       }

}



//get patient list by hospital id

function getPatientsByHid(uint _id) public returns(Patient[] memory){
    
    
      delete patientDropDown;

     for(uint i =1; i<=patientIds.length; i++){
         
        uint hospLength  =patients[i].hospId.length;
         
         for(uint j=0;j<hospLength;j++){
             
             
         if(patients[i].hospId[j] == _id){
             
         patientDropDown.push(patients[i]);

         }        
         
             
         }
         
           
       }
       
    
return patientDropDown;    

}


//get doctors list by hospId

function getAllDoctorsByHid(uint _id) public returns(Doctor[] memory docss){
    
      delete docsDropDown;
        
      for(uint i =1; i<=doctIds.length; i++){
         
        uint hospLength  =doctors[i].hospId.length;
         
         for(uint j=0;j<hospLength;j++){
             
             
         if(doctors[i].hospId[j] == _id){
             
         docsDropDown.push(doctors[i]);

         }        
         
             
         }
         
           
       }
     
       if(docsDropDown.length<=0){
           
                  revert('Doctors not found');

       }else{
                    
                return docsDropDown;           
       }

}

//get patient by doctorId
function getPatientsByDid(uint _id) public returns(Patient[] memory){
    
    
      delete patientDropDown;

     for(uint i =1; i<=patientIds.length; i++){
         
        uint docLength  =patients[i].doctorId.length;
         
         for(uint j=0;j<docLength;j++){
             
             
         if(patients[i].doctorId[j] == _id){
             
         patientDropDown.push(patients[i]);

         }        
         
             
         }
         
           
       }
       
    
return patientDropDown;    

}


//get hospitals by doctorId

function getHospitalsByDid(uint _id) public returns(uint[] memory){
    
    
    return    doctors[_id].hospId;
}

// get doctors by pid

function getAllDoctorsByPid(uint _id) public returns(uint[] memory ){
    
         return    patients[_id].doctorId;


}



}
