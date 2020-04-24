/**
 *Submitted for verification at Etherscan.io on 2018-12-18
*/

pragma solidity ^0.5.0; //TODO: new version 

//NOTICE: prototype to test out different ideas of handling cdps

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSProxyInterface {
    function execute(bytes memory _code, bytes memory _data) public payable returns (address target, bytes32 response);
    function execute(address _target, bytes memory _data) public payable returns (bytes32 response);
}

contract CDPInterface {
    function lad(bytes32 cup) public view returns (address);

    function open() public returns (bytes32 cup);
    function give(bytes32 cup, address guy) public;
    function lock(bytes32 cup, uint wad) public;
    function free(bytes32 cup, uint wad) public;
    function draw(bytes32 cup, uint wad) public;
    function wipe(bytes32 cup, uint wad) public;
    function shut(bytes32 cup) public;
    function bite(bytes32 cup) public;
}

contract MarketplaceAuthority is DSAuthority {

    address public MARKETPLACE_CONTRACT;

    constructor(address _marketplace) public {
        MARKETPLACE_CONTRACT = _marketplace;
    }

    function canCall(address src, address dst, bytes4 sig) public view returns (bool) {
        return (bytes4(keccak256("execute(address,bytes)")) == sig) && (src == MARKETPLACE_CONTRACT);
    }
}

contract Marketplace is DSAuth {

    struct SaleItem {
        uint price;
        uint time;
        address payable lad;
        bool active;
    }

    mapping (bytes32 => SaleItem) public items;
    bytes32[] public itemsArr;
    uint public numItems;

    // address constant TUB_ADDRESS = 0x448a5065aebb8e423f0896e6c5d525c040f59af3;
    address constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2; //KOVAN

    CDPInterface cdp = CDPInterface(TUB_ADDRESS);

    event OnSale(bytes32 indexed cup, address indexed lad, uint price);
    event Bought(bytes32 indexed cup, address indexed newLad, address indexed oldLad, uint price);

    function putOnSale(uint _cup, uint _price) public {
        bytes32 cup = bytes32(_cup);
        
        // require(cdp.lad(cup) == msg.sender, "msg.sender must be cup owner");

        items[cup] = SaleItem({
            price: _price,
            time: now,
            lad: msg.sender,
            active: true
        });

        itemsArr.push(cup);
        
        numItems++;

        emit OnSale(cup, msg.sender, _price);

    }

    function buy(uint _cup) public payable {
        bytes32 cup = bytes32(_cup);
        
        require(items[cup].active == true, "Check if cup is on sale");
        require(msg.value >= items[cup].price, "Check if enough ether is sent for this cup");

        DSProxyInterface usersProxy =  DSProxyInterface(items[cup].lad);

        // give the cup to the buyer, him becoming the lad that owns the cup
        usersProxy.execute(TUB_ADDRESS, 
            abi.encodeWithSignature("give(bytes32, address)", cup, msg.sender));

        //TODO: take a fee?

        items[cup].lad.transfer(items[cup].price); // transfer money to the seller

        //TODO: delete the sales item
        items[cup].active = false;
    }

    function cancel(uint cdpId) public {

    }

}

contract TestContract {
    address constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2; //KOVAN

    CDPInterface cdp = CDPInterface(TUB_ADDRESS);
    
    function callSell(uint _cup, uint _price) public pure returns(bytes memory) {
        bytes memory data = abi.encodeWithSignature("putOnSale(uint256,uint256)", _cup, _price);
        
        return data;

    }
    
    function callCancel(uint _cup) public pure returns(bytes memory) {
        bytes memory data = abi.encodeWithSignature("cancel(uint)", _cup);
        
        return data;

    }
    
    function getOwner(uint _cup) public view returns(address) {
        bytes32 cup = bytes32(_cup);
        
        return cdp.lad(cup);
    }
}
