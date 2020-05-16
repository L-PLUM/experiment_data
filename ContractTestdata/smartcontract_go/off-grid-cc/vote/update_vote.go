package main

import (
	"fmt"
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


// ================================================
// updateVote - replace vote hash with new vote hash
// ================================================

func (vc *VoteChaincode) updateVote(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 0 {
		return shim.Error("Incorrect number of arguments. Pass data using transient map")		
	}

	fmt.Println("- begin amend vote")

	type updateVoteTransientInput struct {
		VoteKey string `json:"voteKey"`
		NewHash string `json:"newHash"`
	}

	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	updateVoteJsonBytes, ok := transMap["amend_vote"]
	if !ok {
		return shim.Error("amend_vote must be key in transient map")
	}

	if len(updateVoteJsonBytes) == 0 {
		return shim.Error("amend_vote value in transient map must be non-empty")
	}

	var updateVoteInput updateVoteTransientInput
	err = json.Unmarshal(updateVoteJsonBytes, &updateVoteInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(updateVoteJsonBytes))
	}

	if len(updateVoteInput.VoteKey) == 0 {
		return shim.Error("vote key field must be a non-empty string")
	}

	if len(updateVoteInput.NewHash) == 0 {
		return shim.Error("New hash field must be a non-empty string")
	}

	voteAsBytes, err := stub.GetPrivateData("collectionVotePrivateDetails", updateVoteInput.VoteKey)
	if err != nil {
		return shim.Error("Failed to get private vote data:" + err.Error())
	} else if voteAsBytes == nil {
		return shim.Error("Vote does not exist: " + updateVoteInput.VoteKey)
	}

	amendedVote := votePrivateDetails{}
	err = json.Unmarshal(voteAsBytes, &amendedVote)
	if err != nil {
		return shim.Error(err.Error())
	}
	amendedVote.VoteHash = updateVoteInput.NewHash

	voteJSONasBytes, _ := json.Marshal(amendedVote)
	err = stub.PutPrivateData(
		"collectionVotePrivateDetails", 
		amendedVote.PollID + amendedVote.VoterID + amendedVote.Salt,
		voteJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end amend vote (success)")
	return shim.Success(nil)
}
