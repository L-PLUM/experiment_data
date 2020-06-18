package store

import (
	"encoding/json"

	"github.com/cdtlab19/coffee-chaincode/model"
	"github.com/hyperledger/fabric/core/chaincode/shim"
)

// CoffeeStore abstracts coffee CRUD methods
type CoffeeStore struct {
	stub   shim.ChaincodeStubInterface
	logger *shim.ChaincodeLogger
}

// newCoffeeKey returns the composite key for a coffee instance
func (c *CoffeeStore) newCoffeeKey(id string) (key string) {
	key, _ = c.stub.CreateCompositeKey(model.CoffeeDocType, []string{id})
	return
}

// NewCoffeeStore creates a new coffee Store
func NewCoffeeStore(stub shim.ChaincodeStubInterface, logger *shim.ChaincodeLogger) *CoffeeStore {
	return &CoffeeStore{stub, logger}
}

// AllCoffee returns all existing coffee
func (c *CoffeeStore) AllCoffee() ([]*model.Coffee, error) {
	c.logger.Debug("Entered AllCoffee")

	iterator, err := c.stub.GetStateByPartialCompositeKey(model.CoffeeDocType, []string{})
	if err != nil {
		return nil, err
	}
	defer iterator.Close()

	c.logger.Debug("AllCoffee: starting iterator")
	coffees := []*model.Coffee{}
	for iterator.HasNext() {
		k, err := iterator.Next()
		if err != nil {
			return nil, err
		}

		coffee := &model.Coffee{}
		if err := json.Unmarshal(k.GetValue(), &coffee); err != nil {
			return nil, err
		}

		c.logger.Debugf("AllCoffee: element with ID '%s' found", coffee.ID)
		coffees = append(coffees, coffee)
	}

	c.logger.Debug("Exiting AllCoffee")
	return coffees, nil
}

// GetCoffee returns a coffee by it's id
func (c *CoffeeStore) GetCoffee(coffeeID string) (coffee *model.Coffee, err error) {
	c.logger.Debug("GetCoffee: searching for coffee %s", coffeeID)

	data, err := c.stub.GetState(c.newCoffeeKey(coffeeID))
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(data, &coffee)
	return
}

// SetCoffee sets a coffee asset by it's id
func (c *CoffeeStore) SetCoffee(coffee *model.Coffee) error {
	c.logger.Debug("SetCoffee: setting coffee %s", coffee.ID)
	return c.stub.PutState(c.newCoffeeKey(coffee.ID), coffee.JSON())
}

// DeleteCoffee deletes a coffee asset by it's id
func (c *CoffeeStore) DeleteCoffee(coffeeID string) error {
	c.logger.Debug("DeleteCoffee: deleting coffee %s", coffeeID)
	return c.stub.DelState(c.newCoffeeKey(coffeeID))
}
