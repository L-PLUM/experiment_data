/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;

contract ValueContract {
  uint private value;

  event NewValue(uint number);

  function getValue() public constant returns(uint) {
    return value;
  }

  function setValue(uint newValue) public {
	require(newValue <= 20);
	value = newValue;
	emit NewValue(value);
  }

}
