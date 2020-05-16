/*
Copyright TokenID 2017 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

// IdentityChainCode  Chaincode implementation
type IdentityChainCode struct {
}

type Identity struct {
	ProviderEnrollmentID     string `json:"providerEnrollmentID"`     //Mundane identity ID - Identity Provider given
	IdentityCode             string `json:"identityCode"`             //Issuer given identity ID
	IdentityTypeCode         string `json:"identityTypeCode"`         //Virtual Identity Type Code (Issuer defined) - gotten from TCert
	IssuerID                 string `json:"issuerID"`                 //Virtual Identity IssuerID - gotten from TCert
	IssuerCode               string `json:"issuerCode"`               //Virtual Identity Issuer Code - gotten from TCert
	IssuerOrganization       string `json:"issuerOrganization"`       //Virtual Identity Issuer Organization - gotten from TCert or Ecert
	EncryptedPayload         string `json:"encryptedPayload"`         // Encrypted Virtual Identity (EVI) payload
	EncryptedKey             string `json:"encryptedKey"`             //Symmetric encryption key for EVI payload encrypted with the public key
	MetaData                 string `json:"metaData"`                 //Miscellanous Identity Information - ONLY NON-SENSITIVE IDENTITY INFORMATION/ATTRIBUTES SHOULD BE ADDED
	EncryptedAttachmentURI   string `json:"encryptedAttachmentURI"`   //Encrypted URIs to Virtual Identity Document e.g. Scanned document image
	CreatedBy                string `json:"createdBy"`                //Identity Creator
	CreatedOnTxTimestamp     int64  `json:"createdOnTxTimestamp"`     //Created on Timestamp -   which is currently taken from the peer receiving the transaction. Note that this timestamp may not be the same with the other peers' time.
	LastUpdatedBy            string `json:"lastUpdatedBy"`            //Last Updated By
	LastUpdatedOnTxTimestamp int64  `json:"lastUpdatedOnTxTimestamp"` //Last Updated On Timestamp -   which is currently taken from the peer receiving the transaction. Note that this timestamp may not be the same with the other peers' time.
	IssuerVerified           bool   `json:"issuerVerified"`           //Identity verified by Issuer
}

type IdentityMin struct {
	ProviderEnrollmentID     string `json:"providerEnrollmentID"`
	IdentityCode             string `json:"identityCode"`
	IdentityTypeCode         string `json:"identityTypeCode"`
	IssuerCode               string `json:"issuerCode"`
	IssuerID                 string `json:"issuerID"`
	IssuerOrganization       string `json:"issuerOrganization"`
	CreatedBy                string `json:"createdBy"`
	CreatedOnTxTimestamp     int64  `json:"createdOnTxTimestamp"`
	LastUpdatedBy            string `json:"lastUpdatedBy"`
	LastUpdatedOnTxTimestamp int64  `json:"lastUpdatedOnTxTimestamp"`
	IssuerVerified           bool   `json:"issuerVerified"`
}

//States key prefixes
const PUBLIC_KEY_PREFIX = "_PK"
const IDENTITY_TBL_PREFIX = "_TABLE"
const ISSUER_TBL_NAME = "ISSUERS_TABLE"

//"EVENTS"
const EVENT_NEW_IDENTITY_ENROLLED = "EVENT_NEW_IDENTITY_ENROLLED"
const EVENT_NEW_IDENTITY_ISSUED = "EVENT_NEW_IDENTITY_ISSUED"
const EVENT_NEW_ISSUER_ENROLLED = "EVENT_NEW_ISSUER_ENROLLED"

//ROLES
const ROLE_ISSUER = "Issuer"
const ROLE_PROVIDER = "Provider"
const ROLE_USER = "User"

var logger = shim.NewLogger("IdentityChaincode")

// ============================================================================================================================
// Main
// ============================================================================================================================
func main() {
	err := shim.Start(new(IdentityChainCode))
	if err != nil {
		fmt.Printf("Error starting Identity ChainCode: %s", err)
	}
}

//=================================================================================================================================
//	 Ping Function
//=================================================================================================================================
//	 Pings the peer to keep the connection alive
//=================================================================================================================================
func (t *IdentityChainCode) Ping(stub shim.ChaincodeStubInterface) ([]byte, error) {
	return []byte("Hi, I'm up!"), nil
}

//=================================================================================================================================
//Initializes chaincode when deployed
//=================================================================================================================================
func (t *IdentityChainCode) Init(stub shim.ChaincodeStubInterface, function string, args []string) ([]byte, error) {
	if len(args) != 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 2 -> [providerEnrollmentID, identityPublicKey]")
	}
	//Create initial identity table
	fmt.Println("Initializing Identity for ->" + args[0])
	val, err := t.InitIdentity(stub, args, true)
	if err != nil {
		fmt.Println(err)
	}
	return val, err
}

//=================================================================================================================================
//Initializes the Identity and sets the default states
//=================================================================================================================================
func (t *IdentityChainCode) InitIdentity(stub shim.ChaincodeStubInterface, args []string, isDeploymentCall bool) ([]byte, error) {

	if len(args) < 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 2 -> [providerEnrollmentID , identityPublicKey]")
	}

	//Check if user is provider
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}
	isProv := isProvider(callerDetails)
	if isProv == false && isDeploymentCall == false { //If its a deployment call, TCert info will not be transmitted to other peers and the role won't be known
		return nil, errors.New("Access Denied")
	}

	var providerEnrollmentID, identityPublicKey string
	providerEnrollmentID = args[0]
	identityPublicKey = args[1]

	//Verify that Enrollment ID and Pubic key is not null
	if providerEnrollmentID == "" || identityPublicKey == "" {
		return nil, errors.New("Provider Enrollment ID or Public key cannot be null")
	}

	//Add Public key state
	existingPKBytes, err := stub.GetState(providerEnrollmentID + PUBLIC_KEY_PREFIX)

	if err == nil && existingPKBytes != nil {
		return nil, fmt.Errorf("Public Key for " + providerEnrollmentID + " already exists ")
	}
	fmt.Println(identityPublicKey)

	pkBytes := []byte(identityPublicKey)

	//Validate Public key is PEM format
	err = validatePublicKey(pkBytes)

	if err != nil {
		return nil, fmt.Errorf("Bad Public Key -> Public key must be in PEM format - [%v]", err)
	}

	//Set Public key state
	err = stub.PutState(providerEnrollmentID+PUBLIC_KEY_PREFIX, pkBytes)

	if err != nil {
		return nil, fmt.Errorf("Failed inserting public key, [%v] -> "+providerEnrollmentID, err)
	}

	//Create Identity Table
	err = t.createIdentityTable(stub, providerEnrollmentID)
	if err != nil {
		return nil, fmt.Errorf("Failed creating Identity Table, [%v] -> "+providerEnrollmentID, err)
	}

	//Broadcast 'New Enrollment'  Event with enrollment ID
	err = stub.SetEvent(EVENT_NEW_IDENTITY_ENROLLED, []byte(providerEnrollmentID))

	if err != nil {
		return nil, fmt.Errorf("Failed to broadcast enrollment event, [%v] -> "+providerEnrollmentID, err)
	}

	return []byte("Enrollment Successful"), nil
}

//=================================================================================================================================
//	 Entry point to invoke a chaincode function
//=================================================================================================================================
func (t *IdentityChainCode) Invoke(stub shim.ChaincodeStubInterface, function string, args []string) ([]byte, error) {
	fmt.Println("invoke is running " + function)

	var bytes []byte
	var err error

	fmt.Println("function -> " + function)

	// Handle different functions
	if function == "init" { //initialize the chaincode state, used as reset
		bytes, err = t.Init(stub, "init", args)
	} else if function == "addIdentity" {
		bytes, err = t.AddIdentity(stub, args)
	} else if function == "removeIdentity" {
		bytes, err = t.RemoveIdentity(stub, args)
	} else {
		fmt.Println("invoke did not find func: " + function) //error

		return nil, errors.New("Received unknown function invocation: " + function)
	}
	if err != nil {
		fmt.Println(err)
	}
	return bytes, err

}

//=================================================================================================================================
//	 Query is our entry point for queries
//=================================================================================================================================
func (t *IdentityChainCode) Query(stub shim.ChaincodeStubInterface, function string, args []string) ([]byte, error) {
	fmt.Println("query is running " + function)

	// Handle different functions

	var bytes []byte
	var err error

	fmt.Println("function -> " + function)
	if function == "ping" {
		bytes, err = t.Ping(stub)

	} else if function == "getIdentities" {
		bytes, err = t.GetIdentities(stub, args)

	} else if function == "getIdentity" {
		bytes, err = t.GetIdentity(stub, args)
	} else if function == "getPublicKey" {
		bytes, err = t.GetPublicKey(stub, args)
	} else {
		fmt.Println("query did not find func: " + function) //error
		return nil, errors.New("Received unknown function query: " + function)
	}
	if err != nil {
		fmt.Println(err)
	}
	return bytes, err

}

//=================================================================================================================================
//	 Create Identity table
//=================================================================================================================================

//Create Identity Table
func (t *IdentityChainCode) createIdentityTable(stub shim.ChaincodeStubInterface, enrollmentID string) error {

	var tableName string

	tableName = enrollmentID + IDENTITY_TBL_PREFIX

	// Create Identity table
	tableErr := stub.CreateTable(tableName, []*shim.ColumnDefinition{
		&shim.ColumnDefinition{Name: "ProviderEnrollmentID", Type: shim.ColumnDefinition_STRING, Key: false},
		&shim.ColumnDefinition{Name: "IdentityCode", Type: shim.ColumnDefinition_STRING, Key: true},
		&shim.ColumnDefinition{Name: "IdentityTypeCode", Type: shim.ColumnDefinition_STRING, Key: true},
		&shim.ColumnDefinition{Name: "EncryptedPayload", Type: shim.ColumnDefinition_BYTES, Key: false},
		&shim.ColumnDefinition{Name: "IssuerCode", Type: shim.ColumnDefinition_STRING, Key: true},
		&shim.ColumnDefinition{Name: "IssuerID", Type: shim.ColumnDefinition_STRING, Key: true},
		&shim.ColumnDefinition{Name: "IssuerOrganization", Type: shim.ColumnDefinition_STRING, Key: false},
		&shim.ColumnDefinition{Name: "EncryptedKey", Type: shim.ColumnDefinition_BYTES, Key: false},
		&shim.ColumnDefinition{Name: "Metadata", Type: shim.ColumnDefinition_STRING, Key: false},
		&shim.ColumnDefinition{Name: "IssuerVerified", Type: shim.ColumnDefinition_BOOL, Key: false},
		&shim.ColumnDefinition{Name: "EncryptedAttachmentURI", Type: shim.ColumnDefinition_BYTES, Key: false},
		&shim.ColumnDefinition{Name: "CreatedBy", Type: shim.ColumnDefinition_STRING, Key: false},
		&shim.ColumnDefinition{Name: "CreatedOnTxTimeStamp", Type: shim.ColumnDefinition_INT64, Key: false},
		&shim.ColumnDefinition{Name: "LastUpdatedBy", Type: shim.ColumnDefinition_STRING, Key: false},
		&shim.ColumnDefinition{Name: "lastUpdatedOnTxTimeStamp", Type: shim.ColumnDefinition_INT64, Key: false},
	})
	if tableErr != nil {
		return fmt.Errorf("Failed creating IdentityTable table, [%v] -> "+enrollmentID, tableErr)
	}
	return nil
}

//=================================================================================================================================
//	 Add New Issued Identity
//=================================================================================================================================
func (t *IdentityChainCode) AddIdentity(stub shim.ChaincodeStubInterface, identityParams []string) ([]byte, error) {

	//Get Caller Details
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}

	//Check if Tcert has a valid role
	validRoles := hasValidRoles(callerDetails)

	if validRoles == false {
		return nil, fmt.Errorf("Access denied. Unknown role in Tcert -> " + callerDetails.role)
	}

	if len(identityParams) < 10 {
		return nil, errors.New("Incomplete number of arguments. Expected 10 -> [ProviderEnrollmentID, IdentityCode, IdentityTypeCode, EncryptedIdentityPayload, EncryptionKey, IssuerID,  MetaData, EncryptedAttachmentURI, IssuerCode, IssuerOrganization ]")
	}

	if strings.EqualFold(callerDetails.role, ROLE_ISSUER) == false && strings.EqualFold(callerDetails.role, ROLE_PROVIDER) == false {
		return nil, errors.New("Access Denied. Not a provider or Issuer")
	}
	isProvider := isProvider(callerDetails)

	var issuerCode, issuerOrganization, issuerID string

	issuerVerified := false

	//For providers, issuer details are required to be submitted
	//Parameters should be in the order -> [ProviderEnrollmentID, IdentityCode, IdentityTypeCode, EncryptedIdentityPayload, EncryptionKey, IssuerID,  MetaData, EncryptedAttachmentURI, IssuerCode, IssuerOrganization ]
	if isProvider == true {
		//Check for empty mandatory fields (first 5 fields)
		for i := 0; i < 6; i++ {
			if identityParams[i] == "" {
				return nil, errors.New("One or more mandatory fields is empty. Mandatory fields are the first 5 which are ProviderEnrollmentID, IdentityCode, IdentityTypeCode, IdentityPayload and IssuerID")
			}
		}
		issuerID = identityParams[5]
		issuerCode = identityParams[8]
		issuerOrganization = identityParams[9]
		
	} else {
		//Issuer details are gotten from Transaction Certificate
		//Check for empty mandatory fields
		for i := 0; i < 5; i++ {
			if identityParams[i] == "" {
				return nil, errors.New("One or more mandatory fields is empty. Mandatory fields are the first 4 which are ProviderEnrollmentID, IdentityCode, IdentityTypeCode  and IdentityPayload")
			}
		}
		issuerID = callerDetails.issuerID
		issuerCode = callerDetails.issuerCode
		issuerOrganization = callerDetails.organization
		//Verified, since the identtity is created by the issuer
		issuerVerified = true
	}

	if isProvider == false && (issuerCode == "" || issuerID == "" || issuerOrganization == "") {
		return nil, errors.New("One of the required fields are not available in transaction certificate [issuerCode, issuerID, organization] -> [" + issuerID + ", " + issuerID + "," + issuerOrganization + "]")
	}

	//Validate Identity Type code
	identityTypeCode := identityParams[2]
	isValid, err := validateIdentityTypeCode(identityTypeCode)
	if err != nil {
		fmt.Println(err)
		return nil, fmt.Errorf("Could not validate identityTypeCode -> [%v]", err)
	}
	if isValid == false {
		return nil, fmt.Errorf("Invalid identityTypeCode. Must contain only AlphaNumeric characters, minimum length of 4 and maximum of 10")
	}

	providerEnrollmentID := identityParams[0]
	identityCode := identityParams[1]

	//Encrypted Payload
	encryptedPayload, err := decodeBase64(identityParams[3])
	if err != nil {
		return nil, fmt.Errorf("Bad Encrypted Payload [%v] ", err)
	}

	//Encrypted Key
	encryptedKey, err := decodeBase64(identityParams[4])
	if err != nil {
		return nil, fmt.Errorf("Bad Encrypted Key [%v] ", err)
	}

	//Encrypted Attachment
	encryptedAttachmentURIString := identityParams[7]
	var encryptedAttachmentURI []byte
	if encryptedAttachmentURIString != "" {
		encryptedAttachmentURI, err = decodeBase64(identityParams[7])
		if err != nil {
			return nil, fmt.Errorf("Bad Encrypted AttachmentURI [%v] ", err)
		}

	}

	//Check if similar Identity exists
	var key2columns []shim.Column
	key2Col1 := shim.Column{Value: &shim.Column_String_{String_: identityCode}}
	//key2Col2 := shim.Column{Value: &shim.Column_String_{String_: identityTypeCode}}
	//key2Col3 := shim.Column{Value: &shim.Column_String_{String_: issuerID}}
	key2columns = append(key2columns, key2Col1)

	tableName := providerEnrollmentID + IDENTITY_TBL_PREFIX

	rows, err := getRows(&stub, tableName, key2columns)
	if err != nil {
		return nil, fmt.Errorf("Error checking for existing identity, [%v]", err)
	}

	if len(rows) > 0 {
		rowPointer := rows[0]
		row := *rowPointer
		return nil, fmt.Errorf("Identity already exists -> " + row.Columns[1].GetString_() + "|" + row.Columns[2].GetString_() + "|" + row.Columns[5].GetString_())
	}
	//Get Transaction TimeStamp
	stampPointer, err := stub.GetTxTimestamp()

	if err != nil {
		return nil, fmt.Errorf("Could not get Transaction timestamp from peer, [%v]", err)

	}

	//Save Identity
	timestamp := *stampPointer
	_, err = stub.InsertRow(
		tableName,
		shim.Row{
			Columns: []*shim.Column{
				&shim.Column{Value: &shim.Column_String_{String_: providerEnrollmentID}},
				&shim.Column{Value: &shim.Column_String_{String_: identityCode}},
				&shim.Column{Value: &shim.Column_String_{String_: identityTypeCode}},
				&shim.Column{Value: &shim.Column_Bytes{Bytes: encryptedPayload}},
				&shim.Column{Value: &shim.Column_String_{String_: issuerCode}},
				&shim.Column{Value: &shim.Column_String_{String_: issuerID}},
				&shim.Column{Value: &shim.Column_String_{String_: issuerOrganization}},
				&shim.Column{Value: &shim.Column_Bytes{Bytes: encryptedKey}},
				&shim.Column{Value: &shim.Column_String_{String_: identityParams[6]}},
				&shim.Column{Value: &shim.Column_Bool{Bool: issuerVerified}},
				&shim.Column{Value: &shim.Column_Bytes{Bytes: encryptedAttachmentURI}},
				&shim.Column{Value: &shim.Column_String_{String_: callerDetails.user}},
				&shim.Column{Value: &shim.Column_Int64{Int64: timestamp.Seconds}},
				&shim.Column{Value: &shim.Column_String_{String_: ""}},
				&shim.Column{Value: &shim.Column_Int64{Int64: 0}},
			},
		})

	fmt.Println(err)

	if err != nil {
		return nil, fmt.Errorf("Could not get save identity, [%v]", err)

	}

	eventPayload := providerEnrollmentID + "|" + identityCode

	//Broadcast 'New ID Issued'
	err = stub.SetEvent(EVENT_NEW_IDENTITY_ISSUED, []byte(eventPayload))
	fmt.Println(err)

	if err != nil {
		return nil, fmt.Errorf("Failed to setevent EVENT_NEW_IDENTITY_ISSUED, [%v] -> "+eventPayload, err)
	}
	return nil, nil

}

func (t *IdentityChainCode) RemoveIdentity(stub shim.ChaincodeStubInterface, args []string) ([]byte, error) {

	//Get Caller Details
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}

	//Check if Tcert has a valid role
	validRoles := hasValidRoles(callerDetails)

	if validRoles == false {
		return nil, fmt.Errorf("Access denied. Unknown role in Tcert -> " + callerDetails.role)
	}

	if len(args) < 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 1 -> [enrollmentID, identityCode]")
	}
	enrollmentID := args[0]
	identityCode := args[1]

	isProv := isProvider(callerDetails)
	isUser := isUser(callerDetails)

	if isUser == true && callerDetails.userEnrollmentID != args[0] {
		errmsg := "Access Denied. User Role found in TCert but Enrollment ID on certificate don't match"
		fmt.Println(errmsg + "->" + callerDetails.userEnrollmentID)
		return nil, fmt.Errorf(errmsg)
	}

	var columns []shim.Column = []shim.Column{}
	keyCol1 := shim.Column{Value: &shim.Column_String_{String_: identityCode}}
	columns = append(columns, keyCol1)

	if isProv == false && isUser == false {
		keyCol2 := shim.Column{Value: &shim.Column_String_{String_: callerDetails.issuerID}}
		columns = append(columns, keyCol2)
	}

	tableName := enrollmentID + IDENTITY_TBL_PREFIX
	rowPointers, err := getRows(&stub, tableName, columns)

	if err != nil {
		return nil, fmt.Errorf("Error Getting Identity, [%v]", err)
	}
	if len(rowPointers) == 0 {
		return nil, fmt.Errorf("Identity does not exist")
	}

	row := *rowPointers[0]

	err = stub.DeleteRow(tableName, []shim.Column{
		shim.Column{Value: &shim.Column_String_{String_: row.Columns[1].GetString_()}},
		shim.Column{Value: &shim.Column_String_{String_: row.Columns[2].GetString_()}},
		shim.Column{Value: &shim.Column_String_{String_: row.Columns[4].GetString_()}},
		shim.Column{Value: &shim.Column_String_{String_: row.Columns[5].GetString_()}},
	})

	if err != nil {
		return nil, fmt.Errorf("Error deleting Identity, [%v] -> "+enrollmentID+"|"+identityCode, err)

	}

	return []byte("Identity successfully removed"), nil

}

func (t *IdentityChainCode) GetIdentities(stub shim.ChaincodeStubInterface, args []string) ([]byte, error) {

	//Get Caller Details
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}

	//Check if Tcert has a valid role
	validRoles := hasValidRoles(callerDetails)

	if validRoles == false {
		return nil, fmt.Errorf("Access denied. Unknown role in Tcert -> " + callerDetails.role)
	}

	if len(args) < 1 {
		return nil, errors.New("Incorrect number of arguments. Expecting 1 -> [enrollmentID]")
	}
	enrollmentID := args[0]
	isProv := isProvider(callerDetails)
	isUser := isUser(callerDetails)

	if isUser == true && callerDetails.userEnrollmentID != args[0] {
		errmsg := "Access Denied. User Role found in TCert but Enrollment ID on certificate don't match"
		fmt.Println(errmsg + "->" + callerDetails.userEnrollmentID)
		return nil, fmt.Errorf(errmsg)
	}
	var columns []shim.Column = []shim.Column{}

	if isProv == false && isUser == false { //Its Issuer
		keyCol1 := shim.Column{Value: &shim.Column_String_{String_: callerDetails.issuerID}}
		columns = append(columns, keyCol1)
	}

	tableName := enrollmentID + IDENTITY_TBL_PREFIX
	rowPointers, err := getRows(&stub, tableName, columns)

	if err != nil {
		return nil, fmt.Errorf("Error Getting Identities, [%v]", err)
	}
	var identities []IdentityMin
	for _, rowPointer := range rowPointers {
		row := *rowPointer
		var identity = IdentityMin{}
		identity.ProviderEnrollmentID = enrollmentID
		identity.IdentityCode = row.Columns[1].GetString_()
		identity.IdentityTypeCode = row.Columns[2].GetString_()
		identity.IssuerCode = row.Columns[4].GetString_()
		identity.IssuerID = row.Columns[5].GetString_()
		identity.IssuerOrganization = row.Columns[6].GetString_()
		identity.CreatedBy = row.Columns[11].GetString_()
		identity.CreatedOnTxTimestamp = row.Columns[12].GetInt64()
		identity.LastUpdatedBy = row.Columns[13].GetString_()
		identity.LastUpdatedOnTxTimestamp = row.Columns[14].GetInt64()
		identity.IssuerVerified = row.Columns[9].GetBool()

		identities = append(identities, identity)

	}

	jsonRp, err := json.Marshal(identities)

	if err != nil {
		return nil, fmt.Errorf("Error Getting Identities, [%v]", err)

	}
	fmt.Println(string(jsonRp))

	return jsonRp, nil

}

func (t *IdentityChainCode) GetIdentity(stub shim.ChaincodeStubInterface, args []string) ([]byte, error) {

	//Get Caller Details
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}

	//Check if Tcert has a valid role
	validRoles := hasValidRoles(callerDetails)

	if validRoles == false {
		return nil, fmt.Errorf("Access denied. Unknown role in Tcert -> " + callerDetails.role)
	}

	if len(args) < 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 1 -> [enrollmentID, identityCode]")
	}
	enrollmentID := args[0]
	identityCode := args[1]

	isProv := isProvider(callerDetails)
	isUser := isUser(callerDetails)

	if isUser == true && callerDetails.userEnrollmentID != args[0] {
		errmsg := "Access Denied. User Role found in TCert but Enrollment ID on certificate don't match"
		fmt.Println(errmsg + "->" + callerDetails.userEnrollmentID)
		return nil, fmt.Errorf(errmsg)
	}

	var columns []shim.Column = []shim.Column{}
	keyCol1 := shim.Column{Value: &shim.Column_String_{String_: identityCode}}
	columns = append(columns, keyCol1)

	if isProv == false && isUser == false {
		keyCol2 := shim.Column{Value: &shim.Column_String_{String_: callerDetails.issuerID}}
		columns = append(columns, keyCol2)
	}

	tableName := enrollmentID + IDENTITY_TBL_PREFIX
	rowPointers, err := getRows(&stub, tableName, columns)

	if err != nil {
		return nil, fmt.Errorf("Error Getting Identity, [%v]", err)
	}

	row := *rowPointers[0]
	var identity = Identity{}
	identity.ProviderEnrollmentID = enrollmentID
	identity.IdentityCode = row.Columns[1].GetString_()
	identity.IdentityTypeCode = row.Columns[2].GetString_()
	identity.EncryptedPayload = encodeBase64(row.Columns[3].GetBytes())
	identity.IssuerCode = row.Columns[4].GetString_()
	identity.IssuerID = row.Columns[5].GetString_()
	identity.IssuerOrganization = row.Columns[6].GetString_()
	identity.EncryptedKey = encodeBase64(row.Columns[7].GetBytes())
	identity.MetaData = row.Columns[8].GetString_()
	identity.IssuerVerified = row.Columns[9].GetBool()
	identity.EncryptedAttachmentURI = encodeBase64(row.Columns[10].GetBytes())
	identity.CreatedBy = row.Columns[11].GetString_()
	identity.CreatedOnTxTimestamp = row.Columns[12].GetInt64()
	identity.LastUpdatedBy = row.Columns[13].GetString_()
	identity.LastUpdatedOnTxTimestamp = row.Columns[14].GetInt64()

	jsonRp, err := json.Marshal(identity)

	if err != nil {
		return nil, fmt.Errorf("Error Getting Identity, [%v]", err)

	}

	return jsonRp, nil

}

func (t *IdentityChainCode) GetPublicKey(stub shim.ChaincodeStubInterface, args []string) ([]byte, error) {

	//Get Caller Details
	callerDetails, err := readCallerDetails(&stub)
	if err != nil {
		return nil, fmt.Errorf("Error getting caller details, [%v]", err)
	}

	//Check if Tcert has a valid role
	validRoles := hasValidRoles(callerDetails)

	if validRoles == false {
		return nil, fmt.Errorf("Access denied. Unknown role in Tcert -> " + callerDetails.role)
	}

	if len(args) < 1 {
		return nil, errors.New("Incorrect number of arguments. Expecting 1 -> [enrollmentID]")
	}
	enrollmentID := args[0]

	//Verify that Enrollment ID and Pubic key is not null
	if enrollmentID == "" {
		return nil, errors.New("Provider Enrollment ID  required")
	}

	//Add Public key state
	existingPKBytes, err := stub.GetState(enrollmentID + PUBLIC_KEY_PREFIX)

	if err != nil {
		return nil, fmt.Errorf("Public Key for " + enrollmentID + "  does not exist")
	}

	return existingPKBytes, nil
}
