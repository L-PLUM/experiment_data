/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Writing Your First Blockchain Application
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"crypto/rand"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math/big"
	"strconv"
	"strings"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

type SmartContract struct {
}

// global
const set_N int = 5
const set_T int = 3
const person_N int = 20

var skList array_n
var pkList array_n
var currentIndex int = 0
var personIndex int = 0
var polyValue array_n_n
var bigX array_n_n
var bigY array_n_n
var combine array_n
var bigS array_n
var vector string = "0000000000"
var hashList [person_N]string
var vef Verifys

type array_t [set_T]*big.Int
type array_n [set_N]*big.Int
type array_n_n [set_N][set_N]*big.Int
type array_3 [3]*big.Int
type array_4 [4]*big.Int

type Pack_Two struct {
	P2w1 array_n `json:"w1"`
	P2w2 array_n `json:"w2"`
	P2c  array_n `json:"c"`
	P2s  array_n `json:"s"`
}

// person
type Person struct {
	Index int    `json:"INDEX"`
	H256  string `json:"HASH"`
}

// participant
type User struct {
	Index2      int      `json:"INDEX2"`
	PrivateKey  *big.Int `json:"SK"`
	PublicKey   *big.Int `json:"PK"`
	Chosen      array_t  `json:"CHOSEN_NUMBER"`
	Commitment  array_t  `json:"COMMITMENT"`
	SecretShare array_n  `json:"SECRET_SHARE"`
	PackOne     array_3  `json:"PROOF_ONE"`
	PackTwo     Pack_Two `json:"PROOF_TWO"`
	PackThree   array_4  `json:"PROOF_THREE"`
}

type Environment struct {
	Prime_p *big.Int `json:"P"` // p
	Prime_q *big.Int `json:"Q"` // q
	Gen_g   *big.Int `json:"G"` // g
	//Gen_h        *big.Int `json:"H"`          // h
	Number        *big.Int `json:"NUMBER_PARTICIPANT"` // n
	Number_person *big.Int `json:"NUMBER_PERSON"`
	Current       *big.Int `json:"NUMBER_CURRENT"`
	Threshold     *big.Int `json:"THRESHOLD"`
	Randomness_1  *big.Int `json:"RANDOMNESS_1"`
	Randomness    *big.Int `json:"RANDOMNESS_2"`
	Prize         *big.Int `json:"PRIZE"`
}

type Verifys struct {
	Proof1 string
	Proof2 string
	Proof3 string
}

