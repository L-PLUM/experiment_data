/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

package main

import (
	"errors"
	"fmt"
	"strconv"
	"encoding/json"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

var logger = shim.NewLogger("GiouChaincode")


//==============================================================================================================================
//	 Structure Definitions
//==============================================================================================================================
//	Chaincode - A blank struct for use with Shim (A HyperLedger included go file used for get/put state
//				and other HyperLedger functions)
//==============================================================================================================================
type  SimpleChaincode struct {
}

// ============================================================================================================================
// Asset Definitions - The ledger will store voters and candidates
// ============================================================================================================================
//==============================================================================================================================
//	Voter - Defines the structure for a voter object. JSON on right tells it what JSON fields to map to
//			  that element when reading a JSON object into the struct e.g. JSON make -> Struct Make.
//==============================================================================================================================
type Voter struct {
	VID 						string `json:"VID"`
	TokensBought    			string `json:"TokensBought"`
	TokensRemaining				string `json:"TokensRemaining"`
	Enabled						bool `json:"Enabled"`
}

type Candidate struct {
	CID 				string `json:"CID"`
	CandidateName    string `json:"CandidateName"`
	VotesReceived    string `json:"VotesReceived"`
}


// ===================================================================================
// Main
// ===================================================================================
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}


// ============================================================================================================================
// Init - initialize the chaincode 
//
// VotingApp does not require initialization, so let's run a simple test instead.
//
// Inputs - Array of strings
//  ["314"]
// 
// Returns - shim.Success or error
// ============================================================================================================================
// Init initializes chaincode
// ===========================
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("\nVotingApp Is Starting Up\n")
	_, args := stub.GetFunctionAndParameters()
	var Aval int
	var err error
	
	fmt.Println("Init() args count:", len(args))
	fmt.Println("Init() args found:", args)

	// expecting 1 arg for instantiate or upgrade
	if len(args) == 1 {
		fmt.Println("Init() arg[0] length", len(args[0]))

		// expecting arg[0] to be length 0 for upgrade
		if len(args[0]) == 0 {
			fmt.Println("args[0] is empty... must be upgrading")
		} else {
			fmt.Println("args[0] is not empty, must be instantiating")

			// convert numeric string to integer
			Aval, err = strconv.Atoi(args[0])
			if err != nil {
				return shim.Error("Expecting a numeric string argument to Init() for instantiate")
			}

			// this is a very simple test. let's write to the ledger and error out on any errors
			// it's handy to read this right away to verify network is healthy if it wrote the correct value
			err = stub.PutState("selftest", []byte(strconv.Itoa(Aval)))
			if err != nil {
				return shim.Error(err.Error())                  //self-test fail
			}
		}
	}

	// store compaitible Voting application version
	err = stub.PutState("voting_ui", []byte("4.0.0"))
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("\n - ready for action")                          //self-test pass
	return shim.Success(nil)
}


//==============================================================================================================================
//	Invoke - Called on chaincode invoke. Takes a function name passed and calls that function.
//==============================================================================================================================
// ============================================================================================================================
// Invoke - Our entry point for Invocations
// ============================================================================================================================
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println(" ")
	fmt.Println("starting invoke, for - " + function)

	// Handle different functions
	if function == "init" {                    //initialize the chaincode state, used as reset
		return t.Init(stub)
	} else if function == "read_voter" {             
		return read_voter(stub, args)
	} else if function == "delete_voter" {    
		return delete_voter(stub, args)
	} else if function == "init_voter" {      
		return init_voter(stub, args)
	}else if function == "init_candidate" {      
		return init_candidate(stub, args)
	}else if function == "read_candidate" {      
		return read_candidate(stub, args)
	}else if function == "delete_candidate" {      
		return delete_candidate(stub, args)
	}else if function == "transfer_vote" {      
		return transfer_vote(stub, args)
	}

	// error out
	fmt.Println("Received unknown invoke function name - " + function)
	return shim.Error("Received unknown invoke function name - '" + function + "'")
}


