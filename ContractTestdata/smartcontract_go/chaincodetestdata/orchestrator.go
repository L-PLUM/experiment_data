/*
Copyright UrbanStack Org. 2017

 contact@urbanstack.co

 This software is part of the UrbanStack project, an open-source machine
 learning platform.
 This software is governed by the CeCILL license, compatible with the
 GNU GPL, under French law and abiding by the rules of distribution of
 free software. You can  use, modify and/ or redistribute the software
 under the terms of the CeCILL license as circulated by CEA, CNRS and
 INRIA at the following URL "http://www.cecill.info".

 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.

 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.

 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL license and that you accept its terms.
*/

package main

import (
	"encoding/json"
	"fmt"
	"sort"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
	"github.com/satori/go.uuid"
)

// SmartContract structure
type SmartContract struct {
}

// Item structures correspond to algo and data.
// ObjectType belongs to algo, data (necessary when switching to couchDB).
// StorageAddress is for now the uuid of the problem on storage.
// Name is the name of the item, defined by the owner, no unicity requirement.
// Problem is the key of the problem on the orchestrator, such as problem_uuid.
type Item struct {
	ObjectType     string `json:"docType"`
	StorageAddress string `json:"storageAddress"`
	Name           string `json:"name"`
	Problem        string `json:"problem"`
}

// Problem structure.
// ObjectType is problem (necessary when switching to couchDB).
// StorageAddress is for now the uuid of the problem on storage.
// SizeTrainDataset is the size of the batch for learning tasks.
// TestData is the list of test data keys on the ledger.
type Problem struct {
	ObjectType       string   `json:"docType"`
	StorageAddress   string   `json:"storageAddress"`
	SizeTrainDataset int      `json:"sizeTrainDataset"`
	TestData         []string `json:"testData"`
}

// Learnuplet structure.
// ObjectType is learnuplet (necessary when switching to couchDB).
// Problem maps the problem key on the orchestrator to its address on Storage.
// Algo maps the algo key on the orchestrator to its address on Storage.
// ModelStartAddress and ModelEndAddress are model addresses on Storage,
// from which to start the learning task and where to store output of the learning.
// TrainData and TestData map the train and test data keys to their addresses
// on Orchestrator.
// Worker is the uuid of the Compute worker realizing the training task.
// Status belongs to [todo, pending, failed, done].
// Rank defines the order in which learnuplets must be trained.
// Perf is the performance on the test dataset.
// TrainPerf and TestPerf map data keys to perf of the model on them
type Learnuplet struct {
	ObjectType        string             `json:"docType"`
	Problem           map[string]string  `json:"problem"`
	Algo              map[string]string  `json:"algo"`
	ModelStartAddress string             `json:"modelStartAddress"`
	ModelEndAddress   string             `json:"modelEndAddress"`
	TrainData         map[string]string  `json:"trainData"`
	TestData          map[string]string  `json:"testData"`
	Worker            string             `json:"worker"`
	Status            string             `json:"status"`
	Rank              int                `json:"rank"`
	Perf              float64            `json:"perf"`
	TrainPerf         map[string]float64 `json:"trainPerf"`
	TestPerf          map[string]float64 `json:"testPerf"`
}

// ErrorUplet structure
type errorUplet struct {
	number int
	what   string
}

func (e *errorUplet) Error() string {
	return fmt.Sprintf("%d - %s", e.number, e.what)
}

// Init method is called when the Smart Contract orchestrator is instantiated by the blockchain network
// Note that chaincode upgrade also calls this function to reset
// or to migrate data, so be careful to avoid a scenario where you
// inadvertently clobber your ledger's data!
// Best practice is to have any Ledger initialization in separate function -- see initLedger()
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	s.initLedger(APIstub)
	return shim.Success(nil)
}