// init smart contract
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	function, args := APIstub.GetFunctionAndParameters()

	if function == "queryId" {
		return s.queryId(APIstub, args)
	} else if function == "initEnv" {
		return s.initEnv(APIstub)
	} else if function == "joinParticipant" {
		return s.joinParticipant(APIstub, args)
	} else if function == "queryAll" {
		return s.queryAll(APIstub)
	} else if function == "getStart" {
		return s.getStart(APIstub)
	} else if function == "pooling" {
		return s.pooling(APIstub)
	} else if function == "proofOne" {
		return s.proofOne(APIstub)
	} else if function == "proofTwo" {
		return s.proofTwo(APIstub)
	} else if function == "proofThree" {
		return s.proofThree(APIstub)
	} else if function == "verifyPack1" {
		return s.verifyPack1(APIstub)
	} else if function == "verifyPack2" {
		return s.verifyPack2(APIstub)
	} else if function == "verifyPack3" {
		return s.verifyPack3(APIstub)
	} else if function == "joinPerson" {
		return s.joinPerson(APIstub, args)
	} else if function == "hashToR1" {
		return s.hashToR1(APIstub)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// query by key
func (s *SmartContract) queryId(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	userAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(userAsBytes)
}

// range query
func (s *SmartContract) queryAll(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := ""
	endKey := ""

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")

		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryIds:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

// init environment
func (s *SmartContract) initEnv(APIstub shim.ChaincodeStubInterface) sc.Response {
	start := time.Now()
	p := big.NewInt(1)
	q := big.NewInt(1)

	// p q 1024
	var Pstring string = "146878113120098309319426121065346073453769536463400376375096979551798440878576432406172565156825134133762977198097003244013513997753672488183722581184892149558594316787681360628246908508146796497105007010657836771281727722222614851352791426176901231871691716725108699860009579740143005309665004213336217062923"
	var Qstring string = "73439056560049154659713060532673036726884768231700188187548489775899220439288216203086282578412567066881488599048501622006756998876836244091861290592446074779297158393840680314123454254073398248552503505328918385640863861111307425676395713088450615935845858362554349930004789870071502654832502106668108531461"
	// p q 512
	//var Pstring string = "10842648270672240498338464699382269305226774958584413826742361903749959213710988939264460621515041241871163193486239661028887396552162795615168603017479489"
	//var Qstring string = "169416379229253757786538510927847957894168358727881466042849404746093112714234202176007197211172519404236924898222494703576365571127543681487009422148117"
	// p q 256
	//var Pstring string = "102224240748727890771869006482457577825410236076121857377946302725525696889229"
	//var Qstring string = "25556060187181972692967251620614394456352559019030464344486575681381424222307"
	p.SetString(Pstring, 10)
	q.SetString(Qstring, 10)

	// g h
	g := generateG(p, q)
	//h := generateH(p, q)
	// parameter
	var Env Environment
	Env.Prime_p = p
	Env.Prime_q = q
	Env.Gen_g = g
	//Env.Gen_h = h
	Env.Number = big.NewInt(int64(set_N))
	Env.Number_person = big.NewInt(int64(person_N))
	Env.Threshold = big.NewInt(int64(set_T))
	Env.Current = big.NewInt(0)
	currentIndex = 0
	personIndex = 1
	envAsBytes, _ := json.Marshal(Env)
	APIstub.PutState("environment", envAsBytes)
	end := time.Since(start)
	fmt.Println("the time of init-------->", end)
	fmt.Println("p--------->", p)
	fmt.Println("q--------->", q)
	fmt.Println("g--------->", g)
	//fmt.Println("h--------->", h)
	fmt.Println("max number--------->", set_N)
	fmt.Println("threshold---------->", set_T)
	fmt.Println("------------------------begin")
	return shim.Success(nil)
}

// join 1 person
func (s *SmartContract) joinPerson(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != set_T {
		return shim.Error("Incorrect number of chosen")
	}

	var pre_hash string
	if personIndex == 1 {
		pre_hash = vector
		fmt.Println("prehash---->", pre_hash)
	} else {
		// var person_pre Person
		// var key string = "perbc" + strconv.Itoa(personIndex-1)
		// personAsBytes, _ := APIstub.GetState(key)
		// json.Unmarshal(personAsBytes, &person_pre)

		pre_hash = hashList[personIndex-2]
		fmt.Println("prehash---->", pre_hash)
	}

	var seed string
	for i := 0; i < set_T; i++ {
		seed += args[i]
	}
	fmt.Println("str-->", seed)

	start := time.Now()

	var person Person

	fmt.Println("personIndex-->", personIndex)
	var seedByte []byte = []byte(strconv.Itoa(personIndex) + seed + pre_hash)
	var result [32]byte = sha256.Sum256(seedByte)
	fmt.Println("SHA256---->", result)
	hashList[personIndex-1] = convert(result)
	person.H256 = hashList[personIndex-1]
	person.Index = personIndex
	fmt.Println("H256-->", person.H256)

	person2AsBytes, _ := json.Marshal(person)
	APIstub.PutState("perbc"+strconv.Itoa(personIndex), person2AsBytes)

	end := time.Since(start)
	fmt.Println("time during person join: ", end)

	fmt.Println("the", personIndex, "person join completed")
	if personIndex != person_N {
		personIndex++
	}
	fmt.Println("--------")

	return shim.Success([]byte(strconv.Itoa(person.Index)))
}

func (s *SmartContract) hashToR1(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	if personIndex != person_N {
		return shim.Error("Incorrect number of person")
	}
	var hash_array [person_N]string
	var seed string
	for i := 0; i < person_N; i++ {
		var person Person
		var key string = "perbc" + strconv.Itoa(i+1)
		personAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(personAsBytes, &person)
		hash_array[i] = person.H256
		seed += hash_array[i]
	}
	var seedByte []byte = []byte(seed)
	var result_32 [32]byte = sha256.Sum256(seedByte)
	var result_s = convert(result_32)
	rn := big.NewInt(1)
	rn.SetString(result_s, 10)
	Env.Randomness_1 = rn
	fmt.Println("---->", rn)
	env2AsBytes, _ := json.Marshal(Env)
	APIstub.PutState("environment", env2AsBytes)

	return shim.Success(nil)
}

// join 2 participant
func (s *SmartContract) joinParticipant(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != set_T {
		return shim.Error("Incorrect number of chosen !")
	}

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	start := time.Now()

	var user User

	fmt.Println("generate key pair")
	sk := generateSk(Env.Prime_q)
	pk := generatePk(sk, Env.Gen_g, Env.Prime_p)
	user.PrivateKey = sk
	user.PublicKey = pk

	if currentIndex < set_N {
		skList[currentIndex] = sk
		pkList[currentIndex] = pk
	} else {
		return shim.Error("incorrect number of participant")
	}

	currentIndex++

	fmt.Println("generate commitment")
	var i int = 0
	for i < set_T {
		chose := big.NewInt(0)
		chose.SetString(args[i], 10)
		fmt.Println("numeber", i+1, "is", chose)
		user.Chosen[i] = chose
		commitment := big.NewInt(0)
		commitment.Exp(Env.Gen_g, chose, Env.Prime_p)
		user.Commitment[i] = commitment
		i++
	}
	user.Index2 = person_N + currentIndex

	end := time.Since(start)
	fmt.Println("time during participant join: ", end)

	userAsBytes, _ := json.Marshal(user)
	APIstub.PutState("pvrnbc"+strconv.Itoa(currentIndex), userAsBytes)

	fmt.Println("the ", currentIndex, " participant join completed")

	return shim.Success([]byte(strconv.Itoa(user.Index2) + "+" + sk.String()))
}

func (s *SmartContract) getStart(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	if currentIndex < set_N {
		return shim.Error("incorrect number of participants")
	}
	fmt.Println("generate secret shares")
	start := time.Now()
	var i int = 0
	for i < set_N {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		var j int = 0
		for j < set_N {
			value := computeValue(user.Chosen, Env.Threshold, big.NewInt(int64(j+1)), Env.Prime_q)
			polyValue[i][j] = value
			Y := big.NewInt(1)
			X := big.NewInt(1)
			Y.Exp(pkList[j], value, Env.Prime_p)
			bigY[i][j] = Y
			user.SecretShare[j] = Y
			X.Exp(Env.Gen_g, value, Env.Prime_p)
			bigX[i][j] = X
			j++
		}
		user2AsBytes, _ := json.Marshal(user)
		APIstub.PutState("pvrnbc"+strconv.Itoa(i+1), user2AsBytes)
		i++
	}
	Env.Current = big.NewInt(int64(currentIndex))
	env2AsBytes, _ := json.Marshal(Env)
	APIstub.PutState("environment", env2AsBytes)
	end := time.Since(start)
	fmt.Println("the time of secret shares: ", end)
	fmt.Println("secret share completed")
	return shim.Success(nil)
}

func (s *SmartContract) pooling(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)
	if currentIndex < set_N {
		return shim.Error("incorrect number of participants")
	}
	start := time.Now()

	fmt.Println("combine secret shares")
	combine = homoroMul(Env.Prime_p, Env.Prime_q)

	fmt.Println("decrypt secret")
	bigS = decryption2J(Env.Prime_p, Env.Gen_g)
	bigS_cmp := decryption1J(Env.Prime_p, skList, combine)
	fmt.Println("bigS = ", bigS)
	fmt.Println("bigS_cmp = ", bigS_cmp)

	fmt.Println("make intepolate")

	Randomness := getr(Env.Prime_q, Env.Gen_g, Env.Prime_p)
	fmt.Println("generate randomness = ", Randomness)
	Env.Randomness = Randomness
	og := big.NewInt(1)
	og.Exp(Randomness, Env.Randomness_1, Env.Prime_p)

	ok1 := set_N + person_N
	ok2 := int64(ok1)
	og.Mod(og, big.NewInt(ok2))
	Env.Prize = og

	env2AsBytes, _ := json.Marshal(Env)
	APIstub.PutState("environment", env2AsBytes)

	test := big.NewInt(1)
	test.Exp(Env.Gen_g, big.NewInt(50), Env.Prime_p)
	fmt.Println("randomness_cmp = ", test)

	end := time.Since(start)
	fmt.Println("the time of decode and intepolate: ", end)
	fmt.Println("all procedure completed")
	return shim.Success(nil)
}

func (s *SmartContract) proofOne(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	fmt.Println("generate proof 1")
	start := time.Now()
	var i int = 0
	for i < set_N {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		w, c, s := packOne(Env.Prime_p, Env.Prime_q, Env.Gen_g, skList[i], pkList[i])
		user.PackOne[0] = w
		user.PackOne[1] = c
		user.PackOne[2] = s
		user2AsBytes, _ := json.Marshal(user)
		APIstub.PutState("pvrnbc"+strconv.Itoa(i+1), user2AsBytes)
		i++
	}
	end := time.Since(start)
	fmt.Println("the time of proof 1: ", end)
	fmt.Println("proof 1 completed")
	return shim.Success(nil)
}

func (s *SmartContract) proofTwo(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)
	fmt.Println("generate proof 2")
	start := time.Now()

	var i int = 0
	for i < set_N {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		w1, w2, c, s := packTwo(Env.Prime_p, Env.Prime_q, Env.Gen_g, i)
		user.PackTwo.P2w1 = w1
		user.PackTwo.P2w2 = w2
		user.PackTwo.P2c = c
		user.PackTwo.P2s = s

		user2AsBytes, _ := json.Marshal(user)
		APIstub.PutState("pvrnbc"+strconv.Itoa(i+1), user2AsBytes)
		i++
	}
	end := time.Since(start)
	fmt.Println("the time of proof two: ", end)
	fmt.Println("proof 2 completed")
	return shim.Success(nil)
}

