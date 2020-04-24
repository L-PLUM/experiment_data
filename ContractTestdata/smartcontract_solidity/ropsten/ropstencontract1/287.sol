/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.0;

contract Certificates {
    address public issuer;                                          // contract owner who is responsible for issuing certificates
    bool public disabled;                                           // contract state
    uint256 certificateCount;

    struct Certification {                                          // certification structure, defining certificate data
        uint256 id;
        string studentName;
        string title;
        string certificationLink;
    }

    mapping(address => Certification[]) issuedCertificates;         // actual certificate data array for each given account address

    constructor() public {
        issuer = msg.sender;
        disabled = false;
    }

    function disable() public returns (bool)
    {
        require(issuer == msg.sender, "Only certificate issuer can disable certification");
        disabled = true;
        return disabled;
    }

    function certify(address studentAddress, string memory studentName, string memory title, string memory certificationLink) public returns(bool)
    {
        require(msg.sender == issuer, "Only issuer can certify a student");
        require(disabled == false, "Certification must be enabled");

        issuedCertificates[studentAddress].push(Certification(certificateCount+1, studentName, title, certificationLink));
        certificateCount++;

        return true;
    }

    function getStudentCertificateCount(address student) public view returns(uint256)
    {
        return issuedCertificates[student].length;
    }

    function getCertificate(address student, uint256 index) public view returns (uint256, string memory, string memory, string memory)
    {
        require (issuedCertificates[student].length > index, "Bad index");

        return (issuedCertificates[student][index].id, issuedCertificates[student][index].studentName, issuedCertificates[student][index].title, issuedCertificates[student][index].certificationLink);
    }
}
