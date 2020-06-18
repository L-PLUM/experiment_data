package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"fabric_cc/trace/trace"
	"fmt"
)




/*
loan 增加贷款记录
repayment 增加还款记录
queryAccountByCardNo 根据账号身份证查询相应的信息（包含该账户所有的历史记录）
*/


type Tracechaincode struct{

}


//init
func (t *Tracechaincode)Init(stub shim.ChaincodeStubInterface) peer.Response {

	return shim.Success(nil)

}


//invoke
func (t *Tracechaincode)Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	fun,args := stub.GetFunctionAndParameters()
	if fun == "loan"{
		return trace.Loan(stub,args)
	}else if fun == "repayment" {
		return trace.Repayment(stub,args)
	}else if fun == "queryAccountByCardNo" {
		return trace.QueryAccountByCardNo(stub,args)
	}

	return  shim.Error("指定操作为非法操作")

}

func main() {

	err := shim.Start(new(Tracechaincode))
	if err!= nil {
		fmt.Errorf("启动链码失败：%v",err)
	}
}


