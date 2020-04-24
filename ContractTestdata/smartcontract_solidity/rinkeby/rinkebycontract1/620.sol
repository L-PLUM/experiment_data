/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

/**
 * Copyright (C) 2018 Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.4.20;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Booking
 * @author Vladimir Khramov <[email protected]>
 */
contract Ledger is Ownable {

    function Ledger() public payable {

        //empty element with id=0
        records.push(Record('','',0));

        
    }
    
    /************************** STRUCT **********************/
    
    struct Record {
string commitHash;
string githubCommitUrlPointingToTheCommit;
bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain;
    }
    
    /************************** EVENTS **********************/
    
    event RecordAdded(uint256 id, string commitHash, string githubCommitUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain);
    
    /************************** CONST **********************/
    
    string public constant name = 'MixBytes Security Audits Registry'; 
    string public constant description = 'Ledger enumerates security audits executed by MixBytes. Each audit is described by a revised version of a code and our report file. Anyone can ascertain that the code was audited by MixBytes. MixBytes cannot ignore this audit in case an overlooked vulnerability is discovered. An audit can be found in this ledger by git commit hash, by full github repository commit url or by existing audit report file.'; 
    string public constant recordName = 'Security Audit'; 

    /************************** PROPERTIES **********************/

    Record[] public records;
    mapping (bytes32 => uint256) commitHash_mapping;
    mapping (bytes32 => uint256) githubCommitUrlPointingToTheCommit_mapping;
    mapping (bytes32 => uint256) auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping;

    /************************** EXTERNAL **********************/

    function addRecord(string _commitHash,string _githubCommitUrlPointingToTheCommit,bytes32 _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) external onlyOwner returns (uint256) {
        require(0==findIdByCommitHash(_commitHash));
        require(0==findIdByGithubCommitUrlPointingToTheCommit(_githubCommitUrlPointingToTheCommit));
        require(0==findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain));
    
    
        records.push(Record(_commitHash, _githubCommitUrlPointingToTheCommit, _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain));
        
        commitHash_mapping[keccak256(_commitHash)] = records.length-1;
        githubCommitUrlPointingToTheCommit_mapping[keccak256(_githubCommitUrlPointingToTheCommit)] = records.length-1;
        auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping[(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain)] = records.length-1;
        
        RecordAdded(records.length - 1, _commitHash, _githubCommitUrlPointingToTheCommit, _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain);
        
        return records.length - 1;
    }
    
    /************************** PUBLIC **********************/
    
    function getRecordsCount() public view returns(uint256) {
        return records.length - 1;
    }
    
    
    function findByCommitHash(string _commitHash) public view returns (uint256 id, string commitHash, string githubCommitUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByCommitHash(_commitHash) ];
        return (
            findIdByCommitHash(_commitHash),
            record.commitHash, record.githubCommitUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByCommitHash(string commitHash) internal view returns (uint256) {
        return commitHash_mapping[keccak256(commitHash)];
    }


    function findByGithubCommitUrlPointingToTheCommit(string _githubCommitUrlPointingToTheCommit) public view returns (uint256 id, string commitHash, string githubCommitUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByGithubCommitUrlPointingToTheCommit(_githubCommitUrlPointingToTheCommit) ];
        return (
            findIdByGithubCommitUrlPointingToTheCommit(_githubCommitUrlPointingToTheCommit),
            record.commitHash, record.githubCommitUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByGithubCommitUrlPointingToTheCommit(string githubCommitUrlPointingToTheCommit) internal view returns (uint256) {
        return githubCommitUrlPointingToTheCommit_mapping[keccak256(githubCommitUrlPointingToTheCommit)];
    }


    function findByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(bytes32 _auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) public view returns (uint256 id, string commitHash, string githubCommitUrlPointingToTheCommit, bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) {
        Record record = records[ findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) ];
        return (
            findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(_auditReportFileKeccakHashOfTheFileIsStoredInBlockchain),
            record.commitHash, record.githubCommitUrlPointingToTheCommit, record.auditReportFileKeccakHashOfTheFileIsStoredInBlockchain
        );
    }
    
    function findIdByAuditReportFileKeccakHashOfTheFileIsStoredInBlockchain(bytes32 auditReportFileKeccakHashOfTheFileIsStoredInBlockchain) internal view returns (uint256) {
        return auditReportFileKeccakHashOfTheFileIsStoredInBlockchain_mapping[(auditReportFileKeccakHashOfTheFileIsStoredInBlockchain)];
    }
}
