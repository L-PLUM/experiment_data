contract Stock():
    def setup(symbol: bytes32): modifying

NewStock: event({symbol: indexed(bytes32), stock: indexed(address)})

stockTemplate: public(address)
symbol_to_stock: map(bytes32, address)
daiToken: public(address)

@public
def initializeFactory(_template: address, _token: address):
    assert self.stockTemplate == ZERO_ADDRESS
    assert _template != ZERO_ADDRESS
    self.stockTemplate = _template
    assert self.daiToken == ZERO_ADDRESS
    assert _token != ZERO_ADDRESS
    self.daiToken = _token

@public
def createStock(symbol: bytes32) -> address:
    assert symbol != EMPTY_BYTES32
    assert self.stockTemplate != ZERO_ADDRESS
    assert self.symbol_to_stock[symbol] == ZERO_ADDRESS
    stock: address = create_with_code_of(self.stockTemplate)
    Stock(stock).setup(symbol)
    self.symbol_to_stock[symbol] = stock
    log.NewStock(symbol, stock)
    return stock

@public
@constant
def getStock(_symbol: bytes32) -> address:
    return self.symbol_to_stock[_symbol]
