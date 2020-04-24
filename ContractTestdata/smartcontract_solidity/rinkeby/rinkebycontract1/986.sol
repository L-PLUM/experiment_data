/**
 *Submitted for verification at Etherscan.io on 2019-01-31
*/

pragma solidity 0.5.3;

/**
 * Can receive money.
 * Can be stolen.
 * Payable at address.
 */
contract GammaPayableRevertable {
    
    function stealMyEth() public {
        address myAddress = address(this);
        msg.sender.transfer(myAddress.balance);
    }
    
    event Received(uint amount, address benefactor);
    
    function () payable external {
        emit Received(msg.value, msg.sender);
        
        revert("Reverting test");
    }
}
