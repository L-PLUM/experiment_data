/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.1;

contract MarkSheet {
    
    address public prof;
    
    constructor() public {
        prof = msg.sender;
    }
    
    struct student {
        string name;
        uint128 rollno;
        uint8 sem;
    }
    
    struct marks {
        uint8 sub1;
        uint8 sub2;
        uint8 sub3;
        uint8 sub4;
    }
    
    modifier isProfessor(){
        require(msg.sender == prof);
        _;
    }
    // function getRollno(address add) public returns(string memory){
    //     return studentAdd[add].rollno;
    // }
    
    mapping(uint128 => student) public studentAdd;
    mapping(uint128 => marks) public studentMarks;
    
    function createNewStudent(uint128 rollno, string memory name, uint8 sem) public isProfessor{
        studentAdd[rollno].name = name;
        studentAdd[rollno].rollno = rollno;
        studentAdd[rollno].sem = sem;
    }
    
    
    function enterMarks(uint128 rollno, uint8 sub1, uint8 sub2, uint8 sub3, uint8 sub4) public isProfessor{
        studentMarks[rollno].sub1 = sub1;
        studentMarks[rollno].sub2 = sub2;
        studentMarks[rollno].sub3 = sub3;
        studentMarks[rollno].sub4 = sub4;
    }
    
    
}
