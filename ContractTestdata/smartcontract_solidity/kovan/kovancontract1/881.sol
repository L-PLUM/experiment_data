/**
 *Submitted for verification at Etherscan.io on 2018-12-19
*/

pragma solidity ^0.4.24;

contract PaymentOrdersStorage {

  event BeginCreateProject(uint projectId, address owner, uint platform_project_id);
  
  event EndCreateProject(uint projectId, address owner, uint platform_project_id);
  
  event BeginCreatePaymentOrder(uint projectId, uint paymentOrderId);
  
  event EndCreatePaymentOrder(uint projectId, uint paymentOrderId);
  
  struct PaymentOrder {
      string from_org_inn;
      string from_org_kpp;
      string from_org_ogrn;
      string from_bank_inn;
      string from_bank_kpp;
      string from_bank_ogrn;
      string from_bank_bik;
      string from_account;
      string to_org_inn;
      string to_org_kpp;
      string to_org_ogrn;
      string to_bank_inn;
      string to_bank_kpp;
      string to_bank_ogrn;
      string to_bank_bik;
      string to_account;
      string amount;
      string execution_time;
  }
  
  struct Project {
      address owner;
      uint platform_project_id;
      mapping(uint => PaymentOrder) orders;
      uint ordersSize;
      bool created;
  }
  
  Project[] public projects;
  
  function beginCreateProject(uint platform_project_id) public {
    Project memory project = Project({owner: msg.sender, ordersSize: 0, platform_project_id: platform_project_id, created: false});
    projects.push(project);
    emit BeginCreateProject(projects.length - 1, project.owner, project.platform_project_id);
  }
  
  function beginCreatePaymentOrder(
    uint projectId,
    string memory from_org_inn,
    string memory from_org_kpp,
    string memory from_org_ogrn,
    string memory from_bank_inn,
    string memory from_bank_kpp,
    string memory from_bank_ogrn,
    string memory from_bank_bik,
    string memory from_account) public {
        
    Project storage project = projects[projectId];
    require(!project.created, "Project already created!");
    require(project.owner == msg.sender, "You are not authorized to finish project!");
    
    PaymentOrder storage order = project.orders[project.ordersSize];
    
    order.from_org_inn = from_org_inn;
    order.from_org_kpp = from_org_kpp;
    order.from_org_ogrn = from_org_ogrn;
    order.from_bank_inn = from_bank_inn;
    order.from_bank_kpp = from_bank_kpp;
    order.from_bank_ogrn = from_bank_ogrn;
    order.from_bank_bik = from_bank_bik;
    order.from_account = from_account;
    
    emit BeginCreatePaymentOrder(projectId, project.ordersSize);
    
    project.ordersSize++;
  }
  
  function endCreatePaymentOrder(
    uint projectId,
    uint orderId,
    string memory to_org_inn,
    string memory to_org_kpp,
    string memory to_org_ogrn,
    string memory to_bank_inn,
    string memory to_bank_kpp,
    string memory to_bank_ogrn,
    string memory to_bank_bik,
    string memory to_account,
    string memory amount,
    string memory execution_time) public {
        
    Project storage project = projects[projectId];
    require(!project.created, "Project already created!");
    require(project.owner == msg.sender, "You are not authorized to finish project!");
    
    PaymentOrder storage order = project.orders[orderId];
    
    order.to_org_inn = to_org_inn;
    order.to_org_kpp = to_org_kpp;
    order.to_org_ogrn = to_org_ogrn;
    order.to_bank_inn = to_bank_inn;
    order.to_bank_kpp = to_bank_kpp;
    order.to_bank_ogrn = to_bank_ogrn;
    order.to_bank_bik = to_bank_bik;
    order.to_account = to_account;
    order.amount = amount;
    order.execution_time = execution_time;
    
    emit EndCreatePaymentOrder(projectId, orderId);
  }
  
  function endCreateProject(uint projectId) public {
      
    Project storage project = projects[projectId];
    require(!project.created, "Project already created!");
    require(project.owner == msg.sender, "You are not authorized to finish project!");
    
    project.created = true;
    
    emit EndCreateProject(projectId, project.owner, project.platform_project_id);
  }

}
