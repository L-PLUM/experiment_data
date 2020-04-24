/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/ITokenTransferValidator.sol

contract ITokenTransferValidator {
  function validateTransfer(address sender, address from, address to, uint256 amount) public view;
  function validateMint(address minter, address to, uint256 amount) public view;
}

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/IRegistry.sol

contract IRegistry {
  string public constant REGISTRY_KEY = "REGISTRY";

  function getAddress(string memory _key) public view returns (address);
}

// File: /Users/martianov/Projects/Exyte/EarthLedger/earth-ledger-token/contracts/IWhitelist.sol

contract IWhitelist {
  function isWhitelisted(address account) public view returns (bool);
}

// File: contracts/TokenTransferValidator.sol

contract TokenTransferValidator is ITokenTransferValidator {
  string constant WHITELIST_KEY = "WHITELIST";
  string constant VESTING_FACTORY_KEY = "VESTING_FACTORY";

  IRegistry public registry;
  IWhitelist public whitelist;
  address public vestingFactoryAddress;
  

  constructor (IRegistry _registry) public {
    registry = _registry;
    whitelist = IWhitelist(_registry.getAddress(WHITELIST_KEY));
    vestingFactoryAddress = _registry.getAddress(VESTING_FACTORY_KEY);
  }

  function validateTransfer(address sender, address from, address to, uint256 amount) public view {
    require(sender == vestingFactoryAddress || whitelist.isWhitelisted(to), 'must be whitelisted');
  }

  function validateMint(address minter, address to, uint256 amount) public view {
    require(whitelist.isWhitelisted(to), 'must be whitelisted');
  }

  function reload() public {
    registry = IRegistry(registry.getAddress("REGISTRY"));
    reloadFromRegistry();
  }

  function reloadFromRegistry() internal {
    whitelist = IWhitelist(registry.getAddress(WHITELIST_KEY));
    vestingFactoryAddress = registry.getAddress(VESTING_FACTORY_KEY);
  }
}