func (s *SmartContract) proofThree(APIstub shim.ChaincodeStubInterface) sc.Response {
	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)
	fmt.Println("generate proof 3")
	start := time.Now()
	var j int = 0
	for j < set_N {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(j+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		w1, w2, c, s := packThree(Env.Prime_p, Env.Prime_q, Env.Gen_g, bigS[j], combine[j], pkList[j], skList[j])
		user.PackThree[0] = w1
		user.PackThree[1] = w2
		user.PackThree[2] = c
		user.PackThree[3] = s
		// 将第j个用户存入区块链
		user2AsBytes, _ := json.Marshal(user)
		APIstub.PutState("pvrnbc"+strconv.Itoa(j+1), user2AsBytes)
		j++
	}
	end := time.Since(start)
	fmt.Println("the time of proof three: ", end)
	fmt.Println("proof 3 completed")
	return shim.Success(nil)
}

func (s *SmartContract) verifyPack1(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	var check1_w array_n
	var check1_c array_n
	var check1_s array_n

	for i := 0; i < set_N; i++ {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		check1_w[i] = user.PackOne[0]
		check1_c[i] = user.PackOne[1]
		check1_s[i] = user.PackOne[2]
	}
	fmt.Println("proof 1 data:")
	x1 := verifyProofOne(Env.Gen_g, check1_s, check1_w, pkList, check1_c, Env.Prime_p)
	vef.Proof1 = x1
	vefAsBytes, _ := json.Marshal(vef)
	APIstub.PutState("verify", vefAsBytes)

	var res []byte
	res = []byte(x1)
	return shim.Success(res)
}

