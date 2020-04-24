contract Snowflake():
  def hydroTokenAddress() -> address: constant

contract HydroToken():
  def approveAndCall(_spender: address, _value: uint256, _extraData: bytes[32]) -> bool: modifying

contract UniswapFactory():
  def getExchange(token: address) -> address: constant

contract UniswapHydroExchange():
  def ethToTokenSwapInput(min_tokens: uint256, deadline: timestamp) -> uint256: modifying
  def ethToTokenSwapOutput(tokens_bought: uint256, deadline: timestamp) -> uint256(wei): modifying

snowflakeAddress: public(address)
hydroTokenAddress: public(address)
uniswapFactoryAddress: public(address)
uniswapHydroExchangeAddress: public(address)
_placeholder: bytes[1]

@public
def __init__(_snowflakeAddress: address, _uniswapFactoryAddress: address):
  self.snowflakeAddress = _snowflakeAddress
  _hydroTokenAddress: address = Snowflake(self.snowflakeAddress).hydroTokenAddress()
  assert (_hydroTokenAddress != ZERO_ADDRESS)
  self.hydroTokenAddress = _hydroTokenAddress

  self.uniswapFactoryAddress = _uniswapFactoryAddress
  _uniswapHydroExchangeAddress: address = UniswapFactory(self.uniswapFactoryAddress).getExchange(self.hydroTokenAddress)
  assert (_uniswapHydroExchangeAddress != ZERO_ADDRESS)
  self.uniswapHydroExchangeAddress = _uniswapHydroExchangeAddress

@public
@payable
def __default__():
  pass

@private
def depositIntoSnowflake(tokens_to_deposit: uint256, recipientEIN: uint256):
  convertedRecipient: bytes[32] = slice(concat(convert(recipientEIN, bytes32), self._placeholder), start=0, len=32)
  assert HydroToken(self.hydroTokenAddress).approveAndCall(self.snowflakeAddress, tokens_to_deposit, convertedRecipient)

@public
@payable
def swapAndDepositInput(min_tokens: uint256, deadline: timestamp, recipientEIN: uint256) -> uint256:
  tokens_bought: uint256 = UniswapHydroExchange(
    self.uniswapHydroExchangeAddress
  ).ethToTokenSwapInput(min_tokens, deadline, value=msg.value)

  self.depositIntoSnowflake(tokens_bought, recipientEIN)

  return tokens_bought

@public
@payable
def swapAndDepositOutput(tokens_bought: uint256, deadline: timestamp, recipientEIN: uint256) -> uint256(wei):
  eth_sold: uint256(wei) = UniswapHydroExchange(
    self.uniswapHydroExchangeAddress
  ).ethToTokenSwapOutput(tokens_bought, deadline, value=msg.value)

  if (self.balance > 0):
    send(msg.sender, self.balance)

  self.depositIntoSnowflake(tokens_bought, recipientEIN)

  return eth_sold
