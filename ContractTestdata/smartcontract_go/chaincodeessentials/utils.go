package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	id "github.com/hyperledger/fabric/core/chaincode/shim/ext/cid"
)

//GetTrxnTS returns the transaction timestamp from stub
func GetTrxnTS(stub shim.ChaincodeStubInterface) string {
	txTs, err := stub.GetTxTimestamp()
	if err != nil {
		return "1970.01.01.00.00.00.000"
	}

	ts := time.Unix(txTs.Seconds, int64(txTs.Nanos)).UTC()
	return ts.Format("2006.01.02.15.04.05.000")
}

//CreateErrorJSON returns the error message in json format
func CreateErrorJSON(typeOfErr, message string) string {
	return fmt.Sprintf("{\"type\":\"%s\",\"message\":\"%s\"}", typeOfErr, message)
}

//CreateErrorsJSON returns the error message in json format
func CreateErrorsJSON(typeOfErr string, message []string) string {
	errObj := map[string]interface{}{
		"type":    typeOfErr,
		"message": message,
	}
	errJSONBytes, _ := json.Marshal(errObj)
	return string(errJSONBytes)
}

//GetInvokerID returns the invoker id
func GetInvokerID(stub shim.ChaincodeStubInterface) string {
	enCert, err := id.GetX509Certificate(stub)
	if err != nil {
		return "Unknown."
	}

	mspID, err := id.GetMSPID(stub)
	if err != nil {
		return "Unknown.."
	}
	return fmt.Sprintf("%s/%s", enCert.Subject.CommonName, mspID)
}
