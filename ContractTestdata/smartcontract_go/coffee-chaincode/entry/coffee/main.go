package main

import (
	"github.com/cdtlab19/coffee-chaincode/chaincode"
	"github.com/hyperledger/fabric/core/chaincode/shim"
)

func main() {
	logger := shim.NewLogger("coffee")
	coffeeChaincode := chaincode.NewCoffeeChaincode(logger)

	if err := shim.Start(coffeeChaincode); err != nil {
		logger.Critical("Chaincode Error: %s", err.Error())
	}
}
