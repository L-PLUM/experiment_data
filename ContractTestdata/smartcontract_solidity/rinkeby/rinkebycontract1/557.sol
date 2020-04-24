/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.2;


interface Token {

    /// @return total amount of tokens
    function totalSupply() external view returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Optionally implemented function to show the number of decimals for the token
    function decimals() external view returns (uint8 decimals);
}

/// @title Utils
/// @notice Utils contract for various helpers used by the Raiden Network smart
/// contracts.
contract Utils {
    string constant public contract_version = "0.6.0";

    /// @notice Check if a contract exists
    /// @param contract_address The address to check whether a contract is
    /// deployed or not
    /// @return True if a contract exists, false otherwise
    function contractExists(address contract_address) public view returns (bool) {
        uint size;

        assembly {
            size := extcodesize(contract_address)
        }

        return size > 0;
    }
}

contract ServiceRegistry is Utils {
    string constant public contract_version = "0.6.0";
    Token public token;

    mapping(address => uint256) public deposits;  // token amount staked by the service provider
    mapping(address => string) public urls;  // URLs of services for HTTP access
    address[] public service_addresses;  // list of available services (ethereum addresses)

    constructor(address _token_address) public {
        require(_token_address != address(0x0));
        require(contractExists(_token_address));

        token = Token(_token_address);
        // Check if the contract is indeed a token contract
        require(token.totalSupply() > 0);
    }

    function deposit(uint amount) public {
        require(amount > 0);

        // This also allows for MSs to deposit and use other MSs
        deposits[msg.sender] += amount;

        // Transfer the deposit to the smart contract
        require(token.transferFrom(msg.sender, address(this), amount));
    }

    /// Set the URL used to access a service via HTTP.
    /// When this is called for the first time, the service's ethereum address
    /// is also added to `service_addresses`.
    function setURL(string memory new_url) public {
        require(bytes(new_url).length != 0);
        if (bytes(urls[msg.sender]).length == 0) {
            service_addresses.push(msg.sender);
        }
        urls[msg.sender] = new_url;
    }

    /// Returns number of registered services. Useful for accessing service_addresses.
    function serviceCount() public returns(uint) {
        return service_addresses.length;
    }
}