// Invoke method is called as a result of an application request to run the Smart Contract
// The calling application program has also specified the particular smart contract function to be called, with arguments
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryObject" {
		return s.queryObject(APIstub, args)
	} else if function == "queryObjects" {
		return s.queryObjects(APIstub, args)
	} else if function == "queryProblemItems" {
		return s.queryProblemItems(APIstub, args)
	} else if function == "registerItem" {
		return s.registerItem(APIstub, args)
	} else if function == "registerProblem" {
		return s.registerProblem(APIstub, args)
	} else if function == "queryStatusLearnuplet" {
		return s.queryStatusLearnuplet(APIstub, args)
	} else if function == "queryAlgoLearnuplet" {
		return s.queryAlgoLearnuplet(APIstub, args)
	} else if function == "setUpletWorker" {
		return s.setUpletWorker(APIstub, args)
	} else if function == "reportLearn" {
		return s.reportLearn(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// ============================================
// initLedger
// ============================================

// initLedger populates the database.
// TODO only for test purposes for now. This should be totally modified once
// tests are done
func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {

	fmt.Println("- start Populate Ledger")

	// Adding two problems
	problems := []Problem{
		Problem{ObjectType: "problem", StorageAddress: "97d10b05-d37f-4b8e-b701-9ebe93fd2161", SizeTrainDataset: 1, TestData: []string{"data_0"}},
		Problem{ObjectType: "problem", StorageAddress: "3fbfe8d5-bfa9-4924-90e2-b11a89faf735", SizeTrainDataset: 2, TestData: []string{"data_0"}},
	}
	for i, problem := range problems {
		problemAsBytes, _ := json.Marshal(problem)
		problemKey := fmt.Sprintf("problem_%d", i)
		APIstub.PutState(problemKey, problemAsBytes)
		fmt.Println("-- added", problem)
	}

	// Adding algorithms
	algos := []Item{
		Item{ObjectType: "algo", StorageAddress: "99o81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_1", Name: "test1"},
		Item{ObjectType: "algo", StorageAddress: "22m81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_1", Name: "test2"},
	}

	for i, algo := range algos {
		algoAsBytes, _ := json.Marshal(algo)
		algoKey := fmt.Sprintf("algo_%d", i)
		APIstub.PutState(algoKey, algoAsBytes)
		fmt.Println("-- added", algo)
		// composite key
		indexName := "algo~problem~key"
		algoProblemIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{algo.ObjectType, algo.Problem, algoKey})
		if err != nil {
			return shim.Error(err.Error())
		}
		value := []byte{0x00}
		APIstub.PutState(algoProblemIndexKey, value)
		// end of composite key
	}

	// Adding data
	datas := []Item{
		Item{ObjectType: "data", StorageAddress: "p9o81bfc-b5f4-4ba2-b81a-b464248f02f8", Problem: "problem_0", Name: ""},
		Item{ObjectType: "data", StorageAddress: "aao81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_0", Name: ""},
		Item{ObjectType: "data", StorageAddress: "bbo81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_1", Name: ""},
		Item{ObjectType: "data", StorageAddress: "e9o81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_1", Name: ""},
		Item{ObjectType: "data", StorageAddress: "92m81bfc-b5f4-4ba2-b81a-b464248f02d1", Problem: "problem_1", Name: ""},
	}
	for i, data := range datas {
		dataAsBytes, _ := json.Marshal(data)
		dataKey := fmt.Sprintf("data_%d", i)
		APIstub.PutState(dataKey, dataAsBytes)
		fmt.Println("-- added", data)
		// composite key
		indexName := "data~problem~key"
		dataProblemIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{data.ObjectType, data.Problem, dataKey})
		if err != nil {
			return shim.Error(err.Error())
		}
		value := []byte{0x00}
		APIstub.PutState(dataProblemIndexKey, value)
		// end of composite key
	}

	fmt.Println("- end Populate Ledger")

	return shim.Success(nil)
}

// =====================================================================================
// 								Problem registration
// =====================================================================================

// registerProblem is the smart contract to register a problem and associated test data
// Should be callable only by administrators
// Args (3 strings): storageAddress, sizeTrainDataset, testDataAddresses (addressData0, addressData1, ...)
func (s *SmartContract) registerProblem(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3: storageAddress, sizeTrainDataset, testDataAdresses (addressData0, addressData1, ...)")
	}
	//       0          		1		 	         2
	// "storageAddress", "sizeTrainDataset", "testDataAddresses"

	fmt.Println("- start create problem \n")

	// Clean input data
	sizeTrainDataset, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(err.Error())
	}
	testDataAddress := strings.Split(strings.Replace(args[2], " ", "", -1), ",")

	// Create Problem Key
	problemKey := "problem_" + uuid.NewV4().String()

	// Store test data
	testData, err := registerTestData(APIstub, problemKey, testDataAddress)
	if err != nil {
		return shim.Error(err.Error())
	}

	// Store Problem
	var problem = Problem{ObjectType: "problem", StorageAddress: args[0], SizeTrainDataset: sizeTrainDataset, TestData: testData}
	problemAsBytes, err := json.Marshal(problem)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = APIstub.PutState(problemKey, problemAsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("- end create problem")
	return shim.Success(nil)
}