//*********************************************************************************
//********************************** WRITE LEDGER *********************************
//*********************************************************************************
// ============================================================================================================================
// Init Voter - create a new voter, store into chaincode state
//
// Inputs - Array of Strings
//           0     ,         1   	.
//      voter id   , TokensBought	.
//           "v001",       "100" 	.
// ============================================================================================================================
func init_voter(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fmt.Println("starting init_voter")

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	//input sanitation
	err = sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	var voter Voter
	voter.VID = args[0]
	voter.TokensBought = args[1]
	voter.TokensRemaining = args[1]
	voter.Enabled = true
	fmt.Println("ID: " + voter.VID + ", TokensBought: " + voter.TokensBought + ", TokensRemaining: " + voter.TokensRemaining + ", Active: " + strconv.FormatBool(voter.Enabled))
	
	//check if user already exists
	_, err = get_voter(stub, voter.VID)
	if err == nil {
		fmt.Println("This voter already exists - " + voter.VID)
		return shim.Error("This voter already exists - " + voter.VID)
	}

	//store user
	voterAsBytes, _ := json.Marshal(voter)                         //convert to array of bytes
	fmt.Println(" putting state in block")
	err = stub.PutState(voter.VID, voterAsBytes)                    //store voter by its Id
	if err != nil {
		fmt.Println("Could not store voter")
		return shim.Error(err.Error())
	}
	
	fmt.Println(voter.VID + " voter has been stored")
	fmt.Println("- end init_voter")
	return shim.Success(nil)
}


// ============================================================================================================================
// Init Candidate - create a new candidate, store into chaincode state
//
// Inputs - Array of Strings
//           	0	    ,	         1   			.
//      candidate id   	, 	candidate's name		.
//           "c001"		,   "christopher wallace"	.
// ============================================================================================================================
func init_candidate(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	fmt.Println("starting init_candidate")

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	//input sanitation
	err = sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	var candidate Candidate
	candidate.CID =  args[0]
	candidate.CandidateName = args[1]
	candidate.VotesReceived = "0"
	fmt.Println("ID: " + candidate.CID + ", CandidateName: " + candidate.CandidateName + ", VotesReceived: " + candidate.VotesReceived)

	//check if user already exists
	_, err = get_candidate(stub, candidate.CID)
	if err == nil {
		fmt.Println("This candidate already exists - " + candidate.CID)
		return shim.Error("This candidate already exists - " + candidate.CID)
	}

	//store user
	candidateAsBytes, _ := json.Marshal(candidate)                         //convert to array of bytes
	fmt.Println(" putting state in block")
	err = stub.PutState(candidate.CID, candidateAsBytes)                    //store candidate by its Id
	if err != nil {
		fmt.Println("Could not store candidate")
		return shim.Error(err.Error())
	}
	
	fmt.Println(candidate.CID + " candidate has been stored")
	fmt.Println("- end init_candidate")
	return shim.Success(nil)
}


// ============================================================================================================================
// delete_voter() - remove a voter from state and from voter index
//
// Inputs - Array of strings
//      0      	.
//     id 		.
//	"v001"		.
// ============================================================================================================================
func delete_voter(stub shim.ChaincodeStubInterface, args []string) (pb.Response) {
	fmt.Println("starting delete_voter")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// input sanitation
	err := sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	vid := args[0]

	// get the voter
	voter, err := get_voter(stub, vid)
	if err != nil{
		fmt.Println("Failed to find voter by vid " + vid)
		return shim.Error(err.Error())
	}

	// remove the voter
	err = stub.DelState(vid) //remove the key from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	fmt.Println(voter.VID + " voter has been deleted")
	fmt.Println("- end delete_voter")
	return shim.Success(nil)
}


// ============================================================================================================================
// delete_candidate() - remove a candidate from state and from candidate index
//
// Inputs - Array of strings
//      0      	.
//     id 		.
//	"c001"		.
// ============================================================================================================================
func delete_candidate(stub shim.ChaincodeStubInterface, args []string) (pb.Response) {
	fmt.Println("starting delete_candidate")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// input sanitation
	err := sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	cid := args[0]

	// get the candidate
	candidate, err := get_candidate(stub, cid)
	if err != nil{
		fmt.Println("Failed to find candidate by cid " + cid)
		return shim.Error(err.Error())
	}

	// remove the candidate
	err = stub.DelState(cid) //remove the key from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	fmt.Println(candidate.CID + " candidate has been deleted")
	fmt.Println("- end delete_candidate")
	return shim.Success(nil)
}


