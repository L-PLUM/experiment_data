package main

import (
	"fmt"
	"encoding/json"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"time"
	"strconv"
)

// search表的映射名
const IndexName = "holderName~billNo"

// 账单数据结构
type Bill struct {
	TaskId string `json:"task_id"`
	UserCode string `json:"user_code"`
	VersionId string `json:"version_id"`
	VersionTime string `json:"version_time"`
	ContractCode string `json:"contract_code"`
	PurchaserUserCode string `json:"purchaser_user_code"`
	PublishTime string  `json:"publish_time`
	BidingStartTime string `json:"biding_start_time"`
	BidingEndTime string `json:"biding_end_time"`
	DealTime string `json:"deal_time"`
	CloseTime string `json:"close_time"`
	ContractStartTime string `json:"contract_start_time"`
	ContractEndTime string `json:"contract_end_time"`
	LinkStart string `json:"link_start"`
	LinkEnd string `json:"link_end"`
	PathList []Path `json:"path_list"`
	ContractStatus string `json:"contract_status"`
}
//路径信息结构
type Path struct {
	PathStart string `json:"path_start"`
	PathEnd string `json:"path_end"`
	PathBandwidth string `json:"path_bandwidth"`
	PathPacketLossRate string `json:"path_packet_loss_rate"`
	PathAvgRtt string `json:"path_avg_rtt"`
	PathResourceList []PathResource `json:"path_resource_list"`
}
//路径资源结构
type PathResource struct {
	SupplyerUserCode string `json:"supplyer_user_code"`
	PathBandwidth string `json:"path_bandwidth"`
	PathPacketLossRate string `json:"path_packet_loss_rate"`
	PathAvgRtt string `json:"path_avg_rtt"`
	PathBandwidthUnitPrice string `json:"path_bandwidth_unit_price"`
	PathDealStatus string `json:"path_deal_status"`
}
//合约关闭时账单数据结构
type BillClose struct {
	TaskId string `json:"task_id"`
	UserCode string `json:"user_code"`
	ContractCode string `json:"contract_code"`
	CloseTime string `json:"close_time"`
	ContractStatus string `json:"contract_status"`
}
//合约成交时账单数据结构
type BillDeal struct {
	TaskId string `json:"task_id"`
	UserCode string `json:"user_code"`
	ContractCode string `json:"contract_code"`
	DealTime string `json:"deal_time"`
	PathList []PathOfDeal `json:"path_list"`
	ContractStatus string `json:"contract_status"`
}
//合约成交时链路数据结构
type PathOfDeal struct {
	PathStart string `json:"path_start"`
	PathEnd string `json:"path_end"`
	PathResourceList []PathResourceOfDeal `json:"path_resource_list"`
}
//合约成交时链路资源数据结构
type PathResourceOfDeal struct {
	SupplyerUserCode string `json:"supplyer_user_code"`
	PathDealStatus string `json:"path_deal_status"`
}

//投标账单数据结构
type BidingBill struct {
	TaskId string `json:"task_id"`
	UserCode string `json:"user_code"`
	ContractCode string `json:"contract_code"`
	PathList []PathOfBiding `json:"path_list"`
}
//投标时链路资源数据结构
type PathOfBiding struct {
	PathStart string `json:"path_start"`
	PathEnd string `json:"path_end"`
	PathResourceList []PathResource `json:"path_resource_list"`
}
//查询账单数据结构
type QueryBill struct {
	TaskId string `json:"task_id"`
	UserCode string `json:"user_code"`
	ContractCode string `json:"contract_code"`
	VersionType string `json:"version_type"`      //last  whole
}
//链码查询返回结构
type queryRet struct {
	Result int `json:"result"` // 1 success otherwise 0
	ErrorCode int `json:"error_code"`  //0:no error 1000:parameter error 2000:content format error
	ErrorMsg string `json:"error_msg"`
	//Code int // 0 success otherwise 1
	//Des  string //description
	DataList []Bill `json:"data_list"`
}

//链码返回结构
type chaincodeRet struct {
	Result int `json:"result"` // 1 success otherwise 0
	ErrorCode int `json:"error_code"`  //0:no error 1000:parameter error 2000:content format error
	ErrorMsg string `json:"error_msg"`
}

// chaincode
type BillChaincode struct {
}

