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
uint hospId;
uint doctorId;

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





//set hospital
function setHosp( string memory _hospName, string memory _hospLocAddress) public {
    
    _hospAutoId+=1;
    
    hosp[_hospAutoId].hospName=_hospName;
    hosp[_hospAutoId].hospLocAddress=_hospLocAddress;
    hosp[_hospAutoId].id=_hospAutoId;
    
    hospIds.push(_hospAutoId); 

} 

//set patient
 function setPatient( uint _hospId, string memory _patientName,uint _doctId) public {
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].patientName=_patientName;
    patients[_patientAutoId].hospId=_hospId;
    patients[_patientAutoId].id=_patientAutoId;
    patients[_patientAutoId].doctorId=_doctId;
    
    patientIds.push(_patientAutoId); 

}

//set Doctor

function setDoctor(uint _hospId, string memory _doctName) public {
    
    _doctsAutoId+=1;
    
    doctors[_doctsAutoId].doctorName=_doctName;
    doctors[_doctsAutoId].hospId=_hospId;
    doctors[_doctsAutoId].id=_doctsAutoId;
    
    doctIds.push(_doctsAutoId); 

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


//get all Patient by hosp id
function getPatientsByHid(uint _id) public returns(Patient[] memory pNamee){
    
    
      delete patientDropDown;

     for(uint i =1; i<=patientIds.length; i++){
         
        if(patients[i].hospId==_id){
            
            patientDropDown.push(patients[i]);

         }
           
       }
       
       if(patientDropDown.length<=0){
                  revert('Patient not found');

       }else{
    
                return patientDropDown;           
       }
    

}

//get all hospitals

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


//get all doctors using hosp id

function getAllDoctorsByHid(uint _id) public returns(Doctor[] memory docss){
    
      delete docsDropDown;
        
     for(uint i =1; i<=doctIds.length; i++){
         
            
        if(doctors[i].hospId==_id){
            
            docsDropDown.push(doctors[i]);

         }

       }
     
       if(docsDropDown.length<=0){
           
                  revert('Doctors not found');

       }else{
                    
                return docsDropDown;           
       }

}


//get all Patientn by hosp id
function getPatientsByDid(uint _id) public returns(Patient[] memory pNamee){
    
    
          delete patientDropDown;

     for(uint i =1; i<=patientIds.length; i++){
         
        if(patients[i].doctorId==_id){
            
            patientDropDown.push(patients[i]);

         }
           
       }
       
       if(patientDropDown.length<=0){
                  revert('Patient not found');

       }else{
    
                return patientDropDown;           
       }
    

}





//get total hospital
function getHospitalCount() view public returns(uint) { 
    
return hospIds.length;

} 

//get total Patient
function getPatientCount() view public returns(uint) { 
    
return patientIds.length;

}

//get Total doctors

function getDoctorCount() view public returns(uint) { 
    
return doctIds.length;

} 

function getPatientCountByDid(uint _id) view public returns(uint){
    
    uint patientCount=0;
    
   for(uint i =1; i<=patientIds.length; i++){
         
        if(patients[i].doctorId==_id){
            
            patientCount+=1;

         }
           
       }
       
      return patientCount; 
       
}


}
