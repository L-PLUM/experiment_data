/**
 *Submitted for verification at Etherscan.io on 2019-01-20
*/

pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Ownable constructor ตั้งค่าบัญชีของ sender ให้เป็น `owner` ดั้งเดิมของ contract 
   *
   */
   constructor() public {
    owner = msg.sender;
  }

  function isContract(address _addr) internal view returns(bool){
     uint256 length;
     assembly{
      length := extcodesize(_addr)
     }
     if(length > 0){
       return true;
    }
    else {
      return false;
    }

  }

 // ถ้าคนที่เรียกใช้ไม่ใช่คนสร้าง smart contract จะหยุดทำงานและคืนค่า gas
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }
// ตรวจสอบว่า ไม่ใช่ contract address 

  function transferOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false); // ตรวจสอบว่าไม่ได้เผลอเอา contract address มาใส่
    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

}

contract Random is Ownable{
	uint256 private seed_;

	constructor() public {
		seed_ = uint256(now);
	}

	function rand() internal returns(uint256){

		seed_ = (seed_ * 214013 + 2531011);
		return (seed_ >> 16 ) & 0x7fff;
	}

	function setSeed(uint256 _seed) public onlyOwner{
		seed_ = _seed;

	}

}


contract ThreeBetBoxTest3 is Random{

	event BetBox(address indexed player, uint32 _boxSelect, uint32 _boxRight,uint256 amount,uint256 gas_);
	event GetReward(address indexed player,uint256 _reward);
	event AddFunc(address indexed addFunc, uint256 _funcAdd);

	// ถ้าชนะ จะเป็น True ถ้าแพ้ จะเป็น False
	function Bet(uint32 _boxSelect) payable public returns(bool){  
		
		uint32  winBox;
		// โดยปกติตำ่สุดที่จะเล่นได้ควรจะเป็นทศนิยม ไม่เกิน 5 ตำแหน่ง คือ 0.00001 ETH
		require(tx.gasprice < msg.value + 1 szabo); // ต้องเล่นอย่างน้อยมากกว่า ค่า Gas เพราะระบบจะคืนค่า Gas ให้
		require(address(this).balance >= msg.value * 5 / 2); // เจ้าต้องมีเงินเหลือด้วย
		require(_boxSelect >=1 && _boxSelect <=3);

		msg.sender.transfer(tx.gasprice); // คืนค่า Gas;
		winBox = uint32(rand() % 3 + 1);
		if(winBox == _boxSelect)
			msg.sender.transfer(msg.value * 2);


		emit BetBox(msg.sender,_boxSelect,winBox,msg.value,tx.gasprice);

		return (winBox == _boxSelect);

	}
// เพิ่มเงินกองกลาง ใครก็สามารถเพิ่มได้ (ยังไม่ได้เขียนให้ lock ไว้สำหรับ เจ้าของเท่านั้น)
	function addFunc() payable public {
		emit AddFunc(msg.sender,msg.value);
	}

	function withDrawFunc(uint256 _fund) public onlyOwner{
		require(address(this).balance <= _fund);
		msg.sender.transfer(_fund);
	}


}
