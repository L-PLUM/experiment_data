pragma solidity 0.4.24;
contract Muloverflow{
uint256 total;
uint newTokens1；
function batchTransfer(address[] _receivers,uint256 _value) public {
uint  cnt = _receivers.length;
uint256  amount = uint256(cnt) * _value;
total = uint256(cnt) * _value;
uint newTokens = msg.value * cnt;
newTokens1 = msg.value * cnt;
}
}
