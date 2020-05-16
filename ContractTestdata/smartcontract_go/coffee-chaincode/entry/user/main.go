package main

import (
	"github.com/cdtlab19/coffee-chaincode/chaincode"
	"github.com/hyperledger/fabric/core/chaincode/shim"
)

func main() {
	logger := shim.NewLogger("user")
	userChaincode := chaincode.NewUserChaincode(logger)

	if err := shim.Start(userChaincode); err != nil {
		logger.Critical("Chaincode Error: %s", err.Error())
	}
}
