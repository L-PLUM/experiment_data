package model

import (
	"encoding/json"
	"errors"
	"fmt"
)

// CoffeeDocType is the docType used in model
const CoffeeDocType = "coffee"

// Coffee defines a basic model for coffee
type Coffee struct {
	DocType string `json:"docType"`
	ID      string `json:"id"`
	Flavour string `json:"flavour"`
	Owner   string `json:"owner"`
}

// NewCoffee creates a new Coffee
func NewCoffee(id string, flavour string) *Coffee {
	return &Coffee{
		DocType: CoffeeDocType,
		ID:      id,
		Flavour: flavour,
		Owner:   "",
	}
}

// HasOwner verifies if a Coffee has a owner
func (c *Coffee) HasOwner() bool {
	return c.Owner != ""
}

// SetOwner sets a Coffe owner if it's not set
func (c *Coffee) SetOwner(owner string) error {
	if c.HasOwner() {
		return errors.New("coffee already has a owner")
	}

	c.Owner = owner
	return nil
}

// Valid verifies if a Coffee is valid
func (c *Coffee) Valid() error {
	if c.DocType != CoffeeDocType {
		return fmt.Errorf("coffee docType not set to '%s'", CoffeeDocType)
	}
	if c.ID == "" {
		return fmt.Errorf("missing coffee ID")
	}
	return nil
}

// JSON encodes a coffe model as a JSON object
func (c *Coffee) JSON() []byte {
	v, _ := json.Marshal(c)
	return v
}
