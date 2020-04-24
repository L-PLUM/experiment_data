/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >0.4.99 <0.6.0;

contract Factory {
  event Deployed(address addr, uint256 salt);

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function deploy(bytes memory code, uint256 salt) public onlyOwner {
    address addr;
    assembly {
      addr := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }

    emit Deployed(addr, salt);
  }
}