// ============================================================================================================================
// Transfer Vote
//
// Inputs - Array of Strings
//       0     	,        1      	,        		2 			.
//  voter id  	,   candidate id  	, 	tokens to use for vote	.
// 	"v001"		, 	"c001"			, 				"20"		. 
// ============================================================================================================================
func transfer_vote(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var voter Voter
	var candidate Candidate
	var err error
	fmt.Println("starting transfer_vote")

	if len(args) != 3 {
		fmt.Println("Incorrect number of arguments. Expecting 3")
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	// input sanitation
	err = sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	vid := args[0]
	cid := args[1]
	tokensToUse := args[2]

	tTU, err := strconv.Atoi(tokensToUse)
	if tTU <= 0 {
		fmt.Println("This voter didn't insert enough tokens to use- " + tokensToUse)
		return shim.Error("This voter didn't insert enough tokens to use- " + tokensToUse)
	}

	fmt.Println("The voter '" + vid + "' votes for the candidate '" + cid + "' with the amount of- |" + tokensToUse + "| -tokens.")

	//check if voter already exists
	voter, err = get_voter(stub, vid)
	if err != nil{
		fmt.Println("Failed to find voter by vid " + vid)
		return shim.Error(err.Error())
	}

	if err != nil || voter.Enabled == false {
		fmt.Println("This voter does not exist or is disabled- " + voter.VID)
		fmt.Println(voter)
		return shim.Error("This voter does not exist or is disabled- " + voter.VID)
	}

	//check if user already exists
	candidate, err = get_candidate(stub, cid)
	if err != nil {
		return shim.Error("This candidate does not exist - " + cid)//cid
	}

	
	tB := voter.TokensBought
	tR, err := strconv.Atoi(voter.TokensRemaining)
	vR, err := strconv.Atoi(candidate.VotesReceived)

	if (tR >= tTU && tR > 0) {
		tR = tR - tTU
		vR = vR + tTU
		voter.TokensRemaining = strconv.Itoa(tR)
		fmt.Println("The voter's remaining tokens are " + voter.TokensRemaining)
        candidate.VotesReceived = strconv.Itoa(vR)
        fmt.Println("The candidate has recieved in total '" + candidate.VotesReceived + "' tokens.")
	}else if (tR > 0 && tTU >tR) {
		fmt.Println("Not enough tokens. Your maximum amount of tokens is: - |" + voter.TokensRemaining + "| -")
		return shim.Error("Not enough tokens. Your maximum amount of tokens is: - |" + voter.TokensRemaining + "| -")
	}

	if (tR <= 0) {
		var v = []string {vid}
		fmt.Println("The voter with vid " + vid + " is gonna be disabled")
		voter.TokensRemaining = strconv.Itoa(tR)
		voter,_ = disable_voter(stub, v)
		voter.VID = vid
		voter.TokensBought = tB
	}

	//store voter
	fmt.Println(voter)
	voterAsBytes, _ := json.Marshal(voter)
	err = stub.PutState(voter.VID, voterAsBytes)
	if err != nil{
		fmt.Println("Could not store voter")
		return shim.Error(err.Error())
	}

	//store user
	candidateAsBytes, _ := json.Marshal(candidate)                         //convert to array of bytes
	err = stub.PutState(candidate.CID, candidateAsBytes)                    //store candidate by its Id
	if err != nil {
		fmt.Println("Could not store candidate")
		return shim.Error(err.Error())
	}

	fmt.Println("- end transfer_vote")
	return shim.Success(nil)
}


//*********************************************************************************
//********************************** READ LEDGER **********************************
//*********************************************************************************
// ============================================================================================================================
// Read Voter- read a voter from ledger
//
// Inputs - Array of strings
//      0      	.
//     id 		.
//	"v001"		.
//
// Returns - string
// ============================================================================================================================
func read_voter(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var jsonResp string
	var err error
	fmt.Println("starting read_voter")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting key of the var to query")
	}

	// input sanitation
	err = sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	vid := args[0]
	voterAsBytes, err := stub.GetState(vid)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + vid + "\"}"
		return shim.Error(jsonResp)
	}

	var voter Voter
	json.Unmarshal(voterAsBytes, &voter)
	fmt.Println(voter)
	fmt.Println("- end read")

	return shim.Success(voterAsBytes)                  //send it onward
}


