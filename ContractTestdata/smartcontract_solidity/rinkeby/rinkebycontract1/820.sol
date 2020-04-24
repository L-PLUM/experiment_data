/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.24;

interface Token {

   function transfer(address receiver, uint amount) external;

   function balanceOf(address _owner) external view returns (uint256 balance);
}

contract NexybitUserWallet {

   address private receiver;
   address private owner;

   modifier onlyOwner {
       require(msg.sender == owner, "only can be called by owner");
       _;
   }

   event ethTransfer(address from, address to, address forward, uint256 amount);

   event tokenTransfer(address tokenContract, address from, address to, uint256 amount);

   constructor (address _receiver, address _owner) public {
       receiver = _receiver;
       owner = _owner;
   }

   function () payable public {

       receiver.transfer(msg.value);

       emit ethTransfer(msg.sender, this, receiver, msg.value);
   }

   function transferToken(address tokenContract)  public {

       Token token = Token(tokenContract);

       address wallet = this;

       uint256 balance = token.balanceOf(wallet);

       if (balance <= 0) {
           return;
       }

       token.transfer(receiver, balance);

       emit tokenTransfer(tokenContract, wallet, receiver, balance);
   }

   function updateReceiver(address _receiver) public onlyOwner {

       receiver = _receiver;
   }
}

contract NexybitUserWalletFactory {

   address private receiver;
   address private owner;

   event WalletCreation(address[] addresses);

   constructor(address _receiver, address _owner) public {
       receiver = _receiver;
       owner = _owner;
   }

   function newWallet(uint256 number) public {

       require(number > 0 && number < 100);

       address[] memory addresses = new address[](number);

       for (uint256 i = 0; i < number; i++) {
           address wallet = createWallet();
           addresses[i] = wallet;
       }

       emit WalletCreation(addresses);
   }

   function createWallet() private returns (address) {

       NexybitUserWallet wallet = new NexybitUserWallet(receiver, owner);

       return wallet;
   }
}
