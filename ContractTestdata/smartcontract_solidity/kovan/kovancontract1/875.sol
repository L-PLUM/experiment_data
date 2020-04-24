/**
 *Submitted for verification at Etherscan.io on 2018-12-19
*/

/**
*  @title Random Number Generator Standard
*  @author Clément Lesaege - <[email protected]>
*
*/

pragma solidity ^0.4.15;

contract RNG{

    /** @dev Contribute to the reward of a random number.
    *  @param _block Block the random number is linked to.
    */
    function contribute(uint _block) public payable;

    /** @dev Request a random number.
    *  @param _block Block linked to the request.
    */
    function requestRN(uint _block) public payable {
        contribute(_block);
    }

    /** @dev Get the random number.
    *  @param _block Block the random number is linked to.
    *  @return RN Random Number. If the number is not ready or has not been required 0 instead.
    */
    function getRN(uint _block) public returns (uint RN);

    /** @dev Get a uncorrelated random number. Act like getRN but give a different number for each sender.
    *  This is to prevent users from getting correlated numbers.
    *  @param _block Block the random number is linked to.
    *  @return RN Random Number. If the number is not ready or has not been required 0 instead.
    */
    function getUncorrelatedRN(uint _block) public returns (uint RN) {
        uint baseRN = getRN(_block);
        if (baseRN == 0)
        return 0;
        else
        return uint(keccak256(msg.sender,baseRN));
    }

}

/**
 *  @title Arbitrator
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;

/** @title Arbitrator
 *  Arbitrator abstract contract.
 *  When developing arbitrator contracts we need to:
 *  -Define the functions for dispute creation (createDispute) and appeal (appeal). Don't forget to store the arbitrated contract and the disputeID (which should be unique, use nbDisputes).
 *  -Define the functions for cost display (arbitrationCost and appealCost).
 *  -Allow giving rulings. For this a function must call arbitrable.rule(disputeID,ruling).
 */
contract Arbitrator{

    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {
        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {
        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    /** @dev To be raised when a dispute is created.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev To be raised when a dispute can be appealed.
     *  @param _disputeID ID of the dispute.
     */
    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev To be raised when the current ruling is appealed.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev Create a dispute. Must be called by the arbitrable contract.
     *  Must be paid at least arbitrationCost(_extraData).
     *  @param _choices Amount of choices the arbitrator can make in this dispute.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return disputeID ID of the dispute created.
     */
    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}

    /** @dev Compute the cost of arbitration. It is recommended not to increase it often, as it can be highly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function arbitrationCost(bytes _extraData) public view returns(uint fee);

    /** @dev Appeal a ruling. Note that it has to be called before the arbitrator contract calls rule.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give extra info on the appeal.
     */
    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {
        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    /** @dev Compute the cost of appeal. It is recommended not to increase it often, as it can be higly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);

    /** @dev Compute the start and end of the dispute's current or next appeal period, if possible.
     *  @param _disputeID ID of the dispute.
     *  @return The start and end of the period.
     */
    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}

    /** @dev Return the status of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return status The status of the dispute.
     */
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);

    /** @dev Return the current ruling of a dispute. This is useful for parties to know if they should appeal.
     *  @param _disputeID ID of the dispute.
     *  @return ruling The ruling which has been given or the one which will be given if there is no appeal.
     */
    function currentRuling(uint _disputeID) public view returns(uint ruling);
}

/**
 *  @title IArbitrable
 *  @author Enrique Piqueras - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;

/** @title IArbitrable
 *  Arbitrable interface.
 *  When developing arbitrable contracts, we need to:
 *  -Define the action taken when a ruling is received by the contract. We should do so in executeRuling.
 *  -Allow dispute creation. For this a function must:
 *      -Call arbitrator.createDispute.value(_fee)(_choices,_extraData);
 *      -Create the event Dispute(_arbitrator,_disputeID,_rulingOptions);
 */
interface IArbitrable {
    /** @dev To be emmited when meta-evidence is submitted.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     *  @param _evidence A link to the meta-evidence JSON.
     */
    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    /** @dev To be emmited when a dispute is created to link the correct meta-evidence to the disputeID
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     */
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID);

    /** @dev To be raised when evidence are submitted. Should point to the ressource (evidences are not to be stored on chain due to gas considerations).
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _party The address of the party submiting the evidence. Note that 0x0 refers to evidence not submitted by any party.
     *  @param _evidence A URI to the evidence JSON file whose name should be its keccak256 hash followed by .json.
     */
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _disputeID, address indexed _party, string _evidence);

    /** @dev To be raised when a ruling is given.
     *  @param _arbitrator The arbitrator giving the ruling.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling The ruling which was given.
     */
    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) public;
}

/**
 *  @title Arbitrable
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.15;

/** @title Arbitrable
 *  Arbitrable abstract contract.
 *  When developing arbitrable contracts, we need to:
 *  -Define the action taken when a ruling is received by the contract. We should do so in executeRuling.
 *  -Allow dispute creation. For this a function must:
 *      -Call arbitrator.createDispute.value(_fee)(_choices,_extraData);
 *      -Create the event Dispute(_arbitrator,_disputeID,_rulingOptions);
 */
contract Arbitrable is IArbitrable {
    Arbitrator public arbitrator;
    bytes public arbitratorExtraData; // Extra data to require particular dispute and appeal behaviour.

    modifier onlyArbitrator {require(msg.sender == address(arbitrator), "Can only be called by the arbitrator."); _;}

    /** @dev Constructor. Choose the arbitrator.
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _arbitratorExtraData Extra data for the arbitrator.
     */
    constructor(Arbitrator _arbitrator, bytes _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {
        emit Ruling(Arbitrator(msg.sender),_disputeID,_ruling);

        executeRuling(_disputeID,_ruling);
    }


    /** @dev Execute a ruling of a dispute.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function executeRuling(uint _disputeID, uint _ruling) internal;
}

pragma solidity ^0.4.18;

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}
 
 pragma solidity ^0.4.18;

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.2'; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != 0) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer throws
           var previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Clone Token Method
////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}
 
 /**
 *  @title Mini Me Token ERC20
 *  Overwrite the MiniMeToken to make it follow ERC20 recommendation.
 *  This is required because the base token reverts when approve is used with the non zero value while allowed is non zero (which not recommended by the standard, see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md).
 *  @author Clément Lesaege - <[email protected]>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.18;

contract Pinakion is MiniMeToken {

    /** @notice Constructor to create a MiniMeTokenERC20
     *  @param _tokenFactory The address of the MiniMeTokenFactory contract that will
     *   create the Clone token contracts, the token factory needs to be deployed first
     *  @param _parentToken Address of the parent token, set to 0x0 if it is a new token
     *  @param _parentSnapShotBlock Block of the parent token that will determine the
     *   initial distribution of the clone token, set to 0 if it is a new token
     *  @param _tokenName Name of the new token
     *  @param _decimalUnits Number of decimals of the new token
     *  @param _tokenSymbol Token Symbol for the new token
     *  @param _transfersEnabled If true, tokens will be able to be transferred
     */
    constructor(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    )  MiniMeToken(
        _tokenFactory,
        _parentToken,
        _parentSnapShotBlock,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        _transfersEnabled
    ) public {}

    /** @notice `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf.
      * This is a ERC20 compliant version.
      * @param _spender The address of the account able to transfer the tokens
      * @param _amount The amount of tokens to be approved for transfer
      * @return True if the approval was successful
      */
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled, "Transfers are not enabled.");
        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount), "Token controller does not approve.");
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
}

pragma solidity ^0.4.18;

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

pragma solidity ^0.4.24;