func (s *SmartContract) verifyPack2(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	var check2_w1 array_n_n
	var check2_w2 array_n_n
	var check2_c array_n_n
	var check2_s array_n_n

	for i := 0; i < set_N; i++ {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)

		for j := 0; j < set_N; j++ {
			check2_w1[i][j] = user.PackTwo.P2w1[j]
			check2_w2[i][j] = user.PackTwo.P2w2[j]
			check2_c[i][j] = user.PackTwo.P2c[j]
			check2_s[i][j] = user.PackTwo.P2s[j]
		}
	}
	fmt.Println("proof 2 data:")
	x2 := verifyProofTwo(Env.Gen_g, pkList, check2_s, check2_w1, check2_w2, check2_c, Env.Prime_p)
	vef.Proof2 = x2
	vefAsBytes, _ := json.Marshal(vef)
	APIstub.PutState("verify", vefAsBytes)

	var res []byte
	res = []byte(x2)
	return shim.Success(res)
}

func (s *SmartContract) verifyPack3(APIstub shim.ChaincodeStubInterface) sc.Response {

	var Env Environment
	envAsBytes, _ := APIstub.GetState("environment")
	json.Unmarshal(envAsBytes, &Env)

	var check3_w1 array_n
	var check3_w2 array_n
	var check3_c array_n
	var check3_s array_n

	for i := 0; i < set_N; i++ {
		var user User
		var key string = "pvrnbc" + strconv.Itoa(i+1)
		userAsBytes, _ := APIstub.GetState(key)
		json.Unmarshal(userAsBytes, &user)
		check3_w1[i] = user.PackThree[0]
		check3_w2[i] = user.PackThree[1]
		check3_c[i] = user.PackThree[2]
		check3_s[i] = user.PackThree[3]
	}
	fmt.Println("proof 3 data:")
	x3 := verifyProofThree(Env.Gen_g, check3_s, check3_w1, check3_w2, pkList, check3_c, Env.Prime_p)
	vef.Proof3 = x3
	vefAsBytes, _ := json.Marshal(vef)
	APIstub.PutState("verify", vefAsBytes)

	var res []byte
	res = []byte(x3)
	return shim.Success(res)
}

