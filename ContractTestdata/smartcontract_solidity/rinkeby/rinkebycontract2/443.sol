pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract KryptoOz is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, ERC20Pausable {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */

    constructor () public ERC20Detailed("KryptoOz", "KPO", 18) {
        _mint(msg.sender, 108000000 * (10 ** uint256(decimals())));
    }
}
