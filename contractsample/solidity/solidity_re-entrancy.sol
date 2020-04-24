pragma solidity 0.5.0;
contract Bank{
    mapping(address => uint) balance;

    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function withraw(uint amount) public payable{
            if(balance[msg.sender] >= amount)
            {
            // <yes> <report> solidity_re-entrancy ree101
                msg.sender.call.value(amount)();
				balance[msg.sender] -=amount;

            }
     }

      function withraw1(uint amount) public payable{
                 if(balance[msg.sender] >= amount)
                 {
                 // <yes> <report> solidity_re-entrancy ree101
                    msg.sender.call.value(amount)();
     				balance[msg.sender] = 0;

                 }
             }

      function withraw2(uint amount) public payable{
                 require(balance[msg.sender] >= amount);
                 // <yes> <report> solidity_re-entrancy ree102
                    msg.sender.call.value(amount)("");
     				balance[msg.sender] -=amount;
             }

      function withraw3(uint amount) public payable{
                 require(balance[msg.sender] >= amount);
                 // <yes> <report> solidity_re-entrancy ree102
                    msg.sender.call.value(amount)("");
     				balance[msg.sender] = 0;
             }

       function withraw4(uint amount) public payable{
                // <yes> <report> solidity_re-entrancy ree103
                  if(msg.sender.call.value(amount)())
                  {
      				balance[msg.sender] -=amount;
                  }
              }

         function withraw5(uint amount) public payable{
                    // <yes> <report> solidity_re-entrancy ree104
                    if(msg.sender.call.value(amount)(""))
                    {
        				balance[msg.sender] = 0;
                    }
                }
}
