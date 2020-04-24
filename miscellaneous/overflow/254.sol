pragma solidity ^0.5.0;

contract Lighthouse {
    using SafeERC20 for XRT;

    IFactory public factory;
    XRT      public xrt;

    function setup(XRT _xrt, uint256 _minimalStake, uint256 _timeoutInBlocks) external returns (bool) {
        require(factory == IFactory(0) && _minimalStake > 0 && _timeoutInBlocks > 0);

        minimalStake    = _minimalStake;
        timeoutInBlocks = _timeoutInBlocks;
        factory         = IFactory(msg.sender);
        xrt             = _xrt;

        return true;
    }

    /**
     * @dev Providers index, started from 1
     */
    mapping(address => uint256) public indexOf;

    function refill(uint256 _value) external returns (bool) {
        xrt.safeTransferFrom(msg.sender, address(this), _value);

        if (stakes[msg.sender] == 0) {
            require(_value >= minimalStake);
            providers.push(msg.sender);
            indexOf[msg.sender] = providers.length;
            emit Online(msg.sender);
        }

        stakes[msg.sender] += _value;
        return true;
    }

    function withdraw(uint256 _value) external returns (bool) {
        require(stakes[msg.sender] >= _value);

        stakes[msg.sender] -= _value;
        xrt.safeTransfer(msg.sender, _value);

        // Drop member with zero quota
        if (quotaOf(msg.sender) == 0) {
            uint256 balance = stakes[msg.sender];
            stakes[msg.sender] = 0;
            xrt.safeTransfer(msg.sender, balance);
            
            uint256 senderIndex = indexOf[msg.sender] - 1;
            uint256 lastIndex = providers.length - 1;
            if (senderIndex < lastIndex)
                providers[senderIndex] = providers[lastIndex];

            providers.length -= 1;
            indexOf[msg.sender] = 0;

            emit Offline(msg.sender);
        }
        return true;
    }

    function keepAliveTransaction() internal {
        if (timeoutInBlocks < block.number - keepAliveBlock) {
            // Set up the marker according to provider index
            marker = indexOf[msg.sender];

            // Thransaction sender should be a registered provider
            require(marker > 0 && marker <= providers.length);

            // Allocate new quota
            quota = quotaOf(providers[marker - 1]);

            // Current provider signal
            emit Current(providers[marker - 1], quota);
        }

        // Store transaction sending block
        keepAliveBlock = block.number;
    }

   
}
