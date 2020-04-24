pragma solidity ^0.5.0;
import "../IERC20.sol";
import "./Ownable.sol";

contract RewardFund is Ownable {

    struct Category {
        uint amount;
        uint limit;
    }

    mapping (uint => Category) public categories;
    mapping (address => mapping (uint => uint)) public rewardRecieved;

    IERC20 constant public Token = IERC20(0x6D46e4EDeDb4FBa8B83C1789FE8F38E7B6bB1809);

    function getBalance () public view returns(uint256)  {
        return Token.balanceOf(address(this));
    }

    function payReward (uint _category, address _to) public onlyOwner  {
        require(categories[_category].limit == 0 || rewardRecieved[_to][_category] < categories[_category].limit, "limit over");
        Token.transfer(_to, categories[_category].amount);
        rewardRecieved[_to][_category] += 1;
    }

    function addCategory(uint _ID, uint _amount, uint _limit) public onlyOwner  {
        categories[_ID].amount = _amount;
        categories[_ID].limit = _limit;
    }

    function changeCategoriesLimit(uint _ID, uint _limit) public {
        categories[_ID].limit = _limit;
    }

    function changeCategoriesAmount(uint _ID, uint _amount) public {
        categories[_ID].amount = _amount;
    }

}
