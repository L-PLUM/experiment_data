package model

import (
	"encoding/json"
	"errors"
	"fmt"
)

// UserDocType is the DocType use in model
const UserDocType = "user"

// User defines a basic model for an user
type User struct {
	DocType         string `json:"docType"`
	ID              string `json:"id"`
	Name            string `json:"name"`
	RemainingCoffee int    `json:"remainingCoffee"`
}

// NewUser creates an user with a exact amount of remaining coffees
func NewUser(id, name string, remainingCoffee int) *User {
	return &User{
		DocType:         UserDocType,
		ID:              id,
		Name:            name,
		RemainingCoffee: remainingCoffee,
	}
}

// DrinkCoffee takes one unit of user's remaining coffees
func (u *User) DrinkCoffee() error {

	if u.RemainingCoffee < 1 {
		return errors.New("user has no remaining coffees")
	}

	u.RemainingCoffee = u.RemainingCoffee - 1
	return nil
}

// Valid verifies if an User is valid
func (u *User) Valid() error {
	if u.DocType != UserDocType {
		return fmt.Errorf("user docType not set to '%s'", UserDocType)
	}
	if u.ID == "" {
		return fmt.Errorf("missing user ID")
	}

	if u.Name == "" {
		return fmt.Errorf("missing user name")
	}
	if u.RemainingCoffee < 0 {
		return errors.New("user has negative number of remaining coffees")
	}
	return nil
}

// JSON encodes an user model as a JSON object
func (u *User) JSON() []byte {
	v, _ := json.Marshal(u)
	return v
}