func lamdaj(j *big.Int) *big.Int {

	i := big.NewInt(1)
	one := big.NewInt(1)
	result := big.NewInt(1)
	temp1 := big.NewInt(1)
	temp2 := big.NewInt(1)
	temp3 := big.NewInt(1)

	for a := 0; a < set_N; a++ {
		w := i.Cmp(j)
		if w != 0 {
			temp1.Sub(i, j)
			temp2.Mul(temp2, temp1)
			temp3.Mul(temp3, i)
		} else {
			//do nothing
		}
		i.Add(i, one)
	}
	result.Div(temp3, temp2)
	return result
}

func getr(q *big.Int, h *big.Int, p *big.Int) *big.Int {

	one := big.NewInt(1)
	j := big.NewInt(1)
	lamda := big.NewInt(1)
	temp1 := big.NewInt(1)
	result := big.NewInt(0)

	for a := 0; a < set_N; a++ {
		lamda = lamdaj(j)
		temp := big.NewInt(0)
		for b := 0; b < set_N; b++ {
			temp.Add(temp, polyValue[b][a])
		}
		temp1.Mul(temp, lamda)
		result.Add(result, temp1)
		result.Mod(result, q)
		j.Add(j, one)
	}
	result.Exp(h, result, p)
	return result
}

func homoroMul(p *big.Int, q *big.Int) array_n {
	var target array_n
	var j int = 0
	for j < set_N {
		result := big.NewInt(1)
		var i int = 0
		for i < set_N {
			temp := bigY[i][j]
			result.Mul(result, temp)
			result.Mod(result, p)
			i++
		}
		target[j] = result
		j++
	}
	return target
}

func decryption1J(p *big.Int, sklist array_n, prefinal array_n) array_n {
	temp := big.NewInt(1)
	temp.Sub(p, big.NewInt(1))
	var secrets array_n
	var j int = 0
	for j < set_N {
		result := big.NewInt(1)
		result.ModInverse(sklist[j], temp) //mod p-1
		result.Exp(prefinal[j], result, p)
		secrets[j] = result
		j++
	}
	return secrets
}

