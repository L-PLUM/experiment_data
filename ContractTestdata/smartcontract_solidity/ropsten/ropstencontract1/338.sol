/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity 0.4.23;

library AddressUtil {
    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {
        if (addr == 0x0) {
            return false;
        } else {
            uint size;
            assembly { size := extcodesize(addr) }
            return size > 0;
        }
    }
}

contract Ownable {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Claimable is Ownable {
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        onlyOwner
        public
    {
        require(newOwner != 0x0 && newOwner != owner);
        pendingOwner = newOwner;
    }
}

contract TokenRegistry {
    event TokenRegistered(
        address indexed addr,
        string          symbol
    );

    event TokenUnregistered(
        address indexed addr,
        string          symbol
    );

    function registerToken(
        address addr,
        string  symbol
        )
        external;

    function unregisterToken(
        address addr,
        string  symbol
        )
        external;

    function areAllTokensRegistered(
        address[] addressList
        )
        external
        view
        returns (bool);

    function isTokenRegistered(
        address addr
        )
        public
        view
        returns (bool);

    function getTokens(
        uint start,
        uint count
        )
        public
        view
        returns (address[] addressList);
}

contract TokenRegistryImpl is TokenRegistry, Claimable {
    using AddressUtil for address;

    address[] public addresses;
    mapping (address => TokenInfo) public addressMap;

    struct TokenInfo {
        uint   pos;      // 0 mens unregistered; if > 0, pos + 1 is the
                         // token's position in `addresses`.
        string symbol;   // Symbol of the token
    } 

    /// @dev Disable default function.
    function ()
        payable
        public
    {
        revert();
    }

    function registerToken(
        address addr,
        string  symbol
        )
        external
        onlyOwner
    {
        registerTokenInternal(addr, symbol);
    }

    function unregisterToken(
        address addr,
        string  symbol
        )
        external
        onlyOwner
    {
        require(addr != 0x0);

        uint pos = addressMap[addr].pos;
        require(pos != 0);
        delete addressMap[addr];

        // We will replace the token we need to unregister with the last token
        // Only the pos of the last token will need to be updated
        address lastToken = addresses[addresses.length - 1];

        // Don't do anything if the last token is the one we want to delete
        if (addr != lastToken) {
            // Swap with the last token and update the pos
            addresses[pos - 1] = lastToken;
            addressMap[lastToken].pos = pos;
        }
        addresses.length--;

        emit TokenUnregistered(addr, symbol);
    }
    
    function areAllTokensRegistered(
        address[] addressList
        )
        external
        view
        returns (bool)
    {
        for (uint i = 0; i < addressList.length; i++) {
            if (addressMap[addressList[i]].pos == 0) {
                return false;
            }
        }
        return true;
    }

    function isTokenRegistered(
        address addr
        )
        public
        view
        returns (bool)
    {
        return addressMap[addr].pos != 0;
    }

    function getTokens(
        uint start,
        uint count
        )
        public
        view
        returns (address[] addressList)
    {
        uint num = addresses.length;
        if (start >= num) {
            return;
        }
        uint end = start + count;
        if (end > num) {
            end = num;
        }
        addressList = new address[](end - start);
        for (uint i = start; i < end; i++) {
            addressList[i - start] = addresses[i];
        }
    }

    function registerTokenInternal(
        address addr,
        string  symbol
        )
        internal
    {
        require(0x0 != addr);
        require(bytes(symbol).length > 0);
        require(0 == addressMap[addr].pos);
        addresses.push(addr);
        addressMap[addr] = TokenInfo(addresses.length, symbol);
        emit TokenRegistered(addr, symbol);
    }
}