// registerTestData stores in the orchestrator new test data
// given their addresses and Storage and their associated problem
func registerTestData(APIstub shim.ChaincodeStubInterface, problemKey string,
	testDataAddress []string) (testData []string, err error) {

	for _, sdata := range testDataAddress {
		// remove leading and trailing space and split address and owner
		sdata = strings.TrimSpace(sdata)
		// create data key
		dataKey := "data_" + uuid.NewV4().String()
		// store data
		_, err = storeItem(APIstub, dataKey, "data", sdata, problemKey, "")
		if err != nil {
			return testData, err
		}
		testData = append(testData, dataKey)
		fmt.Printf("-- test data %s registered \n", dataKey)
	}

	return testData, err
}

// ===================================================================================
// 						Item (data or algo) registration
// ===================================================================================

// storeItem stores an item (data or algo) in the chaincode
func storeItem(APIstub shim.ChaincodeStubInterface, itemKey string, itemType string,
	storageAddress string, problem string, name string) (item Item, err error) {

	item = Item{ObjectType: itemType, StorageAddress: storageAddress, Problem: problem, Name: name}

	itemAsBytes, err := json.Marshal(item)
	if err != nil {
		return item, err
	}
	// Store item
	err = APIstub.PutState(itemKey, itemAsBytes)
	if err != nil {
		return item, err
	}

	// Create composite key to enable (itemtype + problem + itemKey)-based range queries,
	// e.g. return all items associated with a given problem
	indexName := item.ObjectType + "~problem~key"
	itemProblemIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{item.ObjectType, item.Problem, itemKey})
	if err != nil {
		return item, err
	}
	emptyValue := []byte{0x00}
	err = APIstub.PutState(itemProblemIndexKey, emptyValue)
	if err != nil {
		return item, err
	}

	return item, err
}

// registerItem is the smart contract to register new data or algorithm,
// and create associated learnuplets
// Args (4 strings): itemType (data or algo), storageAddress, problem key on Orchestrator, name
func (s *SmartContract) registerItem(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 3: itemType, storage_address, problem")
	}

	fmt.Println("- start create " + args[0])

	// Create item key
	itemKey := args[0] + "_" + uuid.NewV4().String()
	// Store item in ledger and create composite key
	item, err := storeItem(APIstub, itemKey, args[0], args[1], args[2], args[3])
	if err != nil {
		return shim.Error(err.Error())
	}
	// Create associated learnuplet
	if args[0] == "algo" {
		fmt.Println("-- create associated learnuplets")
		algoLearnuplet(APIstub, itemKey, item)
	}
	if args[0] == "data" {
		fmt.Println("-- create associated learnuplets")
		data := []string{itemKey}
		dataLearnuplet(APIstub, data, item.Problem)
	}
	fmt.Println("- end create " + item.ObjectType)
	return shim.Success(nil)
}

// ================================================================================
//                            General object queries
// ================================================================================

// queryObject is a smart contract to query an object (algo/problem/data/learnuplet)
// Arg (1 string): object key on Orchestrator
func (s *SmartContract) queryObject(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: object key")
	}

	key := args[0]
	fmt.Println("- start looking for object with key ", key)
	payload, err := APIstub.GetState(key)
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("- end looking for object with key ", key)
	return shim.Success(payload)
}

// queryObjects is a smart contract to query all objects of a object type
// Arg (1 string): object type
func (s *SmartContract) queryObjects(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: object type")
	}

	objectType := args[0]
	fmt.Printf("- start looking for elements of type %s\n", objectType)
	resultsIterator, _ := APIstub.GetStateByRange(objectType+"_", objectType+"_z")
	var items []map[string]interface{}
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		var item map[string]interface{}
		err = json.Unmarshal(queryResponse.GetValue(), &item)
		if err != nil {
			return shim.Error(err.Error())
		}
		item["key"] = queryResponse.GetKey()
		items = append(items, item)
	}
	fmt.Printf("- end looking for elements of type %s\n", objectType)

	payload, err := json.Marshal(items)
	if err != nil {
		return shim.Error(err.Error())
	}

	//return
	return shim.Success(payload)
}

// ================================================================================
//                            Queries of items related to a problem
// ================================================================================

