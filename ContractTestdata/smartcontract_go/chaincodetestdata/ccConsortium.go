package main

import (	
	"fmt"
	"strings"
	"strconv"
	
	"math/big"
	"crypto/sha256"
	//"crypto/ecdsa"
	"crypto/elliptic"
	
	"encoding/json"
	//"encoding/binary"
	//"gonum.org/v1/gonum/mat"
	//"math"
	
	gf "github.com/cloud9-tools/go-galoisfield"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	
	"github.com/gonum/stat/combin"
)

var( 
	curve				= elliptic.P256() 
)

const(
	consortiumName 		= "RAPDEL"
)

// ************************
func Combine(shares map[byte][]byte) []byte {
	var secret []byte
	for _, v := range shares {
		secret = make([]byte, len(v))
		break
	}

	points := make([]pair, len(shares))
	for i := range secret {
		p := 0
		for k, v := range shares {
			points[p] = pair{x: k, y: v[i]}
			p++
		}
		secret[i] = interpolate(points, 0)
	}

	return secret
}

type pair struct {
	x, y byte
}

// Lagrange interpolation
func interpolate(points []pair, x byte) (value byte) {
	for i, a := range points {
		weight := byte(1)
		for j, b := range points {
			if i != j {
				top := x ^ b.x
				bottom := a.x ^ b.x
				factor := div(top, bottom)
				weight = mul(weight, factor)
			}
		}
		//fmt.Printf("W: %d\n", weight)
		value = value ^ mul(weight, a.y)
	}
	return
}

func mul(e, a byte) byte {
	// campo
	campo := gf.Poly84320_g2
	return campo.Mul(e,a)
}

func div(e, a byte) byte { 
	// campo
	campo := gf.Poly84320_g2
	return campo.Div(e,a)
}
// ************************

type Theorem struct {
	X		string
	Y		string
	Count	int
}

func (t *Theorem) getChallenge(p *Proof) (*big.Int) {
	concat := t.getConcat4SHA() + p.getConcat4SHA()
	c := sha256.Sum256([]byte(concat))
	c_Int := new(big.Int).SetBytes(c[:])

	return c_Int
}

func (t *Theorem) getCount() (int) {
	return t.Count
}

func (t *Theorem) verify(p *Proof) (bool) {
	X, _ := new(big.Int).SetString(t.X, 10);
	Y, _ := new(big.Int).SetString(t.Y, 10);
	
	acX, acY := curve.ScalarMult(X, Y, p.C.Bytes())
	grX, grY := curve.ScalarBaseMult(p.R.Bytes())
	testX, testY := curve.Add(grX, grY, acX, acY)
	
	if(!((testX.Cmp(p.V.X) == 0 && testY.Cmp(p.V.Y) == 0))) {
		return false
	}
	t.increment()
	return true
}

func (t *Theorem) getConcat4SHA() (string) {
	return fmt.Sprintf("%s%s%d", t.X, t.Y, t.Count)
}

func (t *Theorem) String() (string) {
	valueAsBytes, _ := json.Marshal(*t)
	return string(valueAsBytes)
}

func (t *Theorem) increment(){
	//t.Count++
}

func theoremFromBytes(jsonByte []byte) (*Theorem) {
	res := &Theorem{}
	err := json.Unmarshal(jsonByte, res)
	if( err != nil ){
		return nil
	}
	return res
}

type Proof struct {
	C,R *big.Int
	V struct{ X, Y *big.Int}
	Once 	string
}

func (p *Proof) getConcat4SHA()(string){
	return fmt.Sprintf("%s%s%s", p.V.X.String(), p.V.Y.String(), p.Once) 
}

func (p *Proof) verifyChallenge(t *Theorem) bool {
	c := t.getChallenge(p)
	return (p.C.Cmp(c) == 0)
}

func proofFromBytes(jsonByte []byte) (*Proof) {
	res := &Proof{}
	err := json.Unmarshal(jsonByte, res)
	if( err != nil ){
		return nil
	}
	return res
}

func proofsFromBytes(jsonByte []byte) []*Proof{
	res := []*Proof{}
	err := json.Unmarshal(jsonByte, &res)
	if( err != nil ){
		return nil
	}
	return res
}

type CollectionTheorem struct {
	Companies []*Company
	K	int
}

func (t *CollectionTheorem) verify(p []*Proof) (bool) {
	if(len(p) != len(t.Companies)){
		return false
	}
	for i := 0; i < len(p); i++ {
		if (!(t.Companies[i].Th.verify(p[i]))) {
			return false
		}
	}
	return true
}

