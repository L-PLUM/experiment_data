contract Muloverflow3{
  uint256 public sellPrice;
  function sell(uint256 amount) {
        // <yes> <report> solidity_integer_multiplication_overflow mul103
        require(this.balance >= amount * sellPrice);
        msg.sender.transfer(amount * sellPrice);
    }
     function sell2(uint256 _amount) {
            require(_amount * sellPrice /sellPrice == _amount);
            require(this.balance >= _amount * sellPrice);
            msg.sender.transfer(_amount * sellPrice);
        }
  }

contract Muloverflow4{
  uint256 public buyPrice;
  function buy(uint256 total) {
       // <yes> <report> solidity_integer_multiplication_overflow mul104
        require( total * buyPrice <= this.balance);
        msg.sender.transfer(total * buyPrice);
    }
   function buy2(uint256 _total) {
          require(_total * buyPrice /_total == buyPrice);
          require( _total * buyPrice <= this.balance);
          msg.sender.transfer(_total * buyPrice);
      }
  }

