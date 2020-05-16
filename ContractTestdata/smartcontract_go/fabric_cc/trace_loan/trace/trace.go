package trace

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"strconv"
	"encoding/json"
)




//invoke
//实现贷款功能
//-c `{"Args":["loan","身份证号码","银行名称","贷款金额"]}`
func Loan(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//获取参数
	amount,err := strconv.Atoi(args[2])
	if err!=nil{
		return shim.Error("给定的贷款金额错误")
	}

	//创建银行和账户对象
	bank := Bank{
		args[1],
		Bank_flag_loan,
		amount,
		"20100901",
		"20101201",
	}

	account := Account{
		CardNo:args[0],
		AName:"jack",
		Age:29,
		Gender:"男",
		Mobil:"6234567",
		Bank:bank,
	}


	//保存账户
	bl := saveAccount(stub,account)
	if !bl {
		return shim.Error("保存贷款记录失败")
	}

	//给出返回值
	return shim.Success([]byte("贷款成功"))

}





//invoke
//实现还款功能
// -c `{"Args":["loan","身份证号码","银行名称","还款金额"]}`
func Repayment(stub shim.ChaincodeStubInterface,args []string) peer.Response {


	//获取参数
	amount,err := strconv.Atoi(args[2])
	if err !=nil {
		return shim.Error("贷款金额输入有误 ")
	}



	//创建银行和账户对象
	bank := Bank{
		BankName: args[1],
		Flag:Bank_flag_repayment,
		Amount:amount,
		StartDate:"20101001",
		EndDate:"20101201",
	}

	account := Account{
		CardNo:args[0],
		AName:"jack",
		Age:29,
		Gender:"男",
		Mobil:"6234567",
		Bank:bank,
	}


	//保存账户
	bl :=saveAccount(stub,account)
	if !bl {
		return shim.Error("保存还款记录失败")
	}


	//给出返回值
	return shim.Success([]byte("此次还款成功"))

}





//invoke
//根据卡号查询账户
//-c `{"Args":"QueryAccountByCardNo","身份证号码"}`
func QueryAccountByCardNo(stub shim.ChaincodeStubInterface,args []string) peer.Response {


	//判断参数有效性
	if len(args) != 1{
		return shim.Error("必须且只能指定要查询的账户信息的身份证号码")
	}


    //获取账户
	account,bl := GetAccountByNo(stub,args[0])
	if !bl {
		return shim.Error("查询账户时发生错误")
	}


	//查询历史记录

	//1，获取迭代器
	accIterator,err := stub.GetHistoryForKey(account.CardNo)
	if err!=nil {
		return shim.Error("查询历史记录失败")
	}
	defer accIterator.Close()


	var historys []HistoryItem
	var acc Account

	//2，迭代，accIterator.Next()
	for accIterator.HasNext(){

		hisData,err := accIterator.Next()
		if err != nil{
			return shim.Error("处理迭代器对象时发生错误")
		}

		var hisItem HistoryItem
		hisItem.TxId = hisData.TxId
		err = json.Unmarshal(hisData.Value,&acc)
		if err != nil {
			return shim.Error("反序列化历史状态时发生错误")
		}

		//3，处理当前记录状态为nil的情况
		if hisData.Value == nil {
			var empty Account
			hisItem.Account= empty
		}else {
			hisItem.Account =acc
		}

		//将当前处理完毕的历史状态保存到数组中
		historys = append(historys,hisItem)

	}
	account.Historys = historys



	//处理获取的历史记录
	accByte,err :=json.Marshal(account)
	if err !=nil{
		return shim.Error("将账户信息序列化时发生错误")
	}

	//给出返回值
	return shim.Success(accByte)



}





//保存账户
func saveAccount(stub shim.ChaincodeStubInterface,account Account) bool {

	//将账户序列化
	acc,err := json.Marshal(account)
	if err != nil {
		shim.Error("账户序列化有误")
	}


	//将账户存储起来
	err = stub.PutState(account.CardNo,acc)
	if err != nil {
		return false
	}

	//补上返回值
	return true

}



//根据账号查询账户
func GetAccountByNo(stub shim.ChaincodeStubInterface, cardNo string) (Account,bool)  {


	//根据账号查询账户状态
	var account Account
	result,err := stub.GetState(cardNo)
	if err!= nil {
		return account,false
	}

	//将结果反序列化
	err = json.Unmarshal(result,&account)
	if err != nil {
		return account,false
	}
	return account,true

}