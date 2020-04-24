pragma solidity ^0.5.0;

import "ERC20.sol";
import "SafeMath.sol";

contract GlosferLockPrice {
    using SafeMath for uint;

    // Contract admin
    address public admin;
    // Track locked tokens
    uint public lockedAmount;
    // Total amount of tokens on initial phase
    uint private totalPhaseAmount;
    // Amounts to be released
    uint private toRelease;
    // Token contract address
    address public tokenContract;
    // Percentage of released tokens from Total/current balance
    uint private releasePercentage;    
    // Blank address
    address constant ETHER = address(0); 

    // Phase counter
    uint public numPhases;

    // Model a Phase
    struct Phase {
        uint timestamp;
        uint lockedAmount;
        address releaseAddress;
        mapping (uint => Price) prices;
        mapping (uint => PricePercentage) ppercts;
    }
    
    // Model a price
    struct Price {
        uint price1;
        uint price2;
        uint price3;
        uint price4;
        uint price5;
        uint price6;
        uint price7;
        uint price8;
        uint price9;
        uint price10;
        uint releaseTimeIf;
    }
    
    // Model percentage of Price
    struct PricePercentage {
        uint percentage1;
        uint percentage2;
        uint percentage3;
        uint percentage4;
        uint percentage5;
        uint percentage6;
        uint percentage7;
        uint percentage8;
        uint percentage9;
        uint percentage10;
    }    

    // Track phases
    mapping(uint => Phase) public phases;
    // Track released amount per phase
    mapping(uint => uint256) public released;

    ERC20 public ERC20Interface;

    // *** Events *** //
    
    // Release event records the following:
    // 1. Token address
    // 2. Address of sender (this contract)
    // 3. Reciever account tokens are sent to
    // 4. Amount transferred
    // 5. Current (total) Balance of this contract
    event Release(address token, address from, address reciever, uint amount, uint balance);
    
    // Withdraw event records the following:
    // 1. Token address
    // 2. Address of sender
    // 3. Reciever account tokens are sent to
    // 4. Amount transferred
    event Withdraw(address token, address fundsaccount, address reciever, uint amount);

    constructor(address _token, address _admin) public {
        // Check if that's not 0 address
        require(_token != ETHER);
        // Set token contract address
        tokenContract = _token;
        // Set admin
        admin = _admin;
    }

    modifier onlyOwner {
        require(msg.sender == admin);
        _;                            
    }
    
    // ################################################################## //

    // **** Withdraw Tokens **** //
    function withdrawToken(address _to, uint256 _amount) public onlyOwner {
        // Read Token Contract
        ERC20Interface = ERC20(tokenContract);
        
        // Check if this contract has enough tokens to widthraw 
        require(ERC20Interface.balanceOf(address(this)) >= _amount);

        // Transfer tokens to recipient
        require(ERC20Interface.transfer(_to, _amount));
        
        // Emit withdraw event
        emit Withdraw(tokenContract, address(this), _to, _amount);
    }

    // ################################################################## //
    
    // Initialisation | Only admin can call
    
    // **** Generate a Phase **** //
    // Function creates a record which contains the following:
    // 1. Timestamp of Phase creation
    // 2. Locked amount
    function generatePhase (uint _amount, address _releaseAddress) public onlyOwner returns(uint res) {
        // Require valid amount
        require(_amount > 0);        

        // Read tokenContract
        ERC20Interface = ERC20(tokenContract);
        
        // Check if contract address owns that amount of Tokens
        require(ERC20Interface.balanceOf(address(this)) >= _amount);
        
        // Check if those are new transferred to this contract and they aren't locked already.
        // Don't allow more than this contract owns
        require(ERC20Interface.balanceOf(address(this)).sub(_amount) >= lockedAmount);
        
        numPhases ++;
        phases[numPhases] = Phase(now, _amount, _releaseAddress);
        
        // Track total locked amount
        lockedAmount = lockedAmount.add(_amount);

        return numPhases;        
    }
    
    // Initialise Prices for generated Phase
    function initializePrice (uint _phaseid, uint _price1, uint _price2, uint _price3, uint _price4, uint _price5, uint _price6, uint _price7, uint _price8, uint _price9, uint _price10, uint _releaseTimeIf) public onlyOwner {
        // Require passing phaseID
        require(_phaseid > 0);
        Phase storage p = phases[_phaseid];
        // Update Phase with prices and Future releaseTime
        p.prices[0] = Price(_price1, _price2, _price3, _price4,_price5, _price6, _price7, _price8, _price9, _price10, _releaseTimeIf);
    }

    // Initialise Price percentage for generated Phase
    function initPricePercentage (uint _phaseid, uint _per1, uint _per2, uint _per3, uint _per4, uint _per5, uint _per6, uint _per7, uint _per8, uint _per9, uint _per10) public onlyOwner {
        // Require passing phaseID
        require(_phaseid > 0);
        Phase storage p = phases[_phaseid];
        // Update Phase with percentages
        p.ppercts[0] = PricePercentage(_per1, _per2, _per3, _per4, _per5, _per6, _per7, _per8, _per9, _per10);
    }    
    
    // ################################################################## //

    // Entry point function to interact with contract for releasing tokens per Phase
    function releaseTokens (uint _phaseid, uint _price) public onlyOwner {
        // Require passing phaseID
        require(_phaseid > 0);
        // Require valid price
        require(_price > 0);        
        // Check balance of locked tokens
        require(lockedAmount > 0);
        
        // Retirieve the state of phase
        Phase storage p = phases[_phaseid];
        // Get initial amount locked for this (_phaseid) phase
        totalPhaseAmount = p.lockedAmount;
        // Require already released funds per phase to be less than total amount locked for this phase
        require(released[_phaseid] < totalPhaseAmount); 
        // If current time is greater than threshold time decleared on phase initialization -> release everything
        if (now > p.prices[0].releaseTimeIf) {
            releasePercentage = 100;
            release(_phaseid, totalPhaseAmount, releasePercentage);
        } else {
            // Get percentage for each price. If once released set percentage to 0 to avoid release second times
            if (_price > p.prices[0].price1) {
                releasePercentage = p.ppercts[0].percentage1;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage1 = 0;
                }
            }
            if (_price > p.prices[0].price2) {
                releasePercentage = p.ppercts[0].percentage2;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage2 = 0;
                }
            }
            if (_price > p.prices[0].price3) {
                releasePercentage = p.ppercts[0].percentage3;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage3 = 0;
                }
            }
            if (_price > p.prices[0].price4) {
                releasePercentage = p.ppercts[0].percentage4;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage4 = 0;
                }
            }
            if (_price > p.prices[0].price5) {
                releasePercentage = p.ppercts[0].percentage5;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage5 = 0;
                }
            }
            if (_price > p.prices[0].price6) {
                releasePercentage = p.ppercts[0].percentage6;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage6 = 0;
                }
            }
            if (_price > p.prices[0].price7) {
                releasePercentage = p.ppercts[0].percentage7;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage7 = 0;
                }
            }
            if (_price > p.prices[0].price8) {
                releasePercentage = p.ppercts[0].percentage8;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage8 = 0;
                }
            }
            if (_price > p.prices[0].price9) {
                releasePercentage = p.ppercts[0].percentage9;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage9 = 0;
                }
            }
            if (_price > p.prices[0].price10) {
                releasePercentage = p.ppercts[0].percentage10;
                // Call Release function
                if (releasePercentage > 0) {
                    release(_phaseid, totalPhaseAmount, releasePercentage);
                    p.ppercts[0].percentage10 = 0;
                }
            }
        }     
    }
    
    // Release function transfers tokens
    function release(uint _phaseid, uint _totalAmount, uint _releasePercentage) internal {
        if (_releasePercentage == 100) 
            // If none of the decleared price came, than release all amount for this phase
            // Avoid releasing more than it was initial amount by tracking already released amount
            if (released[_phaseid] == 0)
                // If none was released than it is a first call. Release initial amount
                toRelease = _totalAmount;
            else
                // If already released some tokens, calculate amount to release for this account
                // Initial amount minus released amount 
                toRelease = _totalAmount.sub(released[_phaseid]);
        else
            toRelease = _totalAmount * _releasePercentage / 100;    
        
        // Current balance of this contract should be greater that intended release amount
        require(lockedAmount >= toRelease);

        // Retirieve the state of phase
        Phase storage p = phases[_phaseid];        

        // Transfer tokens to release account
        ERC20Interface = ERC20(tokenContract);
        require(ERC20Interface.transfer(p.releaseAddress, toRelease));
        
        // Update total locked amount
        lockedAmount = lockedAmount.sub(toRelease);
        // Update released amount
        released[_phaseid] = released[_phaseid].add(toRelease);
        // Emit withdraw event
        emit Release(tokenContract, address(this), p.releaseAddress, toRelease, lockedAmount);
    }
}
