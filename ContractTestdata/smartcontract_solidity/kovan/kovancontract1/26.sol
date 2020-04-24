/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.24;

// File: contracts/PayamentOrdersStorage.sol

contract PaymentOrdersStorage {

  event BeginCreateProject(uint projectId, address owner, uint platform_project_id);

  event EndCreateProject(uint projectId, address owner, uint platform_project_id);

  event BeginCreatePaymentOrder(uint projectId, uint paymentOrderId);

  event EndCreatePaymentOrder(uint projectId, uint paymentOrderId);

  struct PaymentOrder {
      string from_org_inn;
      string from_org_kpp;
      string from_org_name;
      string from_bank_bik;
      string from_bank_name;
      string from_bank_account;
      string from_bank_corr_account;
      string to_org_inn;
      string to_org_kpp;
      string to_org_name;
      string to_bank_bik;
      string to_bank_name;
      string to_bank_account;
      string to_bank_corr_account;
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
  
    function getPaymentOrderToData(uint projectId, uint paymentOrderId) public view returns(
      string to_org_inn,
      string to_org_kpp,
      string to_org_name,
      string to_bank_bik,
      string to_bank_name,
      string to_bank_account,
      string to_bank_corr_account) {
    PaymentOrder storage po = projects[projectId].orders[paymentOrderId];
    return (po.to_org_inn,
      po.to_org_kpp,
      po.to_org_name,
      po.to_bank_bik,
      po.to_bank_name,
      po.to_bank_account,
      po.to_bank_corr_account);
  }

  function getPaymentOrderFromData(uint projectId, uint paymentOrderId) public view returns(
      string amount,
      string execution_time) {
    PaymentOrder storage po = projects[projectId].orders[paymentOrderId];
    return (po.amount,po.execution_time);
  }
  
  function getPaymentOrderData(uint projectId, uint paymentOrderId) public view returns(
      string from_org_inn,
      string from_org_kpp,
      string from_org_name,
      string from_bank_bik,
      string from_bank_name,
      string from_bank_account,
      string from_bank_corr_account) {
    PaymentOrder storage po = projects[projectId].orders[paymentOrderId];
    return (po.from_org_inn,
      po.from_org_kpp,
      po.from_org_name,
      po.from_bank_bik,
      po.from_bank_name,
      po.from_bank_account,
      po.from_bank_corr_account);
  }

  function beginCreateProject(uint platform_project_id) public {
    Project memory project = Project({owner: msg.sender, ordersSize: 0, platform_project_id: platform_project_id, created: false});
    projects.push(project);
    emit BeginCreateProject(projects.length - 1, project.owner, project.platform_project_id);
  }

  function beginCreatePaymentOrder(
    uint projectId,
    string memory from_org_inn,
    string memory from_org_kpp,
    string memory from_org_name,
    string memory from_bank_bik,
    string memory from_bank_name,
    string memory from_bank_account,
    string memory from_bank_corr_account
  ) public {

    Project storage project = projects[projectId];
    require(!project.created, "Project already created!");
    require(project.owner == msg.sender, "You are not authorized to finish project!");

    PaymentOrder storage order = project.orders[project.ordersSize];

    order.from_org_inn = from_org_inn;
    order.from_org_kpp = from_org_kpp;
    order.from_org_name = from_org_name;
    order.from_bank_bik = from_bank_bik;
    order.from_bank_name = from_bank_name;
    order.from_bank_account = from_bank_account;
    order.from_bank_corr_account = from_bank_corr_account;

    emit BeginCreatePaymentOrder(projectId, project.ordersSize);

    project.ordersSize++;
  }

  function endCreatePaymentOrder(
    uint projectId,
    uint orderId,
    string memory to_org_inn,
    string memory to_org_kpp,
    string memory to_org_name,
    string memory to_bank_bik,
    string memory to_bank_name,
    string memory to_bank_account,
    string memory to_bank_corr_account,
    string memory amount,
    string memory execution_time
  ) public {

    Project storage project = projects[projectId];
    require(!project.created, "Project already created!");
    require(project.owner == msg.sender, "You are not authorized to finish project!");

    PaymentOrder storage order = project.orders[orderId];

    order.to_org_inn = to_org_inn;
    order.to_org_kpp = to_org_kpp;
    order.to_org_name = to_org_name;
    order.to_bank_bik = to_bank_bik;
    order.to_bank_name = to_bank_name;
    order.to_bank_account = to_bank_account;
    order.to_bank_corr_account = to_bank_corr_account;
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
