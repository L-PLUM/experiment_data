/**
 *Submitted for verification at Etherscan.io on 2018-12-30
*/

pragma solidity ^0.4.25;
contract Carbon {
    uint cloth_number=0;
    mapping (uint => uint) carbon_foot_list;  //號碼對碳足跡
    mapping (string => uint) total_carbon;      //帳號對總碳排放量
    function record_foot_carbon(uint number,uint carbon_foot_num,string account) public {
      //紀錄碳足跡
      carbon_foot_list[number]=carbon_foot_num;
      total_carbon[account]+=carbon_foot_num;
      cloth_number++;
    }
    function read_by_number(uint number) view public returns (uint) {
      //透過號碼回傳碳足跡
      return carbon_foot_list[number];
    }
    function read_total_carbon_by_account(string account) view public returns (uint){
      //透過帳號回傳總碳足跡
      return total_carbon[account];
    }
}
