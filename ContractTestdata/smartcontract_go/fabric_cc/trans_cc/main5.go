package main

import (
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"strconv"
	"fmt"
)

type trasactionChiancode struct {
}

//init
func (trans *trasactionChiancode) Init(stub shim.ChaincodeStubInterface) peer.Response {

	//第一步获取参数
	_, args := stub.GetFunctionAndParameters()
	if len(args) != 4 {
		return shim.Error("参数个数有误")
	}

	//第二部判断参数是否合法
	var a = args[0]
	var b = args[2]
	var aValueStr = args[1]
	var bValueStr = args[3]

	if len(a) < 2 {
		return shim.Error("账户名称不够长")
	}
	if len(b) < 2 {
		return shim.Error("账户名称不够长")
	}


	//第三部储存账户状态
	//注意，存储时账户金额按string类型存储
	err := stub.PutState(a, []byte(aValueStr))
	if err != nil {
		shim.Error("a数据保存失败")
	}
	err = stub.PutState(b, []byte(bValueStr))
	if err != nil {
		shim.Error("b数据保存失败")
	}

	//第四部给出返回值
	return shim.Success([]byte("初始化成功"))

}

//invoke
//有几个方法：find,payment，delAccount，set，get
func (trans *trasactionChiancode) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	//第一步获取参数
	fun, args := stub.GetFunctionAndParameters()

	//第二部判断方法并调用
	if fun == "find" {
		return find(stub, args)
	} else if fun == "payment" {
		return payment(stub, args)
	} else if fun == "delAccount" {
		return delAccount(stub, args)
	} else if fun == "set" {
		return set(stub, args)
	} else if fun == "get" {
		return get(stub, args)
	}

	//第三部给出返回值
	return shim.Error("非法操作，指定功能尚未实现")
}



//方法实现
//find
func find(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//判断参数是否正确
	if len(args)!=1{
		return shim.Error("只能指定一个账户名称")
	}
	
	//查询状态
	balance ,err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("账户查询失败")
	}

	//判断返回结果
	if balance == nil {
		return shim.Error("查询结果不存在")
	}


	//给出返回值
	return shim.Success(balance)



}


//payment
func payment(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//判断参数
	if len(args)!=3 {
		return shim.Error("参数个数有误")
	}


	//查询余额并判断
	var from = args[0]
	var amount = args[2]
	var to = args[1]

	//获取from的余额
	fromBalance,err := stub.GetState(from)
	if err != nil {
		return shim.Error("from账户查询失败")
	}
	fromBal,err := strconv.Atoi(string(fromBalance))
	if err!=nil {
		return shim.Error("from账户金额处理失败")
	}

	//获取to的余额
	toBalance ,err := stub.GetState(to)
	if err != nil {
		return shim.Error("to账户查询失败")
	}
	toBal,err := strconv.Atoi(string(toBalance))
	if err!=nil {
		return shim.Error("to账户金额处理失败")
	}


	//判断余额是否足够
	amo ,err := strconv.Atoi(amount)
	if err != nil {
		return shim.Error("转账金额处理失败")
	}
	if fromBal < amo {
		return shim.Error("余额不足")
	}


	//支付
	fromBal = fromBal - amo
	toBal = toBal + amo


	//重置余额,保存状态
	err = stub.PutState(from,[]byte(strconv.Itoa(fromBal)))
	if err!=nil {
		return shim.Error("from账户重置失败")
	}
	err = stub.PutState(to,[]byte(strconv.Itoa(toBal)))
	if err!=nil {
		return shim.Error("to账户重置失败")
	}


	//给出返回值
	return shim.Success([]byte("转账成功"))

}


//delAccount
func delAccount(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//判断参数
	if len(args)!= 1 {
		return shim.Error("请指定一个要删除的账户")
	}


	//查找账户
	account,err := stub.GetState(args[0])
	if err!=nil {
		return shim.Error("获取账户失败")
	}
	if account == nil {
		return shim.Error("账户查询结果为空")
	}

	//删除账户
	err = stub.DelState(args[0])
	if err!= nil {
		return shim.Error("账户删除失败")
	}



	//给出返回值
	return shim.Success([]byte("账户删除成功"))

}


//set
func set(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//获取参数
	if len(args)!= 2 {
		return shim.Error("请指定账户名称和存入金额")
	}

	amount,err := strconv.Atoi(args[1])
	if err !=nil {
		return shim.Error("转账金额处理失败")
	}


	//查找账户
	result,err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("账户查询失败")
	}
	if result == nil {
		return shim.Error("账户内容不存在")
	}

	//处理账户金额
	balance,err := strconv.Atoi(string(result))
	if err !=nil {
		return shim.Error("金额处理错误")
	}



	//存入
	balance= balance+amount


	//重置账户状态
	err = stub.PutState(args[0],[]byte(strconv.Itoa(balance)))
	if err!=nil {
		return shim.Error("账户存储失败")
	}



	//给出返回值
	return shim.Success([]byte("存款成功"))

}




//get
func get(stub shim.ChaincodeStubInterface,args []string) peer.Response {

	//获取参数
	if len(args) != 2{
		return shim.Error("请输入指定的账户及金额")
	}

	amount,err := strconv.Atoi(args[1])
	if err!=nil {
		return shim.Error("金额转换失败")
	}



	//查询账户
	result,err := stub.GetState(args[0])
	if err != nil {
		return shim.Error("账户查询失败")
	}
	if result == nil {
		return shim.Error("账户内容不存在")
	}



	//判断余额
	balance,err := strconv.Atoi(string(result))
	if err!= nil {
		return shim.Error("金额转换出错")
	}

	if balance<amount {
		return shim.Error("账户余额不足")
	}


	//取款
	balance= balance-amount



	//重置账户状态i
	err = stub.PutState(args[0],[]byte(strconv.Itoa(balance)))
	if err!=nil {
		return shim.Error("账户重置失败")
	}


	//给出返回值
	return shim.Success([]byte("取款成功"))

}

func main() {
	err := shim.Start(new(trasactionChiancode))
	if err!= nil {
		fmt.Errorf("链码启动失败")
	}
}