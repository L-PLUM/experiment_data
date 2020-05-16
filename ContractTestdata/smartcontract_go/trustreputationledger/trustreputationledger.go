/*
Package main is the entry point of the hyperledger fabric chaincode and implements the shim.ChaincodeStubInterface
*/
/*
Created by Valerio Mattioli @ HES-SO (valeriomattioli580@gmail.com
*/
package main

import (
	"bytes"
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	a "github.com/pavva91/assets"
	gen "github.com/pavva91/generalcc"
	"strconv"

	// a "github.com/pavva91/trustreputationledger/assets"
	// gen "github.com/pavva91/trustreputationledger/generalcc"
	// in "github.com/pavva91/trustreputationledger/invokeapi"
	in "github.com/pavva91/invokeapi"
)

var log = shim.NewLogger("trustreputationledger")

const(
	InitLedger    = "InitLedger"
	CreateLeafService = "CreateLeafService"
	CreateCompositeService = "CreateCompositeService"
	CreateService = "CreateService"
	CreateAgent   = "CreateAgent"
	CreateServiceAgentRelation = "CreateServiceAgentRelation"
	CreateServiceAgentRelationAndReputation = "CreateServiceAgentRelationAndReputation"
	CreateServiceAndServiceAgentRelationWithStandardValue = "CreateServiceAndServiceAgentRelationWithStandardValue"
	CreateServiceAndServiceAgentRelation                  = "CreateServiceAndServiceAgentRelation"
	GetServiceHistory                                     = "GetServiceHistory"
	GetService                                            = "GetService"
	GetAgent                                              = "GetAgent"
	GetServiceRelationAgent                               = "GetServiceRelationAgent"
	GetServiceNotFoundError                               = "GetServiceNotFoundError"
	GetAgentNotFoundError                                 = "GetAgentNotFoundError"
	ByService                                             = "byService"
	ByAgent                                               = "byAgent"
	GetAgentsByService                                    = "GetAgentsByService"
	GetServicesByAgent                                    = "GetServicesByAgent"
	GetServicesByName                                     = "GetServicesByName"
	DeleteService                                         = "DeleteService"
	DeleteAgent                                           = "DeleteAgent"
	DeleteServiceRelationAgent 							  = "DeleteServiceRelationAgent"
	ModifyServiceRelationAgentCost 						  = "ModifyServiceRelationAgentCost"
	ModifyServiceRelationAgentTime						  = "ModifyServiceRelationAgentTime"
	CreateActivity                                        = "CreateActivity"
	GetActivity                                           = "GetActivity"
	ByExecutedServiceTxId                                 = "byExecutedServiceTxId"
	ByDemanderExecuter                                    = "byDemanderExecuter"
	GetActivitiesByServiceTxId                            = "GetActivitiesByServiceTxId"
	GetActivitiesByDemanderExecuterTimestamp              = "GetActivitiesByDemanderExecuterTimestamp"
	CreateReputation                                      = "CreateReputation"
	ModifyReputationValue                                 = "ModifyReputationValue"
	ModifyOrCreateReputationValue                         = "ModifyOrCreateReputationValue"
	GetReputation = "GetReputation"
	GetReputationNotFoundError = "GetReputationNotFoundError"
	ByAgentServiceRole = "byAgentServiceRole"
	GetReputationsByAgentServiceRole = "GetReputationsByAgentServiceRole"
	Write = "Write"
	Read = "Read"
	ReadEverything = "ReadEverything"
	GetHistory = "GetHistory"
	GetReputationHistory = "GetReputationHistory"
	AllStateDB = "AllStateDB"
	GetValue = "GetValue"
	HelloWorld = "HelloWorld"

)



// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
	testMode bool
}

// ============================================================================================================================
// Main
// ============================================================================================================================
func main() {
	simpleChaincode := new(SimpleChaincode)
	simpleChaincode.testMode = false
	err := shim.Start(simpleChaincode)
	if err != nil {
		fmt.Printf("Error starting Simple chaincode - %s", err)
	}
}

// ============================================================================================================================
// Init - initialize the chaincode
// ============================================================================================================================
// The Init method is called when the Smart Contract "trustreputationledger" is instantiated by the blockchain network
// Best practice is to have any Ledger initialization in separate function -- see InitLedger()
// ============================================================================================================================
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	// TEST BEHAVIOUR
	if t.testMode {
		a.InitLedger(stub)
	}
	// NORMAL BEHAVIOUR
	return shim.Success(nil)
}