// getProblemItems is a function to get all items keys (data or algo) related to a problem
func getProblemItems(APIstub shim.ChaincodeStubInterface, problemKey string, itemType string) (itemKeys []string, err error) {

	fmt.Printf("--- looking for %s associated with %s \n", itemType, problemKey)

	// Query the itemType~problem~key index by problem
	// This will execute a key range query on all keys starting with 'itemType~problem'
	problemAssociatedItemIterator, err := APIstub.GetStateByPartialCompositeKey(itemType+"~problem~key", []string{itemType, problemKey})
	if err != nil {
		return itemKeys, err
	}
	defer problemAssociatedItemIterator.Close()

	// Iterate through result set and for each algo found
	for i := 0; problemAssociatedItemIterator.HasNext(); i++ {
		// Note that we don't get the value (2nd return variable), we'll just get the item name from the composite key
		responseRange, err := problemAssociatedItemIterator.Next()
		if err != nil {
			return itemKeys, err
		}

		// get the itemType, problem, and key from the composite key
		_, compositeKeyParts, err := APIstub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			return itemKeys, err
		}
		returnedProblem := compositeKeyParts[1]
		returnedKey := compositeKeyParts[2]

		fmt.Printf("--- found %s associated with %s \n", returnedKey, returnedProblem)

		// Put item key in slice
		itemKeys = append(itemKeys, returnedKey)
	}

	return itemKeys, nil
}

// queryProblemItems is the smart contract to get keys of items related to a problem
// Args (2 strings): "itemType" (data or algo), "problemKey" (e.g. problem_0)
func (s *SmartContract) queryProblemItems(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: item type and problem key")
	}

	itemType := args[0]
	problemKey := args[1]
	fmt.Printf("- start of query %s related to %s\n", itemType, problemKey)

	// Get slice with keys of items associated to the problem
	itemKeys, _ := getProblemItems(APIstub, problemKey, itemType)

	// Iterate through result set
	results := make(map[string]interface{})
	for _, key := range itemKeys {

		// Get algo given its key
		value, err := APIstub.GetState(key)
		if err != nil {
			return shim.Error(err.Error())
		}
		var ivalue interface{}
		err = json.Unmarshal(value, &ivalue)
		results[key] = ivalue
	}
	payload, err := json.Marshal(results)
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Printf("- end of query %s related to %s\n", itemType, problemKey)

	return shim.Success(payload)
}

// ================================================================================
//                            Learnuplet queries
// ================================================================================

// queryCompositeLearnuplet is a function to get all learnuplets
// having a given status (keyRequest: status, keyValue: todo, ...)
// or being linked with a given algo (keyRequest: algo, keyValue: algoKey)
func getCompositeLearnuplet(APIstub shim.ChaincodeStubInterface, keyRequest string,
	keyValue string) ([]byte, []map[string]interface{}, error) {

	compositeKeyIndex := "learnuplet~" + keyRequest + "~key"
	// Query the learnuplet~<compositeKey>~key index by <compositeKey>
	learnupletIterator, err := APIstub.GetStateByPartialCompositeKey(compositeKeyIndex, []string{"learnuplet", keyValue})
	if err != nil {
		return nil, nil, err
	}
	defer learnupletIterator.Close()

	var learnuplets []map[string]interface{}
	// Iterate through result set
	for i := 0; learnupletIterator.HasNext(); i++ {
		responseRange, err := learnupletIterator.Next()
		if err != nil {
			return nil, nil, err
		}

		// get the ObjectType, status, and key from the composite key
		_, compositeKeyParts, err := APIstub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			return nil, nil, err
		}
		returnedKey := compositeKeyParts[2]
		value, _ := APIstub.GetState(returnedKey)
		var learnuplet map[string]interface{}
		err = json.Unmarshal(value, &learnuplet)
		if err != nil {
			return nil, nil, err
		}
		learnuplet["key"] = returnedKey
		learnuplets = append(learnuplets, learnuplet)
	}

	payload, err := json.Marshal(learnuplets)
	if err != nil {
		return nil, nil, err
	}
	return payload, learnuplets, nil
}

// queryStatusLearnuplet is a smart contract to get all learnuplet with a specific status
// Arg (1 string): "status" ("todo", "pending", "done", "failed")
func (s *SmartContract) queryStatusLearnuplet(APIstub shim.ChaincodeStubInterface,
	args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: asked learnuplet status")
	}

	status := args[0]
	fmt.Println("- start looking for learnuplet with status ", status)

	payload, _, err := getCompositeLearnuplet(APIstub, "status", status)
	if err != nil {
		return shim.Error("Problem querying learnuplet depending on status " +
			status + " - " + err.Error())
	}
	fmt.Println("- end looking for learnuplet with status ", status)

	return shim.Success(payload)
}