func (t *CollectionTheorem) String() (string){
	valueAsBytes, _ := json.Marshal(*t)
	return string(valueAsBytes)
}

func (t *CollectionTheorem) increment(){
	 for i:= 0; i < len(t.Companies); i++ {
		 t.Companies[i].Th.increment()
	 }
}

func (t *CollectionTheorem) getCount(i int) (int){
	if( i > len(t.Companies) || i < 0 ){
		return -1	
	}
	return t.Companies[i].Th.getCount()
}

func (t *CollectionTheorem) verifySharing(p[] *Proof, c *big.Int, k int) (bool) {
	if( len(p) <= 0 ){
		return false
	}
	degree := k+1
	var j byte
	mat := combin.Combinations(len(p), degree)
	for i := 0; i < len(mat); i++ {
		shares := make(map[byte][]byte, degree)
		for j = 0; int(j) < degree; j++ {
			shares[byte(mat[i][j] + 1)] = p[mat[i][j]].C.Bytes()
		}
		challengeCombined := Combine(shares)	
		c_Int := new(big.Int).SetBytes(challengeCombined)
		if(c.Cmp(c_Int) != 0){
			return false
		}
	}
	return true
}

type Route struct {
	RouteID		string
	CompanyID	string
	Stops		[]string
	Km			float64
	Price		float64
	PriceMin	float64
	PriceMax	float64
}

func (r *Route) changeOwner(company string) {
	r.CompanyID = company
}

func (t *Route) changePrice(c float64) (bool) {
	if( c > t.PriceMax || c < t.PriceMin ) {
		return false
	}
	t.Price = c
	return true
}

func (t *Route) isEqual(t2 *Route) (bool) { 
	if( len(t.Stops) != len(t2.Stops)) {
		return false
	}
	if( len(t.Stops) == 0 ){
		return true
	}
	if ( strings.Compare(t.Stops[0],t2.Stops[0]) != 0 ){
		return false
	}
	if( strings.Compare(t.Stops[len(t.Stops)-1],t2.Stops[len(t.Stops)-1]) != 0 ){
		return false
	 }
	 return true
}

func newRoute(RouteID, CompanyID string,  Stops []string, Km, Price, PriceMin, PriceMax float64) (*Route) {
	if( Price < PriceMin || Price > PriceMax ) {
		return nil
	}
	if(len(Stops) < 1 ) {
		return nil
	}
	if( len(CompanyID) <= 3) {
		return nil
	}
	return &Route{RouteID, CompanyID, Stops, Km, Price, PriceMin, PriceMax}
}

type Company struct{
	Name		string
	Th			*Theorem
	Routes 		[]string
}

func (c *Company) assignRoute(route string) {
  	c.Routes = append(c.Routes,route)
}

func (c *Company) isEqual(name string) (bool) {
	return (strings.Compare(c.Name, name) == 0)
}

func (c *Company) changeName(name string, p *Proof) (bool) {
	if( strings.Compare(name,"") == 0 ) {
		return false
	}
	if( ! c.Th.verify(p)) {
		return false
	}
	c.Name = name
	return true
}

func (c *Company) String() (string) {
	valueAsBytes, _ := json.Marshal(*c)
	return string(valueAsBytes)
}

type Consortium struct {
	//Companies		[]*Company
	*CollectionTheorem
	Routes			[]*Route
}

func (c *Consortium) addRoute(r *Route, proofs []*Proof) (bool) {
	if( !c.verify(proofs) ){ 
		return false
	}
	for i := 0; i < len(c.Routes); i++ {
		if(c.Routes[i].isEqual(r) ){
			return false
		}
	}
	c.Routes = append( c.Routes, r)
	for i := 0; i < len(c.Companies); i++ {
		if( c.Companies[i].isEqual(r.CompanyID) ){
			c.Companies[i].assignRoute(r.RouteID)
		}
	}
	return true
}

func (c *Consortium) changeCost(routeId string, newPrice float64, proof *Proof) (bool) {
	if( newPrice <= 0 ) {
		return false
	}
	
	for i := 0; i < len(c.Routes); i++ {
		if( strings.Compare(c.Routes[i].RouteID, routeId) == 0 ){
			cName := c.Routes[i].CompanyID
			for j := 0; j < len(c.Companies); j++ {
				if( c.Companies[i].isEqual(cName) && c.Companies[i].Th.verify(proof) ) {
					return c.Routes[i].changePrice(newPrice)
				}
			}
		}
	}
	return false
}