// for 1 j
func decryption2J(p *big.Int, g *big.Int) array_n {
	var secrets array_n
	var j int = 0
	for j < set_N {
		result := big.NewInt(0)
		var i int = 0
		for i < set_N {
			result.Add(result, polyValue[i][j])
			i++
		}
		result.Exp(g, result, p)
		secrets[j] = result
		j++
	}
	return secrets
}

func computeValue(a array_t, t *big.Int, x *big.Int, q *big.Int) *big.Int {
	result := big.NewInt(0)
	var i int64 = 0
	for i < t.Int64() {
		temp := big.NewInt(1)
		temp.Exp(x, big.NewInt(i), q)
		temp.Mul(temp, a[i])
		result.Add(result, temp)
		i++
	}
	return result
}

func generateP() *big.Int {
	var err error
	prime, err := rand.Prime(rand.Reader, 1024)
	if err != nil {
		fmt.Println("error while generating prime")
	}
	return prime
}

func generateQ(p *big.Int) *big.Int {
	q := big.NewInt(1)
	q.Sub(p, big.NewInt(1))
	salt := big.NewInt(1)
	salt.Mod(q, big.NewInt(2))
	for salt.Mod(q, big.NewInt(2)).Cmp(big.NewInt(1)) < 0 {
		q.Div(q, big.NewInt(2))
		fmt.Println("div2")
	}
	return q
}

func generateH(p *big.Int, q *big.Int) *big.Int {
	var err error
	random, err := rand.Int(rand.Reader, q)
	if err != nil {
		fmt.Println("error while generating random number!")
	}
	h := big.NewInt(1)
	h.Sub(p, big.NewInt(1))
	h.Div(h, q)
	h.Exp(random, h, p)
	return h
}

func generateG(p *big.Int, q *big.Int) *big.Int {
	var err error
	random, err := rand.Int(rand.Reader, q)
	if err != nil {
		fmt.Println("error while generating random number!")
	}
	g := big.NewInt(1)
	g.Sub(p, big.NewInt(1))
	g.Div(g, q)
	g.Exp(random, g, p)
	return g
}

func generateSk(q *big.Int) *big.Int {
	var err error
	sk, err := rand.Int(rand.Reader, q)
	if err != nil {
		fmt.Println("error when generating sk!")
	}
	salt := big.NewInt(1)
	if salt.Mod(sk, big.NewInt(2)).Cmp(big.NewInt(1)) < 0 {
		sk, err = rand.Int(rand.Reader, q)
		if err != nil {
			fmt.Println("error when generating sk!")
		}
	}
	return sk
}

func generatePk(sk *big.Int, g *big.Int, p *big.Int) *big.Int {
	y := big.NewInt(1)
	y.Exp(g, sk, p)
	return y
}

func packOne(p *big.Int, q *big.Int, g *big.Int, sk *big.Int, pk *big.Int) (*big.Int, *big.Int, *big.Int) {
	var err error
	rnd, err := rand.Int(rand.Reader, big.NewInt(100))
	if err != nil {
		fmt.Println("error when generating sk!")
	}
	w := pack1GenW(g, p, rnd)
	c := pack1GenC(w, pk)
	s := pack1GenS(rnd, sk, c, q)
	return w, c, s
}

func pack1GenW(g *big.Int, p *big.Int, rnd *big.Int) *big.Int {
	w := big.NewInt(1)
	w.Exp(g, rnd, p)
	return w
}

func pack1GenC(w *big.Int, pk *big.Int) *big.Int {
	var wString string = w.String()
	var pkString string = pk.String()
	var seedString string = wString + pkString
	var seedByte []byte = []byte(seedString)
	var result [32]byte = sha256.Sum256(seedByte)
	str := convert(result)
	n := big.NewInt(1)
	n.SetString(str, 10)
	//n.Mod(n, p)
	return n
}

func pack1GenS(rnd *big.Int, sk *big.Int, c *big.Int, q *big.Int) *big.Int {
	s := big.NewInt(1)
	s.Mul(sk, c)
	s.Add(s, rnd)
	s.Mod(s, q)
	return s
}

