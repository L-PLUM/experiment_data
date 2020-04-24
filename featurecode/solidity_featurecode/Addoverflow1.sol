pragma solidity 0.4.24;
contract Addoverflow{
uint256 total;
function batch(address[] _receivers,uint256 _value) public returns (bool) {
uint cnt = _receivers.length;
uint256 amount = uint256(cnt) + _value;
total = uint256(cnt) + _value;
}
}
