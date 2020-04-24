contract Muloverflow9{
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
	uint256 public amount;
	event Transfer(address indexed from, address indexed to, uint256 value);
function mintToken(address target, uint256 mintedAmount) onlyOwner {
        // <yes> <report> solidity_integer_multiplication_overflow mul109
        amount *= mintedAmount;
        require(balanceOf[target] * mintedAmount /mintedAmount == balanceOf[target]);
		balanceOf[target] *= mintedAmount;
		// <yes> <report> solidity_integer_multiplication_overflow mul111
		balanceOf[msg.sender] *= mintedAmount;
		require(allowance[msg.sender][target] * mintedAmount / allowance[msg.sender][target] == mintedAmount);
		allowance[msg.sender][target] *= mintedAmount;
        Transfer(msg.sender, target, mintedAmount);
    }
function mintToken1(address to, uint256 minted) onlyOwner {
        require(amount * minted /minted == amount);
        amount *= minted;
        // <yes> <report> solidity_integer_multiplication_overflow mul110
		balanceOf[to] *= minted;
		require(balanceOf[msg.sender] * minted /minted == balanceOf[msg.sender]);
		balanceOf[msg.sender] *= minted;
		// <yes> <report> solidity_integer_multiplication_overflow mul112
		allowance[msg.sender][to] *= minted;
        Transfer(msg.sender, to, minted);
    }
}