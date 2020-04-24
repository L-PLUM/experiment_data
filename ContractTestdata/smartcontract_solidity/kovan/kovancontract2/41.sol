/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.1;
// pragma experimental ABIEncoderV2;

contract HealthRecord {
    address payable owner;
    
    constructor () public  {
        owner = msg.sender;
    }
    
    mapping (address => Doctor) doctors;
    mapping (address => Patient) patients;
    Record[] records;
    
    struct Doctor {
        string name;
        string hospital;
        bool exists;
    }
    
    struct Patient {
        string name;
        string homeAddress;
        int phoneNumber;
    }
    
    struct Medicine {
        string name;
        string usage;
    }
    
    struct DrugPrescription {
        Medicine[] medicines;
        string createdAt;
    }
    
    struct Record {
        Doctor doctor;
        Patient patient;
        string recordDescription;
        string createdAt;
        DrugPrescription prescription;
    }
    
    modifier doctorNotExists(address accountNumber) {
        require(!doctors[accountNumber].exists, "Doctor already exists");
        _;
    }
    
    function addDoctor(address accountNumber, string memory name, string memory hospital) public doctorNotExists(accountNumber) {
        Doctor memory newDoctor = Doctor(name, hospital, true);
        doctors[accountNumber] = newDoctor;
    }
    
    function isDoctorExists(address accountNumber) external view returns(bool) {
        return doctors[accountNumber].exists;
    }
}