// queryAlgoLearnuplet is a smart contract to get all learnuplets related to an algo
// Arg (1 string): "algoKey"
func (s *SmartContract) queryAlgoLearnuplet(APIstub shim.ChaincodeStubInterface,
	args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: algo key")
	}

	algo := args[0]
	fmt.Println("- start looking for learnuplet of algo ", algo)

	payload, _, err := getCompositeLearnuplet(APIstub, "algo", algo)
	if err != nil {
		return shim.Error("Problem querying learnuplet associated with algo " +
			algo + " - " + err.Error())
	}
	fmt.Println("- end looking for learnuplet of algo ", algo)
	return shim.Success(payload)
}

// ====================================================================
// Learnuplet creation - functions called when registering data or algo
// ====================================================================

// getRankAlgoLearnuplet is a function to get the last defined rank of the learnuplets
// associated to an algo, the algo address, and the address of the associated trained model
func getRankAlgoLearnuplet(APIstub shim.ChaincodeStubInterface, algoKey string) (rank int, algoAddress string, modelAddress string, err error) {
	fmt.Printf("--- looking for last learnuplet rank of %s \n", algoKey)

	modelAddress = ""
	algoAddress = ""
	// Query the learnuplet~algo~key index by algo
	algoAssociatedLearnupletIterator, err := APIstub.GetStateByPartialCompositeKey("learnuplet~algo~key", []string{"learnuplet", algoKey})
	if err != nil {
		return -1, algoAddress, modelAddress, err
	}
	defer algoAssociatedLearnupletIterator.Close()

	// Iterate through result set and for each learnuplet found
	var newRank int
	var perf, newPerf float64
	rank = 0
	for i := 0; algoAssociatedLearnupletIterator.HasNext(); i++ {
		responseRange, err := algoAssociatedLearnupletIterator.Next()
		if err != nil {
			return -1, algoAddress, modelAddress, err
		}

		// get the itemType, problem, and key from the composite key
		_, compositeKeyParts, err := APIstub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			return -1, algoAddress, modelAddress, err
		}
		returnedKey := compositeKeyParts[2]
		value, _ := APIstub.GetState(returnedKey)
		retrievedLearnuplet := Learnuplet{}
		err = json.Unmarshal(value, &retrievedLearnuplet)
		if err != nil {
			fmt.Errorf("Problem Unmarshal %s", returnedKey)
			return -1, algoAddress, modelAddress, err
		}
		if i == 0 {
			perf = retrievedLearnuplet.Perf
			algoAddress = retrievedLearnuplet.Algo[algoKey]
		}
		newRank = retrievedLearnuplet.Rank
		newPerf = retrievedLearnuplet.Perf
		// If better perf, update modelAddess
		if retrievedLearnuplet.Status == "done" && newPerf >= perf {
			perf = newPerf
			modelAddress = retrievedLearnuplet.ModelEndAddress
		}
		// If greater rank, update rank
		if newRank >= rank {
			rank = newRank
			if retrievedLearnuplet.Status != "done" {
				modelAddress = ""
			}
		}

		fmt.Printf("- for algo %s: found last rank %s and associated model %s \n", algoKey, rank, modelAddress)
	}

	return rank, algoAddress, modelAddress, nil
}

// getDataAddress is a function to get data addresses on Storage given their keys
func getDataAddress(APIstub shim.ChaincodeStubInterface, data []string) (dataAddresses map[string]string, err error) {
	dataAddresses = make(map[string]string)
	for _, idata := range data {
		value, err := APIstub.GetState(idata)
		if err != nil {
			fmt.Errorf("%s not found", idata)
			return dataAddresses, err
		}
		retrievedData := Item{}
		err = json.Unmarshal(value, &retrievedData)
		if err != nil {
			fmt.Errorf("Problem Unmarshal %s", idata)
			return dataAddresses, err
		}
		dataAddresses[idata] = retrievedData.StorageAddress
	}
	return dataAddresses, nil
}

