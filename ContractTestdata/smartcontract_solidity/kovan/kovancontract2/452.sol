/**
 *Submitted for verification at Etherscan.io on 2019-07-06
*/

interface KYCInterface {
    event Whitelisted(address who, uint128 nonce);

    function isWhitelisted(address who) external view returns(bool);
}


interface SecurityTransferAgent {
  function verify(address from, address to, uint256 value) public view returns (uint256 newValue);
}


contract RestrictedTransferAgent is SecurityTransferAgent {

  KYCInterface KYC;

  function RestrictedTransferAgent(KYCInterface _KYC) {
    KYC = _KYC;
  }

  /**
   * @dev Checking if transfer can happen, and if so, what is the right amount
   *
   * @param from The account sending the tokens
   * @param to The account receiving the tokens
   * @param value The indended amount
   * @return The actual amount permitted
   */
  function verify(address from, address to, uint256 value) public view returns (uint256 newValue) {
    if (address(KYC) == address(0)) {
      return value;
    }

    if (KYC.isWhitelisted(to)) {
      return value;
    } else {
      return 0;
    }
  }
}