// for user i
func packTwo(p *big.Int, q *big.Int, g *big.Int, i int) (array_n, array_n, array_n, array_n) {
	var w1 array_n
	var w2 array_n
	var c array_n
	var s array_n
	var j int = 0
	for j < set_N {
		var err error
		rnd, err := rand.Int(rand.Reader, big.NewInt(100))
		if err != nil {
			fmt.Println("error when generating sk!")
		}

		w1[j], w2[j] = pack2GenW(g, p, rnd, pkList[j])
		c[j] = pack2GenC(w1[j], w2[j], bigX[i][j], bigY[i][j])
		s[j] = pack2GenS(q, polyValue[i][j], rnd, c[j])
		j++
	}
	return w1, w2, c, s
}

// for 1 j
func pack2GenW(g *big.Int, p *big.Int, rnd *big.Int, pk *big.Int) (*big.Int, *big.Int) {
	w1 := big.NewInt(1)
	w2 := big.NewInt(1)
	w1.Exp(g, rnd, p)
	w2.Exp(pk, rnd, p)
	return w1, w2
}

func pack2GenC(w1 *big.Int, w2 *big.Int, Xj *big.Int, Yj *big.Int) *big.Int {
	var w1String string = w1.String()
	var w2String string = w2.String()
	var XjString string = Xj.String()
	var YjString string = Yj.String()
	var seedString string = w1String + XjString + w2String + YjString
	var seedByte []byte = []byte(seedString)
	var result [32]byte = sha256.Sum256(seedByte)
	str := convert(result)
	n := big.NewInt(1)
	n.SetString(str, 10)
	return n
}

func pack2GenS(q *big.Int, value *big.Int, rnd *big.Int, c *big.Int) *big.Int {
	s := big.NewInt(1)
	s.Mul(value, c)
	s.Add(s, rnd)
	s.Mod(s, q)
	return s
}

// for 1 j
func packThree(p *big.Int, q *big.Int, g *big.Int, secret *big.Int, combine *big.Int, pk *big.Int, sk *big.Int) (*big.Int, *big.Int, *big.Int, *big.Int) {
	var err error
	rnd, err := rand.Int(rand.Reader, big.NewInt(100))
	if err != nil {
		fmt.Println("error when generating sk!")
	}
	w1, w2 := pack3GenW(p, g, rnd, secret)
	c := pack3GenC(w1, w2, pk, combine)
	s := pack3GenS(q, rnd, sk, c)
	return w1, w2, c, s
}

func pack3GenW(p *big.Int, h *big.Int, rnd *big.Int, secret *big.Int) (*big.Int, *big.Int) {
	w1 := big.NewInt(1)
	w2 := big.NewInt(1)
	w1.Exp(h, rnd, p)
	w2.Exp(secret, rnd, p)
	return w1, w2
}

func pack3GenC(w1 *big.Int, w2 *big.Int, pk *big.Int, prefinal *big.Int) *big.Int {
	var w1String string = w1.String()
	var w2String string = w2.String()
	var pkString string = pk.String()
	var prefinalString string = prefinal.String()
	var seedString string = w1String + pkString + w2String + prefinalString
	var seedByte []byte = []byte(seedString)
	var result [32]byte = sha256.Sum256(seedByte)
	str := convert(result)
	n := big.NewInt(1)
	n.SetString(str, 10)
	return n
}

func pack3GenS(q *big.Int, rnd *big.Int, sk *big.Int, c *big.Int) *big.Int {
	s := big.NewInt(1)
	s.Mul(sk, c)
	s.Add(rnd, s)
	s.Mod(s, q)
	return s
}

// convert [32]byte to string
func convert(b [32]byte) string {
	s := make([]string, len(b))
	for i := range b {
		s[i] = strconv.Itoa(int(b[i]))
	}
	str := strings.Join(s, ",")
	str = strings.Replace(str, ",", "", -1)
	return str
}