// createLearnuplet is a function to create learnuplets given a set of train data, an algo,
// and parameter of the training related to the problem
func createLearnuplet(
	APIstub shim.ChaincodeStubInterface, trainData []string, szBatch int,
	testData []string, problem string, problemAddress string, algo string,
	algoAddress string, modelStartAddress string, startRank int) (err error) {

	err = nil
	nbFailLearnuplet := 0
	var batchData []string
	// create empty maps for performances
	var trainPerf, testPerf map[string]float64
	trainPerf = make(map[string]float64)
	testPerf = make(map[string]float64)
	// get testData addresses on Storage
	mapTestData, _ := getDataAddress(APIstub, testData)
	// For each mini-batch of data, create a learnuplet
	for i, j := 0, 0; i < len(trainData); i, j = i+szBatch, j+1 {
		if i+szBatch >= len(trainData) {
			batchData = trainData[i:]

		} else {
			batchData = trainData[i : i+szBatch]
		}
		j = j + startRank
		// if not first rank, modelStart is empty, will be filled once first rank has been computed
		// Generation of ModelEnd
		modelEndAddress := uuid.NewV4().String()
		learnupletModelStartAddress := ""
		if j == startRank {
			learnupletModelStartAddress = modelStartAddress
		}
		// get testData addresses on Storage
		mapBatchData, _ := getDataAddress(APIstub, batchData)
		// Learnuplet definition
		newLearnuplet := Learnuplet{
			ObjectType:        "learnuplet",
			Problem:           map[string]string{problem: problemAddress},
			Algo:              map[string]string{algo: algoAddress},
			ModelStartAddress: learnupletModelStartAddress,
			ModelEndAddress:   modelEndAddress,
			TrainData:         mapBatchData,
			TestData:          mapTestData,
			Worker:            "",
			Status:            "todo",
			Rank:              j,
			Perf:              0,
			TrainPerf:         trainPerf,
			TestPerf:          testPerf,
		}
		// Append to ledger
		learnupletKey := "learnuplet_" + uuid.NewV4().String()
		newLearnupletAsBytes, errL := json.Marshal(newLearnuplet)
		if errL != nil {
			fmt.Errorf("Problem marshaling ", learnupletKey)
			nbFailLearnuplet++
			continue
		}
		err = APIstub.PutState(learnupletKey, newLearnupletAsBytes)
		if errL != nil {
			fmt.Errorf("Problem putting state of ", learnupletKey)
			nbFailLearnuplet++
			continue
		}
		// Create composite key learnuplet~algo~key
		indexName := "learnuplet~algo~key"
		learnupletAlgoIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", algo, learnupletKey})
		value := []byte{0x00}
		APIstub.PutState(learnupletAlgoIndexKey, value)
		// Create composite key learnuplet~status~key
		indexName = "learnuplet~status~key"
		learnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "todo", learnupletKey})
		APIstub.PutState(learnupletStatusIndexKey, value)
		fmt.Printf("-- creation of %s ok \n", learnupletKey)

	}

	if nbFailLearnuplet > 0 {
		err = &errorUplet{nbFailLearnuplet, "failure in learnuplet creation"}
	}
	return err
}

// algoLearnuplet is a function to create learnuplet when new algo is registered.
// It calls the function createLearnuplet
func algoLearnuplet(APIstub shim.ChaincodeStubInterface, algoKey string, algo Item) error {

	problem := algo.Problem
	algoAddress := algo.StorageAddress

	// Find test data
	value, err := APIstub.GetState(problem)
	if err != nil {
		fmt.Errorf("%s not found", problem)
		return err
	}
	retrievedProblem := Problem{}
	err = json.Unmarshal(value, &retrievedProblem)
	if err != nil {
		fmt.Errorf("Problem Unmarshal %s", problem)
		return err
	}
	testData := retrievedProblem.TestData
	sizeTrainDataset := retrievedProblem.SizeTrainDataset
	problemAddress := retrievedProblem.StorageAddress
	// Find all active data associated to the same problem and remove test data
	trainData, _ := getProblemItems(APIstub, problem, "data")
	for i := 0; i < len(trainData); i++ {
		itraindata := trainData[i]
		for _, itestdata := range testData {
			if itraindata == itestdata {
				trainData = append(trainData[:i], trainData[i+1:]...)
				i--
				continue
			}
		}
	}
	sort.Strings(trainData)
	// Create learnuplets
	modelStartAddress := algo.StorageAddress
	err = createLearnuplet(
		APIstub, trainData, sizeTrainDataset, testData, problem, problemAddress,
		algoKey, algoAddress, modelStartAddress, 0)
	return err
}

