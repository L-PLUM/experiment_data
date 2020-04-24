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
string addr;

}

struct Patient { 
    
string first_name;
string last_name;
string email;

uint id;
uint hospId;
uint doctorId;

string addr;

}


struct Doctor{
    
    
string first_name;
string last_name;
string email;   
    
    
string doctorName;
uint id;
uint hospId;

string addr;


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
function setHosp( string memory _addr,string memory _hospName, string memory _hospLocAddress) public {
    
    _hospAutoId+=1;
    
    hosp[_hospAutoId].addr=_addr;
    hosp[_hospAutoId].hospName=_hospName;
    hosp[_hospAutoId].hospLocAddress=_hospLocAddress;
    hosp[_hospAutoId].id=_hospAutoId;
    
    hospIds.push(_hospAutoId); 

} 

//set patient
 function setPatient(string memory _addr,string memory _fname,string memory _lname,string memory _email ,uint _hospId,uint _doctId) public {
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].first_name=_fname;
    patients[_patientAutoId].last_name=_lname;
    patients[_patientAutoId].email=_email;
    patients[_patientAutoId].addr=_addr;
    
    patients[_patientAutoId].hospId=_hospId;
    patients[_patientAutoId].id=_patientAutoId;
    patients[_patientAutoId].doctorId=_doctId;
    
    patientIds.push(_patientAutoId); 

}

//set Doctor

function setDoctor(string memory _addr,string memory _fname,string memory _lname,string memory _email ,uint _hospId) public {
    
    _doctsAutoId+=1;
    
    doctors[_doctsAutoId].first_name=_fname;
    doctors[_doctsAutoId].last_name=_lname;
    doctors[_doctsAutoId].email=_email;
    doctors[_doctsAutoId].addr=_addr;
    
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


//get patient id
function getPatientIdByAddress(string memory addr) view public returns(uint){
 
 
     for(uint i=1; i<=patientIds.length; i++){
         
        if(compareStrings(patients[i].addr,addr)){
            
            return patients[i].id; 

         }
           
       }
    
}

//get hospital id

function getHospIdByAddress(string memory addr) view public returns(uint){
 
 
     for(uint i=1; i<=hospIds.length; i++){
         
        if(compareStrings(hosp[i].addr,addr)){
            
            return hosp[i].id; 

         }
           
       }
    
}


//get doctor id


function getDoctIdByAddress(string memory addr) view public returns(uint){
 
 
     for(uint i=1; i<=doctIds.length; i++){
         
        if(compareStrings(doctors[i].addr,addr)){
            
            return doctors[i].id; 

         }
           
       }
    
}




 function compareStrings(string memory s1,string memory s2) public pure returns(bool)
   {
       if(uint(keccak256(abi.encodePacked(s1))) == uint(keccak256(abi.encodePacked(s2)))) {
     return true;
   }else{
       
    return false;
       
   }
       
   }


}
