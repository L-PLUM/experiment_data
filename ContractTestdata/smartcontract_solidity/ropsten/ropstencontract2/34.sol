/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.5.0;

interface IPolicy {
  function isViolated(address contractAddress) external view returns(bool);
}

interface Staking {
    function getPoolState(uint256) external view returns(uint256);
}

contract AnyInsuredContractWasViolated is IPolicy {
  address constant public QUANTSTAMP_STAKING_ADDR = 0x21Ed59CEA9298082147e0d89b59472257E96ea0C;
  uint256 public constant VIOLATED_FUNDED = 5;
  Staking quantstamp_staking;
  bool private violated = false;

  constructor() public { 
    quantstamp_staking = Staking(QUANTSTAMP_STAKING_ADDR);
  }


  function checkPolicyStatus(uint policyId) public view returns (uint256) {
     return quantstamp_staking.getPoolState(policyId);
  }

  function checkIfPolicyViolated(uint policyId) public view returns (bool) {
     uint256 isViolatedAndFunded = quantstamp_staking.getPoolState(policyId);
     return isViolatedAndFunded == VIOLATED_FUNDED;
  }

  function setPolicyViolated(uint256 policyId) public returns (bool) {
      if (checkIfPolicyViolated(policyId)) {
          violated = true;
          return true;
      }
      return false;
  }

  function isViolated(address contractAddress) public view returns (bool) {
    return violated;
  }
}
