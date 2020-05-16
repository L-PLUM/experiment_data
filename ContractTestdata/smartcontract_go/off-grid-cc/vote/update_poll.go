package main

import (
	"fmt"
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


// =============================================================
// updatePollStatus - change "Status" attribute of a poll object
// =============================================================

func (vc *VoteChaincode) updatePollStatus(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	fmt.Println("- begin update poll")

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting poll ID and new poll status")
	}

	pollID := args[0]
	status := args[1]

	var p poll

	existingPollAsBytes, err := stub.GetPrivateData("collectionPoll", pollID)
	if err != nil {
		return shim.Error("Failed to get associated poll: " + err.Error())
	} else if existingPollAsBytes == nil {
		return shim.Error("Poll does not exist: " + pollID)
	}

	err = json.Unmarshal(existingPollAsBytes, &p)
	if err != nil {
		return shim.Error(err.Error())
	}

	p.Status = status
	pollJSONasBytes, err := json.Marshal(p)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutPrivateData("collectionPoll", pollID, pollJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.SetEvent("updateEvent", []byte{})
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end update poll (success)")
	return shim.Success(nil)
}