// 根据返回码和描述返回序列号后的字节数组
func getRetByte(result int,code int,msg string) []byte {
	var r chaincodeRet
	r.Result = result
	r.ErrorCode = code
	r.ErrorMsg = msg

	b,err := json.Marshal(r)

	if err!=nil {
		fmt.Println("marshal Ret failed")
		return nil
	}
	return b
}

// 根据返回码和描述返回序列号后的字符串
func getRetString(result int,code int,msg string) string {
	var r chaincodeRet
	r.Result = result
	r.ErrorCode = code
	r.ErrorMsg = msg

	b,err := json.Marshal(r)

	if err!=nil {
		fmt.Println("marshal Ret failed")
		return ""
	}
	return string(b[:])
}
func getQueryByte(result int,code int,msg string,hist []Bill) []byte {
	var r queryRet
	r.Result = result
	r.ErrorCode = code
	r.ErrorMsg = msg
	r.DataList = hist

	b,err := json.Marshal(r)

	if err!=nil {
		fmt.Println("marshal Ret failed")
		return nil
	}
	return b
}

//初始化默认
func (a *BillChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

//链码Invoke接口
func (a *BillChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function,args := stub.GetFunctionAndParameters()
	//invoke
	if function == "link_contract_create" {
		//发布合约（招标）
		return a.LinkContractCreate(stub, args)
	} else if function == "link_contract_deal" {
		//合约成交
		return a.LinkContractDeal(stub, args)
	} else if function == "link_contract_biding" {
		//合约响应
		return a.LinkContractBiding(stub, args)
	} else if function == "link_contract_close" {
		// 合约关闭
		return a.LinkContractClose(stub, args)
	}

	if function == "query" {
		// the old "Query" is now implemtned in invoke
		return a.query(stub, args)
	}

	res := getRetString(0,1000,"AlgobluChaincode Unknown method!")
	return shim.Error(res)
}

//保存合约
func (a *BillChaincode) putBill(stub shim.ChaincodeStubInterface, bill Bill) ([]byte, bool) {

	byte,err := json.Marshal(bill)
	if err!=nil {
		return nil, false
	}

	err = stub.PutState(bill.ContractCode, byte)
	if err!=nil {
		return nil, false
	}
	return byte, true
}

//根据合约号取出合约
func (a *BillChaincode) getBill(stub shim.ChaincodeStubInterface, bill_No string) (Bill, bool) {

	var bill Bill
	key := bill_No
	b,err := stub.GetState(key)
	if b == nil {
		return bill, false
	}

	err = json.Unmarshal(b,&bill)
	if err!=nil {
		return bill, false
	}
	return bill, true
}

//发布合约
func (a *BillChaincode) LinkContractCreate(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//判断输入参数格式是否正确
	if len(args)!=1 {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractCreate args != 1")
		return shim.Error(res)
	}

	//将输入参数解析到结构体
	arg :=[]byte(args[0])
	bill := Bill{}
	err := json.Unmarshal(arg, &bill)
	if err != nil {
		res := getRetString(0,2000,"AlgobluChaincode Invoke LinkContractCreate unmarshal failed")
		fmt.Println(res)
		return shim.Error(res)
	}
	
	//如果合约代码为空则返回错误
	if bill.ContractCode == ""{
		res := getRetString(0,2000,"AlgobluChaincode Invoke LinkContractCreate contract_code can not be empty!")
		fmt.Println(res)
		return shim.Error(res)
	}

	//根据链路合约代码查找是否合约代码已存在
	_,existbl := a.getBill(stub, bill.ContractCode)
	if existbl {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractCreate failed : the ContractCode has exist!")
		return shim.Error(res)
	}

	//判断调用接口的用户代码和采购方用户代码是否相同
	if bill.UserCode != bill.PurchaserUserCode {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractCreate failed : invalid PurchaserUserCode!")
		return shim.Error(res)
	}

	bill.ContractStatus = "publish"
	bill.VersionId = stub.GetTxID()
	t := time.Now()
	fmt.Println(t)
	timestamp := t.Unix()
	fmt.Println(strconv.FormatInt(timestamp, 10))
	bill.VersionTime = strconv.FormatInt(timestamp, 10)
	_,bl := a.putBill(stub,bill)
	if !bl {
		res := getRetString(0,2000,"AlgobluChaincode Invoke LinkContractCreate putdata failed!")
		return shim.Error(res)
	}

	fmt.Println(bill)
	res := getRetByte(1,0,"Invoke LinkContractCreate success")
	return shim.Success(res)
}

//响应账单
func (a *BillChaincode) LinkContractBiding(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//判断输入参数格式是否正确
	if len(args)!=1 {
		res := getRetString(0, 1000,"AlgobluChaincode Invoke biding args != 1")
		return shim.Error(res)
	}

	//解析输入参数到结构体中
	arg :=[]byte(args[0])
	biding_bill := &BidingBill{}
	err := json.Unmarshal(arg, biding_bill)
	if err!=nil {
		res := getRetString(0, 2000,"AlgobluChaincode json transfer error!")
		return shim.Error(res)
	}

	//根据链路合约代码查找是否合约代码不存在
	key_id := biding_bill.ContractCode
	bill ,bl := a.getBill(stub, key_id)
	if !bl {
		res := getRetString(0,2000,"AlgobluChaincode Invoke accept get bill error：the ContractCode does not exist")
		return shim.Error(res)
	}

	//判断该合约是否已成交或结束
	if bill.ContractStatus == "deal"{
		res := getRetString(0,2000,"AlgobluChaincode Invoke biding error：the ContractCode has been dealt.")
		return shim.Error(res)
	}else if bill.ContractStatus == "close"{
		res := getRetString(0,2000,"AlgobluChaincode Invoke biding error：the ContractCode has been closed.")
		return shim.Error(res)
	}


	//判断PathList长度是否相同
	if len(bill.PathList)!=len(biding_bill.PathList) {
		res := getRetString(0,1000,"PathList Length is not same!!")
		return shim.Error(res)
	}

	//更改票据信息并保存票据
	i := 0
	for i<len(biding_bill.PathList) {
		fmt.Println("Path List ", i)
		if len(biding_bill.PathList[i].PathResourceList) != 1 {
			res := getRetString(0,1000,"ResourceList Length must be 1 !!")
			return shim.Error(res)
		}
		//判断UserCode是否相同
		if biding_bill.PathList[i].PathResourceList[0].SupplyerUserCode!=biding_bill.UserCode {
			res := getRetString(0,1000,"UserCode is not same!!")
			return shim.Error(res)
		}
		//判断是否已经投标
		if len(biding_bill.PathList[i].PathResourceList) != 0{
			for j:=0;j<len(bill.PathList[i].PathResourceList);j++{
				if bill.PathList[i].PathResourceList[j].SupplyerUserCode == biding_bill.PathList[i].PathResourceList[0].SupplyerUserCode{
					res := getRetString(0,2000,"AlgobluChaincode Invoke biding error：the path of ContractCode cannot be bidded twice.")
					return shim.Error(res)
				}
			}
		}
		j := 0
		for j<len(bill.PathList) {
			if biding_bill.PathList[i].PathStart==bill.PathList[j].PathStart && biding_bill.PathList[i].PathEnd==bill.PathList[j].PathEnd && len(biding_bill.PathList[i].PathResourceList)==1 {
				bill.PathList[j].PathResourceList = append(bill.PathList[j].PathResourceList, biding_bill.PathList[i].PathResourceList[0])
			}
			j = j + 1
		}
		i = i + 1
	}
	bill.VersionId = stub.GetTxID()
	t := time.Now()
	fmt.Println(t)
	timestamp := t.Unix()
	fmt.Println(timestamp)
	bill.VersionTime = strconv.FormatInt(timestamp, 10)
	fmt.Println(bill)

	_,bl = a.putBill(stub, bill)
	bill,bl = a.getBill(stub, key_id)
	fmt.Println(bill)
	if !bl {
		res := getRetString(0,1000,"AlgobluChaincode Invoke biding putdata failed!")
		return shim.Error(res)
	}

	res := getRetByte(1,0, "invoke biding success!")
	return shim.Success(res)
}

//合约成交
func (a *BillChaincode) LinkContractDeal(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//判断输入参数格式是否正确
	if len(args)!=1 {
		res := getRetString(0,1000,"AlgobluChaincode Invoke linkContractDeal args != 1")
		return shim.Error(res)
	}

	//解析输入参数到结构体中
	arg :=[]byte(args[0])
	billdeal := &BillDeal{}
	err := json.Unmarshal(arg, billdeal)
	if err != nil {
		res := getRetString(0,2000,"AlgobluChaincode Invoke linkContractDeal unmarshal failed")
		fmt.Println(res)
		return shim.Error(res)
	}

	//根据链路合约代码查找是否合约代码不存在
	bill,existbl := a.getBill(stub, billdeal.ContractCode)
	if !existbl {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractDeal failed : the ContractCode does not exist")
		return shim.Error(res)
	}

	//判断调用接口的用户代码和采购方用户代码是否相同
	if billdeal.UserCode != bill.PurchaserUserCode {
		res := getRetString(0,1000,"AlgobluChaincode Invoke linkContractDeal failed : invalid PurchaserUserCode")
		return shim.Error(res)
	}

	//判断该合约是否已成交或结束
	if bill.ContractStatus == "close"{
		res := getRetString(0,2000,"AlgobluChaincode Invoke biding error：the ContractCode has been closed.")
		return shim.Error(res)
	}

	//判断PathList长度是否相同
	if len(bill.PathList)!=len(billdeal.PathList) {
		res := getRetString(0,1000,"PathList Length is not same!!")
		return shim.Error(res)
	}

	//判断是否一个路径只有一个投标成交

	//修改路径成交状态并保存账单
	for i:=0;i<len(bill.PathList);i++{
		for j:=0;j<len(bill.PathList[i].PathResourceList);j++{
			bill.PathList[i].PathResourceList[j].PathDealStatus = billdeal.PathList[i].PathResourceList[j].PathDealStatus
			//判断是否一个路径只有一个投标成交
			n := 0
			if bill.PathList[i].PathResourceList[j].PathDealStatus == "yes"{
				n = n+1
			}
			if n>1{
				res := getRetString(0,2000,"two bidings's status are yes in one path!!")
				return shim.Error(res)
			}
		}
	}
	bill.ContractStatus = "deal"
	bill.VersionId = stub.GetTxID()
	t := time.Now()
	fmt.Println(t)
	timestamp := t.Unix()
	fmt.Println(timestamp)
	bill.VersionTime = strconv.FormatInt(timestamp, 10)
	_,bl := a.putBill(stub,bill)
	if !bl {
		res := getRetString(0,2000,"ChainnovaChaincode Invoke linkContractDeal putdata failed!")
		return shim.Error(res)
	}
	fmt.Println(bill)
	res := getRetByte(1,0,"invoke linkContractDeal success")
	return shim.Success(res)
}

//合约关闭
func (a *BillChaincode) LinkContractClose(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//判断输入参数格式是否正确
	if len(args)!=1 {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractClose args != 1")
		return shim.Error(res)
	}

	//解析输入参数到结构体中
	arg :=[]byte(args[0])
	billclose := &BillClose{}
	err := json.Unmarshal(arg, billclose)
	if err != nil {
		res := getRetString(0,2000,"AlgobluChaincode Invoke LinkContractClose unmarshal failed")
		fmt.Println(res)
		return shim.Error(res)
	}

	//在数据库中创建key-value
	err = stub.PutState(billclose.ContractCode, arg)
	if err!=nil {
		return shim.Error("ChainnovaChaincode Invoke LinkContractClose putdata failed!")
	}

	//根据链路合约代码查找是否合约代码已存在
	bill,existbl := a.getBill(stub, billclose.ContractCode)
	if !existbl {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractClose failed : the ContractCode does not exist")
		return shim.Error(res)
	}

	//判断调用接口的用户代码和采购方用户代码是否相同
	if billclose.UserCode != bill.PurchaserUserCode {
		res := getRetString(0,1000,"AlgobluChaincode Invoke LinkContractClose failed : invalid UserCode")
		return shim.Error(res)
	}

	//更改合约状态并保存账单
	bill.ContractStatus = billclose.ContractStatus
	bill.CloseTime = billclose.CloseTime
	bill.VersionId = stub.GetTxID()
	t := time.Now()
	fmt.Println(t)
	timestamp := t.Unix()
	fmt.Println(timestamp)
	bill.VersionTime = strconv.FormatInt(timestamp, 10)
	_,bl := a.putBill(stub,bill)
	if !bl {
		return shim.Error("AlgobluChaincode Invoke LinkContractClose close failed!")
	}
	fmt.Println(bill)
	res := getRetByte(1,0,"invoke LinkContractClose success")
	return shim.Success(res)
}

//查询合约
//各种类型查询账单
func (a *BillChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args)!=1 {
		res := getRetString(0, 1000,"AlgobluChaincode Invoke query args != 1")
		return shim.Error(res)
	}
	query_bill := &QueryBill{}
	err := json.Unmarshal([]byte(args[0]), query_bill)
	if err!=nil {
		res := getRetString(0, 2000,"AlgobluChaincode query json transfer error!")
		return shim.Error(res)
	}
	fmt.Println(query_bill)
	if query_bill.VersionType == "last" {
		return a.queryLastBill(stub, query_bill.UserCode, query_bill.ContractCode)
	} else {
		return a.queryWholeBill(stub, query_bill.UserCode, query_bill.ContractCode)
	}
}
//删除切片中元素函数
func remove(s []PathResource, i int) []PathResource {
	return append(s[:i], s[i+1:]...)
}
//查询最新账单
func (a *BillChaincode) queryLastBill(stub shim.ChaincodeStubInterface, userCode string, contractCode string) pb.Response {

	key_id := contractCode
	//取得票据
	bill, bl := a.getBill(stub, key_id)
	if !bl {
		res := getRetString(0,1000,"AlgobluChaincode Invoke queryLastBill putdata failed!")
		return shim.Error(res)
	}
	//判断是否为合约发起方，是：发起方回复完整账单 否：返回部分参与账单
	var history []Bill
	if userCode == bill.PurchaserUserCode {
		var hist Bill
		hist = bill
		history = append(history, hist) //add this tx to the list
		res := getQueryByte(1,0,"", history)
		return shim.Success(res)
	} else {
		var hist Bill
		hist = bill
		i := 0
		for i<len(bill.PathList) {
			j := 0
			for j<len(bill.PathList[i].PathResourceList) {
				if userCode != bill.PathList[i].PathResourceList[j].SupplyerUserCode {
					hist.PathList[i].PathResourceList = remove(hist.PathList[i].PathResourceList, j)
					j = j - 1
				}
				j = j + 1
			}
			i = i + 1
		}
		history = append(history, hist)
		res := getQueryByte(1,0,"", history)
		fmt.Println(history)
		return shim.Success(res)
	}

}

