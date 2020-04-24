/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.2;

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function deductBill(address from, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @title Controllers interface
 */
interface Controllers {
    function consumed(address id, uint256 value) external;
    function updateRate(address id, uint256 rate) external;
    function addControllers(address[] calldata controllers) external;
    function rate(address id) external view returns (uint256);
    function removeControllers(address[] calldata controllers) external;
    function controllersList() external view returns(address[] memory);
    function controllerStatus(address id) external view returns (uint8);
    function tweakControllersStatus(address[] calldata id, uint status) external;
}

interface TxPayloadDeserializer {
    function payloadDeserializer(bytes calldata dataframe) external pure 
    returns (uint8 signByte, uint32 remaning, uint16 decimals, uint32 nonce, uint32 consumedPower);
}

contract Manufacturer{
    using SafeMath for uint256;
    using ECDSA for bytes32;
    
    /*================================
    =            DATASETS            =
    ================================*/      
    
    enum DeviceStatus {AVAIABLE, BLOCKED, LENDED}
    
    //CUSTOMERS
    struct customer {
        address id; //public address
        address[] controllers;
        // uint256 balance; //customer balance
        uint256 arrears; //missed paymets
        uint256 index; //index of data stored in array for customer removal
        mapping(address => uint256) controllersIndex; // index of alloted controllers stored to avoid loops for delete
    }
    
    mapping (address => customer) public customerStruct; //array of structures
    address[] private customers; //array of customers
    mapping(address => address) public dev_Cust; // controllers alloted to customer
    
    //NODES
    struct node {
        bytes15 ip; //public ip
        string name; 
        uint256 index;
    }
    
    mapping (bytes15 => node) public nodeStruct; //array of structures
    bytes15[] private nodesList; //array of nodes
    
  
    // Signature size is 65 bytes (tightly packed  v + r + s)
    uint256 private constant _SIGNATURE_SIZE = 65;
    
    //per uint rate in weis
    uint256 public rate = 100;
    
    bool public balanceUpdate = false;
    uint256 public lastKnownBalance = 0;
  
    
    /*================================
    =         CONFIGURABLES          =
    ================================*/
    
    // Local
    // address wallet = address(0x20D73ef8eBF344b2930d242DA5DeC79d9dD9A92a); //wallet address
    
    // ERC20 private _token = ERC20(address(0xbBF289D846208c16EDc8474705C748aff07732dB)); //ERC20 token
    
    // Controllers private _controllers = Controllers(0x692a70D2e424a56D2C6C27aA97D1a86395877b3A);
    
    //Public
    address wallet = address(0x20D73ef8eBF344b2930d242DA5DeC79d9dD9A92a); //wallet address
    
    address tokenWallet = address(0x20D73ef8eBF344b2930d242DA5DeC79d9dD9A92a); //wallet address
    
    ERC20 private _token = ERC20(address(0xbf97057b5405CED9F33Be11D6FdE3870cc90990A)); //ERC20 token
    
    Controllers private _controllers = Controllers(0x929506Ec67b72D162A743A0247E87250EDC1c930);
    
    TxPayloadDeserializer _tpld = TxPayloadDeserializer(0x81fbf2F95807fE347661A5f648DEee17ed1Beb24);
    
    /*==============================
    =            EVENTS            =
    ==============================*/
    
    event CustomerAdded(address indexed customer_id, uint256 balance, address[] controllers);
    event CustomerRemoved(address indexed customer_id);
    event BalanceUpdated(address indexed customer_id, uint256 newBalance);
    event Billing(address indexed controller_id, uint256 consumedPower, uint256 bill, uint256 remaining, uint256 arrears, bool indexed ArrearsBilling);
    event StatusChanged(address indexed controller_id, uint16 indexed light, uint8 indexed status, uint256 timestamp, string eventName);
    event ConcealControllers(address indexed customer_id, address[] indexed controller_id);
    event LendControllers(address indexed customer_id, address[] indexed controller_id);
    
    /*================================
    =           MODIFIERS            =
    ================================*/
    
    modifier onlyValidCustomer(address customer_id) {
        require(customerStruct[customer_id].id != address(0x0));
        _;
    }
    
    /*=================================
    =            CUSTOMERS            =
    =================================*/
    
    function addCustomer(address customer_id, uint256 balance, 
        address[] memory controllers) public {
        require(customer_id != address(0x0));
        require(customerStruct[customer_id].id == address(0x0) );
        
        _token.transferFrom(tokenWallet, customer_id, balance);
        
        customers.push(customer_id);
        
        customerStruct[customer_id].id = customer_id;
        customerStruct[customer_id].index = customers.length - 1;
        
        lendControllers(customer_id, controllers);
        emit CustomerAdded(customer_id, balance, controllers);
        
    }
    
    function removeCustomer(address customer_id) external {
        uint256 deletedCustomer = customerStruct[customer_id].index;
        require(customerStruct[customer_id].id != address(0x0));
        
        if(deletedCustomer != customers.length -1){
            address lastCustomer = customers[customers.length-1];
            customers[deletedCustomer] = lastCustomer;
            customerStruct[lastCustomer].index = deletedCustomer;
        }
        
        concealControllers(customer_id, customerStruct[customer_id].controllers);
        delete customerStruct[customer_id];
        customers.length--;
        emit CustomerRemoved(customer_id);
    }
    
    function updateBalance(address customer_id, uint256 value)
        external {
        require(customerStruct[customer_id].id != address(0x0));
        require(value > 0);
        
        lastKnownBalance = balanceOf(customer_id);

        _token.transferFrom(msg.sender, customer_id, value);
        balanceUpdate = true;
        
        
        uint256 arrears = customerStruct[customer_id].arrears;
        uint256 balance = balanceOf(customer_id);
        uint256 consumed;
        
        if(arrears > 0 ) {
            if(arrears >= balance) {
                consumed = balance;
                uint256 arrearsLeft = arrears.sub(balance);
                customerStruct[customer_id].arrears = arrearsLeft;
            }else {
                consumed = arrears;
                customerStruct[customer_id].arrears = 0;
            }
            
            _token.deductBill(customer_id, consumed);
            
            emit Billing(customer_id, 0, consumed, balanceOf(customer_id),  customerStruct[customer_id].arrears, true);
        }
        
        emit BalanceUpdated(customer_id, balanceOf(customer_id));
    }
    
    function customerDetails(address customer_id) external view 
        returns(uint256 _balance, address[] memory controllers) {
        return(balanceOf(customer_id), customerStruct[customer_id].controllers);
    }
    
    function customersList () external view returns(address[] memory){
        return customers;
    }
    
    function lendControllers(address customer_id, address[] memory _controllerList) 
        onlyValidCustomer(customer_id) public {
        for(uint256 a = 0; a < _controllerList.length; a++){
            
            //controller should be available to lend
            require(dev_Cust[_controllerList[a]] == address(0x0));
            require(_controllers.controllerStatus(_controllerList[a]) == uint8(DeviceStatus.AVAIABLE));
            
            customerStruct[customer_id].controllers.push(_controllerList[a]);
            customerStruct[customer_id].controllersIndex[_controllerList[a]] = a;
            dev_Cust[_controllerList[a]] = customer_id;
        }
        _controllers.tweakControllersStatus(_controllerList, uint(DeviceStatus.LENDED));
        emit LendControllers(customer_id, _controllerList);
    }
    
    // //TODO: better way to identify controllers right now if require statement 
    function concealControllers(address customer_id, address[] memory controllers) 
        onlyValidCustomer(customer_id) public {
        for(uint256 a = 0; a < controllers.length; a++){
            
            uint256 deletedDevice = customerStruct[customer_id].controllersIndex[controllers[a]];
            if(deletedDevice != customerStruct[customer_id].controllers.length-1) {
                uint256 lastDeviceIndex = customerStruct[customer_id].controllers.length-1;
                address lastDevice = customerStruct[customer_id].controllers[lastDeviceIndex];
                customerStruct[customer_id].controllers[deletedDevice] = lastDevice;
                customerStruct[customer_id].controllersIndex[lastDevice] = deletedDevice;
            }
            customerStruct[customer_id].controllers.length--; //removing for customer.controllers
            delete customerStruct[customer_id].controllersIndex[controllers[a]];
            delete dev_Cust[controllers[a]]; //removing form mapping of controller to customer
        }
        _controllers.tweakControllersStatus(controllers, uint(DeviceStatus.AVAIABLE) );
        emit ConcealControllers(customer_id, controllers);
    }
    
    function deductBill(bytes calldata dataframe, uint8 v, bytes32 r, bytes32 s) external 
        returns(address controller, uint256 bill) 
        {
            uint256 decimals;
            uint256 remaining;
            uint256 nonce;
            uint256 signBit;
            uint256 consumed;
            uint256 consumedPower;
            
            address controller = decodeSigner(dataframe, v, r, s);
            address customer_id = dev_Cust[controller];
            require(customer_id != address(0x0));
            
            (signBit, remaining, decimals, nonce, consumedPower) = decodeData(dataframe);
            
            uint256 balance = balanceOf(customer_id);
            
            remaining = remaining.mul(1 ether); 
            decimals = decimals.mul(10**15); //we are dealing with 3 deciamls 0.001 is minimum value
            consumed = customerStruct[customer_id].arrears; //already consumed
            remaining = remaining.add(decimals); //also count decimals in Billing
            
            if(balanceUpdate == false)
                    consumed = consumed.add(balance.sub(remaining));
            else { //balanceUpdate = true
                // if(lastKnownBalance > lastKnownBalance.sub(remaining))
                consumed = consumed.add(lastKnownBalance.sub(remaining));
                balanceUpdate = false;                    
            }

            
            _token.deductBill(customer_id, consumed);
            _controllers.consumed(controller, consumed);
            emit Billing(controller,consumedPower, consumed, balanceOf(customer_id), customerStruct[customer_id].arrears, false);
            return (controller, consumed);
        }
    
    /*=================================
    =              NODES              =
    =================================*/

    function addNodes(bytes15 nodeIp, string calldata nodeName) external {
        require(nodeStruct[nodeIp].ip != nodeIp);
        nodesList.push(nodeIp);
        nodeStruct[nodeIp] = node(nodeIp, nodeName, (nodesList.length-1));
    }
    
    function removeNode(bytes15 deletedNode) external {
        uint256 deletedNodeIndex = nodeStruct[deletedNode].index;

        if (deletedNodeIndex != nodesList.length-1) {
            // last node
            bytes15 lastNode = nodesList[nodesList.length-1];
            nodesList[deletedNodeIndex] = lastNode;
            nodeStruct[lastNode].index = deletedNodeIndex; 
        }
        delete nodeStruct[deletedNode];
        nodesList.length--;
    }
    
    function nodes() external view returns (bytes15[] memory){
        return nodesList;
    }
    
    function nodeDetails(uint256 index) external view returns(bytes15 ip, string memory name){
        return (nodesList[index], nodeStruct[nodesList[index]].name);
    }
    
    /*=================================
    =        CONTROLLERS INVENTORY        =
    =================================*/
    
    function broadcastStatus(address device, string calldata eventName, bytes2 light, bytes1 status) external {
        emit StatusChanged(device, uint16(light), uint8(status), block.timestamp, eventName);
    }
    
    function controllerStatus(address controller) external view returns(uint) {
        return _controllers.controllerStatus(controller);
    }
    
    
    function controllersList() public view returns(address[] memory controllers){
        return _controllers.controllersList();
    }
    
    function controllerRatePerUnit(address controller) public view returns (uint256) {
        return _controllers.rate(controller);
    }
    
    function tweakControllersStatus(address[] calldata id, DeviceStatus status) external {
        _controllers.tweakControllersStatus(id,uint(status));
    }
    
    /*=================================
    =        CONTROLLERS CONTROL      =
    =================================*/
    

    /*=================================
    =        UPDATE INTERFACES        =
    =================================*/
    function updateWallet (address _wallet) external {
        require(_wallet != address(0x0));
        wallet = _wallet;
    }
    
    function updateTokenWallet (address _wallet) external {
        require(_wallet != address(0x0));
        tokenWallet = _wallet;
    }
    
    function updateERC20Contract (ERC20 tokenContract) external {
        require(address(tokenContract) != address(0x0));
        _token = ERC20(address(tokenContract));
    }
    
    function updateControllersContract (address controllersContract) external {
        require(controllersContract != address(0x0));
        _controllers = Controllers(address(controllersContract));
    }
    
    /*=================================
    =           MISCELLANEOUS         =
    =================================*/

    function balanceOf(address customer_id) public view returns(uint256) {
        return _token.balanceOf(customer_id);
    }
    
    function tokenAmount(uint256 amount) external view returns(uint256) {
        return amount.mul(rate);
    }
    
    function remaningUnits(address controller) external view returns(uint256) {
        return balanceOf(msg.sender).div(controllerRatePerUnit(controller));
    }
    
    function contractBalance() external view returns(uint256){
        return _token.allowance(msg.sender, address(this));
    }
    
    function decodeSigner(bytes memory dataframe, uint8 v, bytes32 r, bytes32 s) public pure 
        returns (address signer){
        bytes32 frameHash = keccak256(abi.encodePacked(dataframe));
        address signingDevice = ecrecover(frameHash, v,r,s);
        require(signingDevice != address(0x0)); // to prevent deleted controllers in next validation
        return signingDevice;
    }
    
    
    function decodeData(bytes memory dataframe) public view 
        returns (uint8 signBit, uint32 remaning, uint32 decimals, uint32 nonce, uint32 consumedPower) {
        return (_tpld.payloadDeserializer(dataframe));
    }
    
}
