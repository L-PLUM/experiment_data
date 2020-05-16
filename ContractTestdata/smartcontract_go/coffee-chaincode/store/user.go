package store

import (
	"encoding/json"

	"github.com/cdtlab19/coffee-chaincode/model"
	"github.com/hyperledger/fabric/core/chaincode/shim"
)

// UserStore abstracts user CRUD methods
type UserStore struct {
	stub   shim.ChaincodeStubInterface
	logger *shim.ChaincodeLogger
}

// NewUserStore creates a new user Store
func NewUserStore(stub shim.ChaincodeStubInterface, logger *shim.ChaincodeLogger) *UserStore {
	return &UserStore{stub, logger}
}

func (u *UserStore) newUserKey(id string) (key string) {
	key, _ = u.stub.CreateCompositeKey(model.UserDocType, []string{id})
	return
}

// AllUser returns all existing users
func (u *UserStore) AllUser() ([]*model.User, error) {
	u.logger.Debug("Entered AllUser")
	iterator, err := u.stub.GetStateByPartialCompositeKey(model.UserDocType, []string{})
	if err != nil {
		return nil, err
	}
	defer iterator.Close()

	u.logger.Debug("AllUser: starting iterator")
	users := []*model.User{}
	for iterator.HasNext() {
		k, err := iterator.Next()
		if err != nil {
			return nil, err
		}

		user := &model.User{}
		if err := json.Unmarshal(k.GetValue(), &user); err != nil {
			return nil, err
		}

		u.logger.Debugf("AllUsers: element with ID '%s' found", user.ID)
		users = append(users, user)
	}

	u.logger.Debug("Exiting AllUsers")
	return users, nil
}

// GetUser returns an user by it's ID
func (u *UserStore) GetUser(userID string) (user *model.User, err error) {
	u.logger.Debug("GetUser: searching for user '%s'", userID)

	data, err := u.stub.GetState(u.newUserKey(userID))
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(data, &user)
	return
}

// SetUser sets an user asset by it's ID
func (u *UserStore) SetUser(user *model.User) error {
	u.logger.Debug("SetUser: setting user %s", user.ID)
	return u.stub.PutState(u.newUserKey(user.ID), user.JSON())
}

// DeleteUser deletes an user asset by it's ID
func (u *UserStore) DeleteUser(userID string) error {
	u.logger.Debug("DeleteUser: deleting user %s", userID)
	return u.stub.DelState(u.newUserKey(userID))
}
