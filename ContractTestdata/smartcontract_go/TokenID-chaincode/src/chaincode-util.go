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
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"fmt"
	"regexp"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

type CallerDetails struct {
	user             string
	role             string
	issuerCode       string
	issuerID         string
	userEnrollmentID string
	organization     string
}

func readCallerDetails(stubPointer *shim.ChaincodeStubInterface) (CallerDetails, error) {
	var callerDetails CallerDetails

	stub := *stubPointer
	userBytes, err := stub.ReadCertAttribute("username")
	if err != nil {
		fmt.Println("Error reading attribute 'username'")
		fmt.Println(err)
		callerDetails.user = ""
	} else {
		callerDetails.user = string(userBytes)
	}

	roleBytes, err := stub.ReadCertAttribute("role")
	if err != nil {
		fmt.Println("Error reading attribute 'role'")
		fmt.Println(err)
		callerDetails.role = ""
	} else {
		callerDetails.role = string(roleBytes)
	}

	issuerCodeBytes, err := stub.ReadCertAttribute("issuerCode")
	if err != nil {
		callerDetails.issuerCode = ""
	} else {
		callerDetails.issuerCode = string(issuerCodeBytes)
	}

	issuerIDBytes, err := stub.ReadCertAttribute("issuerID")
	if err != nil {
		callerDetails.issuerID = ""
	} else {
		callerDetails.issuerID = string(issuerIDBytes)
	}

	orgBytes, err := stub.ReadCertAttribute("organization")
	if err != nil {
		callerDetails.organization = ""
	} else {
		callerDetails.organization = string(orgBytes)
	}

	return callerDetails, nil

}

func recordExistsInTable(stubPointer *shim.ChaincodeStubInterface, tableName string, columnKeys []shim.Column) (bool, error) {
	stub := *stubPointer

	var rowChannel <-chan shim.Row

	rowChannel, err := stub.GetRows(tableName, columnKeys)
	if err != nil {
		return false, err
	}
	return len(rowChannel) > 0, nil

}

func getRows(stubPointer *shim.ChaincodeStubInterface, tableName string, columnKeys []shim.Column) ([]*shim.Row, error) {
	stub := *stubPointer

	var rowChannel <-chan shim.Row

	rowChannel, err := stub.GetRows(tableName, columnKeys)
	if err != nil {
		return nil, err
	}

	var rows []*shim.Row
	for {
		select {
		case row, ok := <-rowChannel:
			if !ok {
				rowChannel = nil
			} else {
				rows = append(rows, &row)
			}
		}
		if rowChannel == nil {
			break
		}
	}
	return rows, nil

}

func isProvider(callerDetails CallerDetails) bool {
	if strings.EqualFold(callerDetails.role, ROLE_PROVIDER) {
		return true
	}
	return false
}

func isUser(callerDetails CallerDetails) bool {
	if strings.EqualFold(callerDetails.role, ROLE_USER) {
		return true
	}
	return false
}

func isIssuer(callerDetails CallerDetails) bool {
	if strings.EqualFold(callerDetails.role, ROLE_ISSUER) {
		return true
	}
	return false
}
func hasValidRoles(callerDetails CallerDetails) bool {
	return (isProvider(callerDetails) || isIssuer(callerDetails) || isUser(callerDetails))
}

func encodeBase64(bytes []byte) string {
	return base64.StdEncoding.EncodeToString(bytes)
}
func decodeBase64(val string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(val)
}

func validateIdentityTypeCode(code string) (bool, error) {
	return regexp.MatchString("^[a-zA-Z0-9]{4,10}$", code)
}

func validatePublicKey(pemKeyBytes []byte) error {

	block, _ := pem.Decode(pemKeyBytes)

	if block == nil {
		return fmt.Errorf("Failed Decoding PEM public key")
	}

	_, err := x509.ParsePKIXPublicKey(block.Bytes)

	if err != nil {
		return fmt.Errorf("Failed to parse RSA public key: [%v]", err)
	}
	return nil
}