// dataLearnuplet is a function to create learnuplet when new data is registered
// It calls the function createLearnuplet
func dataLearnuplet(APIstub shim.ChaincodeStubInterface, data []string, problem string) (err error) {

	nbFailLearnuplet := 0
	err = nil

	// Find test data
	value, err := APIstub.GetState(problem)
	if err != nil {
		fmt.Errorf("%s not found", problem)
		return err
	}
	retrievedProblem := Problem{}
	err = json.Unmarshal(value, &retrievedProblem)
	if err != nil {
		fmt.Errorf("Problem Unmarshal %s", problem)
		return err
	}
	testData := retrievedProblem.TestData
	sizeTrainDataset := retrievedProblem.SizeTrainDataset
	problemAddress := retrievedProblem.StorageAddress
	// Find all active algo associated to the same problem
	algoKeys, _ := getProblemItems(APIstub, problem, "algo")
	// For each algo, find the last rank and create learnuplet
	var rank int
	var algoAddress, modelAddress string
	for _, algoKey := range algoKeys {
		rank, algoAddress, modelAddress, err = getRankAlgoLearnuplet(APIstub, algoKey)
		if err != nil {
			nbFailLearnuplet = nbFailLearnuplet + err.(*errorUplet).number
			continue
		}
		err = createLearnuplet(
			APIstub, data, sizeTrainDataset, testData, problem, problemAddress,
			algoKey, algoAddress, modelAddress, rank+1)
		if err != nil {
			nbFailLearnuplet = nbFailLearnuplet + err.(*errorUplet).number
		}
	}
	if nbFailLearnuplet > 0 {
		err = &errorUplet{nbFailLearnuplet, "failure in learnuplet creation"}
	}
	return err
}

// ================================================================================
// 				Push from Compute: update learnuplets and preduplets
// ================================================================================

// setUpletWorker is a smart contract to set a worker for a learnuplet.
// It should be callable by Compute only.
// Args (2 strings): "upletKey", "worker"
// As for many other functions, this is for now a simple function, much more checks will be applied later...
func (s *SmartContract) setUpletWorker(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: upletKey, worker")
	}
	upletKey := args[0]
	worker := args[1]
	fmt.Printf("- start set worker for %s \n", upletKey)

	value, _ := APIstub.GetState(upletKey)
	retrievedLearnuplet := Learnuplet{}
	if value == nil {
		return shim.Error("No learnuplet with key - " + upletKey)
	}
	err := json.Unmarshal(value, &retrievedLearnuplet)
	if err != nil {
		return shim.Error("Problem Unmarshal uplet - " + err.Error())
	}
	if retrievedLearnuplet.Status == "pending" {
		return shim.Error("Uplet status is already pending...")
	} else {
		retrievedLearnuplet.Status = "pending"
		retrievedLearnuplet.Worker = worker
		learnupletAsBytes, err := json.Marshal(retrievedLearnuplet)
		if err != nil {
			return shim.Error("Problem (re)marshaling uplet - " + err.Error())
		}
		err = APIstub.PutState(upletKey, learnupletAsBytes)
		if err != nil {
			return shim.Error("Problem storing uplet - " + err.Error())
		}
		// Update associated composite key learnuplet~status~key
		indexName := "learnuplet~status~key"
		emptyValue := []byte{0x00}
		oldLearnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "todo", upletKey})
		APIstub.DelState(oldLearnupletStatusIndexKey)
		learnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "pending", upletKey})
		APIstub.PutState(learnupletStatusIndexKey, emptyValue)
	}
	fmt.Printf("- end set worker for %s \n", upletKey)
	return shim.Success(nil)
}