func (c *Consortium) changeOwnerRoute(newOwner, routeId string, proofs []*Proof) (bool) {
	if( !c.verify(proofs) ){ 
		return false
	}
	
	
	var route *Route
	route = nil
	for i := 0; (i < len(c.Routes) && (route == nil)); i++  {
		if( strings.Compare(c.Routes[i].RouteID,routeId) == 0 ) {
			route = c.Routes[i]
		}
	}
	
	if( route == nil ) {
		return false
	}
	
	flag := false
	for i := 0; i < len(c.Companies) && !flag; i++  {
		if(c.Companies[i].isEqual(newOwner) ) {
			flag = !flag
		}
	}
	
	if( !flag ) {
		return false
	}
	
	if( !c.verify(proofs) ) {
		return false
	}
	
	route.CompanyID = newOwner
	return true
}

func (c *Consortium) getAllRoutes() (string) {
	routes := make([]*Route, len(c.Routes))
	for i:=0;i<len(c.Routes);i++ {
		routes[i]=c.Routes[i]
	}
	valueAsBytes, _ := json.Marshal(routes)
	return string(valueAsBytes)
}

func (c *Consortium) getRoutesByCompany(companyId string) (string) {
	var routes []*Route
	for i:=0;i<len(c.Routes);i++ {
		if(strings.Compare(c.Routes[i].CompanyID,companyId)==0){
		 	routes = append(routes, c.Routes[i])
		}
	}
	valueAsBytes, _ := json.Marshal(routes)
	return string(valueAsBytes)
}

func (c *Consortium) getRoutesByID(routeID string) (string) {
	var routes []*Route
	for i:=0;i<len(c.Routes);i++ {
		if(strings.Compare(c.Routes[i].RouteID,routeID)==0){
			routes = append(routes, c.Routes[i])
		}
	}
	valueAsBytes, _ := json.Marshal(routes)
	return string(valueAsBytes)
}

func (c *Consortium) getAllCompany() (string) {
	companies := make([]*Company, len(c.Companies))
	for i:=0;i<len(c.Companies);i++ {
		companies[i]=c.Companies[i]
	}
	valueAsBytes, _ := json.Marshal(companies)
	return string(valueAsBytes)
}

func (c *Consortium) getCompany(companyID string) (string) {
	for i:=0;i < len(c.Companies);i++ {
		if(strings.Compare(c.Companies[i].Name,companyID)==0){
		 	return c.Companies[i].String()
		}
	}
	return ""
}

func (c *Consortium) String() (string) {
	valueAsBytes, _ := json.Marshal(*c)
	return string(valueAsBytes)
}

func consortiumFromBytes(jsonByte []byte) *Consortium{
	res := &Consortium{}
	err := json.Unmarshal(jsonByte, res)
	if( err != nil ){
		return nil
	}
	return res
}

type Response struct {
	Info 		string
	IsError 	bool
}

func (c *Response) String() (string) {
	valueAsBytes, _ := json.Marshal(*c)
	return string(valueAsBytes)
}

func responseFromBytes(jsonByte []byte) (*Response) {
	res := &Response{}
	err := json.Unmarshal(jsonByte, res)
	if( err != nil ){
		return nil
	}
	return res
}

type Asset struct {
} 

func (a *Asset) get(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	valueAsBytes, err := stub.GetState(args[0])
	
	
	t := &Theorem{}
	err = json.Unmarshal(valueAsBytes, t)
	if( err != nil ){
		res.Info = fmt.Sprintf("Non so fare una get %v", err)
		res.IsError = true
		return res.String()
	}
	
	res.Info = t.X
	res.IsError = false
	return res.String()
}

// per ora il consorzio è unico
func (a *Asset) addNewRoute(stub shim.ChaincodeStubInterface, args []string) (string){
	res := &Response{}
	
	if( len(args) != 8 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'IdRoute, IdCompany, Stops, Km, Price, PriceMin, PriceMax, []Proof'\n"
		return res.String()
	}
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	if(errCons != nil || len(consortiumAsByte) == 0){
		res.IsError = true
		res.Info = "Consortium not Found!"
		return res.String()
	}
	cons := consortiumFromBytes(consortiumAsByte)
	
	idRoute := args[0]
	compName := args[1]
	stops := []string{}
	errP1 := json.Unmarshal([]byte(args[2]), &stops)
	km, errC1 := strconv.ParseFloat(args[3], 64) 
	price, errC2 := strconv.ParseFloat(args[4], 64)
	priceMin, errC3 := strconv.ParseFloat(args[5], 64) 
	priceMax, errC4 := strconv.ParseFloat(args[6], 64) 
	proofs:= proofsFromBytes([]byte(args[7])) 
	if( errP1 != nil || errC1 != nil || errC2 != nil || errC3 != nil || errC4 != nil || proofs == nil) {
		res.IsError = true
		res.Info= "Parsing error"
		return res.String()
	}
	
	
	newRoute := newRoute(idRoute, compName, stops, km, price, priceMin, priceMax)
	if( newRoute == nil ) {
		res.IsError = true
		res.Info= "Route is not valid"
		return res.String()
	}
	
	if( !cons.addRoute(newRoute, proofs) ) {
		res.IsError = true
		res.Info= "ZKP is not valid OR Route already exists."
		return res.String()
	}
		
	_ = stub.PutState(consortiumName, []byte(cons.String()))
	res.IsError = false
	res.Info= "Route is successfully registered"
	return res.String()
}

