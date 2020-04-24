/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223Interface {
    uint public totalSupply;

    function balanceOf(address who) public view returns (uint);

    function transfer(address to, uint value) public;

    function transfer(address to, uint value, bytes memory data) public;

    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

contract BankRollerInterface {
    uint public softCapDeposit;
    uint public hardCapDeposit;
    uint public totalDeposit;
    uint public minCapIndividualDeposit;
    uint public houseEdgePermille;
    uint public houseEdgeMinimumAmount;
    uint public bankRollerRewardPermille;
    uint public founderRewardPermille;
    uint public donationPermille;

    function assignAffiliate(address from, address affWallet) public;

    function balance() public view returns (uint256);

    function transferToken(address beneficiary, uint amount) public;

    function bankRollerBalance(address bankRoller) public view returns (uint256);

    function bankRollerWithdraw(uint8 withdrawPercent) public;

    function sendFunds(address beneficiary, uint amount, uint successLogAmount, uint houseEdge) public;

    event BankRollerTopUp(address indexed from, uint256 value);
    event BankRollerWithdraw(address indexed from, uint8 withdrawPercent, uint256 value);
}

// * https://mcashdice.com/ - fair games that pay Midas Cash (the first Tomochain's TRC-20 tokens) - 100% decentralized
//
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.
//
// * Refer to https://github.com/tomodice/contracts/whitepaper.pdf for detailed description and proofs.
contract TomoTRC20Dice {
    /// *** Constants section

    // Bets lower than this amount do not participate in jackpot rolls (and are not deducted jackpotFee).
    uint public minJackpotBet;
    uint public jackpotFee;

    // There is minimum and maximum bets.
    uint public minBet;
    uint public maxBet;

    // Max bet profit. Used to cap bets against dynamic odds.
    uint public maxProfit;

    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
    uint constant JACKPOT_MODULO = 1000;

    // Modulo is a number of equiprobable outcomes in a game:
    //  - 2 for coin flip
    //  - 6 for dice
    //  - 6*6 = 36 for double dice
    //  - 37 for roulette
    //  - 4, 13, 26, 52 for poker
    //  - 100 for tomorain
    //  - 200 for tomoroll
    //  - 1000 for tomolotto
    //  etc.
    // It's called so because 256-bit entropy is treated like a huge integer and
    // the remainder of its division by modulo is considered bet outcome.
    uint constant MAX_MODULO = 65535;

    uint24 constant TOMOROLL_MODULO = 200;
    uint24 constant TOMOLOTTO_4D_MODULO = 10000;
    uint24 constant BACCARAT_MODULO = 0x49a6b9; // 13^6 = 4826809

    // For modulos below this threshold rolls are checked against a bit mask,
    // thus allowing betting on any combination of outcomes. For example, given
    // modulo 6 for dice, 101000 mask (base-2, big endian) means betting on
    // 4 and 6; for games with modulos higher than threshold (Tomoroll), a simple
    // limit is used, allowing betting on any outcome in [0, N) range.
    //
    // The specific value is dictated by the fact that 256-bit intermediate
    // multiplication result allows implementing population count efficiently
    // for numbers that are up to 42 bits, and 40 is the highest multiple of
    // eight below 42.
    uint256 constant MASK_MODULO_40 = 40;

    // This is a check on bet mask overflow.
    uint256 constant MAX_BET_MASK_SMALL_MODULO = 2 ** MASK_MODULO_40;

    // bigger modulo, shift multiple times and count.
    uint256 constant MAX_MASK_BIG_MODULO = 249;
    uint256 constant MAX_BET_MASK_BIG_MODULO = 2 ** MAX_MASK_BIG_MODULO;

    // EVM BLOCKHASH opcode can query no further than 256 blocks into the
    // past. Given that settleBet uses block hash of placeBet as one of
    // complementary entropy sources, we cannot process bets older than this
    // threshold. On rare occasions tomodice's croupier may fail to invoke
    // settleBet in this timespan due to technical issues or extreme Tomochain
    // congestion; such bets can be refunded via invoking refundBet.
    uint constant BET_EXPIRATION_BLOCKS = 250;

    // Some deliberately invalid address to initialize the secret signer with.
    // Forces maintainers to invoke setSecretSigner before processing any bets.
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Standard contract ownership transfer.
    address payable public owner;
    address payable private nextOwner;

    // The address of trc20 token supported for this game.
    address public trc20Token;

    // Bank roller contract address.
    address payable public bankRoller;

    // The address corresponding to a private key used to sign placeBet commits.
    address public secretSigner;

    // Croupier accounts.
    mapping(address => bool) public croupiers;

    // Accumulated jackpot fund.
    uint128 public jackpotSize;

    // Funds that are locked in potentially winning bets. Prevents contract from
    // committing to bets it cannot pay out.
    uint128 public lockedInBets;

    // A structure representing a single bet.
    struct Bet {
        // Wager amount in wei.
        uint amount;
        // Modulo of a game.
        uint24 modulo;
        // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),
        // and used instead of mask for games with modulo > MAX_MASK_BIG_MODULO.
        uint24 rollUnder;
        // Block number of placeBet tx.
        uint40 placeBlockNumber;
        // Bit mask representing winning bet outcomes (see MASK_MODULO_40 comment).
        uint256 mask;
        // Address of a gambler, used to pay out winning bets.
        address gambler;
    }

    // Mapping from commits to all currently active & processed bets.
    mapping(uint => Bet) bets;

    // Lotto prize structures (4-digits).
    uint24[5] LOTTO_PRIZE_4D = [0, 15, 40, 400, 10000]; // 0x, 1.5x, 4x, 40x, 1000x

    // Baccarat bet multiplers
    uint24[3] BACCARAT_BET_MULTIPLERS = [920, 202, 198]; // [0]Tie: 9x, [1]Player: 2x, [2]Banker: 1.9x

    // Events that are issued to make statistic recovery easier.
    event JackpotPayment(address indexed beneficiary, uint amount);

    // These events are emitted in placeBet to record commit in the logs.
    event Commit(uint commit);

    // Constructor
    constructor (address _trc20Token, uint _minJackpotBet, uint _jackpotFee,
        uint _minBet, uint _maxBet, uint _maxProfit) public {
        owner = msg.sender;
        trc20Token = _trc20Token;
        secretSigner = DUMMY_ADDRESS;
        setJackpotSettings(_minJackpotBet, _jackpotFee);
        setBetAmountSettings(_minBet, _maxBet);
        setMaxProfit(_maxProfit);
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyCroupier {
        require(croupiers[msg.sender], "OnlyCroupier methods called by non-croupier.");
        _;
    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    // Not allow to top up Tomo
    function() external payable {
        revert();
    }

    // Change bank roller account.
    function setBankRoller(address payable newBankRoller) external onlyOwner {
        bankRoller = newBankRoller;
    }

    // See comment for "secretSigner" variable.
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    // Set/unset the croupier address.
    function setCroupier(address croupier, bool croupierStatus) external onlyOwner {
        croupiers[croupier] = croupierStatus;
    }

    // Change jackpot settings
    function setJackpotSettings(uint _minJackpotBet, uint _jackpotFee) public onlyOwner {
        require(_minJackpotBet >= 1 ether, "minJackpotBet should be at least 1.0 token.");
        require(_jackpotFee >= 0.01 ether, "jackpotFee should be at least 0.01 token.");
        minJackpotBet = _minJackpotBet;
        jackpotFee = _jackpotFee;
    }

    // Change bet amount settings
    function setBetAmountSettings(uint _minBet, uint _maxBet) public onlyOwner {
        require(_minBet >= 0.01 ether, "minBet should be at least 0.01 token.");
        require(_maxBet <= 100000 ether, "maxBet should be at most 100,000 token.");
        require(_minBet < _maxBet, "minBet should be less than maxBet.");
        minBet = _minBet;
        maxBet = _maxBet;
    }

    // Change max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require(_maxProfit < maxBet * 10000, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    // This function is used to bump up the jackpot fund. Cannot be used to lower it.
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require(increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        require(lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        uint contractBalance = BankRollerInterface(bankRoller).balance();
        BankRollerInterface(bankRoller).transferToken(owner, contractBalance);
        selfdestruct(owner);
    }

    // Funds withdrawal to cover costs of mcash.tomodice.com operation.
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require(withdrawAmount <= BankRollerInterface(bankRoller).balance(), "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + withdrawAmount <= BankRollerInterface(bankRoller).balance(), "Not enough funds.");
        BankRollerInterface(bankRoller).transferToken(beneficiary, withdrawAmount);
    }

    /// *** Betting logic

    // Bet states:
    //  amount == 0 && gambler == 0 - 'clean' (can place a bet)
    //  amount != 0 && gambler != 0 - 'active' (can be settled or refunded)
    //  amount == 0 && gambler != 0 - 'processed' (can clean storage)
    //
    //  NOTE: Storage cleaning is not implemented in this contract version; it will be added
    //        with the next upgrade to prevent polluting Tomochain state with expired bets.

    // Bet placing transaction - issued by the player.
    //  betMask         - bet outcomes bit mask for modulo <= MAX_MASK_MODULO,
    //                    [0, betMask) for larger modulos.
    //  modulo          - game modulo.
    //  commitLastBlock - number of the maximum block where "commit" is still considered valid.
    //  commit          - Keccak256 hash of some secret "reveal" random number, to be supplied
    //                    by the mcash.tomodice.com croupier bot in the settleBet transaction. Supplying
    //                    "commit" ensures that "reveal" cannot be changed behind the scenes
    //                    after placeBet have been mined.
    //  r, s            - components of ECDSA signature of (commitLastBlock, commit). v is
    //                    guaranteed to always equal 27.
    //  affWallet       - wallet to receive commission if this sender is new
    // Commit, being essentially random 256-bit number, is used as a unique bet identifier in
    // the 'bets' mapping.
    //
    // Commits are signed with a block limit to ensure that they are used at most once - otherwise
    // it would be possible for a miner to place a bet with a known commit/reveal pair and tamper
    // with the blockhash. Croupier guarantees that commitLastBlock will always be not greater than
    // placeBet block number plus BET_EXPIRATION_BLOCKS. See whitepaper for details.
    function placeBet(address from, uint amount, uint256 betMask, uint24 modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s, address affWallet) internal {
        // Check that the bet is in 'clean' state.
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "Bet should be in a 'clean' state.");

        // Validate bank roller deposit amount soft cap
        require(BankRollerInterface(bankRoller).totalDeposit() >= BankRollerInterface(bankRoller).softCapDeposit(), "The house reserve has not passed softCap.");

        // Validate input data ranges.
        require(modulo > 1 && (modulo == BACCARAT_MODULO || modulo <= MAX_MODULO), "Modulo should be within range.");
        require(amount >= minBet && amount <= maxBet, "Amount should be within range.");

        // Check that commit is valid - it has not expired and its signature is valid.
        require(block.number <= commitLastBlock, "Commit has expired.");
        require(secretSigner == ecrecover(keccak256(abi.encodePacked(uint40(commitLastBlock), commit)), 27, r, s), "ECDSA signature is not valid.");

        uint rollUnder;
        uint mask;

        if (modulo == TOMOROLL_MODULO || modulo > MAX_MASK_BIG_MODULO) {// or TOMOLOTTO_4D or BACCARAT_MODULO
            // Larger modulos or specific games specify the right edge of half-open interval of winning bet outcomes.
            if (modulo == TOMOLOTTO_4D_MODULO) {
                require(betMask >= 0 && betMask < modulo, "High modulo range, betMask larger than modulo.");
            } else if (modulo == BACCARAT_MODULO) {
                require(betMask >= 0 && betMask <= 2, "Baccarat game: betMask needs to be between 0 and 2.");
            } else {
                require(betMask > 0 && betMask < modulo, "High modulo range, betMask larger than modulo.");
            }
            rollUnder = betMask;
        } else {
            require(betMask > 0 && betMask < MAX_BET_MASK_BIG_MODULO, "Mask should be within range.");
            // Small modulo games specify bet outcomes via bit mask.
            // rollUnder is a number of 1 bits in this mask (population count).
            // This magic looking formula is an efficient way to compute population
            // count on EVM for numbers below 2**40. For detailed proof consult
            // the mcash.tomodice.com whitepaper.
            if (modulo <= MASK_MODULO_40) {
                // Small modulo games specify bet outcomes via bit mask.
                // rollUnder is a number of 1 bits in this mask (population count).
                // This magic looking formula is an efficient way to compute population
                // count on EVM for numbers below 2**40.
                rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
                mask = betMask;
            } else if (modulo <= MASK_MODULO_40 * 2) {
                rollUnder = getRollUnder(betMask, 2);
                mask = betMask;
            } else if (modulo <= MASK_MODULO_40 * 3) {
                rollUnder = getRollUnder(betMask, 3);
                mask = betMask;
            } else if (modulo <= MASK_MODULO_40 * 4) {
                rollUnder = getRollUnder(betMask, 4);
                mask = betMask;
            } else if (modulo <= MASK_MODULO_40 * 5) {
                rollUnder = getRollUnder(betMask, 5);
                mask = betMask;
            } else {// (modulo <= MAX_MASK_BIG_MODULO)
                rollUnder = getRollUnder(betMask, 6);
                mask = betMask;
            }
        }

        // Winning amount and jackpot increase.
        uint _possibleWinAmount;
        uint _jackpotFee;

        (_possibleWinAmount, _jackpotFee, ,) = getDiceWinAmount(amount, modulo, rollUnder);

        // Enforce max profit limit.
        require(_possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        // Lock funds.
        lockedInBets += uint128(_possibleWinAmount);
        jackpotSize += uint128(_jackpotFee);

        // Check whether contract has enough funds to process this bet.
        require(jackpotSize + lockedInBets <= BankRollerInterface(bankRoller).balance() + amount, "Cannot afford to lose this bet.");

        ERC223Interface(trc20Token).transfer(bankRoller, amount);

        // Record commit in logs.
        emit Commit(commit);

        // Store bet parameters on blockchain.
        bet.amount = amount;
        bet.modulo = uint24(modulo);
        bet.rollUnder = uint24(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint256(mask);
        bet.gambler = from;

        BankRollerInterface(bankRoller).assignAffiliate(from, affWallet);
    }

    // This is the method used to settle 99% of bets. To process a bet with a specific
    // "commit", settleBet should supply a "reveal" number that would Keccak256-hash to
    // "commit". "blockHash" is the block hash of placeBet block as seen by croupier; it
    // is additionally asserted to prevent changing the bet outcomes on Tomochain reorgs.
    function settleBet(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
        require(block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require(block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");
        require(blockhash(placeBlockNumber) == blockHash);

        // Settle bet using reveal and blockHash as entropy sources.
        settleBetCommon(bet, reveal, blockHash);
    }

    // This is the method used to settle 1% of bets left with passed blockHash seen by croupier
    // It needs player to trust croupier and can only be executed after between [BET_EXPIRATION_BLOCKS, 10*BET_EXPIRATION_BLOCKS]
    function settleBetLate(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require(block.number >= placeBlockNumber + BET_EXPIRATION_BLOCKS, "block.number needs to be after BET_EXPIRATION_BLOCKS");
        require(block.number <= placeBlockNumber + 100 * BET_EXPIRATION_BLOCKS, "block.number needs to be before 100 * BET_EXPIRATION_BLOCKS");

        // Settle bet using reveal and blockHash as entropy sources.
        settleBetCommon(bet, reveal, blockHash);
    }

    // Common settlement code for settleBet.
    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash) private {
        // Fetch bet parameters into local variables (to save gas).
        uint amount = bet.amount;
        uint24 modulo = bet.modulo;
        uint24 rollUnder = bet.rollUnder;
        address gambler = bet.gambler;

        // Check that bet is in 'active' state.
        require(amount != 0, "Bet should be in an 'active' state");

        // Move bet into 'processed' state already.
        bet.amount = 0;

        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        // Do a roll by taking a modulo of entropy. Compute winning amount.
        uint256 dice = uint256(entropy) % modulo;

        uint diceWinAmount;
        uint _houseEdge;
        uint betAmount;

        (diceWinAmount, , _houseEdge, betAmount) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;

        // Determine dice outcome.
        if (modulo == TOMOLOTTO_4D_MODULO) {
            diceWin = getLottoWinAmount(modulo, rollUnder, dice, betAmount);
        } else if (modulo == BACCARAT_MODULO) {
            diceWin = getBaccaratWinAmount(modulo, rollUnder, dice, betAmount);
        } else if (modulo == TOMOROLL_MODULO || modulo > MAX_MASK_BIG_MODULO) {
            // For larger modulos or tomoroll, check inclusion into half-open interval.
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }
        } else if (modulo <= MAX_MASK_BIG_MODULO) {
            // For small modulo games, check the outcome against a bit mask.
            if ((uint256(2) ** dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }
        }

        uint jackpotWin = 0;

        // Unlock the bet amount, regardless of the outcome.
        lockedInBets -= uint128(diceWinAmount);

        // Roll for a jackpot (if eligible).
        if (amount >= minJackpotBet) {
            // The second modulo, statistically independent from the "main" dice roll.
            // Effectively you are playing two games at once!
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            // Bingo!
            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        // Log jackpot win.
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        // Send the funds to gambler.
        uint sentAmount = diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin;
        BankRollerInterface(bankRoller).sendFunds(gambler, sentAmount, diceWin, _houseEdge);
    }

    // Refund transaction - return the bet amount of a roll that was not processed in a
    // due timeframe. Processing such blocks is not possible due to EVM limitations (see
    // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself
    // in a situation like this, just contact the mcash.tomodice.com support, however nothing
    // precludes you from invoking this method yourself.
    function refundBet(uint commit) external {
        // Check that bet is in 'active' state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require(amount != 0, "Bet should be in an 'active' state");

        // Check that bet has already expired long ago.
        require(block.number > bet.placeBlockNumber + 20 * BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        // Move bet into 'processed' state, release funds.
        bet.amount = 0;

        uint _diceWinAmount;
        uint _jackpotFee;

        (_diceWinAmount, _jackpotFee, ,) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets -= uint128(_diceWinAmount);
        jackpotSize -= uint128(_jackpotFee);

        // Send the refund.
        BankRollerInterface(bankRoller).sendFunds(bet.gambler, amount, amount, 0);
    }

    // Get the expected win amount after house edge is subtracted.
    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private view returns (uint winAmount, uint _jackpotFee, uint _houseEdge, uint betAmount) {
        require(0 <= rollUnder && rollUnder <= modulo, "Win probability out of range.");

        _jackpotFee = (amount >= minJackpotBet) ? jackpotFee : 0;

        _houseEdge = amount * BankRollerInterface(bankRoller).houseEdgePermille() / 1000;

        uint houseEdgeMinimumAmount = BankRollerInterface(bankRoller).houseEdgeMinimumAmount();
        if (_houseEdge < houseEdgeMinimumAmount) {
            _houseEdge = houseEdgeMinimumAmount;
        }

        uint _bankRollerReward = amount * BankRollerInterface(bankRoller).bankRollerRewardPermille() / 1000;
        uint _founderReward = amount * BankRollerInterface(bankRoller).founderRewardPermille() / 1000;
        uint _donation = amount * BankRollerInterface(bankRoller).donationPermille() / 1000;

        require(_houseEdge + _bankRollerReward + _founderReward + _donation + _jackpotFee <= amount,
            "Bet doesn't even cover houseEdge, bankRoller, founderReward, donation and jackpot fees.");

        betAmount = amount - _houseEdge - _bankRollerReward - _founderReward - _donation - _jackpotFee;
        if (modulo == TOMOLOTTO_4D_MODULO) {
            winAmount = betAmount * LOTTO_PRIZE_4D[4] / 10;
        } else if (modulo == BACCARAT_MODULO) {
            winAmount = betAmount * BACCARAT_BET_MULTIPLERS[rollUnder] / 100;
        } else {
            winAmount = betAmount * modulo / rollUnder;
        }
    }

    // get lotto win
    function getLottoWinAmount(uint modulo, uint rollUnder, uint dice, uint betAmount) private view returns (uint winAmount) {
        require(modulo == TOMOLOTTO_4D_MODULO, "Calculate lotto win amount only.");

        uint8 digitMatch = 0;
        if (rollUnder % 10 == dice % 10) ++digitMatch;
        if ((rollUnder % 100) / 10 == (dice % 100) / 10) ++digitMatch;
        if ((rollUnder % 1000) / 100 == (dice % 1000) / 100) ++digitMatch;
        if (rollUnder / 1000 == dice / 1000) ++digitMatch;

        return betAmount * LOTTO_PRIZE_4D[digitMatch] / 10;
    }

    // event BaccaratCards(uint dice, uint8[] cards, uint8 playerSum, uint8 bankerSum);

    function calculateSum(uint8 currentSum, uint8 card) private pure returns (uint8 sum) {
        return (card >= 9) ? currentSum : (currentSum + card + 1) % 10;
    }

    // get baccarat win
    function getBaccaratWinAmount(uint modulo, uint rollUnder, uint dice, uint betAmount) private view returns (uint winAmount) {
        require(modulo == BACCARAT_MODULO, "Calculate baccarat win amount only.");

        uint8[] memory cards = new uint8[](6);
        // uint _dice = dice;
        for (uint8 pos = 0; pos < 6; pos++) {
            cards[pos] = (uint8) (dice % 13);
            dice = dice / 13;
        }

        uint8 playerSum = calculateSum(calculateSum(0, cards[0]), cards[2]);
        uint8 bankerSum = calculateSum(calculateSum(0, cards[1]), cards[3]);

        if (playerSum < 8 && bankerSum < 8) {
            if (bankerSum >= 0 && bankerSum <= 2) bankerSum = calculateSum(bankerSum, cards[5]);
            if (playerSum >= 0 && playerSum <= 5) {
                playerSum = calculateSum(playerSum, cards[4]);
                if (bankerSum > 2 && bankerSum < 7) {
                    uint8 player3rdCardNumber = cards[4] + 1;
                    if (bankerSum == 3) {
                        if (player3rdCardNumber != 8) bankerSum = calculateSum(bankerSum, cards[5]);
                    } else if (bankerSum == 4) {
                        if (player3rdCardNumber >= 2 && player3rdCardNumber <= 7) bankerSum = calculateSum(bankerSum, cards[5]);
                    } else if (bankerSum == 5) {
                        if (player3rdCardNumber >= 4 && player3rdCardNumber <= 7) bankerSum = calculateSum(bankerSum, cards[5]);
                    } else {// bankerSum == 6
                        if (player3rdCardNumber >= 6 && player3rdCardNumber <= 7) bankerSum = calculateSum(bankerSum, cards[5]);
                    }
                }
            }
        }

        // emit BaccaratCards(_dice, cards, playerSum, bankerSum);

        if (playerSum == bankerSum) return (rollUnder == 0) ? betAmount * BACCARAT_BET_MULTIPLERS[rollUnder] / 100 : 0;
        else if (playerSum > bankerSum) return (rollUnder == 1) ? betAmount * BACCARAT_BET_MULTIPLERS[rollUnder] / 100 : 0;
        else return (rollUnder == 2) ? betAmount * BACCARAT_BET_MULTIPLERS[rollUnder] / 100 : 0;
    }

    event EmergencyERC20Drain(address token, address owner, uint256 amount);

    // owner can drain tokens that are sent here by mistake
    function emergencyERC20Drain(ERC20 token, uint amount) external onlyOwner {
        emit EmergencyERC20Drain(address(token), owner, amount);
        token.transfer(owner, amount);
    }

    // This are some constants making O(1) population count in placeBet possible.
    // See whitepaper for intuition and proofs behind it.
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;
    uint constant MASK40 = 0xFFFFFFFFFF;

    function getRollUnder(uint betMask, uint n) private pure returns (uint rollUnder) {
        rollUnder += (((betMask & MASK40) * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
        for (uint i = 1; i < n; i++) {
            betMask = betMask >> MASK_MODULO_40;
            rollUnder += (((betMask & MASK40) * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
        }
        return rollUnder;
    }

    event ApprovalReceived(address indexed from, uint256 value, bytes data);
    event TokenFallback(address indexed from, uint256 value, bytes data);
    event CustomFallback(address indexed from, uint256 value, bytes data);

    // https://www.ethereum.org/token
    // function in contract 'tokenRecipient'
    function receiveApproval(address from, uint256 value, bytes memory data) public {
        emit ApprovalReceived(from, value, data);
    }

    // ERC223
    // function in contract 'ContractReceiver'
    function tokenFallback(address from, uint value, bytes memory data) public {
        require(msg.sender == trc20Token, "Not supported TRC20 token");
        require(data.length >= 224, "Not enough data for placeBet");
        uint256 betMask = sliceUint(data, 0);
        uint256 modulo = sliceUint(data, 32);
        uint256 commitLastBlock = sliceUint(data, 64);
        uint256 commit = sliceUint(data, 96);
        uint256 r = sliceUint(data, 128);
        uint256 s = sliceUint(data, 160);
        uint256 affWallet = sliceUint(data, 192);
        placeBet(from, value, uint256(betMask), uint24(modulo), uint(commitLastBlock), uint(commit), bytes32(r), bytes32(s), address(affWallet));
        emit TokenFallback(from, value, data);
    }

    // ERC223
    function customFallback(address from, uint value, bytes memory data) public {
        emit CustomFallback(from, value, data);
    }

    function sliceUint(bytes memory bs, uint start) internal pure returns (uint) {
        require(bs.length >= start + 32, "slicing out of range");
        uint x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return x;
    }
}
