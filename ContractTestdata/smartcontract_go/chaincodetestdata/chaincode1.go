package main

//besides the normal packages, we need to import shim and peer
//which can be found within fabric (git)
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

// we implement chaincode under 'ourChain' structure
type ourChain struct {
}

// we represent metadata with 'ourdata' structure
type entry struct {
	ObjectType  string `json:"docType"`
	ID          string `json:"id"`          //ID for the entry
	Hash        string `json:"hash"`        //primary ID for each entry
	Application string `json:"application"` //participating app
	NodeIP      string `json:"nodeIP"`      //IP of device device that created entry
	Owner       string `json:"owner"`       //username
	Updated     int    `json:"updated"`     //0 is outdated, 1 for updated
}

//main innitiate smartcontract ourChain
func main() {
	err := shim.Start(new(ourChain))
	if err != nil {
		fmt.Print("Error starting the chaincode, reason: %s", err)
	}
}

//Initialize the ledger
func (v *ourChain) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

//invoke a given function
func (v *ourChain) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, arguments := stub.GetFunctionAndParameters()
	fmt.Println("function is running....")

	if function == "initEntry" {
		return v.initEntry(stub, arguments)
		//} else if function == "setentry" {
		//return v.setentry(stub, arguments)
	} else if function == "readEntry" {
		return v.readEntry(stub, arguments)
	} else if function == "deleteEntry" {
		return v.deleteEntry(stub, arguments)	
	} else if function == "searchByOwner" {
		return v.searchByOwner(stub, arguments)
	}

	fmt.Println("invoke did not find func: " + function)
	return shim.Error("function not found")
}

//innitialize chaincode entry
func (v *ourChain) initEntry(stub shim.ChaincodeStubInterface, arguments []string) peer.Response {

	//detect errors in entry
	var err error
	if len(arguments) != 6 {
		return shim.Error("Incorrect # of arguments, expecting 6")
	}
	if len(arguments[0]) <= 0 {
		return shim.Error("ID must be 1 string")
	}
	if len(arguments[1]) <= 0 {
		return shim.Error("hash must be a string")
	}
	if len(arguments[2]) <= 0 {
		return shim.Error("Application must be a string")
	}
	if len(arguments[3]) <= 0 {
		return shim.Error("Node must be a string")
	}
	if len(arguments[4]) <= 0 {
		return shim.Error("Owner must be a string")
	}
	if len(arguments[5]) <= 0 {
		return shim.Error("Updated must be a string")
	}
	id := arguments[0]
	hash := arguments[1]
	application := arguments[2]
	node := arguments[3]
	owner := arguments[4]
	updated, err := strconv.Atoi(arguments[5])

	//make sure that updated is a number, 0 or 1
	if (updated != 0 && updated != 1) {
		return shim.Error("Invalid entry for updated")
	}

	//check if entry already exists
	entryBytes, err := stub.GetState(id)
	if err != nil {
		return shim.Error("Fail to get entry: " + err.Error())
	} else if entryBytes != nil {
		return shim.Error("This entry already exists.")
	}

	//create entry and marshal to JSON
	objectType := "entry"
	entry := &entry{objectType, id, hash, application, node, owner, updated}
	entryJSONbytes, err := json.Marshal(entry)
	if err != nil {
		return shim.Error(err.Error())
	}

	//save entry to state/blockchain
	err = stub.PutState(id, entryJSONbytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//composite key
	indices := "application-owner"
	indicesKey, err := stub.CreateCompositeKey(indices, []string{entry.Application, entry.Owner})
	if err != nil {
		return shim.Error(err.Error())
	}

	//save the indices entry to a state
	value := []byte{0x00}
	stub.PutState(indicesKey, value)

 	//register event
	err = stub.SetEvent("initEvent", []byte{})
	if err != nil {
		return shim.Error(err.Error())
	}

	//return success
	fmt.Println("end initiation")
	return shim.Success(nil)
}

//read an entry into the ledger
func (v *ourChain) readEntry(stub shim.ChaincodeStubInterface, arguments []string) peer.Response {
	var id, jsonResponse string
	var err error
	
	fmt.Println("reached")
	//check for length
	if len(arguments) != 1 {
		return shim.Error("Incorrect number of arguments. expecting ID")
	}

	//get the record for corresponding ID
	id = arguments[0]
	entrybytes, err := stub.GetState(id)
	if err != nil {
		jsonResponse = "failed to get entry"
		return shim.Error(jsonResponse)
	} else if entrybytes == nil {
		jsonResponse = "No entry for " + id + " was found"
		return shim.Error(jsonResponse)
	}
	return shim.Success(entrybytes)
}

//delete an entry from the state
func (v *ourChain) deleteEntry(stub shim.ChaincodeStubInterface, arguments []string) peer.Response {
	var jsonResponse string
	var entryJSON entry

	if len(arguments) != 1 {
		return shim.Error("Incorrect number of arguments")
	}

	//obtain the state:
	entry := arguments[0]
	entrybytes, err := stub.GetState(entry)
	if err != nil {
		jsonResponse = "failed to get entry"
		return shim.Error(jsonResponse)
	} else if entrybytes == nil {
		jsonResponse = "No entry for " + entry + " was found"
		return shim.Error(jsonResponse)
	}

	err = json.Unmarshal([]byte(entrybytes), &entryJSON) //unmarshall
	if err != nil {
		jsonResponse = "{\"Error\":\"Failed to get state for " + entry + "\"}"
		return shim.Error(jsonResponse)
	}

	err = stub.DelState(entry) //delete
	if err != nil {
		return shim.Error("Failed to delete the state")
	}

	//register event
	err = stub.SetEvent("deleteEvent", []byte{})
	if err != nil {
		return shim.Error(err.Error())
	}


	return shim.Success(nil)
}

//get all entry for an owner
func (v *ourChain) searchByOwner(stub shim.ChaincodeStubInterface, arguments []string) peer.Response {

	//check the length to insure it is 1
	if len(arguments) != 1 {
		return shim.Error("Incorrect number of arguments. expecting owner")
	}

	//json string
	owner := arguments[0]
	jsonString := fmt.Sprintf("{\"selector\":{\"docType\":\"entry\",\"owner\":\"%s\"}}", owner)

	//call fuction that gets results for the corresponding string
	results, err := resultFromString(stub, jsonString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(results)
}

//get

//get query result from string is obtained and passed as byte array
func resultFromString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	//get iterator
	result, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer result.Close()

	//construct query result from iterator
	buffer, err := constructQueryResponse(result)
	if err != nil {
		return nil, err
	}

	fmt.Printf("Query result: %s\n", buffer)
	return buffer.Bytes(), nil
}

//get records in byte format from iterator
func constructQueryResponse(result shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	var buffer bytes.Buffer
	buffer.WriteString("[")

	writtenarray := false
	for result.HasNext() {
		queryResponse, err := result.Next()
		if err != nil {
			return nil, err
		}
		if writtenarray == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(",\"Record\":")
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		writtenarray = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}