// ============================================================================================================================
// Read Candidate- read a candidate from ledger
//
// Inputs - Array of strings
//      0      	.
//     id 		.
//	"c001"		.
//
// Returns - string
// ============================================================================================================================
func read_candidate(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var jsonResp string
	var err error
	fmt.Println("starting read candidate")

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting key of the var to query")
	}

	// input sanitation
	err = sanitize_arguments(args)
	if err != nil {
		return shim.Error(err.Error())
	}

	cid := args[0]
	candidateAsbytes, err := stub.GetState(cid)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + cid + "\"}"
		return shim.Error(jsonResp)
	}

	var candidate Candidate
	json.Unmarshal(candidateAsbytes, &candidate)
	fmt.Println(candidate)
	fmt.Println("- end read")

	return shim.Success(candidateAsbytes)                  //send it onward
}


//*********************************************************************************
//********************************** LIB ******************************************
//*********************************************************************************
// ============================================================================================================================
// Get Voter - get a voter asset from ledger
//
// ============================================================================================================================
func get_voter(stub shim.ChaincodeStubInterface, vid string) (Voter, error) {
	var voter Voter
	voterAsBytes, err := stub.GetState(vid) //getState retreives a key/value from the ledger. If the key does not exist in the state database, (nil, nil) is returned.

	if err != nil {                                          
		return voter, errors.New("Failed to find voter - " + vid)
	}
	json.Unmarshal(voterAsBytes, &voter) //un stringify it aka JSON.parse()

	if voter.VID != vid {  
		return voter, errors.New("Voter does not exist - " + vid)
	}

	return voter, nil
}


// ============================================================================================================================
// Get Canddidate - get a candidate asset from ledger
// ============================================================================================================================
func get_candidate(stub shim.ChaincodeStubInterface, cid string) (Candidate, error) {
	var candidate Candidate
	candidateAsBytes, err := stub.GetState(cid) //getState retreives a key/value from the ledger. If the key does not exist in the state database, (nil, nil) is returned.

	if err != nil {             
		return candidate, errors.New("Failed to find candidate - " + cid)
	}
	json.Unmarshal(candidateAsBytes, &candidate) //un stringify it aka JSON.parse()

	if candidate.CID != cid {
		return candidate, errors.New("Candidate does not exist - " + cid) 
	}

	return candidate, nil
}


// ============================================================================================================================
// Disable Voter
// ============================================================================================================================
func disable_voter(stub shim.ChaincodeStubInterface, args []string) (Voter, error){
	var voter Voter
	fmt.Println("starting disable_voter")

	var vid = args[0]
	
	//if the voter doesn't have tokens, he must be disabled
	tR,_ := strconv.Atoi(voter.TokensRemaining)
	if tR <= 0 {
		fmt.Println(" Voter - " + vid + " - is gonna be disabled because of not remaining tokens")
		voter.Enabled = false
		voter.TokensRemaining = strconv.Itoa(tR)
		fmt.Println("- end disable_voter")
		return voter, nil
	}

	fmt.Println("The voter '" + vid + "' has '" + voter.TokensRemaining + "' remaining tokens")
	return voter,errors.New("The voter '" + vid + "' has " + voter.TokensRemaining + " remaining tokens")
}


// ============================================================================================================================
// Input Sanitation - dumb input checking, look for empty strings
// ============================================================================================================================
func sanitize_arguments(strs []string) error{
	for i, val := range strs {
		if len(val) <= 0 {
			return errors.New("Argument " + strconv.Itoa(i) + " must be a non-empty string")
		}
		if len(val) > 32 {
			return errors.New("Argument " + strconv.Itoa(i) + " must be <= 32 characters")
		}
	}
	return nil
}
