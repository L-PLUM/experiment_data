# ERC20 events
Transfer: event({_from: indexed(address), _to: indexed(address), _value: uint256})
Approval: event({_owner: indexed(address), _spender: indexed(address), _value: uint256})

BuyShare: event({trader: indexed(address), value: uint256})
SellShare: event({trader: indexed(address), value: uint256})

symbol: public(bytes32)
balances: map(address, uint256)
allowances: map(address, map(address, uint256))
decimals: public(uint256)
daiToken: address(ERC20)

SHARE_PRICE: constant(uint256) = 100 # 1 share = 100 DAI

@public
def __init__(_symbol: bytes32, _token: address):
    self.symbol = _symbol
    self.decimals = 18
    self.daiToken = _token
    assert self.daiToken.decimals() == self.decimals

@public
def buy(amount: uint256) -> bool:
    assert amount > 0

    self.balances[msg.sender] += amount
    dai_amount: uint256 = amount * SHARE_PRICE * 101 / 100

    transferFromResult: bool = self.daiToken.transferFrom(msg.sender, self, dai_amount)
    assert transferFromResult

    log.BuyShare(msg.sender, amount)
    return True

@public
def setup(_symbol: bytes32):
    assert self.symbol == EMPTY_BYTES32
    assert _symbol != EMPTY_BYTES32
    self.symbol = _symbol

@public
def sell(amount: uint256) -> bool:
    assert amount > 0
    assert amount <= self.balances[msg.sender]

    self.balances[msg.sender] -= amount
    dai_amount: uint256 = amount * SHARE_PRICE * 99 / 100

    transferResult: bool = self.daiToken.transfer(msg.sender, dai_amount)
    assert transferResult

    log.SellShare(msg.sender, amount)
    return True

# ERC-20 functions

@public
@constant
def balanceOf(_owner: address) -> uint256:
    return self.balances[_owner]

@public
def transfer(_to: address, _value: uint256) -> bool:
    self.balances[msg.sender] -= _value
    self.balances[_to] += _value
    log.Transfer(msg.sender, _to, _value)
    return True

@public
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    self.balances[_from] -= _value
    self.balances[_to] += _value
    self.allowances[_from][msg.sender] -= _value
    log.Transfer(_from, _to, _value)
    return True

@public
def approve(_spender: address, _value: uint256) -> bool:
    self.allowances[msg.sender][_spender] = _value
    log.Approval(msg.sender, msg.sender, _value)
    return True

@public
@constant
def allowance(_owner: address, _spender: address) -> uint256:
    return self.allowances[_owner][_spender]
