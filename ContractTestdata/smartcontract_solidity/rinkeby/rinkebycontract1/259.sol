/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity 0.5.0;

// File: /Users/ogawashohei/Desktop/test-project/Solidity/erc20_sample/node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SimpleStore {
    
    using SafeMath for uint256;

    struct Post{
        address owner;
        string value;
        string imgHash;
        string textHash;
    }

    mapping(uint256=> Post) posts;

    uint256 postCtr;

    event NewPost();

    function sendHash(
        string memory _val,
        string memory _img,
        string memory _text
    )
    public
    {
        postCtr = postCtr.add(1);
        Post storage posting = posts[postCtr];
        posting.owner = msg.sender;
        posting.value = _val;
        posting.imgHash = _img;
        posting.textHash = _text;

        emit NewPost();
    }

    function getHash(uint256 _index)public view returns(
        string memory val,
        string memory img,
        string memory text,
        address owner
    )
    {
        owner = posts[_index].owner;
        val = posts[_index].value;
        img = posts[_index].imgHash;
        text = posts[_index].textHash;
    }

    function getCounter() public view returns(uint256){ return postCtr; }

    // function set(string memory _value) public {
    //     value = _value;
    // }

    // function get() public view returns (string memory) {
    //     return (value);
    // }
}
