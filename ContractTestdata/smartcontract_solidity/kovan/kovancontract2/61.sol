/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity >=0.5.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IShifter {
    function shiftIn(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);
    function shiftOut(bytes calldata _to, uint256 _amount) external returns (uint256);
}

interface IShifterRegistry {
    function getShifterBySymbol(string calldata _tokenSymbol) external view returns (IShifter);
    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (IERC20);
}

contract Basic {
    IShifterRegistry public registry;
    
    event Deposit(uint256 _amount, bytes _msg);
    event Withdrawal(bytes _to, uint256 _amount, bytes _msg);

    constructor(IShifterRegistry _registry) public {
        registry = _registry;
    }

    function deposit(
        // Parameters from users
        bytes calldata _msg,
        // Parameters from Darknodes
        uint256        _amount,
        bytes32        _nHash,
        bytes calldata _sig
    ) external {
        bytes32 pHash = keccak256(abi.encode(_msg));
        uint256 shiftedInAmount = registry.getShifterBySymbol("zBTC").shiftIn(pHash, _amount, _nHash, _sig);
        emit Deposit(shiftedInAmount, _msg);
    }

    function withdraw(bytes calldata _msg, bytes calldata _to, uint256 _amount) external {
        uint256 shiftedOutAmount = registry.getShifterBySymbol("zBTC").shiftOut(_to, _amount);
        emit Withdrawal(_to, shiftedOutAmount, _msg);
    }

    function balance() public view returns (uint256) {
        return registry.getTokenBySymbol("zBTC").balanceOf(address(this));
    }
}
