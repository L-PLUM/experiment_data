/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.1; 
pragma experimental ABIEncoderV2;

contract MediChain {

struct Hosp { 
    
uint id;
string hospName;
string hospLocAddress; 
string addr;

}

struct Patient { 

uint id;

string first_name;
string last_name;
string email;

uint[] doctorId;

uint[] hospId;

string addr;

}


struct Doctor{
   
uint id;
string first_name;
string last_name;
string email;  

uint[] hospId;

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




//set patient
 function setPatient(string memory _addr,string memory _fname,string memory _lname,string memory _email ,uint _hospId,uint _doctId) public {
    
    _patientAutoId+=1;
    
    patients[_patientAutoId].first_name=_fname;
    patients[_patientAutoId].last_name=_lname;
    patients[_patientAutoId].email=_email;
    patients[_patientAutoId].addr=_addr;
    
   patients[_patientAutoId].hospId.push(_hospId);
    patients[_patientAutoId].id=_patientAutoId;
    patients[_patientAutoId].doctorId.push(_doctId);
    
    
    patientIds.push(_patientAutoId); 

}

//set Doctor
function setDoctor(string memory _addr,string memory _fname,string memory _lname,string memory _email ,uint _hospId) public {
    
    _doctsAutoId+=1;
    
    doctors[_doctsAutoId].first_name=_fname;
    doctors[_doctsAutoId].last_name=_lname;
    doctors[_doctsAutoId].email=_email;
    doctors[_doctsAutoId].addr=_addr;
    
       doctors[_doctsAutoId].hospId.push(_hospId);
    doctors[_doctsAutoId].id=_doctsAutoId;
    
    
    doctIds.push(_doctsAutoId); 

}


//set hospital
function setHosp( string memory _addr,string memory _hospName, string memory _hospLocAddress) public {
    
    _hospAutoId+=1;
    
    hosp[_hospAutoId].addr=_addr;
    hosp[_hospAutoId].hospName=_hospName;
    hosp[_hospAutoId].hospLocAddress=_hospLocAddress;
    hosp[_hospAutoId].id=_hospAutoId;
    
    hospIds.push(_hospAutoId); 

} 


function addDoctorHospitalByPatient(uint _patientId,uint _doctId, uint _hospId) public returns(string memory) {
    
    patients[_patientId].doctorId.push(_doctId);
    patients[_patientId].hospId.push(_hospId);
    
    
        return "Doctor and Hospital added successfully...!";

}



function addHospitalByDoctor(uint _doctorId, uint _hospId) public returns(string memory){
    
    doctors[_doctorId].hospId.push(_hospId);
    
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
