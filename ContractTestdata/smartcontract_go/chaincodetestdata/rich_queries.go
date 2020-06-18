package main

import (
	"fmt"
	"strings"
	"bytes"
	"encoding/json"
	"encoding/gob"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

// ===================================================================
// getVotePrivateDetailsByPoll - retrieve vote private details by poll
// ===================================================================

func (vc *VoteChaincode) queryVotePrivateDetailsByPoll(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting poll ID")
	}

	iterator, err := stub.GetPrivateDataByPartialCompositeKey("collectionVotePrivateDetails", "vote", args)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get private details by partial composite key\"}")
	} else if iterator == nil {
		return shim.Error("{\"Error\":\"Vote private details with partial composite key do not exist\"}")
	}
	defer iterator.Close()

	// populate an array of strings with the hashes of the votes
	var hashes []string
	// hashes := []string{}

	for iterator.HasNext() {
		kv, err := iterator.Next()
		if err != nil {
			return shim.Error("Failed to iterate over iterator: " + err.Error())
		}

		var v votePrivateDetails

		err = json.Unmarshal(kv.GetValue(), &v)
		if err != nil {
			return shim.Error("Failed to unmarshal vote private details: " + err.Error())
		}
		hashes = append(hashes, v.VoteHash)
	}

	// encode []string into []byte
	var hashesBuf bytes.Buffer

	enc := gob.NewEncoder(&hashesBuf)
	err = enc.Encode(hashes)
	if err != nil {
		return shim.Error("Error during byte encoding of hashes: " + err.Error())
	}

	return shim.Success(hashesBuf.Bytes())
}



// ===== Parametrized rich queries =========================================================

// =========================================================================================
// queryVotesByPoll takes the poll ID as a parameter, builds a query string using
// the passed poll ID, executes the query, and returns the result set.
// =========================================================================================
func (vc *VoteChaincode) queryVotesByPoll(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: Poll ID")
	}

	pollID := strings.ToLower(args[0])
	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"vote\",\"pollID\":\"%s\"}}", pollID)
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(queryResults)
}

// =========================================================================================
// queryVotesByVoter takes the voter ID as a parameter, builds a query string using
// the passed voter ID, executes the query, and returns the result set.
// =========================================================================================	
func (vc *VoteChaincode) queryVotesByVoter(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: Voter ID")
	}

	voterID := strings.ToLower(args[0])
	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"vote\",\"voterID\":\"%s\"}}", voterID)
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(queryResults)
}

// ===== Ad hoc rich queries ===============================================================

// =========================================================================================
// Taken from fabric-samples/marbles_chaincode.go.
// queryVotes uses a query string to perform a query for votes.
// Query string matching state database syntax is passed in and executed as is.
// Supports ad hoc queries that can be defined at runtime by the client.
// =========================================================================================
func (vc *VoteChaincode) queryVotes(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	queryString := args[0]
	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(queryResults)
}
