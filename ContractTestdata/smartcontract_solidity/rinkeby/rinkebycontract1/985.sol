/**
 *Submitted for verification at Etherscan.io on 2019-01-31
*/

pragma solidity 0.5.3;

contract Addressable {
    address payable public target;
    
    function addressSet(address payable y) public {
        target = y;
    }
}


/**
 * Can receive money.
 * Can be stolen.
 * Payable at address.
 */
contract GammaPayableRevertable is Addressable {
    
    uint public amount = 1;
    
    function stealMyEth() public {
        address myAddress = address(this);
        msg.sender.transfer(myAddress.balance);
    }
    
    event Received(uint amount, address benefactor);
    event AboutToSending(uint amount, address benefactor);
    
    function () payable external {
        emit Received(msg.value, msg.sender);
        
        emit AboutToSending(amount++, target);
        
        target.transfer(amount);
        revert("Reverting test");
    }
}
