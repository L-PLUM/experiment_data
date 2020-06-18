package chaincode

import (
	"github.com/cdtlab19/coffee-chaincode/model"
	"github.com/cdtlab19/coffee-chaincode/store"
	"github.com/cdtlab19/coffee-chaincode/utils"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"github.com/vtfr/rocha"
	"github.com/vtfr/rocha/argsmw"
)

// CoffeeChaincode is a chaincode for controller coffee assets
type CoffeeChaincode struct {
	logger *shim.ChaincodeLogger
	router *rocha.Router
}

// Checagem em tempo de compilação se CoffeeChaincode implementa shim.CoffeeChaincode
var _ shim.Chaincode = &CoffeeChaincode{}

// NewCoffeeChaincode cria uma nova instância do CoffeeChaincode para gerenciamento de
// cafés com os parâmetros default
func NewCoffeeChaincode(logger *shim.ChaincodeLogger) *CoffeeChaincode {
	chaincode := &CoffeeChaincode{logger: logger}
	chaincode.router = rocha.NewRouter().
		// CreateCoffee creates a new coffee with `flavour`
		Handle("CreateCoffee",
			utils.RespondJSON(chaincode.CreateCoffee),
			argsmw.Arguments(argsmw.String("flavour"))).
		// UseCoffee sets a coffee's owner to `user`
		Handle("UseCoffee", utils.RespondJSON(chaincode.UseCoffee),
			argsmw.Arguments(
				argsmw.String("id"),
				argsmw.String("user"))).
		Handle("GetCoffee", utils.RespondJSON(chaincode.GetCoffee),
			argsmw.Arguments(argsmw.String("id"))).
		// AllCoffee returns all coffees
		Handle("AllCoffee", utils.RespondJSON(chaincode.AllCoffee)).
		// DeleteCoffee deletes a coffe by it's `id`
		Handle("DeleteCoffee", utils.RespondJSON(chaincode.DeleteCoffee),
			argsmw.Arguments(argsmw.String("id")))

	return chaincode
}

// Init realiza as operações de inicialização do CoffeeChaincode
func (cc *CoffeeChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Invoke é chamado toda vez que o Chaicode é invocado
func (cc *CoffeeChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fn, args := stub.GetFunctionAndParameters()
	return cc.router.Invoke(stub, fn, args)
}

func (cc *CoffeeChaincode) store(stub shim.ChaincodeStubInterface) *store.CoffeeStore {
	return store.NewCoffeeStore(stub, cc.logger)
}

// CreateCoffee cria um novo café
func (cc *CoffeeChaincode) CreateCoffee(c rocha.Context) (interface{}, error) {
	stub := c.Stub()

	coffee := model.NewCoffee(stub.GetTxID(), c.String("flavour"))

	if err := cc.store(stub).SetCoffee(coffee); err != nil {
		return nil, err
	}

	return struct {
		Coffee *model.Coffee `json:"coffee"`
	}{coffee}, nil
}

// UseCoffee uses a coffee capsule
func (cc *CoffeeChaincode) UseCoffee(c rocha.Context) (interface{}, error) {
	// retrieve the store
	st := cc.store(c.Stub())

	coffee, err := st.GetCoffee(c.String("id"))
	if err != nil {
		return nil, err
	}

	if err := coffee.SetOwner(c.String("user")); err != nil {
		return nil, err
	}

	return nil, st.SetCoffee(coffee)
}

// GetCoffee retorna um café
func (cc *CoffeeChaincode) GetCoffee(c rocha.Context) (interface{}, error) {
	coffee, err := cc.store(c.Stub()).GetCoffee(c.String("id"))
	if err != nil {
		return nil, err
	}

	return struct {
		Coffee *model.Coffee `json:"coffee"`
	}{coffee}, nil
}

// AllCoffee retorna todos os cafés
func (cc *CoffeeChaincode) AllCoffee(c rocha.Context) (interface{}, error) {
	coffees, err := cc.store(c.Stub()).AllCoffee()
	if err != nil {
		return nil, err
	}

	return struct {
		Coffees []*model.Coffee `json:"coffees"`
	}{coffees}, nil
}

// DeleteCoffee retorna todos os cafés
func (cc *CoffeeChaincode) DeleteCoffee(c rocha.Context) (interface{}, error) {
	return nil, cc.store(c.Stub()).DeleteCoffee(c.String("id"))
}