/**
 *  @title SortitionSumTreeFactory
 *  @author Enrique Piqueras - <[email protected]>
 *  @dev A factory of trees that keep track of staked values for sortition.
 */
library SortitionSumTreeFactory {
    /* Structs */

    struct SortitionSumTree {
        uint K;
        uint[] stack;
        uint[] nodes;
        // Two-way mapping of IDs to node indexes. Note that node index 0 is reserved for the root node, and means the ID does not have a node.
        mapping(bytes32 => uint) IDsToTreeIndexes;
        mapping(uint => bytes32) nodeIndexesToIDs;
    }

    /* Storage */

    struct SortitionSumTrees {
        mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
    }

    /* Public */

    /**
     *  @dev Create a sortition sum tree at the specified key.
     *  @param _key The key of the new tree.
     *  @param _K The number of children each node in the tree should have.
     */
    function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) public {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.K == 0, "Tree already exists.");
        require(_K > 1, "K must be greater than one.");
        tree.K = _K;
        tree.stack.length = 0;
        tree.nodes.length = 0;
        tree.nodes.push(0);
    }

    /**
     *  @dev Delete a sortition sum tree at the specified key.
     *  @param _key The key of the tree to delete.
     */
    function deleteTree(SortitionSumTrees storage self, bytes32 _key) public {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        tree.K = 0;
        tree.stack.length = 0;
        tree.nodes.length = 0;
        delete self.sortitionSumTrees[_key];
    }

    /**
     *  @dev Append a value to a tree.
     *  @param _key The key of the tree to append to.
     *  @param _value The value to append.
     *  @param _ID The ID of the value.
     *  @return The index of the appended value in the tree.
     */
    function append(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) public returns(uint treeIndex) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        require(tree.IDsToTreeIndexes[_ID] == 0, "ID already has a value in this tree.");
        
        // Add node.
        if (tree.stack.length == 0) { // No vacant spots.
            // Get the index and append the value.
            treeIndex = tree.nodes.length;
            tree.nodes.push(_value);

            // Potentially append a new node and make the parent a sum node.
            if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { // Is first child.
                uint parentIndex = treeIndex / tree.K;
                bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
                uint newIndex = treeIndex + 1;
                tree.nodes.push(tree.nodes[parentIndex]);
                delete tree.nodeIndexesToIDs[parentIndex];
                tree.IDsToTreeIndexes[parentID] = newIndex;
                tree.nodeIndexesToIDs[newIndex] = parentID;
            }
        } else { // Some vacant spot.
            // Pop the stack and append the value.
            treeIndex = tree.stack[tree.stack.length - 1];
            tree.stack.length--;
            tree.nodes[treeIndex] = _value;
        }

        // Add label.
        tree.IDsToTreeIndexes[_ID] = treeIndex;
        tree.nodeIndexesToIDs[treeIndex] = _ID;

        updateParents(self, _key, treeIndex, true, _value);
    }

    /**
     *  @dev Remove a value from a tree.
     *  @param _key The key of the tree to remove from.
     *  @param _ID The ID of the value.
     */
    function remove(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) public {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToTreeIndexes[_ID];
        require(treeIndex != 0, "ID does not have a value in this tree.");

        // Remember value and set to 0.
        uint value = tree.nodes[treeIndex];
        tree.nodes[treeIndex] = 0;

        // Push to stack.
        tree.stack.push(treeIndex);

        // Clear label.
        delete tree.IDsToTreeIndexes[tree.nodeIndexesToIDs[treeIndex]];
        delete tree.nodeIndexesToIDs[treeIndex];

        updateParents(self, _key, treeIndex, false, value);
    }

    /**
     *  @dev Set a value of a tree.
     *  @param _key The key of the tree.
     *  @param _value The new value.
     *  @param _ID The ID of the value.
     */
    function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) public {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToTreeIndexes[_ID];
        require(treeIndex != 0, "ID does not have a value in this tree.");

        bool plusOrMinus = tree.nodes[treeIndex] <= _value;
        uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
        tree.nodes[treeIndex] = _value;

        updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
    }

    /* Public Views */

    /**
     *  @dev Query the leafs of a tree.
     *  @param _key The key of the tree to get the leafs from.
     *  @param _cursor The pagination cursor.
     *  @param _count The number of items to return.
     *  @return The index at which leafs start, the values of the returned leafs, and wether there are more for pagination.
     *  Complexity: This function is O(n) where `n` is the max number of elements ever appended.
     */
    function queryLeafs(SortitionSumTrees storage self, bytes32 _key, uint _cursor, uint _count) public view returns(uint startIndex, uint[] values, bool hasMore) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        // Find the start index.
        for (uint i = 0; i < tree.nodes.length; i++) {
            if ((tree.K * i) + 1 >= tree.nodes.length) {
                startIndex = i;
                break;
            }
        }

        // Get the values.
        uint loopStartIndex = startIndex + _cursor;
        values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
        uint valuesIndex = 0;
        for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
            if (valuesIndex < _count) {
                values[valuesIndex] = tree.nodes[j];
                valuesIndex++;
            } else {
                hasMore = true;
                break;
            }
        }
    }

    /**
     *  @dev Draw an ID from a tree using a number. Note that this function reverts if the sum of all values in the tree is 0.
     *  @param _key The key of the tree.
     *  @param _drawnNumber The drawn number.
     *  @return The drawn ID.
     *  Complexity: This function is O(n) where `n` is the max number of elements ever appended.
     */
    function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) public view returns(bytes32 ID) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = 0;
        uint currentDrawnNumber = _drawnNumber % tree.nodes[0];

        while ((tree.K * treeIndex) + 1 < tree.nodes.length)  // While it still has children.
            for (uint i = 1; i <= tree.K; i++) { // Loop over children.
                uint nodeIndex = (tree.K * treeIndex) + i;
                uint nodeValue = tree.nodes[nodeIndex];

                if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; // Go to the next child.
                else { // Pick this child.
                    treeIndex = nodeIndex;
                    break;
                }
            }
        
        ID = tree.nodeIndexesToIDs[treeIndex];
    }

    /** @dev Gets a specified ID's associated value.
     *  @param _key The key of the tree.
     *  @param _ID The ID of the value.
     *  @return The associated value.
     */
    function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) public view returns(uint value) {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];
        uint treeIndex = tree.IDsToTreeIndexes[_ID];

        if (treeIndex == 0) value = 0;
        else value = tree.nodes[treeIndex];
    }

    /* Private */

    /**
     *  @dev Update all the parents of a node.
     *  @param _key The key of the tree to update.
     *  @param _treeIndex The index of the node to start from.
     *  @param _plusOrMinus Wether to add (true) or substract (false).
     *  @param _value The value to add or substract.
     *  Complexity: This function is O(log(k)(n)) where `n` is the max number of elements ever appended.
     */
    function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {
        SortitionSumTree storage tree = self.sortitionSumTrees[_key];

        uint parentIndex = _treeIndex;
        while (parentIndex != 0) {
            parentIndex = (parentIndex - 1) / tree.K;
            tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
        }
    }
}


/**
 *  @title Random Number Generator usign blockhash
 *  @author Clément Lesaege - <[email protected]>
 *
 *  This contract implements the RNG standard and gives parties incentives to save the blockhash to avoid it to become unreachable after 256 blocks.
 *
 */
pragma solidity ^0.4.15;

/** Simple Random Number Generator returning the blockhash.
 *  Allows saving the random number for use in the future.
 *  It allows the contract to still access the blockhash even after 256 blocks.
 *  The first party to call the save function gets the reward.
 */
