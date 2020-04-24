/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity 0.5.3;

contract ToDoMVC {
  mapping (uint256 => bool) public completed;
  mapping (uint256 => string) public title;
  uint256 public count;

  function addTodo(string memory _title) public {
    title[count] = _title;
    count = count + 1;
  }

  function setCompleted(uint256 id, bool _completed) public {
    require(id < count);
    completed[id] = _completed;
  }

  function setTitle(uint256 id, string memory _title) public {
    require(id < count);
    title[id] = _title;
  }

  function toggle(uint256 id) public {
    require(id < count);
    completed[id] = !completed[id];
  }
}
