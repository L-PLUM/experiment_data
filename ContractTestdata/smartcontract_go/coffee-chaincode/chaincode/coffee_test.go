package chaincode_test

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "github.com/cdtlab19/coffee-chaincode/chaincode"
	"github.com/cdtlab19/coffee-chaincode/model"
	"github.com/cdtlab19/coffee-chaincode/store"
)

var _ = Describe("Coffee", func() {
	var mock *shim.MockStub
	var logger *shim.ChaincodeLogger
	var st *store.CoffeeStore

	BeforeEach(func() {
		logger = shim.NewLogger("coffee-test")
		mock = shim.NewMockStub("coffee", NewCoffeeChaincode(logger))
		st = store.NewCoffeeStore(mock, logger)
	})

	It("Should Init", func() {
		result := mock.MockInit("0000", [][]byte{})
		Expect(int(result.Status)).To(Equal(shim.OK))
		Expect(result.Payload).To(BeEmpty())
	})

	Context("AllCoffee", func() {
		It("Should return all coffees", func() {
			coffee1 := model.NewCoffee("0000", "cappuccino")
			coffee2 := model.NewCoffee("0002", "chocolate")

			createTestCoffee(mock, st, coffee1)
			createTestCoffee(mock, st, coffee2)

			result := mock.MockInvoke("0000", [][]byte{
				[]byte("AllCoffee"),
			})

			Expect(int(result.Status)).To(Equal(shim.OK))

			var res struct {
				Coffees []*model.Coffee `json:"coffees"`
			}

			Expect(json.Unmarshal(result.Payload, &res)).ToNot(HaveOccurred())
			Expect(res.Coffees).To(HaveLen(2))
			Expect(res.Coffees).To(ContainElement(coffee1))
			Expect(res.Coffees).To(ContainElement(coffee2))
		})
	})

	It("Should CreateCoffee", func() {
		result := mock.MockInvoke("0000", [][]byte{
			[]byte("CreateCoffee"),
			[]byte("cappuccino"),
		})

		// verify status
		Expect(int(result.Status)).To(Equal(shim.OK))

		// verify payload
		var response struct {
			Coffee *model.Coffee `json:"coffee"`
		}

		Expect(json.Unmarshal(result.Payload, &response)).ToNot(HaveOccurred())
		Expect(response.Coffee.Flavour).To(Equal("cappuccino"))
		Expect(response.Coffee.ID).To(Equal("0000"))

		coffee, err := st.GetCoffee("0000")
		Expect(err).NotTo(HaveOccurred())
		Expect(coffee.Flavour).To(Equal("cappuccino"))

		result = mock.MockInvoke("0001", [][]byte{
			[]byte("CreateCoffee"),
			[]byte("cappuccino"),
			[]byte("somethineElse"),
		})

	})

	Context("GetCoffee Method", func() {
		const method = "GetCoffee"

		It("Should return error if no coffee found", func() {
			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})
			Expect(int(result.Status)).To(Equal(shim.ERROR))
			Expect(result.Payload).To(BeEmpty())
		})

		It("Should return a valid coffee if it exists", func() {
			createTestCoffee(mock, st, model.NewCoffee("0000", "cappuccino"))

			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})
			Expect(int(result.Status)).To(Equal(shim.OK))
			Expect(result.Payload).NotTo(BeEmpty())

			// Payload: { "coffee": {...} }
			var response struct {
				Coffee *model.Coffee `json:"coffee"`
			}

			Expect(json.Unmarshal(result.Payload, &response)).NotTo(HaveOccurred())
			Expect(response.Coffee.ID).To(Equal("0000"))
			Expect(response.Coffee.Flavour).To(Equal("cappuccino"))
		})
	})

	Context("Method UseCoffee", func() {
		const method = "UseCoffee"

		It("Should not set the owner to an already owned chaincode", func() {
			coffee := model.NewCoffee("0000", "cappuccino")
			coffee.SetOwner("owner")
			createTestCoffee(mock, st, coffee)

			// invoke UseCoffee
			result := mock.MockInvoke("0000", [][]byte{
				[]byte("UseCoffee"),
				[]byte("0000"),
				[]byte("test-owner"),
			})

			Expect(int(result.Status)).To(Equal(shim.ERROR))
			Expect(result.Payload).To(BeEmpty())
		})

		It("Should execute successfuly", func() {
			// create asset for testing
			createTestCoffee(mock, st, model.NewCoffee("0000", "cappuccino"))

			// invoke UseCoffee
			result := mock.MockInvoke("0000", [][]byte{
				[]byte("UseCoffee"),
				[]byte("0000"),
				[]byte("test-owner"),
			})

			// test if transaction was successful
			Expect(int(result.Status)).To(Equal(shim.OK))
			Expect(result.Payload).To(BeEmpty())

			// test if state changed
			coffee, err := st.GetCoffee("0000")
			Expect(err).NotTo(HaveOccurred())
			Expect(coffee.Owner).To(Equal("test-owner"))
		})
	})

	Context("DeleteCoffee", func() {
		const method = "DeleteCoffee"

		It("Should execute successfuly", func() {
			createTestCoffee(mock, st, model.NewCoffee("0000", "cappuccino"))

			// invoke UseCoffee
			result := mock.MockInvoke("0000", [][]byte{
				[]byte(method),
				[]byte("0000"),
			})

			// test if transaction was successful
			Expect(int(result.Status)).To(Equal(shim.OK))
			Expect(result.Payload).To(BeEmpty())

			// test if state changed
			_, err := st.GetCoffee("0000")
			Expect(err).To(HaveOccurred())
		})
	})
})

func createTestCoffee(mock *shim.MockStub, st *store.CoffeeStore, coffee *model.Coffee) {
	mock.MockTransactionStart("int")
	defer mock.MockTransactionEnd("int")

	if err := st.SetCoffee(coffee); err != nil {
		panic(err)
	}
}
