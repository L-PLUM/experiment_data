/*
 * The sample smart contract
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
	"time"
)

// sample Id generator starts at 4
var id = 0
var partId = 0

// returns the next CAR ID
func NextId() string {
	id++
	return fmt.Sprintf("CAR%s", strconv.Itoa(id))
}

// returns the next CAR PART ID
func NextPartId() string {
	partId++
	return fmt.Sprintf("PRT%s", strconv.Itoa(partId))
}

// Define the Smart Contract structure
type SmartContract struct {
}


// Define the car structure.  Structure tags are used by encoding/json library
type Car struct {
	Id      string    `json:"id"`
	Make    string    `json:"make"`
	Model   string    `json:"model"`
	MaxSpeed int 	  `json:"maxSpeed"`
	Colour  string    `json:"colour"`
	Owner   string    `json:"owner"`
	Created time.Time `json:"created"`
	Parts   []CarPart `json:"parts"`
}

// A car part is part of a car and
type CarPart struct {
	Id       string    `json:"id"`
	ParentId string    `json:"parentId"`
	Model    string    `json:"model"`
	Created  time.Time `json:"created"`
}

func NewCar(makeCar, model, color, owner string, maxSpeed int, parts ...string) *Car {
	idStr := NextId()

	p := make([]CarPart, 0)
	for i := 0; i < len(parts); i++ {
		part := NewCarPart(parts[i], idStr)
		p = append(p, *part)
	}

	return &Car{
		Id:      idStr,
		Make:    makeCar,
		Model:   model,
		Colour:  color,
		MaxSpeed: maxSpeed,
		Owner:   owner,
		Created: time.Now(),
		Parts:   p,
	}
}

func NewCarPart(parentId, model string) *CarPart {
	idStr := NextPartId()

	return &CarPart{
		Id:       idStr,
		Model:    model,
		ParentId: parentId,
		Created:  time.Now(),
	}
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryCar" {
		return s.queryCar(APIstub, args)
	} else if function == "initLedger" {
		return s.initLedger(APIstub)
	} else if function == "createCar" {
		return s.createCar(APIstub, args)
	} else if function == "queryAllCars" {
		return s.queryAllCars(APIstub)
	} else if function == "changeCarOwner" {
		return s.changeCarOwner(APIstub, args)
	} else if function == "addCarPart" {
		return s.addCarPart(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) queryCar(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	carAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(carAsBytes)
}

// builds initial state
func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	cars := make([]Car, 0)
	car1 := NewCar("Toyota", "Prius", "blue", "Tomoko", 200,"T Engine 1", "Pirelli Tire F51", "Jetsys Air System T159")
	cars = append(cars, *car1)
	car2 := NewCar("Ford", "Mustang", "red", "Brad", 250, "Ford Duratec V6", "Michellini Tire F52", "Jaguar Air System T200")
	cars = append(cars, *car2)
	car3 := NewCar("Volkswagen", "Passat", "yellow", "Max", 220,"AJ V8", "Michellini Tire F45", "Jamex Air System S120")
	cars = append(cars, *car3)

	i := 0
	for i < len(cars) {
		carAsBytes, _ := json.Marshal(cars[i])
		APIstub.PutState(cars[i].Id, carAsBytes)
		fmt.Println("Added", cars[i])
		i = i + 1
	}

	return shim.Success(nil)
}

func (s *SmartContract) createCar(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	mk := args[0]
	model := args[1]
	color := args[2]
	owner := args[3]
	maxSpeed, _ := strconv.Atoi(args[4])

	car := NewCar(mk, model, color, owner, maxSpeed)

	carAsBytes, _ := json.Marshal(car)
	APIstub.PutState(car.Id, carAsBytes)

	return shim.Success(carAsBytes)
}

func (s *SmartContract) queryAllCars(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "CAR0"
	endKey := "CAR999"

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
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

	fmt.Printf("- queryAllCars:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) changeCarOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	carAsBytes, _ := APIstub.GetState(args[0])
	car := Car{}

	json.Unmarshal(carAsBytes, &car)
	car.Owner = args[1]

	carAsBytes, _ = json.Marshal(car)
	APIstub.PutState(args[0], carAsBytes)

	return shim.Success(nil)
}

// adds a new part to a car - called by parts service
func (s *SmartContract) addCarPart(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	carId := args[0]
	model := args[1]

	if carId == "" || model == "" {
		return shim.Error("Invalid arguments")
	}

	carAsBytes, _ := APIstub.GetState(carId)
	car := Car{}

	json.Unmarshal(carAsBytes, &car)
	part := NewCarPart(carId, model)
	car.Parts = append(car.Parts, *part)

	carAsBytes, _ = json.Marshal(car)
	APIstub.PutState(carId, carAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