// 根据票号取得票据 以及该票据背书历史查询历史账单
//  0 - Bill_No ;
func (a *BillChaincode) queryWholeBill(stub shim.ChaincodeStubInterface, userCode string, contractCode string) pb.Response {
	// 取得该票据
	key_id := contractCode

	// 取得背书历史: 通过fabric api取得该票据的变更历史
	resultsIterator, err := stub.GetHistoryForKey(key_id)
	if err != nil {
		res := getRetString(0,1000,"AlgobluChaincode queryWholeBill GetHistoryForKey error")
		return shim.Error(res)
	}
	defer resultsIterator.Close()

	var history []Bill
	for resultsIterator.HasNext() {
		historyData, err := resultsIterator.Next()
		if err != nil {
			res := getRetString(0,1000,"AlgobluChaincode queryByBillNo resultsIterator.Next() error")
			return shim.Error(res)
		}
		var hist Bill
		//json.Unmarshal(historyData.Value, &hisBill) //un stringify it aka JSON.parse()
		if historyData.Value  == nil {              //bill has been deleted
			var emptyBill Bill
			hist = emptyBill //copy nil marble
		} else {
			json.Unmarshal(historyData.Value, &hist) //un stringify it aka JSON.parse()
			fmt.Println(hist)
		}
		//判断权限
		if userCode == hist.PurchaserUserCode {
			history = append(history, hist) //add this tx to the list
			fmt.Println(history)
		} else {
			i := 0
			for i<len(hist.PathList) {
				j := 0
				for j<len(hist.PathList[i].PathResourceList) {
					if userCode != hist.PathList[i].PathResourceList[j].SupplyerUserCode {
						hist.PathList[i].PathResourceList = remove(hist.PathList[i].PathResourceList, j)
						j = j - 1
					}
					j = j + 1
				}
				i = i + 1
			}
			history = append(history, hist)
			fmt.Println(history)
		}
	}
	// 将背书历史做为票据的一个属性 一同返回
	res := getQueryByte(1,0,"", history)
	return shim.Success(res)
}


func main() {
	if err := shim.Start(new(BillChaincode)); err != nil {
		fmt.Printf("Error starting Bill chaincode: %s", err)
	}
}