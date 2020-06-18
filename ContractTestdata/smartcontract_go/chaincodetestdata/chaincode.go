/*
 * SPDX-License-Identifier: Apache-2.0
 */

package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Chaincode is the definition of the chaincode structure.
type Chaincode struct {
}

// Init is called when the chaincode is instantiated by the blockchain network.
func (cc *TicketsChaincode) Init(stub shim.ChaincodeStubInterface) sc.Response {
	fcn, params := stub.GetFunctionAndParameters()
	fmt.Println("Init()", fcn, params)
	return shim.Success(nil)
}

// Invoke is called as a result of an application request to run the chaincode.
func (cc *TicketsChaincode) Invoke(stub shim.ChaincodeStubInterface) sc.Response {
	fcn, args := stub.GetFunctionAndParameters()
	fmt.Println("Invoke()", fcn, args)

	if fcn == "initTicket" { //create a new ticket
		return cc.initTicket(stub, args)
	} else if fcn == "transferTicket" { //change holder of a ticket
		return cc.transferTicket(stub, args)
	} else if fcn == "readTicket" { //read ticket
		return cc.readTicket(stub, args)
	} else if fcn == "redeemTicket" { //redeem ticket
		return cc.redeemTicket(stub, args)
	} else if fcn == "deleteTicket" { //delete ticket
		return cc.deleteTicket(stub, args)
	}

	fmt.Println("invoke did not find func: " + fcn) //error
	return shim.Error("Received unknown function invocation")

}

type TicketsChaincode struct {
}

type ticket struct {
	ObjectType string `json:"docType"`
	TicketID   string `json:"ticketId"`
	EventName  string `json:"eventName"`
	Location   string `json:"location"`
	EventDate  int    `json:"eventDate"`
	Holder     string `json:"holder"`
	Redeemed   bool   `json:"redeemed"`
}

func (cc *TicketsChaincode) initTicket(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var err error

	// check for proper # of argument
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	//Input sanitation
	fmt.Println("- start init ticket")
	if len(args[0]) <= 0 {
		return shim.Error("1st argument must be a non-empty string")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument must be a non-empty string")
	}
	if len(args[2]) <= 0 {
		return shim.Error("3rd argument must be a non-empty string")
	}
	if len(args[3]) <= 0 {
		return shim.Error("4th argument must be a non-empty string")
	}
	if len(args[4]) <= 0 {
		return shim.Error("5th argument must be a non-empty string")
	}

	ticketID := args[0]
	eventName := strings.ToLower(args[1])
	location := strings.ToLower(args[2])
	eventDate, err := strconv.Atoi(args[3])
	if err != nil {
		return shim.Error("argument must be a numeric string")
	}
	holder := strings.ToLower(args[4])
	redeemed := false

	//Check if ticket already exists
	ticketAsBytes, err := stub.GetState(ticketID)
	if err != nil {
		return shim.Error("Failed to get ticket: " + err.Error())
	} else if ticketAsBytes != nil {
		return shim.Error("This ticket already exists: " + ticketID)
	}

	// Create ticket object and marshal to JSON
	objectType := "ticket"
	ticket := &ticket{objectType, ticketID, eventName, location, eventDate, holder, redeemed}
	ticketJSONasBytes, err := json.Marshal(ticket)
	if err != nil {
		return shim.Error(err.Error())
	}

	// Save ticket to state
	err = stub.PutState(ticketID, ticketJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//Ticket saved and indexed. Return success
	fmt.Println("- end init ticket")
	return shim.Success(nil)
}

// create search index for ledger

func (cc *TicketsChaincode) createIndex(stub shim.ChaincodeStubInterface, indexName string, attributes []string) error {
	fmt.Println("- start create index")
	var err error

	indexKey, err := stub.CreateCompositeKey(indexName, attributes)
	if err != nil {
		return err
	}

	value := []byte{0x00}
	stub.PutState(indexKey, value)

	fmt.Println("created index")
	return nil
}

// delete index
func (cc *TicketsChaincode) deleteIndex(stub shim.ChaincodeStubInterface, indexName string, attributes []string) error {
	fmt.Println("- start delete index")
	var err error

	indexKey, err := stub.CreateCompositeKey(indexName, attributes)
	if err != nil {
		return err
	}
	//  Delete index by key
	stub.DelState(indexKey)

	fmt.Println("deleted index")
	return nil
}

func (cc *TicketsChaincode) readTicket(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var ticketID, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting Ticket ID number")
	}

	ticketID = args[0]
	valAsbytes, err := stub.GetState(ticketID) //get the ticket from chaincode state
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + ticketID + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"Ticket does not exist: " + ticketID + "\"}"
		return shim.Error(jsonResp)
	}

	return shim.Success(valAsbytes)
}