// reportLearn is a smart contract to set output of a learnuplet, updating the corresponding learnuplet.
// Args (5 strings): "upletKey", "status", "perf", "trainPerf" ("{\"train_data_i\": perf_i, \"train_data_j\": perf_j, ...}"),
// "testPerf" ("{\"test_data_i\": perf_j, \"test_data_j\": perf_j, ...}").
// As for many other functions, this is for now a simple function, much more checks will be applied later...
func (s *SmartContract) reportLearn(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5: uplet_key, status (failed / done), perf, train_perf ({\"train_data_i\": perf_i, \"train_data_j\": perf_j, ...}), test_perf ({\"train_data_i\": perf_i, \"train_data_j\": perf_j, ...}")
	}

	upletKey := args[0]
	fmt.Printf("- start Report learning phase of %s \n", upletKey)
	// Get learnuplet
	value, _ := APIstub.GetState(upletKey)
	retrievedLearnuplet := Learnuplet{}
	err := json.Unmarshal(value, &retrievedLearnuplet)
	if err != nil {
		return shim.Error(fmt.Sprintf("Error Unmarshal uplet %s - %s", upletKey, err))
	}

	// Update learnuplet status and model end value
	retrievedLearnuplet.Status = args[1]

	// Deal with the status "failed" case
	if retrievedLearnuplet.Status == "failed" {
		// Store updated learnuplet
		learnupletAsBytes, err := json.Marshal(retrievedLearnuplet)
		if err != nil {
			return shim.Error(fmt.Sprintf("Error re-Unmarshal uplet %s - %s", upletKey, err))
		}
		err = APIstub.PutState(upletKey, learnupletAsBytes)
		if err != nil {
			return shim.Error("Problem storing learnuplet - " + err.Error())
		}
		// Update associated composite key learnuplet~status~key
		indexName := "learnuplet~status~key"
		emptyValue := []byte{0x00}
		oldLearnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "pending", upletKey})
		APIstub.DelState(oldLearnupletStatusIndexKey)
		learnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "failed", upletKey})
		APIstub.PutState(learnupletStatusIndexKey, emptyValue)

		fmt.Printf("- end Report learning phase of %s \n", upletKey)
		return shim.Success(nil)
	}

	// Unmarhall perf data
	var perf float64
	var trainPerf, testPerf map[string]float64
	if args[2] != "" {
		perf, err = strconv.ParseFloat(args[2], 64)
		if err != nil {
			return shim.Error("Error parsing performance - " + err.Error())
		}
		// TODO check data addresses correspond to train and test data
		fmt.Printf("before train")
		fmt.Println(args[3])
		err = json.Unmarshal([]byte(args[3]), &trainPerf)
		if err != nil {
			return shim.Error("Error un-marshalling train perf - " + err.Error())
		}
		fmt.Printf("before train")
		err = json.Unmarshal([]byte(args[4]), &testPerf)
		if err != nil {
			return shim.Error("Error un-marshalling test perf - " + err.Error())
		}
	}

	// Update Learnuplet Perf results
	retrievedLearnuplet.Perf = perf
	retrievedLearnuplet.TrainPerf = trainPerf
	retrievedLearnuplet.TestPerf = testPerf

	// Store updated learnuplet
	learnupletAsBytes, err := json.Marshal(retrievedLearnuplet)
	if err != nil {
		return shim.Error("Problem (re)marshaling learnuplet - " + err.Error())
	}
	err = APIstub.PutState(upletKey, learnupletAsBytes)
	if err != nil {
		return shim.Error("Problem storing learnuplet - " + err.Error())
	}

	// Update associated composite key learnuplet~status~key
	indexName := "learnuplet~status~key"
	emptyValue := []byte{0x00}
	oldLearnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "pending", upletKey})
	APIstub.DelState(oldLearnupletStatusIndexKey)
	learnupletStatusIndexKey, _ := APIstub.CreateCompositeKey(indexName, []string{"learnuplet", "done", upletKey})
	APIstub.PutState(learnupletStatusIndexKey, emptyValue)

	// Update model start of learnuplet of next rank
	var algoKey string
	for k := range retrievedLearnuplet.Algo {
		algoKey = k
	}
	_, algoLearnuplet, err := getCompositeLearnuplet(APIstub, "algo", algoKey)
	if err != nil {
		return shim.Error("Problem getting learnuplets of same algo - " + err.Error())
	}
	if len(algoLearnuplet) > 1 {
		var nextLearnupletKey string
		bestPerf := perf
		newModelStart := retrievedLearnuplet.ModelEndAddress
		for _, learnuplet := range algoLearnuplet {
			// Type conversion
			// TOFIX: bad practice here
			rank, _ := learnuplet["rank"].(float64)
			key, _ := learnuplet["key"].(string)
			perf, _ := learnuplet["perf"].(float64)
			status, _ := learnuplet["status"].(string)
			modelEnd, _ := learnuplet["modelEnd"].(string)

			if int(rank) == retrievedLearnuplet.Rank+1 {
				nextLearnupletKey = key
			}
			if perf > bestPerf && status == "done" {
				newModelStart = modelEnd
				bestPerf = perf
			}
		}
		value, _ := APIstub.GetState(nextLearnupletKey)
		nextUplet := Learnuplet{}
		err := json.Unmarshal(value, &nextUplet)
		if err != nil {
			return shim.Error(fmt.Sprintf("Error Unmarshal next uplet - %s", err))
		}
		nextUplet.ModelStartAddress = newModelStart

		// Store updated learnuplet
		nextUpletAsBytes, err := json.Marshal(nextUplet)
		if err != nil {
			return shim.Error("Problem (re)marshaling next learnuplet - " + err.Error())
		}
		err = APIstub.PutState(nextLearnupletKey, nextUpletAsBytes)
		if err != nil {
			return shim.Error("Problem storing next learnuplet - " + err.Error())
		}

	}
	fmt.Printf("- end Report learning phase of %s \n", upletKey)
	return shim.Success(nil)
}

// ==============================================
// MAIN FUNCTION. Only relevant in unit test mode
// ==============================================
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
