contract Muloverflow7{
  uint256 public sellPrice;
  uint256 public tokenLimit;
  function sell(uint256 amount) {
        // <yes> <report> solidity_integer_multiplication_overflow mul107
        require(tokenLimit >= amount * sellPrice);
        msg.sender.transfer(amount * sellPrice);
    }
     function sell2(uint256 _amount) {
            require(_amount * sellPrice /sellPrice == _amount);
            require(tokenLimit >= _amount * sellPrice);
            msg.sender.transfer(_amount * sellPrice);
        }
  }

contract Muloverflow8{
  uint256 public buyPrice;
  function buy(uint256 total) {
       // <yes> <report> solidity_integer_multiplication_overflow mul108
        require( total * buyPrice <= tokenLimit);
        msg.sender.transfer(total * buyPrice);
    }
   function buy2(uint256 _total) {
          require(_total * buyPrice /_total == buyPrice);
          require( _total * buyPrice <= tokenLimit);
          msg.sender.transfer(_total * buyPrice);
      }
  }

