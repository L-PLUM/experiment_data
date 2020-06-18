package trace


//银行标记
const(
	Bank_flag_loan = 1  //代表贷款
	Bank_flag_repayment = 2  //代表还款
)


//银行：银行名称，银行标记，账户金额，贷款日期，还款日期
type Bank struct {
	BankName string  `json:"bankname"`
	Flag int  `json:"flag"`
	Amount int  `json:"amount"`
	StartDate string  `json:"startdata"`
	EndDate string  `json:"enddate"`
}


//账户：卡号，户名，年龄，性别，手机号码，银行，历史记录
type Account struct {
	CardNo string `json:"cardno"`
	AName string  `json:"aname"`
	Age int `json:"age"`
	Gender string `json:"gender"`
	Mobil string  `json:"mobil"`
	Bank Bank `json:"bank"`
	Historys []HistoryItem

}


//历史交易记录：交易编号，账户
type HistoryItem struct {
	TxId string
	Account Account
}