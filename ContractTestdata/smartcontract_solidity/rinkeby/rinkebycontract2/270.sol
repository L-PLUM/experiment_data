/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

pragma solidity >=0.4.21 <0.6.0;

contract TennisMatch {
  address public owner;
  uint8 public currentGame = 0;

  uint8 public playerAScore = 0;
  uint8 public playerAGamesWon = 0;

  uint8 public playerBScore = 0;
  uint8 public playerBGamesWon = 0;


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function _maybeIncrementGame() private {
    if (playerAScore == 50) {
      playerAGamesWon++;
      _resetScore();
    } else if (playerBScore == 50) {
      playerBGamesWon++;
      _resetScore();
    }
  }

  function addPoints(uint8 player) public onlyOwner {
    require(player <= 1);

    if (player == 0) {
      playerAScore += 15;
    } else {
      playerBScore += 15;
    }

    _maybeIncrementGame();
  }

  function resetGame() public onlyOwner {
    currentGame = 0;
    _resetScore();
  }

  function _resetScore() private {
    playerAScore = 0;
    playerBScore = 0;
  }
}