//implementare ZKP
func (a *Asset) changeCost(stub shim.ChaincodeStubInterface, args []string) (string){
	res := &Response{}
	if( len(args) != 3 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'RouteId, Price, Proof"
		return res.String()
	}
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}

	routeId := args[0]
	newPrice, errP1 := strconv.ParseFloat(args[1], 64)
	proof:= proofFromBytes([]byte(args[2]))
	if( errP1 != nil || proof == nil) {
		res.IsError = true
		res.Info= "Bad arguments."
		return res.String()
	}
	
	if( !cons.changeCost(routeId, newPrice, proof)  ){
		res.IsError = true
		res.Info= "ZKP or price is not valid"
		return res.String()
	}
	_ = stub.PutState(consortiumName, []byte(cons.String()))
	res.IsError = false
	res.Info= "Price is successfully changed."
	return res.String()
}

//implementare (k,n) ZKP
func (a *Asset) changeOwner(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 3 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'NewOwner, routeID, []Proof'"
		return res.String()
	}
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}
	
	
	newOwner := args[0]
	routeId := args[1]
	proofs := proofsFromBytes([]byte(args[2]))
	if( len(routeId) < 3 || len(newOwner) < 3 || proofs == nil ) {	
		res.IsError = true
		res.Info= "Bad arguments." 
		return res.String()
	}
	if( !cons.changeOwnerRoute(newOwner, routeId, proofs) ) {
		res.IsError = true
		res.Info= "ZKP or Owner is not valid."
		return res.String()
	}
	
	_ = stub.PutState(consortiumName, []byte(cons.String()))
		res.IsError = false
		res.Info= "Owner is successfully changed."
		return res.String()
}

func (a *Asset) getCompany(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 1 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'CompanyID'"
		return res.String()
	}
	
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}
	res.Info = cons.getCompany(args[0])
	res.IsError = false
	return res.String()
}

func (a *Asset) getAllCompany(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 0 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'Nothing.'"
		return res.String()
	}
	
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= fmt.Sprintf("Consortium not found %t, %t, %t \n\n %s", errCons != nil, len(consortiumAsByte) == 0, cons == nil, cons)
		return res.String()
	}
	res.Info = cons.getAllCompany()
	res.IsError = false
	return res.String()
}

func (a *Asset) getAllRoutes(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 0 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting Nothing"
		return res.String()
	}
	
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}
	res.Info = cons.getAllRoutes()
	res.IsError = false
	return res.String()
}

func (a *Asset) getRoutesByCompany(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 1 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'CompanyID'"
		return res.String()
	}
	
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}
	res.Info = cons.getRoutesByCompany(args[0])
	res.IsError = false
	return res.String()
}

func (a *Asset) getRouteByID(stub shim.ChaincodeStubInterface, args []string) (string) {
	res := &Response{}
	if( len(args) != 1 ) {
		res.IsError = true
		res.Info= "Incorrect arguments. Expecting 'RouteID'"
		return res.String()
	}
	
	consortiumAsByte, errCons := stub.GetState(consortiumName)
	cons := consortiumFromBytes(consortiumAsByte)
	if(errCons != nil || len(consortiumAsByte) == 0 || cons == nil){
		res.IsError = true
		res.Info= "Consortium not found"
		return res.String()
	}
	res.Info = cons.getRoutesByID(args[0])
	res.IsError = false
	return res.String()
}

