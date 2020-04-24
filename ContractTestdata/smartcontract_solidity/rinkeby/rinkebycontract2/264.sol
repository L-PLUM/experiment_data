/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.2;

// File: contracts/lib/Roles.sol

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: contracts/lib/AssignerRole.sol

contract AssignerRole {
    using Roles for Roles.Role;

    event AssignerAdded(address indexed account);
    event AssignerRemoved(address indexed account);

    Roles.Role private _assigners;

    constructor () internal {
        _addAssigner(msg.sender);
    }

    modifier onlyAssigner() {
        require(isAssigner(msg.sender), "AssignerRole: caller does not have the Assigner role");
        _;
    }

    function isAssigner(address account) public view returns (bool) {
        return _assigners.has(account);
    }

    function addAssigner(address account) public onlyAssigner {
        _addAssigner(account);
    }

    function removeAssigner() public {
        _removeAssigner(msg.sender);
    }

    function _addAssigner(address account) internal {
        _assigners.add(account);
        emit AssignerAdded(account);
    }

    function _removeAssigner(address account) internal {
        _assigners.remove(account);
        emit AssignerRemoved(account);
    }
}

// File: contracts/token/IERC20.sol

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/EmethJob.sol

contract EmethJob is AssignerRole {

    Job[] public _jobs;
    mapping(bytes16 => JobIndex) public _jobIndex;
    mapping(address => JobIndex[]) public _ownerJobIndex;
    mapping(bytes16 => mapping(uint256 => Node)) public _assignedNodes;
    mapping(bytes16 => mapping(address => NodeIndex)) public _assignedNodeIndex;
    address public payableTokenAddr;
    
    uint256 REQUESTED = 0;
    uint256 ASSIGNED = 1;
    uint256 PROCESSING = 2;
    uint256 COMPLETED = 3;
    uint256 CANCELED = 4;
    uint256 FAILED = 5;
    
    event Request(address indexed owner, bytes16 indexed jobId, uint256 gas);
    event Cancel(bytes16 indexed jobId);
    event Assign(bytes16 indexed jobId, address nodeAddress);
    event Status(bytes16 indexed jobId, address nodeAddress, uint256 status);

    struct Job {
        bytes16 jobId;
        address owner;
        uint256 programId;
        string programLink;
        string param;
        uint256 gas;
        uint256 numOfNodes;
        uint256 status; //0: requested, 1: assigned, 2: processing, 3: completed, 4: canceled
        bool exist;
    }
    
    struct JobIndex {
        uint256 index;
        bool exist;
    }
    
    struct Node {
        address nodeAddress;
        uint256 status; //1: assigned, 3: completed, 5: failed
        string result;
    }
    
    struct NodeIndex {
        uint256 index;
        bool exist;
    }
    
    modifier onlyAssignedNode(bytes16 _jobId) {
        require(_jobIndex[_jobId].exist);
        require(_assignedNodeIndex[_jobId][msg.sender].exist);
        _;
    }

    constructor(address _payableTokenAddr) public {
        payableTokenAddr = _payableTokenAddr;
    }

    function request(bytes16 _jobId, uint256 _programId, string calldata _programLink, string calldata _param, uint256 _gas) external returns (bool) {
        require(!_jobIndex[_jobId].exist);
        
        IERC20 token = IERC20(payableTokenAddr);
        require(token.balanceOf(msg.sender) >= _gas);
        token.transferFrom(msg.sender, address(this), _gas);
    
        _jobs.push(Job(_jobId, msg.sender, _programId, _programLink, _param, _gas, 0, REQUESTED, true));
        
        _jobIndex[_jobId] = JobIndex(_jobs.length - 1, true);
        _ownerJobIndex[msg.sender].push(JobIndex(_jobs.length - 1, true));
        
        emit Request(msg.sender, _jobId, _gas);
    }
    
    function cancel(bytes16 _jobId) external returns (bool) {
        require(_jobIndex[_jobId].exist);
        Job storage job = _jobs[_jobIndex[_jobId].index];
        require(job.exist);
        require(job.owner == msg.sender);
        require(job.status == REQUESTED);
        
        uint256 refund = job.gas;
        
        job.status = CANCELED;
        job.gas = 0;
        
        IERC20 token = IERC20(payableTokenAddr);
        token.transfer(msg.sender, refund);
        
        emit Cancel(_jobId);
    }
    
    function assign(bytes16 _jobId, address[] calldata _nodes) external onlyAssigner returns (bool) {
        Job storage job = _jobs[_jobIndex[_jobId].index];
        if(job.numOfNodes != 0) {
            for(uint256 i = 0; i < job.numOfNodes; i++) {
                _assignedNodeIndex[_jobId][_assignedNodes[_jobId][i].nodeAddress].exist = false;
            }
        }
        for(uint256 i = 0; i < _nodes.length; i++) {
            _assignedNodes[_jobId][i] = Node(_nodes[i], ASSIGNED, "");
            _assignedNodeIndex[_jobId][_nodes[i]] = NodeIndex(i, true);
            emit Assign(_jobId, _nodes[i]);
        }
        job.numOfNodes = _nodes.length;
    
        return true;
    }
    
    function process(bytes16 _jobId) external onlyAssignedNode(_jobId) returns (bool) {
        require(_jobIndex[_jobId].exist);
        require(_assignedNodeIndex[_jobId][msg.sender].exist);
        require(_assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status == ASSIGNED);
        _assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status = PROCESSING;
    }
    
    function submit(bytes16 _jobId, string calldata _result, bool _master) external onlyAssignedNode(_jobId) returns (bool) {
        require(_jobIndex[_jobId].exist);
        require(_assignedNodeIndex[_jobId][msg.sender].exist);
        require(_assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status == PROCESSING);
        _assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status = COMPLETED;
        _assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].result = _result;

        if(_master) {
            uint256 workerCount = 0;
            for(uint256 i = 0; i < _jobs[_jobIndex[_jobId].index].numOfNodes; i++) {
                if(_assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status == COMPLETED) {
                    workerCount++;
                }
            }
            if(workerCount > 1) {
                IERC20 token = IERC20(payableTokenAddr);
                uint256 payout = _jobs[_jobIndex[_jobId].index].gas / workerCount;
                for(uint256 i = 0; i < _jobs[_jobIndex[_jobId].index].numOfNodes; i++) {
                    if(_assignedNodes[_jobId][_assignedNodeIndex[_jobId][msg.sender].index].status == COMPLETED) {
                        token.transfer(_assignedNodes[_jobId][i].nodeAddress, payout);
                    }
                }
            }
        }
    }
    
    function getJobAt(uint256 _index) external view returns (bytes16, uint256, string memory, uint256, uint256) {
        Job memory job = _jobs[_index];
        return (job.jobId, job.programId, job.programLink, job.gas, job.status);
    }
    
    function getJob(bytes16 _jobId) public view returns (
        bytes16 jobId,
        address owner,
        uint256 programId,
        string memory programLink,
        string memory param,
        uint256 gas,
        uint256 numOfNodes,
        uint256 status,
        bool exist) {
            require(_jobIndex[_jobId].exist);
            Job memory job = _jobs[_jobIndex[_jobId].index];
            return (_jobId, job.owner, job.programId, job.programLink, job.param, job.gas, job.numOfNodes, job.status, job.exist);
    }
    
    function getJobCountOf(address _owner) external view returns (uint256) {
        return _ownerJobIndex[_owner].length;
    }
    
    function getJobOf(address _owner, uint256 _index) external view returns (
        bytes16 _jobId,
        uint256 _programId,
        string memory programLink,
        string memory param,
        uint256 gas,
        uint256 numOfNodes,
        uint256 status,
        bool exist) {
        Job memory job = _jobs[_ownerJobIndex[_owner][_index].index];
        return (job.jobId, job.programId, job.programLink, job.param, job.gas, job.numOfNodes, job.status, job.exist);
    }
    
    function getAssignedNodeCount(bytes16 _jobId) external view returns (uint256) {
        require(_jobIndex[_jobId].exist);
        return _jobs[_jobIndex[_jobId].index].numOfNodes;
    }
    
    function getAssignedNode(bytes16 _jobId, uint256 _index) external view returns (address nodeAddress, uint256 status, string memory result) {
        require(_jobIndex[_jobId].exist);
        Node memory node = _assignedNodes[_jobId][_index];
        return (node.nodeAddress, node.status, node.result);
    }
    
    function getResultAt(bytes16 _jobId, uint256 _nodeIndex) external view returns (string memory) {
        require(_jobIndex[_jobId].exist);
        return _assignedNodes[_jobId][_nodeIndex].result;
    }
    
    function getStatus(bytes16 _jobId) external view returns (uint256) {
        require(_jobIndex[_jobId].exist);
        Job storage job = _jobs[_jobIndex[_jobId].index];
        
        if(job.numOfNodes == 0) {
            return job.status;
        }else{
            uint256 status = COMPLETED;
            for(uint256 i = 0; i < job.numOfNodes; i++) {
                if(status > _assignedNodes[_jobId][i].status) status = _assignedNodes[_jobId][i].status;
            }
            return status;
        }
    }
}