contract BlockHashRNG is RNG {

    mapping (uint => uint) public randomNumber; // randomNumber[block] is the random number for this block, 0 otherwise.
    mapping (uint => uint) public reward; // reward[block] is the amount to be paid to the party w.



    /** @dev Contribute to the reward of a random number.
     *  @param _block Block the random number is linked to.
     */
    function contribute(uint _block) public payable { reward[_block] += msg.value; }


    /** @dev Return the random number. If it has not been saved and is still computable compute it.
     *  @param _block Block the random number is linked to.
     *  @return RN Random Number. If the number is not ready or has not been requested 0 instead.
     */
    function getRN(uint _block) public returns (uint RN) {
        RN = randomNumber[_block];
        if (RN == 0){
            saveRN(_block);
            return randomNumber[_block];
        }
        else
            return RN;
    }

    /** @dev Save the random number for this blockhash and give the reward to the caller.
     *  @param _block Block the random number is linked to.
     */
    function saveRN(uint _block) public {
        if (blockhash(_block) != 0x0)
            randomNumber[_block] = uint(blockhash(_block));
        else
            randomNumber[_block] = getFallbackRN(_block);

        if (randomNumber[_block] != 0) { // If the number is set.
            uint rewardToSend = reward[_block];
            reward[_block] = 0;
            msg.sender.send(rewardToSend); // Note that the use of send is on purpose as we don't want to block in case msg.sender has a fallback issue.
        }
    }

    /** @dev Fallback strategy. This class has no fallback. Subclass provides fallback strategy by overriding this method.
     *  @param _block Block the random number is linked to.
     */
    function getFallbackRN(uint _block) internal view returns (uint) {
        return 0x0; 
    }
}


pragma solidity ^0.4.24;

/**
 *  @title KlerosLiquid
 *  @author Enrique Piqueras - <[email protected]>
 *  @dev The main Kleros contract with dispute resolution logic for the Athena release.
 */
