/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity 0.4.23;


contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract airdrop {

  address public owner;
  ERC20 token;

  event TransferredToken(address indexed to, uint256 value);
  event FailedTransfer(address indexed to, uint256 value);

  modifier whenDropIsActive() {
    assert(isActive());

    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor() public
  {
      address _tokenAddr = 0x2e270c0b2c426b4e8c147a47df84da374731dee8; //here pass address of your token
      token = ERC20(_tokenAddr);
      owner = msg.sender;
  }

  function isActive() constant internal returns (bool) {
    return (
        tokensAvailable() > 0 // Tokens must be available to send
    );
  }
  //below function can be used when you want to send every recipeint with different number of tokens
  function sendTokens(address[] dests, uint256[] values) whenDropIsActive onlyOwner external {
    uint256 i = 0;
    while (i < dests.length) {
        uint256 toSend = values[i] * 10**18;
        sendInternally(dests[i] , toSend, values[i]);
        i++;
    }
  }

  // this function can be used when you want to send same number of tokens to all the recipients
  function sendTokensSingleValue(address[] dests, uint256 value) whenDropIsActive onlyOwner external {
    uint256 i = 0;
    uint256 toSend = value * 10**18;
    while (i < dests.length) {
        sendInternally(dests[i] , toSend, value);
        i++;
    }
  }

  function sendInternally(address recipient, uint256 tokensToSend, uint256 valueToPresent) internal {
    if(recipient == address(0)) return;

    if(tokensAvailable() >= tokensToSend) {
      token.transfer(recipient, tokensToSend);
      emit TransferredToken(recipient, valueToPresent);
    } else {
      emit FailedTransfer(recipient, valueToPresent);
    }
  }


  function tokensAvailable() constant returns (uint256) {
    return token.balanceOf(this);
  }

  function destroy() internal onlyOwner {
    uint256 balance = tokensAvailable();
    require (balance > 0);
    token.transfer(owner, balance);
    selfdestruct(owner);
  }
}
