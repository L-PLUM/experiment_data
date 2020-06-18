package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


// =====================================================
// getVote - retrieve vote metadata from chaincode state
// =====================================================

func (vc *VoteChaincode) getVote(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting poll ID and voter ID to query")
	}

	voteKey, err := stub.CreateCompositeKey("vote", args)
	if err != nil {
		return shim.Error("Failed to create composite key in getVote(): " + err.Error())
	}

	// ==== retrieve the vote ====
	voteAsBytes, err := stub.GetPrivateData("collectionVote", voteKey)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + voteKey + "\"}")
	} else if voteAsBytes == nil {
		return shim.Error("{\"Error\":\"Vote does not exist: " + voteKey + "\"}")
	}

	return shim.Success(voteAsBytes)
}

// ==========================================================================
// getVotePrivateDetails - retrieve vote private details from chaincode state
// ==========================================================================

func (vc *VoteChaincode) getVotePrivateDetails(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting poll ID and voter ID to query")
	}

	iterator, err := stub.GetPrivateDataByPartialCompositeKey("collectionVotePrivateDetails", "vote", args)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get private details by partial composite key\"}")
	} else if iterator == nil {
		return shim.Error("{\"Error\":\"Vote private details with partial composite key do not exist\"}")
	}

	defer iterator.Close()

	kv, err := iterator.Next()
	if err != nil {
		return shim.Error("Failed to iterate over iterator: " + err.Error())
	}
	privateDetailsKey := kv.GetKey()

	voteAsBytes, err := stub.GetPrivateData("collectionVotePrivateDetails", privateDetailsKey)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + privateDetailsKey + "\"}")
	} else if voteAsBytes == nil {
		return shim.Error("{\"Error\":\"Vote does not exist: " + privateDetailsKey + "\"}")
	}

	return shim.Success(voteAsBytes)
}

// ==============================================================
// getVotePrivateDetailsHash - retrieve hash of value from ledger
// ==============================================================

func (vc *VoteChaincode) getVotePrivateDetailsHash(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting vote key to query")
	}

	iterator, err := stub.GetPrivateDataByPartialCompositeKey("collectionVotePrivateDetails", "vote", args)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get private details by partial composite key\"}")
	} else if iterator == nil {
		return shim.Error("{\"Error\":\"Vote private details with partial composite key do not exist\"}")
	}

	defer iterator.Close()

	kv, err := iterator.Next()
	if err != nil {
		return shim.Error("Failed to iterate over iterator: " + err.Error())
	}
	privateDetailsKey := kv.GetKey()

	voteHashAsBytes, err := stub.GetPrivateDataHash("collectionVotePrivateDetails", privateDetailsKey)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get private data hash for " + privateDetailsKey + "\"}")
	} else if voteHashAsBytes == nil {
		return shim.Error("{\"Error\":\"Vote private data does not exist: " + privateDetailsKey + "\"}")
	}

	return shim.Success(voteHashAsBytes)
}