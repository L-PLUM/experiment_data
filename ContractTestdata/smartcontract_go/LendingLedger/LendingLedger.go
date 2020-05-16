package main

import (
	"errors"
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"

	"strconv"
	"time"
	"math"
	"strings"
	"encoding/json"
	"sort"
)

type  SimpleChaincode struct {
}

const (
	REQUEST_CREATED = iota //  initial state, items can only be added at this state.
	ITEMS_SHIPPED_TO_LENDER = iota //  lender has sent the item
	ITEMS_RECEIVED_BY_LENDER = iota //  lendee has received the item
	ITEMS_SHIPPED_BY_LENDER = iota //  lendee has sent back the item
	ITEMS_RECEIVED_BY_LENDEE = iota //  lender has received the item back
)

const MAX_TIME_DIFF_IN_MIN = 5 // to validate timestamp

const REQ_CTR_KEY = "REQ_CTR"
const REQ_KEY_PREFIX = "REQ/"
const ITEM_KEY_PREFIX = "ITEM/"
const HIST_KEY_PREFIX = "REQ_HIST/"

type Request struct { // REQ/00001
	RequestId  string `json:"request_id"`  // 00001
	LenderId string `json:"lender_id"`
	LendeeId string `json:"lendee_id"`
	LatestHistoryId string `json:"latest_history_id"`
}

type Item struct { // ITEM/00001/00001

	RequestId  string `json:"request_id"`  // 00001
	ItemId  string `json:"item_id"`   // 00001
	ItemName string `json:"item_name"`
}


type RequestHistory struct { // REQ_HIST/00001/00001

	RequestId  string `json:"request_id"` // 00001
	HistoryId  string `json:"history_id"`  // 00001
	//ChangerId string `json:"changer_id"`
	StatusFrom int `json:"status_from"`
	StatusTo int `json:"status_to"`
	StatusFrom_s string `json:"status_from_s"` // not used in KVS, used for output
	StatusTo_s string `json:"status_to_s"` // not used in KVS, used for output
	TimeStamp string `json:"time_stamp"`
	Note string `json:"note"`
}

// 履歴を並べ替える用
type RequestHistories []RequestHistory
func (h RequestHistories) Len() int {
	return len(h)
}
func (h RequestHistories)  Swap(i, j int)  {
	h[i], h[j] = h[j], h[i]
}
func (h RequestHistories)  Less(i, j int) bool {
	xi, _ := strconv.Atoi(h[i].HistoryId)
	xj, _ := strconv.Atoi(h[j].HistoryId)
	return xi < xj

}


// 以下結果返し用
type RequestSet struct{
	Requests []RequestRecord `json:"requests"`
}

type RequestRecord struct{
	RequestId  string `json:"request_id"`
	LenderId string `json:"lender_id"`
	LendeeId string `json:"lendee_id"`
	LatestHistoryId string `json:"latest_history_id"`
	UpdatedTimeStamp string `json:"updated_timestamp"`
	Items []Item `json:"items"`
	Status string `json:"status"`
	Histories []RequestHistory `json:"histories"`
}