func verifyProofOne(g *big.Int, s array_n, w array_n, y array_n, c array_n, p *big.Int) string {
	r1 := big.NewInt(1)
	r2 := big.NewInt(1)
	temp := big.NewInt(1)
	for a := 0; a < set_N; a++ {
		r1.Exp(g, s[a], p)
		fmt.Println("r1 = ", r1)
		temp.Exp(y[a], c[a], p)
		r2.Mul(temp, w[a])
		r2.Mod(r2, p)
		fmt.Println("r2 = ", r2)
		if r1.Cmp(r2) != 0 {
			return "INVALID"
		}
	}
	return "VALID"
}

func verifyProofTwo(g *big.Int, y array_n, s array_n_n, w1 array_n_n, w2 array_n_n, c array_n_n, p *big.Int) string {

	r1temp := big.NewInt(1)
	temp1 := big.NewInt(1)
	temp2 := big.NewInt(1)
	r2temp := big.NewInt(1)
	r3temp := big.NewInt(1)
	r4temp := big.NewInt(1)
	for a := 0; a < set_N; a++ {
		r1 := big.NewInt(1)
		r2 := big.NewInt(1)
		r3 := big.NewInt(1)
		r4 := big.NewInt(1)
		for b := 0; b < set_N; b++ {
			r1temp.Exp(g, s[a][b], p)
			r1.Mul(r1temp, r1)
			r1.Mod(r1, p)

			r3temp.Exp(y[b], s[a][b], p)
			r3.Mul(r3temp, r3)
			r3.Mod(r3, p)

			r2temp.Exp(bigX[a][b], c[a][b], p)
			temp1.Mul(r2temp, w1[a][b])
			temp1.Mod(temp1, p)
			r2.Mul(temp1, r2)
			r2.Mod(r2, p)

			r4temp.Exp(bigY[a][b], c[a][b], p)
			temp2.Mul(r4temp, w2[a][b])
			temp2.Mod(temp2, p)
			r4.Mul(temp2, r4)
			r4.Mod(r4, p)

		}
		fmt.Println("r1 = ", r1)
		fmt.Println("r2 = ", r2)
		if r1.Cmp(r2) != 0 {
			return "INVALID"
		}
		fmt.Println("r3 = ", r3)
		fmt.Println("r4 = ", r4)
		if r3.Cmp(r4) != 0 {
			return "INVALID"
		}

	}
	return "VALID"
}

func verifyProofThree(g *big.Int, s array_n, w1 array_n, w2 array_n, y array_n, c array_n, p *big.Int) string {
	r1 := big.NewInt(1)
	r2 := big.NewInt(1)
	r3 := big.NewInt(1)
	r4 := big.NewInt(1)
	temp1 := big.NewInt(1)
	temp2 := big.NewInt(1)
	for a := 0; a < set_N; a++ {
		r1.Exp(g, s[a], p)
		fmt.Println("r1 = ", r1)
		temp1.Exp(y[a], c[a], p)
		r2.Mul(temp1, w1[a])
		r2.Mod(r2, p)
		fmt.Println("r2 = ", r2)
		r3.Exp(bigS[a], s[a], p)
		fmt.Println("r3 = ", r3)
		temp2.Exp(combine[a], c[a], p)
		r4.Mul(temp2, w2[a])
		r4.Mod(r4, p)
		fmt.Println("r4 = ", r4)
		if r1.Cmp(r2) != 0 {
			return "INVALID"
		}
		if r3.Cmp(r4) != 0 {
			return "INVALID"
		}
	}
	return "VALID"
}

func verifySingle(p *big.Int, g *big.Int, w *big.Int, c *big.Int, s *big.Int, y *big.Int) string {
	r1 := big.NewInt(1)
	r2 := big.NewInt(1)
	temp := big.NewInt(1)
	r1.Exp(g, s, p)
	fmt.Println("r1 = ", r1)
	temp.Exp(y, c, p)
	r2.Mul(temp, w)
	r2.Mod(r2, p)
	fmt.Println("r2 = ", r2)
	if r1.Cmp(r2) != 0 {
		return "INVALID"
	}
	return "VALID"
}

// main function
func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
