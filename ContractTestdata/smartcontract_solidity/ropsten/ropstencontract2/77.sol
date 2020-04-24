/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.5.10;

contract Oracle {

  address public created_by;

  struct record {
    address created_by;
    address updated_by;
    address pointer;
    bool exists;
  }
  mapping(string => record) internal register;

   event writeRegister(
    string _identifier,
    address _pointer
  );

  constructor () public {
    created_by = msg.sender;
  }

  function write(string memory _identifier, address _pointer) public returns (bool) {

      address creator = msg.sender;
      if (register[_identifier].exists) {
          creator = register[_identifier].created_by;
      }
      register[_identifier] = record({pointer: _pointer, exists: true, updated_by: msg.sender, created_by: creator});
      emit writeRegister(_identifier, _pointer);

      return true;
  }

  function read(string memory _identifier) public view returns (address) {
        require(register[_identifier].exists, "This record is empty");

        return register[_identifier].pointer;
  }
}
