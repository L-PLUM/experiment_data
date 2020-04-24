/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity 0.5.3;


contract Stake  {

  mapping (address => UserStake) public stakes;

  //account
  struct UserStake { uint quantity; }

  event Staked(address indexed user, uint levs);
  event Restaked(address indexed user, uint levs);
  event Redeemed(address indexed user, uint levs);


  function min(uint x, uint y) internal pure returns (uint) { return x <= y ? x : y; }

  function restake(int signedQuantity) private {
    UserStake storage stake = stakes[msg.sender];

    uint lev = stake.quantity;
    uint withdrawLev = signedQuantity >= 0 ? 0 : min(stake.quantity, uint(signedQuantity * -1));
    redeem(withdrawLev);
    stake.quantity = lev - withdrawLev;
    if (stake.quantity == 0) {
      delete stakes[msg.sender];
      return;
    }

    emit Restaked(msg.sender, stake.quantity);
  }

  function stake(int signedQuantity) external {
    restake(signedQuantity);
    if (signedQuantity <= 0) return;

    stakeInCurrentPeriod(uint(signedQuantity));
  }

  function stakeInCurrentPeriod(uint quantity) private {
    stakes[msg.sender].quantity = stakes[msg.sender].quantity + quantity;
    emit Staked(msg.sender, quantity);
  }

  function redeem(uint howMuchLEV) private {
    delete stakes[msg.sender];
    emit Redeemed(msg.sender, howMuchLEV);
  }
}
