package chaincode_test

import (
	"encoding/json"
	"fmt"

	"github.com/cdtlab19/coffee-chaincode/model"
	"github.com/cdtlab19/coffee-chaincode/store"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "github.com/cdtlab19/coffee-chaincode/chaincode"
)

var _ = Describe("User", func() {
	var mock *shim.MockStub
	var logger *shim.ChaincodeLogger
	var st *store.UserStore

	BeforeEach(func() {
		logger = shim.NewLogger("user-test")
		mock = shim.NewMockStub("user", NewUserChaincode(logger))
		st = store.NewUserStore(mock, logger)
	})

	It("Should Init", func() {
		result := mock.MockInit("0000", [][]byte{})
		Expect(int(result.Status)).To(Equal(shim.OK))
		Expect(result.Payload).To(BeEmpty())
	})

	Context("CreateUser method", func() {
		const method = "CreateUser"

		It("Shoud create an user", func() {
			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("name"),
				[]byte("3"),
			})

			Expect(int(result.Status)).To(Equal(shim.OK))

			// verify payload
			var response struct {
				User *model.User `json:"user"`
			}

			Expect(json.Unmarshal(result.Payload, &response)).ToNot(HaveOccurred())
			Expect(response.User.Name).To(Equal("name"))
			Expect(response.User.ID).To(Equal("0000"))
			Expect(response.User.RemainingCoffee).To(Equal(3))

			user, err := st.GetUser("0000")
			Expect(err).NotTo(HaveOccurred())
			Expect(user.Name).To(Equal("name"))
			Expect(user.RemainingCoffee).To(Equal(3))
		})
	})

	Context("GetUser", func() {
		const method = "GetUser"

		It("Should return error if no user was found", func() {
			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})
			Expect(int(result.Status)).To(Equal(shim.ERROR))
			Expect(result.Payload).To(BeEmpty())
		})

		It("Should return an user if it exists", func() {
			createTestUser(mock, st, model.NewUser("0000", "someone", 3))

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})
			Expect(int(result.Status)).To(Equal(shim.OK))
			Expect(result.Payload).NotTo(BeEmpty())

			// Payload: { "user": {...} }
			var response struct {
				User *model.User `json:"user"`
			}

			Expect(json.Unmarshal(result.Payload, &response)).NotTo(HaveOccurred())
			Expect(response.User.ID).To(Equal("0000"))
			Expect(response.User.Name).To(Equal("someone"))

		})
	})

	Context("AllUser", func() {
		const method = "AllUser"
		It("Should return all users", func() {
			user1 := model.NewUser("0000", "Someone", 3)
			user2 := model.NewUser("0001", "Anyone", 3)
			user3 := model.NewUser("0002", "Everybody", 3)

			createTestUser(mock, st, user1)
			createTestUser(mock, st, user2)
			createTestUser(mock, st, user3)

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
			})

			Expect(int(result.Status)).To(Equal(shim.OK))

			var res struct {
				Users []*model.User `json:"users"`
			}

			Expect(json.Unmarshal(result.Payload, &res)).ToNot(HaveOccurred())

			fmt.Printf("%+v", res)

			Expect(res.Users).To(HaveLen(3))
			Expect(res.Users).To(ContainElement(user1))
			Expect(res.Users).To(ContainElement(user2))
			Expect(res.Users).To(ContainElement(user3))
		})

	})

	Context("DrinkCoffee", func() {
		const method = "DrinkCoffee"

		It("Should return error if no user was found", func() {
			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})
			Expect(int(result.Status)).To(Equal(shim.ERROR))
			Expect(result.Payload).To(BeEmpty())
		})

		It("Should throw an error if there's no coffee available", func() {
			createTestUser(mock, st, model.NewUser("0000", "someone", 0))

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})

			Expect(int(result.Status)).To(Equal(shim.ERROR))

		})

		It("Shoud drink an unit of it's available coffees", func() {
			createTestUser(mock, st, model.NewUser("0000", "someone", 3))

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})

			Expect(int(result.Status)).To(Equal(shim.OK))

			// verify payload
			var response struct {
				User *model.User `json:"user"`
			}

			Expect(json.Unmarshal(result.Payload, &response)).ToNot(HaveOccurred())
			Expect(response.User.Name).To(Equal("someone"))
			Expect(response.User.ID).To(Equal("0000"))
			Expect(response.User.RemainingCoffee).To(Equal(2))

			user, err := st.GetUser("0000")
			Expect(err).NotTo(HaveOccurred())
			Expect(user.Name).To(Equal("someone"))
			Expect(user.RemainingCoffee).To(Equal(2))
		})
	})

	Context("DeleteUser", func() {
		const method = "DeleteUser"

		It("Should delete an user", func() {
			createTestUser(mock, st, model.NewUser("0000", "someone", 3))

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})

			Expect(int(result.Status)).To(Equal(shim.OK))
			Expect(result.Payload).To(BeEmpty())

		})

	})

})

func createTestUser(mock *shim.MockStub, st *store.UserStore, user *model.User) {
	mock.MockTransactionStart("int")
	defer mock.MockTransactionEnd("int")

	if err := st.SetUser(user); err != nil {
		panic(err)
	}
}