func (cc *TicketsChaincode) deleteTicket(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var jsonResp string
	var ticketJSON ticket
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	ticketID := args[0]

	valAsbytes, err := stub.GetState(ticketID) //get the ticket from chaincode state
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + ticketID + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"Ticket does not exist: " + ticketID + "\"}"
		return shim.Error(jsonResp)
	}

	err = json.Unmarshal([]byte(valAsbytes), &ticketJSON)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to decode JSON of: " + ticketID + "\"}"
		return shim.Error(jsonResp)
	}

	err = stub.DelState(ticketID) //remove the ticket from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state:" + err.Error())
	}

	return shim.Success(nil)
}

func (cc *TicketsChaincode) transferTicket(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	//   0       1       2
	// "name", "from", "to"
	if len(args) < 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	ticketID := args[0]
	currentHolder := strings.ToLower(args[1])
	newHolder := strings.ToLower(args[2])
	fmt.Println("- start transferTicket ", ticketID, currentHolder, newHolder)

	message, err := cc.transferTicketHelper(stub, ticketID, currentHolder, newHolder)
	if err != nil {
		return shim.Error(message + err.Error())
	} else if message != "" {
		return shim.Error(message)
	}

	fmt.Println("- end transferTicket (success)")
	return shim.Success(nil)
}

func (cc *TicketsChaincode) transferTicketHelper(stub shim.ChaincodeStubInterface, ticketID string, currentHolder string, newHolder string) (string, error) {

	fmt.Println("Transfering ticket with ID: " + ticketID + " To: " + newHolder)
	ticketAsBytes, err := stub.GetState(ticketID)
	if err != nil {
		return "Failed to get ticket:", err
	} else if ticketAsBytes == nil {
		return "Ticket does not exist", err
	}

	ticketToTransfer := ticket{}
	err = json.Unmarshal(ticketAsBytes, &ticketToTransfer) //unmarshal ticket
	if err != nil {
		return "", err
	}

	if currentHolder != ticketToTransfer.Holder {
		return "This ticket is currently owned by another entity.", err
	}

	ticketToTransfer.Holder = newHolder //change the holder

	ticketJSONBytes, _ := json.Marshal(ticketToTransfer)
	err = stub.PutState(ticketID, ticketJSONBytes) //rewrite the ticket
	if err != nil {
		return "", err
	}

	return "", nil
}

func (cc *TicketsChaincode) redeemTicket(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var ticketID, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting Ticket ID number")
	}

	ticketID = args[0]
	ticketAsBytes, err := stub.GetState(ticketID)
	if err != nil {
		return "Failed to get ticket:", err
	} else if ticketAsBytes == nil {
		return "Ticket does not exist", err
	}

	ticketToRedeem := ticket{}
	err = json.Unmarshal(ticketAsBytes, &ticketToRedeem) //unmarshal ticket
	if err != nil {
		return "", err
	}

	if ticketToRedeem.Redeemed == true {
		return "This ticket has already been redeemed.", err
	}

	ticketToRedeem.Redeemed = true //set ticket to redeemed

	ticketJSONBytes, _ := json.Marshal(ticketToRedeem)
	err = stub.PutState(ticketID, ticketJSONBytes) //rewrite the ticket
	if err != nil {
		return "", err
	}

	return "", nil
}
