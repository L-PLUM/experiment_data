package main

import (
	"fmt"
	"bytes"
		
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


type vote struct {
	ObjectType 	string 	`json:"docType"`
	PollID		string 	`json:"pollID"`
	VoterID		string 	`json:"voterID"`
	VoterSex 	string 	`json:"voterSex"`
	VoterAge	int 	`json:"voterAge"`
}


type votePrivateDetails struct {
	ObjectType 	string 	`json:"docType"`
	PollID		string 	`json:"pollID"`
	VoterID		string 	`json:"voterID"`
	Salt 		string 	`json:"salt"`
	VoteHash 	string 	`json:"voteHash"`
}


type poll struct {
	ObjectType 	string 	`json:"docType"`
	PollID		string 	`json:"pollID"`
	Status		string 	`json:"status"`
	NumVotes	int 	`json:"numVotes"`
}


type pollPrivateDetails struct {
	ObjectType 	string 	`json:"docType"`
	PollID		string 	`json:"pollID"`
	Salt 		string 	`json:"salt"`
	PollHash 	string 	`json:"pollHash"`
}


type VoteChaincode struct {
}


func main() {
	err := shim.Start(new(VoteChaincode))
	if err != nil {
		fmt.Printf("Error starting Vote chaincode: %s", err)
	}
}

// ============================
// Init - initializes chaincode
// ============================
func (vc *VoteChaincode) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

// =================================================
// Invoke - starting point for chaincode invocations
// =================================================
func (vc *VoteChaincode) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	fn, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + fn)

	switch fn {
	case "initVote":
		return vc.initVote(stub, args)
	case "getVote":
		return vc.getVote(stub, args)
	case "getVotePrivateDetails":
		return vc.getVotePrivateDetails(stub, args)
	case "getVotePrivateDetailsHash":
		return vc.getVotePrivateDetailsHash(stub, args)
	case "amendVote":
		return vc.updateVote(stub, args)
	case "queryVotePrivateDetailsByPoll":
		return vc.queryVotePrivateDetailsByPoll(stub, args)
	case "queryVotesByPoll":								// parametrized rich query w/ poll ID
		return vc.queryVotesByPoll(stub, args)
	case "queryVotesByVoter":								// parametrized rich query w/ voter ID
		return vc.queryVotesByVoter(stub, args)			
	case "queryVotes":										// ad hoc rich query
		return vc.queryVotes(stub, args)
	case "initPoll":
		return vc.initPoll(stub, args)
	case "getPoll":
		return vc.getPoll(stub, args)
	case "getPollPrivateDetails":
		return vc.getPollPrivateDetails(stub, args)
	case "updatePollStatus":
		return vc.updatePollStatus(stub, args)
	}

	fmt.Println("invoke did not find fn: " + fn)
	return shim.Error("Received unknown function invocation")
}

// ===========================================================================================
// Taken from fabric-samples/marbles_chaincode.go.
// constructQueryResponseFromIterator constructs a JSON array containing query results from
// a given result iterator
// ===========================================================================================
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

// =========================================================================================
// Taken from fabric-samples/marbles_chaincode.go.
// getQueryResultForQueryString executes the passed in query string.
// Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetPrivateDataQueryResult("collectionVote", queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}