contract KlerosLiquid is TokenController, Arbitrator {
    /* Enums */

    // General
    enum Phase {
      staking, // Stake sum trees can be updated. Pass after `minStakingTime` passes and there is at least one dispute without jurors.
      generating, // Waiting on random number. Pass as soon as it is ready.
      drawing // Jurors can be drawn. Pass after all disputes have jurors or `maxDrawingTime` passes.
    }

    // Dispute
    enum Period {
      evidence, // Evidence can be submitted. This is also when drawing has to take place.
      commit, // Jurors commit a hashed vote. This is skipped for courts without hidden votes.
      vote, // Jurors reveal/cast their vote depending on wether the court has hidden votes or not.
      appeal, // The dispute can be appealed.
      execution // Tokens are redistributed and the ruling is executed.
    }

    /* Structs */

    // General
    struct Court {
        uint96 parent; // The parent court.
        uint[] children; // List of child courts.
        bool hiddenVotes; // Wether to use commit and reveal or not.
        uint minStake; // Minimum tokens needed to stake in the court.
        uint alpha; // Basis point of tokens that are lost when incoherent.
        uint jurorFee; // Arbitration fee paid per juror.
        // The appeal after the one that reaches this number of jurors will go to the parent court if any, otherwise, no more appeals are possible.
        uint jurorsForJump;
        uint[4] timesPerPeriod; // The time allotted to each dispute period in the form `timesPerPeriod[period]`.
    }
    struct DelayedSetStake {
        address account; // The address of the juror.
        uint96 subcourtID; // The ID of the subcourt.
        uint128 stake; // The new stake.
    }

    // Dispute
    struct Vote {
        address account; // The address of the juror.
        bytes32 commit; // The commit of the juror. For courts with hidden votes.
        uint choice; // The choice of the juror.
        bool voted; // True if the vote has been cast or revealed, false otherwise.
    }
    struct VoteCounter {
        // The choice with the most votes. Note that in the case of a tie, it is the choice that reached the tied number of votes first.
        uint winningChoice;
        uint[] counts; // The sum of votes for each choice in the form `counts[choice]`.
        bool tied; // True if there is a tie, false otherwise.
    }
    struct Dispute { // Note that appeal `0` is equivalent to the first round of the dispute.
        uint96 subcourtID; // The ID of the subcourt the dispute is in.
        Arbitrable arbitrated; // The arbitrated arbitrable contract.
        // The number of choices jurors have when voting. This does not include choice `0` which is reserved for "refuse to arbitrate"/"no ruling".
        uint numberOfChoices;
        Period period; // The current period of the dispute.
        uint lastPeriodChange; // The last time the period was changed.
        // The votes in the form `votes[appeal][voteID]`. On each round, a new list is pushed and packed with as many empty votes as there are draws. We use `dispute.votes.length` to get the number of appeals.
        Vote[][] votes;
        VoteCounter[] voteCounters; // The vote counters in the form `voteCounters[appeal]`.
        uint[] jurorAtStake; // The amount of tokens at stake for each juror in the form `jurorAtStake[appeal]`.
        uint[] totalJurorFees; // The total juror fees paid in the form `totalJurorFees[appeal]`.
        uint drawsInRound; // A counter of draws made in the current round.
        uint commitsInRound; // A counter of commits made in the current round.
        uint votesInRound; // A counter of votes made in the current round.
        uint[] repartitionsPerRound; // A counter of vote reward repartitions made in each round in the form `repartitionsPerRound[appeal]`.
        uint[] penaltiesPerRound; // The amount of tokens collected from penalties in each round in the form `penaltiesPerRound[appeal]`.
        uint[2][] rewardsPerRound; // The amount of tokens and ETH rewarded in each round in the form `rewardsPerRound[appeal][tokens, ETH]`.
        bool ruled; // True if the ruling has been executed, false otherwise.
    }

    // Juror
    struct Juror {
        uint96[] subcourtIDs; // The IDs of subcourts where the juror has stake path ends.
        uint stakedTokens; // The juror's total amount of tokens staked in subcourts.
        uint lockedTokens; // The juror's total amount of tokens locked in disputes.
    }

    /* Events */

    /** @dev Emitted when we pass to a new phase.
     *  @param _phase The new phase.
     */
    event NewPhase(Phase _phase);

    /** @dev Emitted when a dispute passes to a new period.
     *  @param _disputeID The ID of the dispute.
     *  @param _period The new period.
     */
    event NewPeriod(uint indexed _disputeID, Period _period);

    /** @dev Emitted when a juror's stake is set.
     *  @param _address The address of the juror.
     *  @param _subcourtID The ID of the subcourt at the end of the stake path.
     *  @param _stake The new stake.
     *  @param _newTotalStake The new total stake.
     */
    event StakeSet(address indexed _address, uint _subcourtID, uint128 _stake, uint _newTotalStake);

    /** @dev Emitted when a juror is drawn.
     *  @param _address The drawn address.
     *  @param _disputeID The ID of the dispute.
     *  @param _voteID The vote ID.
     */
    event Draw(address indexed _address, uint indexed _disputeID, uint _voteID);

    /** @dev Emitted when a juror wins or loses tokens and ETH from a dispute.
     *  @param _address The juror affected.
     *  @param _disputeID The ID of the dispute.
     *  @param _tokenAmount The amount of tokens won or lost.
     *  @param _ETHAmount The amount of ETH won or lost.
     */
    event TokenAndETHShift(address indexed _address, uint indexed _disputeID, int _tokenAmount, int _ETHAmount);

    /* Storage */

    // General Constants
    uint public constant NON_PAYABLE_AMOUNT = (2 ** 256 - 2) / 2;
    uint public constant ALPHA_DIVISOR = 1e4;
    uint public constant MAX_STAKE_PATHS = 4;
    // General Contracts
    address public governor;
    Pinakion public pinakion;
    RNG public RNGenerator;
    // General Dynamic
    Phase public phase;
    uint public lastPhaseChange;
    uint public disputesWithoutJurors;
    uint public RNBlock;
    uint public RN;
    uint public minStakingTime;
    uint public maxDrawingTime;
    bool public lockInsolventTransfers = true;
    // General Storage
    Court[] public courts;
    using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees;
    SortitionSumTreeFactory.SortitionSumTrees internal sortitionSumTrees;
    mapping(uint => DelayedSetStake) public delayedSetStakes;
    // The index of the next `delayedSetStakes` item to execute. Starts at 1 because `lastDelayedSetStake` starts at 0.
    uint public nextDelayedSetStake = 1;
    uint public lastDelayedSetStake; // The index of the last `delayedSetStakes` item. 0 is skipped because it is the initial value.

    // Dispute
    Dispute[] public disputes;

    // Juror
    mapping(address => Juror) public jurors;

    /* Modifiers */

    /** @dev Requires a specific phase.
     *  @param _phase The required phase.
     */
    modifier onlyDuringPhase(Phase _phase) {require(phase == _phase, "Incorrect phase."); _;}

    /** @dev Requires a specific period in a dispute.
     *  @param _disputeID The ID of the dispute.
     *  @param _period The required period.
     */
    modifier onlyDuringPeriod(uint _disputeID, Period _period) {require(disputes[_disputeID].period == _period, "Incorrect period."); _;}

    /** @dev Requires that the sender is the governor. */
    modifier onlyByGovernor() {require(governor == msg.sender, "Can only be called by the governor."); _;}

    /* Constructor */

    /** @dev Constructs the KlerosLiquid contract.
     *  @param _governor The governor's address.
     *  @param _pinakion The address of the token contract.
     *  @param _RNGenerator The address of the RNG contract.
     *  @param _minStakingTime The minimum time that the staking phase should last.
     *  @param _maxDrawingTime The maximum time that the drawing phase should last.
     *  @param _hiddenVotes The `hiddenVotes` property value of the general court.
     *  @param _minStake The `minStake` property value of the general court.
     *  @param _alpha The `alpha` property value of the general court.
     *  @param _jurorFee The `jurorFee` property value of the general court.
     *  @param _jurorsForJump The `jurorsForJump` property value of the general court.
     *  @param _timesPerPeriod The `timesPerPeriod` property value of the general court.
     *  @param _sortitionSumTreeK The number of children per node of the general court's sortition sum tree.
     */
    constructor(
        address _governor,
        Pinakion _pinakion,
        RNG _RNGenerator,
        uint _minStakingTime,
        uint _maxDrawingTime,
        bool _hiddenVotes,
        uint _minStake,
        uint _alpha,
        uint _jurorFee,
        uint _jurorsForJump,
        uint[4] _timesPerPeriod,
        uint _sortitionSumTreeK
    ) public {
        // Initialize contract.
        governor = _governor;
        pinakion = _pinakion;
        RNGenerator = _RNGenerator;
        minStakingTime = _minStakingTime;
        maxDrawingTime = _maxDrawingTime;
        lastPhaseChange = now;

        // Create the general court.
        courts.push(Court({
            parent: 0,
            children: new uint[](0),
            hiddenVotes: _hiddenVotes,
            minStake: _minStake,
            alpha: _alpha,
            jurorFee: _jurorFee,
            jurorsForJump: _jurorsForJump,
            timesPerPeriod: _timesPerPeriod
        }));
        sortitionSumTrees.createTree(bytes32(0), _sortitionSumTreeK);
    }

    /* External */

    /** @dev Creates a subcourt under a specified parent court.
     *  @param _parent The `parent` property value of the subcourt.
     *  @param _hiddenVotes The `hiddenVotes` property value of the subcourt.
     *  @param _minStake The `minStake` property value of the subcourt.
     *  @param _alpha The `alpha` property value of the subcourt.
     *  @param _jurorFee The `jurorFee` property value of the subcourt.
     *  @param _jurorsForJump The `jurorsForJump` property value of the subcourt.
     *  @param _timesPerPeriod The `timesPerPeriod` property value of the subcourt.
     *  @param _sortitionSumTreeK The number of children per node of the subcourt's sortition sum tree.
     */
    function createSubcourt(
        uint96 _parent,
        bool _hiddenVotes,
        uint _minStake,
        uint _alpha,
        uint _jurorFee,
        uint _jurorsForJump,
        uint[4] _timesPerPeriod,
        uint _sortitionSumTreeK
    ) external onlyByGovernor {
        require(courts.length < 2 ** 96, "Maximum number of subcourts reached.");
        require(courts[_parent].minStake <= _minStake, "A subcourt cannot be a child of a subcourt with a higher minimum stake.");

        // Create the subcourt.
        uint96 subcourtID = uint96(
            courts.push(Court({
                parent: _parent,
                children: new uint[](0),
                hiddenVotes: _hiddenVotes,
                minStake: _minStake,
                alpha: _alpha,
                jurorFee: _jurorFee,
                jurorsForJump: _jurorsForJump,
                timesPerPeriod: _timesPerPeriod
            })) - 1
        );
        sortitionSumTrees.createTree(bytes32(subcourtID), _sortitionSumTreeK);

        // Update the parent.
        courts[_parent].children.push(subcourtID);
    }

    /** @dev Changes the `hiddenVotes` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _hiddenVotes The new value for the `hiddenVotes` property value.
     */
    function changeSubcourtHiddenVotes(uint96 _subcourtID, bool _hiddenVotes) external onlyByGovernor {
        courts[_subcourtID].hiddenVotes = _hiddenVotes;
    }

    /** @dev Changes the `minStake` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _minStake The new value for the `minStake` property value.
     */
    function changeSubcourtMinStake(uint96 _subcourtID, uint _minStake) external onlyByGovernor {
        courts[_subcourtID].minStake = _minStake;
    }

    /** @dev Changes the `alpha` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _alpha The new value for the `alpha` property value.
     */
    function changeSubcourtAlpha(uint96 _subcourtID, uint _alpha) external onlyByGovernor {
        courts[_subcourtID].alpha = _alpha;
    }

    /** @dev Changes the `jurorFee` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _jurorFee The new value for the `jurorFee` property value.
     */
    function changeSubcourtJurorFee(uint96 _subcourtID, uint _jurorFee) external onlyByGovernor {
        courts[_subcourtID].jurorFee = _jurorFee;
    }

    /** @dev Changes the `jurorsForJump` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _jurorsForJump The new value for the `jurorsForJump` property value.
     */
    function changeSubcourtJurorsForJump(uint96 _subcourtID, uint _jurorsForJump) external onlyByGovernor {
        courts[_subcourtID].jurorsForJump = _jurorsForJump;
    }

    /** @dev Changes the `timesPerPeriod` property value of the specified subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _timesPerPeriod The new value for the `timesPerPeriod` property value.
     */
    function changeSubcourtTimesPerPeriod(uint96 _subcourtID, uint[4] _timesPerPeriod) external onlyByGovernor {
        courts[_subcourtID].timesPerPeriod = _timesPerPeriod;
    }

    /** @dev Passes the phase. TRUSTED */
    function passPhase() external {
        if (phase == Phase.staking) {
            require(now - lastPhaseChange >= minStakingTime, "The minimum staking time has not passed yet.");
            require(disputesWithoutJurors > 0, "There are no disputes that need jurors.");
            RNBlock = block.number + 1;
            RNGenerator.requestRN(RNBlock);
            phase = Phase.generating;
        } else if (phase == Phase.generating) {
            RN = RNGenerator.getUncorrelatedRN(RNBlock);
            require(RN != 0, "Random number is not ready yet.");
            phase = Phase.drawing;
        } else if (phase == Phase.drawing) {
            require(disputesWithoutJurors == 0 || now - lastPhaseChange >= maxDrawingTime, "There are still disputes without jurors and the maximum drawing time has not passed yet.");
            phase = Phase.staking;
        }

        lastPhaseChange = now;
        emit NewPhase(phase);
    }

    /** @dev Passes the period of a specified dispute.
     *  @param _disputeID The ID of the dispute.
     */
    function passPeriod(uint _disputeID) external {
        Dispute storage dispute = disputes[_disputeID];
        if (dispute.period == Period.evidence) {
            require(now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)], "The evidence period time has not passed yet.");
            require(dispute.drawsInRound == dispute.votes[dispute.votes.length - 1].length, "The dispute has not finished drawing yet.");
            dispute.period = courts[dispute.subcourtID].hiddenVotes ? Period.commit : Period.vote;
        } else if (dispute.period == Period.commit) {
            require(
                now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)] || dispute.commitsInRound == dispute.votes[dispute.votes.length - 1].length,
                "The commit period time has not passed yet and not every juror has committed yet."
            );
            dispute.period = Period.vote;
        } else if (dispute.period == Period.vote) {
            require(
                now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)] || dispute.votesInRound == dispute.votes[dispute.votes.length - 1].length,
                "The vote period time has not passed yet and not every juror has voted yet."
            );
            dispute.period = Period.appeal;
        } else if (dispute.period == Period.appeal) {
            require(now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)], "The appeal period time has not passed yet.");
            dispute.period = Period.execution;
        } else if (dispute.period == Period.execution) {
            revert("The dispute is already in the last period.");
        }

        dispute.lastPeriodChange = now;
        emit NewPeriod(_disputeID, dispute.period);
    }

    /** @dev Sets the caller's stake in a subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _stake The new stake.
     */
    function setStake(uint96 _subcourtID, uint128 _stake) external {
        _setStake(msg.sender, _subcourtID, _stake);
    }

    /** @dev Executes the next delayed set stakes.
     *  @param _iterations The number of delayed set stakes to execute.
     */
    function executeDelayedSetStakes(uint _iterations) external onlyDuringPhase(Phase.staking) {
        uint actualIterations = (nextDelayedSetStake + _iterations) - 1 > lastDelayedSetStake ?
            (lastDelayedSetStake - nextDelayedSetStake) + 1 : _iterations;
        uint newNextDelayedSetStake = nextDelayedSetStake + actualIterations;
        for (uint i = nextDelayedSetStake; i < newNextDelayedSetStake; i++) {
            DelayedSetStake storage delayedSetStake = delayedSetStakes[i];
            this.call( // solium-disable-line security/no-low-level-calls
                abi.encodeWithSignature("_setStake(address,uint96,uint128)", delayedSetStake.account, delayedSetStake.subcourtID, delayedSetStake.stake)
            ); // Intentional use to avoid blocking.
            delete delayedSetStakes[i];
        }
        nextDelayedSetStake = newNextDelayedSetStake;
    }

    /** @dev Draws jurors for a dispute. Can be called in parts.
     *  `O(n * k * log_k(j))` where
     *  `n` is the number of iterations to run,
     *  `k` is the number of children per node of the dispute's court's sortition sum tree,
     *  and `j` is the maximum number of jurors that ever staked in it simultaneously.
     *  @param _disputeID The ID of the dispute.
     *  @param _iterations The number of iterations to run.
     */
    function drawJurors(
        uint _disputeID,
        uint _iterations
    ) external onlyDuringPhase(Phase.drawing) onlyDuringPeriod(_disputeID, Period.evidence) {
        Dispute storage dispute = disputes[_disputeID];
        uint endIndex = dispute.drawsInRound + _iterations;

        // Avoid going out of range.
        if (endIndex > dispute.votes[dispute.votes.length - 1].length) endIndex = dispute.votes[dispute.votes.length - 1].length;
        for (uint i = dispute.drawsInRound; i < endIndex; i++) {
            // Draw from sortition tree.
            (
                address drawnAddress,
                uint subcourtID
            ) = stakePathIDToAccountAndSubcourtID(sortitionSumTrees.draw(bytes32(dispute.subcourtID), uint(keccak256(RN, _disputeID, i))));

            // Save the vote.
            dispute.votes[dispute.votes.length - 1][i].account = drawnAddress;
            jurors[msg.sender].lockedTokens += dispute.jurorAtStake[dispute.jurorAtStake.length - 1];
            emit Draw(drawnAddress, _disputeID, i);

            // If dispute is fully drawn.
            if (i == dispute.votes[dispute.votes.length - 1].length - 1) disputesWithoutJurors--;
        }
        dispute.drawsInRound += endIndex - dispute.drawsInRound;
    }

    /** @dev Sets the caller's commits for the specified votes.
     *  `O(n)` where
     *  `n` is the number of commits.
     *  @param _disputeID The ID of the dispute.
     *  @param _voteIDs The IDs of the votes.
     *  @param _commits The commits.
     */
    function commit(uint _disputeID, uint[] _voteIDs, bytes32[] _commits) external onlyDuringPeriod(_disputeID, Period.commit) {
        Dispute storage dispute = disputes[_disputeID];
        for (uint i = 0; i < _voteIDs.length; i++) {
            require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].account == msg.sender, "The caller has to own the vote.");
            require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit == bytes32(0), "Already committed this vote.");
            dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit = _commits[i];
        }
        dispute.commitsInRound += _voteIDs.length;
    }

    /** @dev Sets the caller's choices for the specified votes.
     *  `O(n)` where
     *  `n` is the number of votes.
     *  @param _disputeID The ID of the dispute.
     *  @param _voteIDs The IDs of the votes.
     *  @param _choice The choice.
     *  @param _salts The salts for the commits if the votes were hidden.
     */
    function vote(uint _disputeID, uint[] _voteIDs, uint _choice, uint[] _salts) external onlyDuringPeriod(_disputeID, Period.vote) {
        Dispute storage dispute = disputes[_disputeID];

        // Save the votes.
        for (uint i = 0; i < _voteIDs.length; i++) {
            require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].account == msg.sender, "The caller has to own the vote.");
            require(dispute.numberOfChoices >= _choice, "The choice has to be less than or equal to the number of choices for the dispute.");
            require(
                !courts[dispute.subcourtID].hiddenVotes || dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit == keccak256(_choice, _salts[i]),
                "The commit must match the choice in subcourts with hidden votes."
            );
            require(!dispute.votes[dispute.votes.length - 1][_voteIDs[i]].voted, "Vote already cast.");
            dispute.votes[dispute.votes.length - 1][_voteIDs[i]].choice = _choice;
            dispute.votes[dispute.votes.length - 1][_voteIDs[i]].voted = true;
        }
        dispute.votesInRound += _voteIDs.length;

        // Update winning choice.
        VoteCounter storage voteCounter = dispute.voteCounters[dispute.voteCounters.length - 1];
        voteCounter.counts[_choice] += _voteIDs.length;
        if (_choice == voteCounter.winningChoice) { // Voted for the winning choice.
            if (voteCounter.tied) voteCounter.tied = false; // Potentially broke tie.
        } else { // Voted for another choice.
            if (voteCounter.counts[_choice] == voteCounter.counts[voteCounter.winningChoice]) { // Tie.
                if (!voteCounter.tied) voteCounter.tied = true;
            } else if (voteCounter.counts[_choice] > voteCounter.counts[voteCounter.winningChoice]) { // New winner.
                voteCounter.winningChoice = _choice;
                voteCounter.tied = false;
            }
        }
    }

    /** @dev Computes the token and ETH rewards for a specified appeal in a specified dispute. NOTE: Temporary function until solidity increases local variable allowance.
     *  @param _disputeID The ID of the dispute.
     *  @param _appeal The appeal.
     *  @return The token and ETH rewards.
     */
    function computeTokenAndETHRewards(uint _disputeID, uint _appeal) private view returns(uint tokenReward, uint ETHReward) {
        Dispute storage dispute = disputes[_disputeID];
        uint winningChoice = dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
        uint coherentCount = dispute.voteCounters[_appeal].counts[winningChoice];

        // Distribute penalties and arbitration fees.
        if (dispute.voteCounters[dispute.voteCounters.length - 1].tied) {
            tokenReward = 0; // No penalties to distribute.
            ETHReward = dispute.totalJurorFees[_appeal] / dispute.votes[_appeal].length; // Distribute fees evenly.
        } else {
            // Distribute penalties and fees evenly between coherent jurors.
            tokenReward = dispute.penaltiesPerRound[_appeal] / coherentCount;
            ETHReward = dispute.totalJurorFees[_appeal] / coherentCount;
        }
    }

    /** @dev Repartitions tokens and ETH for a specified appeal in a specified dispute. Can be called in parts.
     *  `O(i + u * n * (n + p * log_k(j)))` where
     *  `i` is the number of iterations to run,
     *  `u` is the number of jurors that need to be unstaked,
     *  `n` is the maximum number of subcourts one of these jurors has staked in,
     *  `p` is the depth of the subcourt tree,
     *  `k` is the minimum number of children per node of one of these subcourts' sortition sum tree,
     *  and `j` is the maximum number of jurors that ever staked in one of these subcourts simultaneously.
     *  @param _disputeID The ID of the dispute.
     *  @param _appeal The appeal.
     *  @param _iterations The number of iterations to run.
     */
    function execute(uint _disputeID, uint _appeal, uint _iterations) external onlyDuringPeriod(_disputeID, Period.execution) {
        lockInsolventTransfers = false;
        Dispute storage dispute = disputes[_disputeID];
        uint end = dispute.repartitionsPerRound[_appeal] + _iterations;
        uint penaltiesInRoundCache = dispute.penaltiesPerRound[_appeal]; // For saving gas.

        // Avoid going out of range.
        if (
            !dispute.voteCounters[dispute.voteCounters.length - 1].tied &&
            dispute.voteCounters[_appeal].counts[dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice] == 0
        ) {
            // We loop over the votes once as there are no rewards because it is not a tie and no one in this round is coherent with the final outcome.
            if (end > dispute.votes[_appeal].length) end = dispute.votes[_appeal].length;
        } else {
            // We loop over the votes twice, first to collect penalties, and second to distribute them as rewards along with arbitration fees.
            (uint tokenReward, uint ETHReward) = dispute.repartitionsPerRound[_appeal] >= dispute.votes[_appeal].length ? computeTokenAndETHRewards(_disputeID, _appeal) : (0, 0);
            if (end > dispute.votes[_appeal].length * 2) end = dispute.votes[_appeal].length * 2;
        }
        for (uint i = dispute.repartitionsPerRound[_appeal]; i < end; i++) {
            Vote storage vote = dispute.votes[_appeal][i % dispute.votes[_appeal].length];
            if (
                vote.choice == dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice ||
                dispute.voteCounters[dispute.voteCounters.length - 1].tied
            ) { // Winning vote or it's a tie.
                if (i >= dispute.votes[_appeal].length) { // Only execute in the second half of the iterations.

                    // Reward.
                    pinakion.transfer(vote.account, tokenReward);
                    // Intentional use to avoid blocking.
                    vote.account.send(ETHReward); // solium-disable-line security/no-send
                    emit TokenAndETHShift(vote.account, _disputeID, int(tokenReward), int(ETHReward));
                    jurors[vote.account].lockedTokens -= dispute.jurorAtStake[_appeal];
                }
            } else { // Losing vote and it's not a tie.
                if (i < dispute.votes[_appeal].length) { // Only execute in the first half of the iterations.

                    // Penalize.
                    uint penalty = dispute.jurorAtStake[_appeal] > pinakion.balanceOf(vote.account) ? pinakion.balanceOf(vote.account) : dispute.jurorAtStake[_appeal];
                    pinakion.transferFrom(vote.account, this, penalty);
                    emit TokenAndETHShift(vote.account, _disputeID, -int(penalty), 0);
                    penaltiesInRoundCache += penalty;
                    jurors[vote.account].lockedTokens -= dispute.jurorAtStake[_appeal];

                    // Unstake juror if his penalty made balance less than his total stake or if he lost due to inactivity.
                    if (pinakion.balanceOf(vote.account) < jurors[vote.account].stakedTokens || !vote.voted)
                        for (uint j = 0; j < jurors[vote.account].subcourtIDs.length; j++)
                            this.call( // solium-disable-line security/no-low-level-calls
                                abi.encodeWithSignature("_setStake(address,uint96,uint128)", vote.account, jurors[vote.account].subcourtIDs[j], 0)
                            ); // Intentional use to avoid blocking.

                }
            }
            if (i == dispute.votes[_appeal].length - 1) {
                // Send fees to the governor if it is not a tie and no one in this round is coherent with the final outcome.
                if (!dispute.voteCounters[dispute.voteCounters.length - 1].tied && dispute.voteCounters[_appeal].counts[dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice] == 0)
                    // Intentional use to avoid blocking.
                    governor.send(dispute.totalJurorFees[_appeal]); // solium-disable-line security/no-send
                else {
                    dispute.penaltiesPerRound[_appeal] = penaltiesInRoundCache;
                    (tokenReward, ETHReward) = computeTokenAndETHRewards(_disputeID, _appeal);
                }
            }
        }
        if (dispute.penaltiesPerRound[_appeal] != penaltiesInRoundCache) dispute.penaltiesPerRound[_appeal] = penaltiesInRoundCache;
        dispute.repartitionsPerRound[_appeal] += end - dispute.repartitionsPerRound[_appeal];
        lockInsolventTransfers = true;
    }

    /** @dev Executes a specified dispute's ruling. UNTRUSTED.
     *  @param _disputeID The ID of the dispute.
     */
    function executeRuling(uint _disputeID) external onlyDuringPeriod(_disputeID, Period.execution) {
        Dispute storage dispute = disputes[_disputeID];
        require(!dispute.ruled, "Ruling already executed.");
        dispute.ruled = true;
        uint winningChoice = dispute.voteCounters[dispute.voteCounters.length - 1].tied ? 0
            : dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
        dispute.arbitrated.rule(_disputeID, winningChoice);
    }

    /* External Views */

    /** @dev Gets a specified subcourt's non primitive properties.
     *  @param _subcourtID The ID of the subcourt.
     *  @return The subcourt's non primitive properties.
     */
    function getSubcourt(uint96 _subcourtID) external view returns(
        uint[] children,
        uint[4] timesPerPeriod
    ) {
        Court storage subcourt = courts[_subcourtID];
        children = subcourt.children;
        timesPerPeriod = subcourt.timesPerPeriod;
    }

    /** @dev Gets a specified vote for a specified appeal in a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @param _appeal The appeal.
     *  @param _voteID The ID of the vote.
     *  @return The vote.
     */
    function getVote(uint _disputeID, uint _appeal, uint _voteID) external view returns(
        address account,
        bytes32 commit,
        uint choice,
        bool voted
    ) {
        Vote storage vote = disputes[_disputeID].votes[_appeal][_voteID];
        account = vote.account;
        commit = vote.commit;
        choice = vote.choice;
        voted = vote.voted;
    }

    /** @dev Gets the vote counter for a specified appeal in a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @param _appeal The appeal.
     *  @return The vote counter.
     */
    function getVoteCounter(uint _disputeID, uint _appeal) external view returns(
        uint winningChoice,
        uint[] counts,
        bool tied
    ) {
        VoteCounter storage voteCounter = disputes[_disputeID].voteCounters[_appeal];
        winningChoice = voteCounter.winningChoice;
        counts = voteCounter.counts;
        tied = voteCounter.tied;
    }

    /** @dev Gets a specified dispute's non primitive properties.
     *  @param _disputeID The ID of the dispute.
     *  @return The dispute's non primitive properties.
     */
    function getDispute(uint _disputeID) external view returns(
        uint[] jurorAtStake,
        uint[] totalJurorFees,
        uint[] repartitionsPerRound,
        uint[] penaltiesPerRound,
        uint[] tokenRewardPerRound,
        uint[] ETHRewardPerRound
    ) {
        Dispute storage dispute = disputes[_disputeID];
        jurorAtStake = dispute.jurorAtStake;
        totalJurorFees = dispute.totalJurorFees;
        repartitionsPerRound = dispute.repartitionsPerRound;
        penaltiesPerRound = dispute.penaltiesPerRound;
        for (uint i = 0; i < dispute.rewardsPerRound.length; i++) {
            tokenRewardPerRound[i] = dispute.rewardsPerRound[i][0];
            ETHRewardPerRound[i] = dispute.rewardsPerRound[i][1];
        }
    }

    /** @dev Gets a specified juror's non primitive properties.
     *  @param _account The address of the juror.
     *  @return The juror's non primitive properties.
     */
    function getJuror(address _account) external view returns(
        uint96[] subcourtIDs
    ) {
        Juror storage juror = jurors[_account];
        subcourtIDs = juror.subcourtIDs;
    }

    /** @dev Gets the stake of a specified juror in a specified subcourt.
     *  @param _account The address of the juror.
     *  @param _subcourtID The ID of the subcourt.
     *  @return The stake.
     */
    function stakeOf(address _account, uint96 _subcourtID) external view returns(uint stake) {
        return sortitionSumTrees.stakeOf(bytes32(_subcourtID), accountAndSubcourtIDToStakePathID(_account, _subcourtID));
    }

    /* Public */

    /** @dev Creates a dispute. Must be called by the arbitrable contract.
     *  @param _numberOfChoices Number of choices to choose from in the dispute to be created.
     *  @param _extraData Additional info about the dispute to be created. We use it to pass the ID of the subcourt to create the dispute in (first 32 bytes) and the minimum number of jurors required (next 32 bytes).
     *  @return The ID of the created dispute.
     */
    function createDispute(
        uint _numberOfChoices,
        bytes _extraData
    ) public payable requireArbitrationFee(_extraData) returns(uint disputeID)  {
        (uint96 subcourtID, uint minJurors) = extraDataToSubcourtIDAndMinJurors(_extraData);
        disputeID = disputes.length++;
        Dispute storage dispute = disputes[disputeID];
        dispute.subcourtID = subcourtID;
        dispute.arbitrated = Arbitrable(msg.sender);
        dispute.numberOfChoices = _numberOfChoices;
        dispute.period = Period.evidence;
        dispute.lastPeriodChange = now;
        // As many votes that can be afforded by the provided funds.
        dispute.votes[dispute.votes.length++].length = msg.value / courts[dispute.subcourtID].jurorFee;
        // Add one for choice "0", "refuse to arbitrate"/"no ruling".
        dispute.voteCounters[dispute.voteCounters.length++].counts.length = dispute.numberOfChoices + 1;
        dispute.voteCounters[dispute.voteCounters.length - 1].tied = true;
        dispute.jurorAtStake.push((courts[dispute.subcourtID].minStake * courts[dispute.subcourtID].alpha) / ALPHA_DIVISOR);
        dispute.totalJurorFees.push(msg.value);
        dispute.repartitionsPerRound.push(0);
        dispute.penaltiesPerRound.push(0);
        dispute.rewardsPerRound.length++;
        disputesWithoutJurors++;

        emit DisputeCreation(disputeID, Arbitrable(msg.sender));
    }

    /** @dev Appeals the ruling of a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @param _extraData Additional info about the appeal. Not used by this contract.
     */
    function appeal(
        uint _disputeID,
        bytes _extraData
    ) public payable requireAppealFee(_disputeID, _extraData) onlyDuringPeriod(_disputeID, Period.appeal) {
        Dispute storage dispute = disputes[_disputeID];
        require(
            msg.sender == governor || msg.sender == address(dispute.arbitrated),
            "Can only be called by the governor or the arbitrable contract."
        );
        if (dispute.votes[dispute.votes.length - 1].length >= courts[dispute.subcourtID].jurorsForJump) // Jump to parent subcourt.
            dispute.subcourtID = courts[dispute.subcourtID].parent;
        dispute.period = Period.evidence;
        dispute.lastPeriodChange = now;
        // As many votes that can be afforded by the provided funds.
        dispute.votes[dispute.votes.length++].length = msg.value / courts[dispute.subcourtID].jurorFee;
        // Add one for choice "0", "refuse to arbitrate"/"no ruling".
        dispute.voteCounters[dispute.voteCounters.length++].counts.length = dispute.numberOfChoices + 1;
        dispute.voteCounters[dispute.voteCounters.length - 1].tied = true;
        dispute.jurorAtStake.push((courts[dispute.subcourtID].minStake * courts[dispute.subcourtID].alpha) / ALPHA_DIVISOR);
        dispute.totalJurorFees.push(msg.value);
        dispute.drawsInRound = 0;
        dispute.commitsInRound = 0;
        dispute.votesInRound = 0;
        dispute.repartitionsPerRound.push(0);
        dispute.penaltiesPerRound.push(0);
        dispute.rewardsPerRound.length++;
        disputesWithoutJurors++;

        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    /** @dev Called when `_owner` sends ether to the MiniMe Token contract.
     *  @param _owner The address that sent the ether to create tokens.
     *  @return Wether the operation should be allowed or not.
     */
    function proxyPayment(address _owner) public payable returns(bool allowed) { allowed = false; }

    /** @dev Notifies the controller about a token transfer allowing the controller to react if desired.
     *  @param _from The origin of the transfer.
     *  @param _to The destination of the transfer.
     *  @param _amount The amount of the transfer.
     *  @return Wether the operation should be allowed or not.
     */
    function onTransfer(address _from, address _to, uint _amount) public returns(bool allowed) {
        if (lockInsolventTransfers) { // Never block penalties or rewards.
            uint newBalance = pinakion.balanceOf(_from) - _amount;
            if (newBalance < jurors[_from].stakedTokens || newBalance < jurors[_from].lockedTokens) return false;
        }
        allowed = true;
    }

    /** @dev Notifies the controller about an approval allowing the controller to react if desired.
     *  @param _owner The address that calls `approve()`.
     *  @param _spender The spender in the `approve()` call.
     *  @param _amount The amount in the `approve()` call.
     *  @return Wether the operation should be allowed or not.
     */
    function onApprove(address _owner, address _spender, uint _amount) public returns(bool allowed) { allowed = true; }

    /* Public Views */

    /** @dev Gets the cost of arbitration in a specified subcourt.
     *  @param _extraData Additional info about the dispute. We use it to pass the ID of the subcourt to create the dispute in (first 32 bytes) and the minimum number of jurors required (next 32 bytes).
     *  @return The cost.
     */
    function arbitrationCost(bytes _extraData) public view returns(uint cost) {
        (uint96 subcourtID, uint minJurors) = extraDataToSubcourtIDAndMinJurors(_extraData);
        cost = courts[subcourtID].jurorFee * minJurors;
    }

    /** @dev Gets the cost of appealing a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @param _extraData Additional info about the appeal. Not used by this contract.
     *  @return The cost.
     */
    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint cost) {
        Dispute storage dispute = disputes[_disputeID];
        uint lastNumberOfJurors = dispute.votes[dispute.votes.length - 1].length;
        if (lastNumberOfJurors >= courts[dispute.subcourtID].jurorsForJump) { // Jump to parent subcourt.
            if (dispute.subcourtID == 0) // Already in the general court.
                cost = NON_PAYABLE_AMOUNT;
            else // Get the cost of the parent subcourt.
                cost = courts[courts[dispute.subcourtID].parent].jurorFee * ((lastNumberOfJurors * 2) + 1);
        } else // Stay in current subcourt.
            cost = courts[dispute.subcourtID].jurorFee * ((lastNumberOfJurors * 2) + 1);
    }

    /** @dev Gets the start and end of a specified dispute's current appeal period.
     *  @param _disputeID The ID of the dispute.
     *  @return The start and end of the appeal period.
     */
    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {
        Dispute storage dispute = disputes[_disputeID];
        if (dispute.period == Period.appeal) {
            start = dispute.lastPeriodChange;
            end = dispute.lastPeriodChange + courts[dispute.subcourtID].timesPerPeriod[uint(Period.appeal)];
        } else {
            start = 0;
            end = 0;
        }
    }

    /** @dev Gets the status of a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @return The status.
     */
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status) {
        Dispute storage dispute = disputes[_disputeID];
        if (dispute.period < Period.appeal) status = DisputeStatus.Waiting;
        else if (dispute.period < Period.execution) status = DisputeStatus.Appealable;
        else status = DisputeStatus.Solved;
    }

    /** @dev Gets the current ruling of a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @return The current ruling.
     */
    function currentRuling(uint _disputeID) public view returns(uint ruling) {
        Dispute storage dispute = disputes[_disputeID];
        ruling = dispute.voteCounters[dispute.voteCounters.length - 1].tied ? 0
            : dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
    }

    /* Internal */

    /** @dev Sets the the specified juror's stake in a subcourt.
     *  `O(n + p * log_k(j))` where
     *  `n` is the number of subcourts the juror has staked in,
     *  `p` is the depth of the subcourt tree,
     *  `k` is the minimum number of children per node of one of these subcourts' sortition sum tree,
     *  and `j` is the maximum number of jurors that ever staked in one of these subcourts simultaneously.
     *  @param _account The address of the juror.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _stake The new stake.
     */
    function _setStake(address _account, uint96 _subcourtID, uint128 _stake) public {
        require(msg.sender == _account || msg.sender == address(this), "Can only be called by a juror setting his own stake or internally.");
        // Delayed action logic.
        if (phase != Phase.staking) {
            delayedSetStakes[++lastDelayedSetStake] = DelayedSetStake({ account: _account, subcourtID: _subcourtID, stake: _stake });
            return;
        }

        require(
            _stake == 0 || courts[_subcourtID].minStake <= _stake,
            "The juror's stake cannot be lower than the minimum stake for the subcourt."
        );
        Juror storage juror = jurors[_account];
        bytes32 stakePathID = accountAndSubcourtIDToStakePathID(_account, _subcourtID);
        uint currentStake = sortitionSumTrees.stakeOf(bytes32(_subcourtID), stakePathID);
        require(_stake == 0 || currentStake > 0 || juror.subcourtIDs.length < MAX_STAKE_PATHS, "Maximum stake paths reached.");
        uint newTotalStake = juror.stakedTokens - currentStake + _stake; // Can't overflow because _stake is a uint128.
        require(
            _stake == 0 || pinakion.balanceOf(_account) >= newTotalStake,
            "The juror's total amount of staked tokens cannot be higher than the juror's balance."
        );

        // Update juror's records.
        juror.stakedTokens = newTotalStake;
        if (_stake == 0) {
            for (uint i = 0; i < juror.subcourtIDs.length; i++)
                if (juror.subcourtIDs[i] == _subcourtID) {
                    juror.subcourtIDs[i] = juror.subcourtIDs[juror.subcourtIDs.length - 1];
                    juror.subcourtIDs.length--;
                    break;
                }
        } else if (currentStake == 0) juror.subcourtIDs.push(_subcourtID);

        // Update subcourt parents.
        bool finished = false;
        uint currentSubcourtID = _subcourtID;
        while (!finished) {
            uint currentSubcourtStake = sortitionSumTrees.stakeOf(bytes32(currentSubcourtID), stakePathID);
            if (currentSubcourtStake == 0) sortitionSumTrees.append(bytes32(currentSubcourtID), _stake, stakePathID);
            else sortitionSumTrees.set(
                bytes32(currentSubcourtID),
                _stake,
                stakePathID
            );
            if (currentSubcourtID == 0) finished = true;
            else currentSubcourtID = courts[currentSubcourtID].parent;
        }
        emit StakeSet(_account, _subcourtID, _stake, newTotalStake);
    }

    /** @dev Gets a subcourt ID and the minimum number of jurors required from the specified extra data bytes array.
     *  @param _extraData The extra data.
     *  @return The subcourt ID and the minimum number of jurors required.
     */
    function extraDataToSubcourtIDAndMinJurors(bytes _extraData) internal view returns (uint96 subcourtID, uint minJurors) {
        if (_extraData.length >= 64) {
            assembly { // solium-disable-line security/no-inline-assembly
                subcourtID := mload(add(_extraData, 0x20))
                minJurors := mload(add(_extraData, 0x40))
            }
            if (subcourtID >= courts.length) subcourtID = 0;
            if (minJurors == 0) minJurors = 1;
        } else {
            subcourtID = 0;
            minJurors = 1;
        }
    }

    /** @dev Packs an account and a subcourt ID into a stake path ID.
     *  @param _account The account to pack.
     *  @param _subcourtID The subcourt ID to pack.
     *  @return The stake path ID.
     */
    function accountAndSubcourtIDToStakePathID(address _account, uint96 _subcourtID) internal pure returns (bytes32 stakePathID) {
        assembly { // solium-disable-line security/no-inline-assembly
            let ptr := mload(0x40)
            for { let i := 0x00 } lt(i, 0x14) { i := add(i, 0x01) } {
                mstore8(add(ptr, i), byte(add(0x0c, i), _account))
            }
            for { let i := 0x14 } lt(i, 0x20) { i := add(i, 0x01) } {
                mstore8(add(ptr, i), byte(i, _subcourtID))
            }
            stakePathID := mload(ptr)
        }
    }
    
    /** @dev Unpacks a stake path ID into an account and a subcourt ID.
     *  @param _stakePathID The stake path ID to unpack.
     *  @return The account and subcourt ID.
     */
    function stakePathIDToAccountAndSubcourtID(bytes32 _stakePathID) internal pure returns (address account, uint96 subcourtID) {
        assembly { // solium-disable-line security/no-inline-assembly
            let ptr := mload(0x40)
            for { let i := 0x00 } lt(i, 0x14) { i := add(i, 0x01) } {
                mstore8(add(add(ptr, 0x0c), i), byte(i, _stakePathID))
            }
            account := mload(ptr)
            subcourtID := _stakePathID
        }
    }
}
