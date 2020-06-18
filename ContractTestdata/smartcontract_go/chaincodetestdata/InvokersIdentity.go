/*
Copyright IBM Corp. 2016 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
Modified the uniqueKeyValue example to identify the invoker 
*/

package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	crypto "crypto/x509"
	pem "encoding/pem"
	"fmt"
	"io"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// cryptoChaincode is allows the following transactions
//    "put", "key", val - returns "OK" on success
//    "get", "key" - returns val stored previously
type cryptoChaincode struct {
}

const (
	AESKeyLength = 32 // AESKeyLength is the default AES key length
	NonceSize    = 24 // NonceSize is the default NonceSize
)

///////////////////////////////////////////////////
// GetRandomByt es returns len random looking bytes
///////////////////////////////////////////////////
func GetRandomBytes(len int) ([]byte, error) {
	//TODO: Should we fix the length ?
	key := make([]byte, len)

	_, err := rand.Read(key)
	if err != nil {
		return nil, err
	}

	return key, nil
}

////////////////////////////////////////////////////////////
// GenAESKey returns a random AES key of length AESKeyLength
// 3 Functions to support Encryption and Decryption
// GENAESKey() - Generates AES symmetric key
func (t *cryptoChaincode) GenAESKey() ([]byte, error) {
	return GetRandomBytes(AESKeyLength)
}

//Init implements chaincode's Init interface
func (t *cryptoChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println(" ############## Init ##############")
	return shim.Success(nil)
}

//Invoke implements chaincode's Invoke interface
func (t *cryptoChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	if function == "put" {
		if len(args) < 2 {
			return shim.Error(fmt.Sprintf("invalid number of args for put %d", len(args)))
		}
		fmt.Println(" ############## Invoke ##############")
		return t.writeTransaction(stub, args)
	} else if function == "get" {
		fmt.Println(" ############## Query ##############")
		return t.readTransaction(stub, args)
	}
	fmt.Println(" ############## Invalid function ##############")
	return shim.Error(fmt.Sprintf("unknown function %s", function))
}

func (t *cryptoChaincode) encryptAndDecrypt(arg string) []byte {
	AES_key, _ := t.GenAESKey()
	AES_enc := t.Encrypt(AES_key, []byte(arg))

	value := t.Decrypt(AES_key, AES_enc)
	return value
}

func (t *cryptoChaincode) Encrypt(key []byte, byteArray []byte) []byte {
	fmt.Println(" ############## Encryption ##############")
	// Create the AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}

	// Empty array of 16 + byteArray length
	// Include the IV at the beginning
	ciphertext := make([]byte, aes.BlockSize+len(byteArray))

	// Slice of first 16 bytes
	iv := ciphertext[:aes.BlockSize]

	// Write 16 rand bytes to fill iv
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		panic(err)
	}

	// Return an encrypted stream
	stream := cipher.NewCFBEncrypter(block, iv)

	// Encrypt bytes from byteArray to ciphertext
	stream.XORKeyStream(ciphertext[aes.BlockSize:], byteArray)

	return ciphertext
}

func (t *cryptoChaincode) Decrypt(key []byte, ciphertext []byte) []byte {
	fmt.Println(" ############## Decrypt ##############")
	// Create the AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}

	// Before even testing the decryption,
	// if the text is too small, then it is incorrect
	if len(ciphertext) < aes.BlockSize {
		panic("Text is too short")
	}

	// Get the 16 byte IV
	iv := ciphertext[:aes.BlockSize]

	// Remove the IV from the ciphertext
	ciphertext = ciphertext[aes.BlockSize:]

	// Return a decrypted stream
	stream := cipher.NewCFBDecrypter(block, iv)

	// Decrypt bytes from ciphertext
	stream.XORKeyStream(ciphertext, ciphertext)

	return ciphertext
}

func (t *cryptoChaincode) writeTransaction(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Println("------------- writeTransaction/Invoke -------------")
	fmt.Printf(" Key => \"%s\" , Value => %s", args[0], args[1])
	cryptoArg := t.encryptAndDecrypt(args[1])
	err := stub.PutState(args[0], cryptoArg)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success([]byte("OK"))
}

func (t *cryptoChaincode) readTransaction(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fmt.Println("------------- readTransaction/Query 9-------------")
	signatureBytes, err := stub.GetCreator()
	if err == nil {
		signatureString := string(signatureBytes)
		fmt.Printf("Signature %s", signatureString)
		pos := strings.Index(signatureString, "-----BEGIN CERTIFICATE-----")
		if pos != -1 {
			actualSignature := signatureString[pos : len(signatureString)-1]
			fmt.Printf("Only Signature %s", actualSignature)
			block, _ := pem.Decode([]byte(actualSignature))
			if block != nil {
				certificate, err := crypto.ParseCertificate(block.Bytes)
				if err != nil {
					fmt.Printf("Error in parsing certificate %v", err)
				} else {
					fmt.Printf("\nCert Subject Common Name %v", certificate.Subject.CommonName)
					fmt.Printf("\nCert Issuer Common Name %v", certificate.Issuer.CommonName)
					fmt.Printf("\nCert Version %v", certificate.Version)
				}
			}
		}

	} else {
		fmt.Printf("Error in GetCreator %v", err)
	}
	// Get the state from the ledger
	val, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Printf(" Key => \"%s\" , Value => %s", args[0], string(val))
	return shim.Success(val)
}

func main() {
	err := shim.Start(new(cryptoChaincode))
	if err != nil {
		fmt.Printf("Error starting New key per invoke: %s", err)
	}
}
