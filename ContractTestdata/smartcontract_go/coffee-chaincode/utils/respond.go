package utils

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"github.com/vtfr/rocha"
)

// RespondJSON receives a handler returning (interface{}, error) and converts
// it to a valid JSON pb.Response or an error pb.Response
func RespondJSON(h func(c rocha.Context) (interface{}, error)) rocha.Handler {
	return func(c rocha.Context) pb.Response {
		ret, err := h(c)
		if err != nil {
			return shim.Error(err.Error())
		}

		// if no data is sent, return simple Success message
		if ret == nil {
			return shim.Success(nil)
		}

		// encode JSON data
		data, err := json.Marshal(ret)
		if err != nil {
			return shim.Error(fmt.Sprintf("Failed encoding response: %s", err.Error()))
		}
		return shim.Success(data)
	}
}