// ============================================================================================================================
// Invoke - Our entry point for Invocations
// ============================================================================================================================
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	log.Info("########### INVOKE: " + function + " ###########")

	// Route to the appropriate handler function to interact with the ledger appropriately
	switch function {
	// AGENT, SERVICE, AGENT SERVICE RELATION INVOKES

	// CREATE:
	case InitLedger:
		response := a.InitLedger(stub)
		return response
	case CreateLeafService:
		return in.CreateLeafService(stub, args)
	case CreateCompositeService:
		return in.CreateCompositeService(stub, args)
	case CreateService:
		return in.CreateService(stub, args)
	case CreateAgent:
		return in.CreateAgent(stub, args)
	case CreateServiceAgentRelation:
		// Already with reference integrity controls (service already exist, agent already exist, relation don't already exist)
		// NO REPUTATION INITIALIZATION
		return in.CreateServiceAgentRelation(stub, args)
	case CreateServiceAgentRelationAndReputation:
		// Already with reference integrity controls (service already exist, agent already exist, relation don't already exist)
		// Standard reputation value (6) from inside
		return in.CreateServiceAgentRelationAndReputation(stub, args)
	case CreateServiceAndServiceAgentRelationWithStandardValue:
		// If service doesn't exist it will create with a standard value of reputation defined inside the function
		return in.CreateServiceAndServiceAgentRelationWithStandardValue(stub, args)
	case CreateServiceAndServiceAgentRelation:
		// If service doesn't exist it will create
		return in.CreateServiceAndServiceAgentRelation(stub, args)

		// GET:
	case GetServiceHistory:
		return a.GetServiceHistory(stub, args)
	case GetService:
		return in.QueryService(stub,args)
	case GetAgent:
		return in.QueryAgent(stub,args)
	case GetServiceRelationAgent:
		return in.QueryServiceRelationAgent(stub, args)

		// GET NOT FOUND (DEPRECATED):
	case GetServiceNotFoundError:
		return in.QueryServiceNotFoundError(stub, args)
	case GetAgentNotFoundError:
		return in.QueryAgentNotFoundError(stub, args)


		// RANGE QUERY:
	case ByService:
		return in.QueryByServiceAgentRelation(stub, args)
	case ByAgent:
		return in.QueryByAgentServiceRelation(stub, args)
	case GetAgentsByService:
		// also with only one record result return always a JSONArray
		return in.GetServiceRelationAgentByServiceWithCostAndTime(stub, args)
	case GetServicesByAgent:
		// also with only one record result return always a JSONArray
		return in.GetServiceRelationAgentByAgentWithCostAndTimeNotFoundError(stub, args)
	case GetServicesByName:
		return in.QueryByServiceName(stub,args)

		// DELETE:
	case DeleteService:
		return a.DeleteService(stub, args)
	case DeleteAgent:
		return a.DeleteAgent(stub, args)
	case DeleteServiceRelationAgent:
		return in.DeleteServiceRelationAgentAndIndexes(stub, args)

		// MODIFY:
	case ModifyServiceRelationAgentCost:
		return in.ModifyServiceRelationAgentCost(stub,args)
	case ModifyServiceRelationAgentTime:
		return in.ModifyServiceRelationAgentTime(stub,args)

	// ACTIVITY INVOKES
	// CREATE:
	case CreateActivity:
		return in.CreateActivity(stub, args)
		// GET:
	case GetActivity:
		return in.QueryActivity(stub, args)
		// RANGE QUERY:
	case ByExecutedServiceTxId:
		return in.QueryByExecutedServiceTx(stub, args)
	case ByDemanderExecuter:
		return in.QueryByDemanderExecuter(stub, args)
	case GetActivitiesByServiceTxId:
		// also with only one record result return always a JSONArray
		return in.GetActivitiesByExecutedServiceTxId(stub, args)
	case GetActivitiesByDemanderExecuterTimestamp:
		// also with only one record result return always a JSONArray
		return in.GetActivitiesByDemanderExecuterTimestamp(stub, args)

	// REPUTATION INVOKES
	// CREATE:
	case CreateReputation:
		return in.CreateReputation(stub, args)
		// MODIFTY:
	case ModifyReputationValue:
		return in.ModifyReputationValue(stub, args)
	case ModifyOrCreateReputationValue:
		return in.ModifyOrCreateReputationValue(stub, args)

		// GET:
	case GetReputation:
		return in.QueryReputation(stub,args)
	case GetReputationNotFoundError:
		return in.QueryReputationNotFoundError(stub, args)
		// RANGE QUERY:
	case ByAgentServiceRole:
		return in.QueryByAgentServiceRole(stub, args)
	case GetReputationsByAgentServiceRole:
		// also with only one record result return always a JSONArray
		return in.GetReputationsByAgentServiceRole(stub, args)

		// GENERAL INVOKES
	case Write:
		return gen.Write(stub, args)
	case Read:
		return gen.Read(stub, args)
	case ReadEverything:
		return a.ReadEverything(stub)
	case GetHistory:
		// Get Block Chain Transaction Log of that assetId
		return gen.GetHistory(stub, args)
	case GetReputationHistory:
		return in.GetReputationHistory(stub, args)
	case AllStateDB:
		// All Records Level DB (World State DB)
		return gen.ReadAllStateDB(stub)
	case GetValue:
		return gen.GetValue(stub, args)
	case HelloWorld:
		log.Info("Hello, lorem ipsum")
		var buffer bytes.Buffer
		buffer.WriteString("[{\"Hello\":\"HelloWorld\"}]")
		// TRY SET EVENT, OK WORKS
		transientMap, _ := stub.GetTransient()
		transientData, ok := transientMap["event"]
		log.Info("OK: " + strconv.FormatBool(ok))
		log.Info(transientMap)
		log.Info(transientData)
		eventPayload:="EventHello"
		payloadAsBytes := []byte(eventPayload)
		eventError := stub.SetEvent("HelloEvent",payloadAsBytes)
		if eventError != nil {
			log.Info(eventError.Error())
		}else {
			log.Info("Event Create Service OK")
		}

		return shim.Success(buffer.Bytes())
	default:
		// Error Output
		log.Info("Received unknown in function Name - " + function)
		return shim.Error("Invalid Smart Contract function Name.")
	}


}

// ============================================================================================================================
// Query - legacy function
// ============================================================================================================================
func (t *SimpleChaincode) Query(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Error("Unknown supported call - Query()")
}