//==============================================================================================================================
//	Init Function - Called when the user deploys the chaincode
//==============================================================================================================================
func (t *SimpleChaincode) Init(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {

	if len(args) == 0 {
		// init request_id counter
		err := stub.PutState(REQ_CTR_KEY, []byte("00000"))
		if err != nil {
			return nil, errors.New("Unable to put the state")
		}
		return nil, nil
	}else if len(args) == 1 {
		// migrate from old chaincode. args[0] should have chaincode address
		val, err := stub.QueryChaincode(args[0],"get_all", []string{} )
		if err != nil {
			return nil, errors.New("Unable to call chaincode " + args[0])
		}
		//return nil, errors.New("QueryChaincode: " + string(val))
		var states interface{}
		err = json.Unmarshal(val, &states)
		if err != nil {
			return nil, errors.New("Unable to marshal chaincode return value " + string(val))
		}
		//fmt.Printf("%+v", states)
		//return nil, errors.New("QueryChaincode: " + fmt.Sprintf("%+v", states))
		for _, stateIf := range states.([]interface{}){
			state := stateIf.([]interface{})
			stateKey := state[0].(string)
			stateVal := state[1].(string)
			if stateKey == "" {
				return nil, errors.New("Unable to PutState: missing statekey [ " + stateKey +" , "+ string(stateVal) + " ]")
			}
			err = stub.PutState(stateKey, []byte(stateVal))
			if err != nil {
				return nil, errors.New("Unable to PutState [ " + stateKey +" , "+ string(stateVal) + " ]")
			}
			//return nil, errors.New("DEBUG:  " + fmt.Sprintf("%+v", state))
		}

		next_ctr, err := stub.GetState(REQ_CTR_KEY)
		if err != nil || len(next_ctr) == 0 {
			return nil, errors.New("Failed to GetState "+REQ_CTR_KEY)
		}

		return nil, nil
	}

	return nil, errors.New("Invalid numbers of args.")

}

//==============================================================================================================================
//	 Router Functions
//==============================================================================================================================
//	Invoke - Called on chaincode invoke. Takes a function name passed and calls that function. Converts some
//		  initial arguments passed to other things for use in the called function e.g. name -> ecert
//==============================================================================================================================
func (t *SimpleChaincode) Invoke(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {

	//caller, caller_affiliation, err := t.get_caller_data(stub)
	//if err != nil { return nil, errors.New("Error retrieving caller information")}


	if function == "create_request" {

		if len(args) < 5 {
			fmt.Printf("Incorrect number of arguments passed"); return nil, errors.New("INVOKE: Incorrect number of arguments passed")
		}

		lender_id := args[0]
		lendee_id := args[1]
		timestamp := args[2]

		if !validate_timestamp(timestamp) {
			fmt.Printf("Timestamp: Incorrect format or too far from system clock "+timestamp); return nil, errors.New("INVOKE: Timestamp: Incorrect format or too far from system clock"+timestamp)
		}

		item_counts, err := strconv.ParseInt(args[3],10,64)

		if err !=nil || int64(len(args)) != int64(4) + item_counts {
			fmt.Printf("item_counts and len(args) doesn't match"); return nil, errors.New("INVOKE: item_counts and len(args) doesn't match")
		}

		items := args[4:4 + item_counts ]

		return t.create_request(stub, lender_id, lendee_id, timestamp, items)

	} else if function == "change_request_status" {

		if len(args) < 5 {
			fmt.Printf("Incorrect number of arguments passed"); return nil, errors.New("INVOKE: Incorrect number of arguments passed")
		}

		request_id := args[0]
		status_from := args[1]
		status_to := args[2]
		timestamp := args[3]

		if !validate_timestamp(timestamp) {
			fmt.Printf("Timestamp: Incorrect format or too far from system clock "+timestamp); return nil, errors.New("INVOKE: Timestamp: Incorrect format or too far from system clock"+timestamp)
		}

		return t.change_request_status(stub, request_id, status_from, status_to, timestamp)

	}
	return nil, errors.New("Function of that name doesn't exist.")
}
//=================================================================================================================================
//	Query - Called on chaincode query. Takes a function name passed and calls that function. Passes the
//  		initial arguments passed are passed on to the called function.
//=================================================================================================================================
func (t *SimpleChaincode) Query(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {

	if function == "get_all_requests" {


		if len(args) != 0 {
			fmt.Printf("Incorrect number of arguments passed"); return nil, errors.New("QUERY: Incorrect number of arguments passed")
		}

		return t.get_all_requests(stub)


	}else if function == "get_all" {

		if len(args) != 0 {
			fmt.Printf("Incorrect number of arguments passed"); return nil, errors.New("QUERY: Incorrect number of arguments passed")
		}

		return t.get_all(stub)

	}else if function == "get_request" {

		if len(args) != 1 {
			fmt.Printf("Incorrect number of arguments passed"); return nil, errors.New("QUERY: Incorrect number of arguments passed")
		}
		request_id := args[0]
		return t.get_request(stub,request_id)

	}
	return nil, errors.New("QUERY: No such function.")

}

// state changing function should;
//  - receive timestamp as an argument (to keep consistency between validating peers)
//  - should validate the received timestamp with
//  -- it is within 5min of the machine time => validate_timestamp
//  -- it is larger than the previous state

func (t *SimpleChaincode) create_request(stub *shim.ChaincodeStub, lender_id string, lendee_id string, timestamp string, items []string) ([]byte, error) {

	// Register Request
	request_id := next_req_ctr(stub)
	reqKey := REQ_KEY_PREFIX + request_id
	request:= Request{
		RequestId:request_id,
		LenderId:lender_id,
		LendeeId:lendee_id,
		LatestHistoryId:"00000",
	}
	bytes, err := json.Marshal(request)
	if err != nil {
		return nil, errors.New("Error creating Reqest record")
	}
	err = stub.PutState( reqKey, []byte(bytes))
	if err != nil {
		return nil, errors.New("Unable to put the state")
	}

	// Register Items
	for i, itemName := range items{
		s:=strings.Repeat("0",5) + strconv.Itoa(i)
		item_id:=s[len(s)-5:] // 00000 012345
		itemKey:=ITEM_KEY_PREFIX + request_id+"/"+ item_id
		item:=Item{
			RequestId:request_id,
			ItemId:item_id,
			ItemName:itemName,
		}
		bytes, err := json.Marshal(item)
		if err != nil {
			return nil, errors.New("Error creating Reqest record")
		}
		err = stub.PutState( itemKey, []byte(bytes))
		if err != nil {
			return nil, errors.New("Unable to put the state")
		}
	}

	// Register RequestHistory
	hist:=RequestHistory{
		RequestId:request_id,
		HistoryId:request.LatestHistoryId, //00000
		StatusFrom:REQUEST_CREATED,
		StatusTo:ITEMS_SHIPPED_TO_LENDER,
		TimeStamp:timestamp,
		Note:"",
	}
	histKey := HIST_KEY_PREFIX + hist.RequestId+"/"+hist.HistoryId
	histBytes, err := json.Marshal(hist)
	if err != nil {
		return nil, errors.New("Error creating Reqest record")
	}
	err = stub.PutState( histKey, []byte(histBytes))
	if err != nil {
		return nil, errors.New("Unable to put the state")
	}

	increment_req_ctr(stub)
	return nil, nil
}


func (t *SimpleChaincode) change_request_status(stub *shim.ChaincodeStub, request_id string, status_from string, status_to string, timestamp string) ([]byte, error) {

	// check status_from -> status_to is a valid transition
	// the followings are allowed combination.
	// ITEMS_SHIPPED_TO_LENDER => ITEMS_RECEIVED_BY_LENDER
	// ITEMS_RECEIVED_BY_LENDER =>ITEMS_SHIPPED_BY_LENDER
	// ITEMS_SHIPPED_BY_LENDER => ITEMS_RECEIVED_BY_LENDEE

	from, err := strconv.Atoi(status_from); if err != nil {panic(err)}
	to, err := strconv.Atoi(status_to); if err != nil {panic(err)}
	if 	( from == ITEMS_SHIPPED_TO_LENDER   && to == ITEMS_RECEIVED_BY_LENDER ) ||
		( from ==  ITEMS_RECEIVED_BY_LENDER && to == ITEMS_SHIPPED_BY_LENDER) ||
		( from == ITEMS_SHIPPED_BY_LENDER   && to == ITEMS_RECEIVED_BY_LENDEE) {
		// OK.
	} else {
		return nil, errors.New("Invalid transision of status")
	}

	// Get Request
	var req Request
	reqKey := REQ_KEY_PREFIX + request_id
	requestAsByte, err := stub.GetState( reqKey)
	if err != nil {
		return nil, errors.New("Unable to get the state " + reqKey)
	}
	if err = json.Unmarshal(requestAsByte, &req) ; err != nil {
		return nil, errors.New("Error unmarshalling data "+string(requestAsByte))
	}

	// Get RequestHistory and check if the current status is equal to status_from
	var hist RequestHistory
	statusKey:= HIST_KEY_PREFIX +req.RequestId+"/"+req.LatestHistoryId
	histAsbytes, err := stub.GetState(statusKey)
	if err != nil {return nil, errors.New("Error getting history data of "+statusKey)}
	if err = json.Unmarshal(histAsbytes, &hist) ; err != nil {return nil, errors.New("Error unmarshalling data "+string(histAsbytes))}
	if hist.StatusTo != from {return nil, errors.New("Error: current status and status_from doesn't match.")}

	// Register RequestHistory
	hid, err := strconv.Atoi(string(hist.HistoryId) ); if err != nil {panic(err)}
	str:=strings.Repeat("0",5)+ strconv.Itoa(hid + 1)
	newHid := str[len(str)-5:]
	newHist:=RequestHistory{
		RequestId:request_id,
		HistoryId:newHid, //00000
		StatusFrom:REQUEST_CREATED,
		StatusTo:ITEMS_SHIPPED_TO_LENDER,
		TimeStamp:timestamp,
		Note:"",
	}
	newHistKey := HIST_KEY_PREFIX + newHist.RequestId+"/"+newHist.HistoryId
	newHistBytes, err := json.Marshal(newHist)
	if err != nil {
		return nil, errors.New("Error creating newHist record")
	}
	err = stub.PutState( newHistKey, []byte(newHistBytes))
	if err != nil {
		return nil, errors.New("Unable to put the state")
	}


	//increment LatestHistoryId
	req.LatestHistoryId = newHist.HistoryId
	newReqBytes, err := json.Marshal(req)
	if err != nil {
		return nil, errors.New("Error creating newHist record")
	}
	err = stub.PutState( reqKey, []byte(newReqBytes))
	if err != nil {
		return nil, errors.New("Unable to put the state " + reqKey)
	}


	return nil, nil
}

func (t *SimpleChaincode) get_all_requests(stub *shim.ChaincodeStub) ([]byte, error) {

	var rset RequestSet
	var req Request
	var record RequestRecord
	var items []Item
	var item Item
	var hist RequestHistory

	reqsIter, err := stub.RangeQueryState(REQ_KEY_PREFIX, REQ_KEY_PREFIX + "~")
	if err != nil {
		return nil, errors.New("Unable to start the iterator")
	}

	defer reqsIter.Close()

	for reqsIter.HasNext() {
		_, valAsbytes, iterErr := reqsIter.Next()
		if iterErr != nil {
			return nil, errors.New("keys operation failed. Error accessing next state")
		}

		if err = json.Unmarshal(valAsbytes, &req) ; err != nil {
			return nil, errors.New("Error unmarshalling data "+string(valAsbytes))
		}

		items = nil
		itemsIter, err := stub.RangeQueryState( ITEM_KEY_PREFIX +req.RequestId+"/", ITEM_KEY_PREFIX +req.RequestId+"/~")
		if err != nil {
			return nil, errors.New("Unable to start the iterator")
		}
		for itemsIter.HasNext() {
			_, itemAsbytes, err := itemsIter.Next()
			if err != nil {	return nil, fmt.Errorf("keys operation failed. Error accessing state: %s", err)	}
			if err = json.Unmarshal(itemAsbytes, &item) ; err != nil { return nil, errors.New("Error unmarshalling data "+string(itemAsbytes))}
			items = append(items,item)
		}
		itemsIter.Close()

		statusKey:= HIST_KEY_PREFIX +req.RequestId+"/"+req.LatestHistoryId
		histAsbytes, err := stub.GetState(statusKey)
		if err != nil {return nil, errors.New("Error getting history data of "+statusKey)}
		if err = json.Unmarshal(histAsbytes, &hist) ; err != nil {return nil, errors.New("Error unmarshalling data "+string(histAsbytes))}

		record = RequestRecord{
			RequestId:req.RequestId ,
			LenderId:req.LenderId ,
			LendeeId:req.LendeeId ,
			LatestHistoryId:req.LatestHistoryId ,
			UpdatedTimeStamp:hist.TimeStamp,
			Items:items  ,
			Status:status_in_string(hist.StatusTo)  ,
		}

		rset.Requests = append(rset.Requests,record)
	}

	bytes, err := json.Marshal(rset.Requests)
	if err != nil {
		return nil, errors.New("Error creating Reqests record")
	}
	return []byte(bytes), nil
}


func (t *SimpleChaincode) get_request(stub *shim.ChaincodeStub, request_id string) ([]byte, error) {

	var req Request
	var record RequestRecord
	var items []Item
	var item Item
	var histories []RequestHistory
	//var histories RequestHistories
	var hist RequestHistory

	// get request
	valAsbytes, err := stub.GetState(REQ_KEY_PREFIX + request_id)
	if err != nil {return nil, errors.New("Error getting request data of "+ request_id)}
	if err = json.Unmarshal(valAsbytes, &req) ; err != nil {
		return nil, errors.New("Error unmarshalling data "+string(valAsbytes))
	}

	items = nil
	itemsIter, err := stub.RangeQueryState(ITEM_KEY_PREFIX +req.RequestId+"/", ITEM_KEY_PREFIX + req.RequestId+"/~")
	if err != nil {
		return nil, errors.New("Unable to start the iterator")
	}
	for itemsIter.HasNext() {
		_, itemAsbytes, err := itemsIter.Next()
		if err != nil {	return nil, errors.New("Error getting items related to "+ request_id)	}
		if err = json.Unmarshal(itemAsbytes, &item) ; err != nil { return nil, errors.New("Error unmarshalling data "+string(itemAsbytes))}
		items = append(items,item)
	}
	itemsIter.Close()

	statusKey:= HIST_KEY_PREFIX + req.RequestId+"/"+req.LatestHistoryId
	histAsbytes, err := stub.GetState(statusKey)
	if err != nil {return nil, errors.New("Error getting history data of "+statusKey)}
	if err = json.Unmarshal(histAsbytes, &hist) ; err != nil {return nil, errors.New("Error unmarshalling data "+string(histAsbytes))}

	histIter, err := stub.RangeQueryState( HIST_KEY_PREFIX + req.RequestId+"/", HIST_KEY_PREFIX +req.RequestId+"/~")
	if err != nil {
		return nil, errors.New("Unable to start the iterator")
	}
	for histIter.HasNext() {
		_, hiAsbytes, err := histIter.Next()
		if err != nil {	return nil, errors.New("Error getting history data " )	}
		if err = json.Unmarshal(hiAsbytes, &hist) ; err != nil { return nil, errors.New("Error unmarshalling data "+string(hiAsbytes))}
		hist.StatusFrom_s = status_in_string(hist.StatusFrom)
		hist.StatusTo_s = status_in_string(hist.StatusTo)
		histories = append(histories,hist)
	}
	histIter.Close()
	//sort.Sort(histories)
	histories = sort_history(histories)

	record = RequestRecord{
		RequestId:req.RequestId ,
		LenderId:req.LenderId ,
		LendeeId:req.LendeeId ,
		LatestHistoryId:req.LatestHistoryId ,
		UpdatedTimeStamp:hist.TimeStamp,
		Items:items  ,
		Status:status_in_string(hist.StatusTo)  ,
		Histories:histories,
	}

	bytes, err := json.Marshal(record)
	if err != nil {
		return nil, errors.New("Error creating Reqests record")
	}
	return []byte(bytes), nil
}


func (t *SimpleChaincode) get_all(stub *shim.ChaincodeStub) ([]byte, error) {


	var tupples [][]string

	keysIter, err := stub.RangeQueryState("", "~")
	if err != nil {
		return nil, errors.New("Unable to start the iterator")
	}

	defer keysIter.Close()

	for keysIter.HasNext() {
		key, val, iterErr := keysIter.Next()
		if iterErr != nil {
			return nil, fmt.Errorf("keys operation failed. Error accessing state: %s", err)
		}
		tupple := []string{ key , string(val) }
		tupples=append(tupples, tupple)

	}

	marshalledTupples, err := json.Marshal(tupples)
	return []byte(marshalledTupples), nil
}

func validate_timestamp(timestamp string) (bool) {
	time_on_timestamp , err := time.Parse(time.RFC3339Nano, timestamp)
	//time_on_timestamp , err := time.Parse(time.RFC3339Nano, "2013-06-05T14:1043.678Z")
	if err == nil && math.Abs(time_on_timestamp.Sub(time.Now()).Minutes()) <= MAX_TIME_DIFF_IN_MIN {
		return true
	}
	return false
}

func next_req_ctr(stub *shim.ChaincodeStub) (string) {
	next_ctr, err := stub.GetState(REQ_CTR_KEY)
	if err != nil || len(next_ctr) == 0 {
		panic("Failed to GetState")
	}
	ctr, err := strconv.Atoi(string(next_ctr) )
	if err != nil {panic(err)}
	if ctr > 60000  {
		panic("Counter overflow.")
	}

	str:=strings.Repeat("0",5)+ strconv.Itoa(ctr + 1)
	return str[len(str)-5:]
}

func increment_req_ctr(stub *shim.ChaincodeStub) () {
	next_ctr, err := stub.GetState(REQ_CTR_KEY)
	if err != nil || len(next_ctr) == 0 {
		panic("Failed to GetState")
	}
	ctr, err := strconv.Atoi(string(next_ctr) )
	if err != nil {panic(err)}
	str:=strings.Repeat("0",5)+ strconv.Itoa(ctr + 1)
	stub.PutState("REQ_CTR",[]byte(str[len(str)-5:]))
	return
}

func status_in_string(status int) (string) {
	var val = ""
	switch status{
		case REQUEST_CREATED : val = "REQUEST_CREATED" //  initial state, items can only be added at this state.
		case ITEMS_SHIPPED_TO_LENDER: val = "ITEMS_SHIPPED_TO_LENDER" //  lender has sent the item
		case ITEMS_RECEIVED_BY_LENDER : val = "ITEMS_RECEIVED_BY_LENDER"  //  lendee has received the item
		case ITEMS_SHIPPED_BY_LENDER : val = "ITEMS_SHIPPED_BY_LENDER" //  lendee has sent back the item
		case ITEMS_RECEIVED_BY_LENDEE : val = "ITEMS_RECEIVED_BY_LENDEE"  //  lender has received the item back
	}
	return val
}


func status_in_int(status string) (int) {
	var val int
	switch status{
		case "REQUEST_CREATED" : val = REQUEST_CREATED //  initial state, items can only be added at this state.
		case "ITEMS_SHIPPED_TO_LENDER": val = ITEMS_SHIPPED_TO_LENDER //  lender has sent the item
		case "ITEMS_RECEIVED_BY_LENDER" : val = ITEMS_RECEIVED_BY_LENDER  //  lendee has received the item
		case "ITEMS_SHIPPED_BY_LENDER" : val = ITEMS_SHIPPED_BY_LENDER //  lendee has sent back the item
		case "ITEMS_RECEIVED_BY_LENDEE" : val = ITEMS_RECEIVED_BY_LENDEE  //  lender has received the item back
	}
	return val
}

func sort_history(history []RequestHistory) ([]RequestHistory){
	var toSort RequestHistories= history
	sort.Sort(toSort)
	var sorted []RequestHistory = toSort
	return sorted
}


//=================================================================================================================================
//	 Main - main - Starts up the chaincode
//=================================================================================================================================
func main() {

	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Chaincode: %s", err)
	}
}