/*
func (a *Asset) Query(stub shim.ChaincodeStubInterface) (peer.Response) {
	fn, args := stub.GetFunctionAndParameters()
	
	var result string
	var err error
	
	switch fn {
	case "getCompanies":
		result, err = a.getAllCompany(stub, args)
	case "getCompany":
		result, err = a.getCompany(stub, args)
	case "getRoutes":
		result, err = a.getAllRoutes(stub, args)
	case "getRouteByID":
		result, err = a.getRouteByID(stub, args)
	case "getRouteByCompany":
		result, err = a.getRouteByCompany(stub, args)
	default :
		result = "Wrong request\n"
		err = nil
	}
	
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte(result))
}
*/

func (a *Asset) Invoke(stub shim.ChaincodeStubInterface) (peer.Response) {
	fn, args := stub.GetFunctionAndParameters()

	var result string

	switch fn {
	case "changeOwner":
		result = a.changeOwner(stub, args)
	case "newRoute":
		result = a.addNewRoute(stub, args)
	case "changeCost":
		result = a.changeCost(stub, args)
	case "getCompanies":
		result = a.getAllCompany(stub, args)
	case "getCompany":
		result = a.getCompany(stub, args)
	case "getRoutes":
		result = a.getAllRoutes(stub, args)
	case "getRouteByID":
		result = a.getRouteByID(stub, args)
	case "getRouteByCompany":
		result = a.getRoutesByCompany(stub, args)
	case "debug":
		result = a.get(stub, args)
	default :
		res := &Response{"Wrong request", true}
		result = res.String()
	}
	res := responseFromBytes([]byte(result))
	if((res == nil) || (res.IsError)) {
		return shim.Error("InvokeError. " + res.Info)
	}
	return shim.Success([]byte(res.Info))
}

func (t *Asset) Init(stub shim.ChaincodeStubInterface) peer.Response {	
	t1 := theoremFromBytes([]byte("{\"X\":\"47797774575095622166547957220177615540886918239845290804264587617452038841830\",\"Y\":\"103747043514213939569165896769541903708348509212261881966094138542901652705696\",\"Count\":0}"))
	c1 := &Company{"CSTP", t1, []string{"001"}}
	t2 := theoremFromBytes([]byte("{\"X\":\"80131084105585640864111912269459382479697664205010398933567215811989493963576\",\"Y\":\"61745800963240875686425973289051540081218529509241748110182069939013924473700\",\"Count\":0}"))
	c2 := &Company{"AIR", t2, []string{"002"}}
	t3 := theoremFromBytes([]byte("{\"X\":\"94105354386433170744573323041569379091911367324661928374118087159782480035076\",\"Y\":\"30130962657130423435424259312771666160210868114607882078501420567050553202497\",\"Count\":0}"))
	c3 := &Company{"UNIVERSAL", t3, []string{"003"}}
	t4 := theoremFromBytes([]byte("{\"X\":\"82109354421193012560603734009935897774826969265643743864708276239906454176364\",\"Y\":\"113178912597343203632733772056074939370505761398780392252759094680229994396625\",\"Count\":0}"))
	c4 := &Company{"SITA", t4, []string{"004"}}
	t5 := theoremFromBytes([]byte("{\"X\":\"68327095023128296203952691150040286093932836955856906175723268885041162204786\",\"Y\":\"22384322286589943170998482170661916669727352908014803766628508425333997712835\",\"Count\":0}"))
	c5 := &Company{"LEONETTI", t5, []string{"005"}}
	r1 := &Route{ "001", "CSTP", []string{"FISCIANO", "SALERNO"}, 12.0, 2.2, 2.0, 3.0 }
	r2 := &Route{ "002", "AIR", []string{"LANCUSI", "AVELLINO"}, 28.0, 3.1, 3.0, 4.0 }
	r3 := &Route{ "003", "UNIVERSAL", []string{"GRAGNANO", "FISCIANO"}, 46.0, 3.6, 3.0, 4.0 }
	r4 := &Route{ "004", "SITA", []string{"AVELLINO" , "MONTORO", "SALERNO"}, 35.0, 3.2, 3.0, 4.0 }
	r5 := &Route{ "009", "LEONETTI", []string{"BRACIGLIANO", "SALERNO"}, 24.0, 2.8, 2.5, 3.0 }
	
	routes := []*Route{r1, r2, r3, r4, r5}
	companies := []*Company{c1, c2, c3, c4, c5}
	
	
	ths := &CollectionTheorem{companies, 3}
	
	cons := &Consortium{ths, routes}
	
	_ = stub.PutState(consortiumName, []byte(cons.String()))	
	return shim.Success([]byte(cons.String())) 
}

func main() {
	if err := shim.Start(new(Asset)); err != nil {
		fmt.Printf("Error starting chaincode: %s\n", err)
	}
}
