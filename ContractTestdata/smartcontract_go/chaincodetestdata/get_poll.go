package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


// ===================================================================
// getPoll - retrieve poll metadata from chaincode state
// ===================================================================

func (vc *VoteChaincode) getPoll(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting poll ID to query")
	}

	pollID := args[0]

	// ==== retrieve the vote ====
	pollAsBytes, err := stub.GetPrivateData("collectionPoll", pollID)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + pollID + "\"}")
	} else if pollAsBytes == nil {
		return shim.Error("{\"Error\":\"Poll does not exist: " + pollID + "\"}")
	}

	return shim.Success(pollAsBytes)
}

// ========================================================================
// getPollPrivateDetails - retrieve poll data IPFS CID from chaincode state
// ========================================================================

func (vc *VoteChaincode) getPollPrivateDetails(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting cc key to query")
	}

	iterator, err := stub.GetPrivateDataByPartialCompositeKey("collectionPollPrivateDetails", "poll", args)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get poll private details by partial composite key\"}")
	} else if iterator == nil {
		return shim.Error("{\"Error\":\"Poll private details with partial composite key do not exist\"}")
	}
	defer iterator.Close()

	kv, err := iterator.Next()
	if err != nil {
		return shim.Error("Failed to iterate over iterator: " + err.Error())
	}
	privateDetailsKey := kv.GetKey()

	pollAsBytes, err := stub.GetPrivateData("collectionPollPrivateDetails", privateDetailsKey)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + privateDetailsKey + "\"}")
	} else if pollAsBytes == nil {
		return shim.Error("{\"Error\":\"Poll does not exist: " + privateDetailsKey + "\"}")
	}

	return shim.Success(pollAsBytes)
}
