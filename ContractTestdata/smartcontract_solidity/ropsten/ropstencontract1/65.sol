/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity >=0.4.22 <0.6.0;

contract Poker {

    uint8 public numPlayers;
	// numero carte mazzo (con 2 giocatori: 32 carte)
    uint8 public numCards;
	// valore carta più basso mazzo
    uint8 public minCard;
    uint8 public numRounds;

    // costo partita
    uint public constant buy_in = 100;
    // costo iscrizione
    uint public constant registration_fee = 1 ether;
    // costo 1 fiche (1 ether = 1000 fiches)
    uint public constant chip_value = 1 finney;

    constructor() public {
        owner_address = msg.sender;
        initGame(2,2);
    }

    function() external payable {}

    enum Stage {
        WaitingPlayers,
        RoundStarted,
        BettingTime,
        RoundFinished,
        GameFinished
    }

    event UserAdded(string name);
    event PlayerAdded();
    event GameStarted(uint8 player_id, string name);
    event RoundStarted(uint8 round);
    event BetStarted();
    event PlayerTurn(uint8 player_id);
    event PlayerAction(uint8 player_id, string action, uint amount);
    event RevealPlayer(uint8 player_id, uint8[5] cards, string score);
    event Winner(uint8 player_id);
    event GameFinished();

    struct User {
        string nickname;
        uint chips;
        uint playedRounds;
        uint finishedRounds;
        uint wonRounds;
    }

    struct Player {
        uint id;
        uint chips;
        uint bet;
        uint8[5] cards;
        uint32 score;
    }

    struct Game {
        Player[] players;
        uint8[] deck;
        uint8 nextCard;
        uint currentBet;
        uint pot;
        Stage currentStage;
        uint8 turn;
        uint8 lastBet;
        uint8 currentRound;
        mapping (uint8 => bool) inGame;
    }

    Game private game;

    // lista nomi utenti
    mapping (string => bool) private names;
    // lista utenti registrati
    mapping (uint => User) private users;
    // lista utenti giocatori
    mapping (uint => bool) private current_players;

    // conteggio numero utenti registrati
    uint public usersCount;

    // da nickname a utente
    mapping (string => uint) private nameToUserID;
    // da indirizzo a utente
    mapping (address => uint) private addressToUserID;
    // da indirizzo a giocatore
    mapping (address => uint8) private addressToPlayerID;

    // proprietario contratto
    address payable public owner_address;
    uint public owner_reward = 0;

    modifier onlyUnregistered() {
        require(addressToUserID[msg.sender] == 0, "Utente già registrato.");
        _;
    }

    modifier onlyUser() {
        require(addressToUserID[msg.sender] != 0, "Non sei un utente registrato.");
        _;
    }

    modifier onlyPlayer() {
        require(addressToUserID[msg.sender] != 0, "Non sei un utente registrato.");
        require(current_players[addressToUserID[msg.sender]], "Non stai giocando nessuna partita.");
        require(addressToPlayerID[msg.sender] == game.turn, "Non è il tuo turno.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner_address, "Non sei il proprietario.");
        _;
    }

    modifier atStage(Stage stage) {
        require(game.currentStage == stage, "Non è possibile effettuare questa operazione in questa fase di gioco.");
        _;
    }

    function addUser(string memory name) private {
        names[name] = true;
        User memory u;
        u.nickname = name;
        u.chips = 500;
        usersCount++;
        uint user_id = usersCount;
        users[user_id] = u;
        nameToUserID[name] = user_id;
        addressToUserID[msg.sender] = user_id;
        owner_reward += 0.5 ether;
        emit UserAdded(name);
    }

    function addPlayer(uint user_id) private {
        current_players[user_id] = true;
        Player memory p;
        p.id = user_id;
        p.chips = buy_in;
        for (uint8 i = 0; i < 5; i++) {
                p.cards[i] = getCard();
            }
        uint8 player_id = uint8(game.players.length);
        game.players.push(p);
        users[user_id].chips -= buy_in;
        users[user_id].playedRounds += numRounds;
        addressToPlayerID[msg.sender] = player_id;
        game.inGame[player_id] = true;
        emit PlayerAdded();
        if (game.players.length == numPlayers) {
            pubNames();
            nextStage();
            emit RoundStarted(game.currentRound);
            emit PlayerTurn(game.turn);
        }
    }

    function resetPlayer(uint8 player_id) private {
        Player storage p = game.players[player_id];
        delete p.bet;
        delete p.cards;
        delete p.score;
    }

    function resetRound() private {
        for (uint8 i = 0; i < numPlayers; i++) {
            resetPlayer(i);
        }
        delete game.nextCard;
        delete game.currentBet;
        delete game.pot;
        delete game.turn;
        delete game.lastBet;
        for (uint8 i = 0; i < numPlayers; i++) {
            game.inGame[i] = true;
        }
        game.currentStage = Stage.RoundStarted;
        emit RoundStarted(game.currentRound);
        emit PlayerTurn(game.turn);
    }

    function removePlayers() private {
        uint user_id;
        for (uint8 i = 0; i < numPlayers; i++) {
            user_id = game.players[i].id;
            delete current_players[user_id];
        }
    }

    function pubNames() private {
        for (uint8 i = 0; i < numPlayers; i++) {
            uint user_id = game.players[i].id;
            string memory player_name = users[user_id].nickname;
            emit GameStarted(i, player_name);
        }
    }

    function newRound() private {
        resetRound();
        shuffleCards();
        dealCards();
    }

    function initGame(uint8 _players, uint8 _rounds) private {
        numPlayers = _players;
        minCard = 9-numPlayers;
        numCards = 52-((minCard-2)*4);
        numRounds = _rounds;
        initDeck();
        shuffleCards();
    }

    function initDeck() private {
        uint8 c;
        for (uint i = 0; i < numCards; i++) {
            game.deck.push(c);
        }
    }

    // mischia le carte ordinando mazzo in modo casuale
    function shuffleCards() private {

		// array temporaneo per ordinamento
		uint8[] memory tempDeck = new uint8[](numCards);

		// aggiungi assi
		tempDeck[0]=1;
		tempDeck[1]=14;
		tempDeck[2]=27;
		tempDeck[3]=40;

		uint8 val = minCard;

		// aggiungi carte valide (dipende dalla carta più bassa)
		for (uint i = 4; i < numCards; i++) {
		    tempDeck[i] = val;
		    if(val%13 == 0) {
		        val += minCard;
		        continue;
		    }
		    val++;
		}

        // ordina elementi array in modo casuale
		for (uint i = 0; i < numCards; i++) {
		    // random sulle posizioni rimanenti
		    uint r = i + getRandom(numCards - i);
		    // scambia elementi
		    uint8 tempCard = tempDeck[r];
		    tempDeck[r] = tempDeck[i];
		    tempDeck[i] = tempCard;
		}

		// imposta mazzo reale
		for (uint i = 0; i < numCards; i++) {
		    game.deck[i] = tempDeck[i];
		}
    }

    // pesca prossima carta dal mazzo
    function getCard() private returns (uint8) {
        uint8 card = game.deck[game.nextCard];
        game.nextCard++;
        return card;
    }

    // distribuisci carte ai giocatori
    function dealCards() private {
        for (uint8 i = 0; i < numPlayers; i++) {
            for (uint8 j = 0; j < 5; j++) {
                game.players[i].cards[j] = getCard();
            }
        }
    }

    function getGame() private view returns (uint, uint, uint[] memory, uint[] memory) {
        uint[] memory players_chips = new uint[](numPlayers);
        uint[] memory players_bet = new uint[](numPlayers);
        for (uint8 i = 0; i < numPlayers; i++) {
            players_chips[i] = game.players[i].chips;
            players_bet[i] = game.players[i].bet;
        }
        return (game.pot, game.currentBet, players_chips, players_bet);
    }

    function _changeCards(uint8 player_id, uint8[] memory cards) private {
        for (uint8 i = 0; i < cards.length; i++) {
            game.players[player_id].cards[cards[i]] = getCard();
        }
        nextPlayer();
    }

    function _check() private {
        nextPlayer();
    }

    function _fold(uint8 player_id) private {
        game.inGame[player_id] = false;
        emit PlayerAction(player_id, "FOLD", 0);
        nextPlayer();
    }

    function _bet(uint8 player_id, uint amount) private {
        game.currentBet += amount;
        game.players[player_id].chips -= amount;
        game.players[player_id].bet += amount;
        game.pot += amount;
        game.lastBet = player_id;
        emit PlayerAction(player_id, "BET", amount);
        nextPlayer();
    }

    function _call(uint8 player_id) private {
        uint amount = game.currentBet - game.players[player_id].bet;
        game.players[player_id].chips -= amount;
        game.players[player_id].bet += amount;
        game.pot += amount;
        emit PlayerAction(player_id, "CALL", 0);
        nextPlayer();
    }

    function _raise(uint8 player_id, uint amount) private {
        uint final_amount = (game.currentBet - game.players[player_id].bet) + amount;
        game.currentBet += amount;
        game.players[player_id].chips -= final_amount;
        game.players[player_id].bet += final_amount;
        game.pot += final_amount;
        game.lastBet = player_id;
        emit PlayerAction(player_id, "RAISE", amount);
        nextPlayer();
    }

    function _allIn(uint8 player_id) private {
        uint amount = game.players[player_id].chips;
        game.players[player_id].chips = 0;
        game.players[player_id].bet += amount;
        game.pot += amount;
        emit PlayerAction(player_id, "ALL IN", 0);
        nextPlayer();
    }

    function _nextRound() private {
        nextPlayer();
    }

    function findNextPlayer(uint8 last_player) private view returns (uint8) {
        uint8 temp = last_player;
        // salta giocatori folded e all in
        while (!game.inGame[temp] || (game.inGame[temp] && (game.players[temp].chips == 0))) {
            temp++;
            if (temp == numPlayers) {
                temp = 0;
            }
        }
        return temp;
    }

    function checkLastPlayer() private view returns (bool) {
        uint8 countF = 0;
        uint8 countA = 0;
        for (uint8 i = 0; i < numPlayers; i++) {
            if (game.inGame[i]) {
                countF++;
            }
            if (game.inGame[i] && (game.players[i].chips > 0)) {
                countA++;
            }
        }
        if (countF == 1 || countA == 0) {
            return true;
        }
        else {
            return false;
        }
    }

    function checkChips() private view returns (bool) {
        uint8 count = 0;
        for (uint8 i = 0; i < numPlayers; i++) {
            if (game.players[i].chips == 0) {
                count++;
            }
        }
        if (count != 0) {
            return true;
        }
        else {
            return false;
        }
    }

    function nextPlayer() private {
        if (game.currentStage == Stage.RoundStarted) {
            game.turn++;
            if (game.turn == numPlayers) {
                game.turn = 0;
                nextStage();
                emit PlayerTurn(game.turn);
                emit BetStarted();
                return;
            }
            emit PlayerTurn(game.turn);
        }
        if (game.currentStage == Stage.BettingTime) {
            uint8 lastTurn = game.turn;
            game.turn++;
            // turno ciclico
            if (game.turn == numPlayers) {
                game.turn = 0;
            }
            // ultimo giocatore
            bool isLast = checkLastPlayer();
            if (isLast) {
                checkWinner();
                return;
            }
            // cerca giocatore successivo ancora in gioco
            uint8 tempTurn = findNextPlayer(game.turn);
            game.turn = tempTurn;
            // giro terminato
            if ((game.turn == game.lastBet) || (game.turn == lastTurn)) {
                checkWinner();
                return;
            }
            emit PlayerTurn(game.turn);
        }
        if (game.currentStage == Stage.RoundFinished) {
            game.turn++;
            if (game.turn == numPlayers) {
                newRound();
                return;
            }
            emit PlayerTurn(game.turn);
        }
    }

    function nextStage() private {
        game.currentStage = Stage(uint(game.currentStage)+1);
    }

    function checkWinner() private {
        uint maxScore = 0;
        uint8 winner;
        for (uint8 i = 0; i < numPlayers; i++) {
            if (game.inGame[i]) {
                uint8[5] memory p_cards = game.players[i].cards;
                uint8 hand_t;
                uint8[5] memory hand_c;
                (hand_t, hand_c) = evaluateHand(p_cards);
                uint32 score = uint32(calculateScore(hand_t, hand_c));
                game.players[i].score = score;
                if (score > maxScore) {
                    maxScore = score;
                    winner = i;
                }
                uint user_id = game.players[i].id;
                users[user_id].finishedRounds++;
            }
        }
        pubResult();
        emit Winner(winner);
        game.players[winner].chips += game.pot;
        uint user_id = game.players[winner].id;
        users[user_id].wonRounds++;
        game.currentRound++;
        bool chipsFinished = checkChips();
        if ((game.currentRound == numRounds) || chipsFinished) {
            updateUsers();
            game.currentStage = Stage.GameFinished;
            emit GameFinished();
            return;
        }
        else {
            game.turn = 0;
            emit PlayerTurn(game.turn);
            nextStage();
        }
    }

    // converte codice carta (0-51) in valore (0-12) e seme (0-3)
    function getCardInfo(uint8 card) private pure returns (uint8, uint8) {
        require(card >=0 && card < 52);
        return (card%13, card/13);
    }

    // converte valore carta nel valore reale (1-13) per ordine in caso di pareggio
	// asso è carta più alta quindi valori diventano (2-14)
    function getCardOrder(uint8 card) private pure returns (uint8) {
        // asso
		if (card == 0) {
			return 14;
		}
		return (card+1);
    }

    // ordina array in ordine decrescente
    function sortHand(uint8[5] memory cards) private pure returns (uint8[5] memory) {
        uint8 i;
        uint8[5] memory arr;

        for (i = 0; i < 5; i++) {
            arr[i] = cards[i];
        }

        uint8 key;
        uint8 j;

        for (i = 1; i < 5; i++) {
            key = arr[i];
            for (j = i; j > 0 && arr[j-1] < key; j--) {
                arr[j] = arr[j-1];
            }
            arr[j] = key;
        }

        return arr;
    }

    // valuta tipo mano
    function evaluateHand(uint8[5] memory cards) private view returns (uint8, uint8[5] memory) {

        uint8 i;

        // valori carte con asso = 14
        uint8[5] memory cardsList;
        // carte in ordine decrescente per valore
        uint8[5] memory sortedCards;
        // array per coppie
        uint8[2] memory pairs;
        // array valori ritorno
		uint8[5] memory result;

		// array per conteggio valori (coppia, tris, poker)
		uint8[13] memory values;
		// array per conteggio semi (colore)
        uint8[4] memory suits;
        // valore carta
        uint8 cardValue;
        // seme carta
        uint8 cardSuit;

        // tipo mano
        uint8 handRank;

        for (i = 0; i < 5; i++) {

            (cardValue, cardSuit) = getCardInfo(cards[i]-1);
            cardsList[i] = getCardOrder(cardValue);

            values[cardValue]++;

            // poker
            if (values[cardValue] == 4 && handRank < 7) {
                handRank = 7;
                result[0] = cardsList[i];
            }

            // tris
            else if (values[cardValue] == 3 && handRank < 3) {
                handRank = 3;
                result[0] = cardsList[i];
            }

            // coppia
            else if (values[cardValue] == 2) {
                // memorizzo valore coppia
                // prima coppia
                if (pairs[0] == 0) {
                    pairs[0] = cardsList[i];
                }
                // seconda coppia
                else {
                    pairs[1] = cardsList[i];
                }
            }

            suits[cardSuit]++;

            // colore
            if (suits[cardSuit] == 5) {

                // ordina carte
                sortedCards = sortHand(cardsList);

                // scala colore
                if (sortedCards[0] - sortedCards[4] == 4) {

                    // scala reale colore (con asso valore massimo)
                    if (sortedCards[0] == 14) {
                        handRank = 9;
                    }

                    // scala colore
                    else {
                        handRank = 8;
                    }

                    result[0] = sortedCards[0];
                    return (handRank, result);
                }

                // scala colore (con asso valore minimo)
                else if (sortedCards[0] == 14 && sortedCards[1] == (minCard+3) && (sortedCards[1] - sortedCards[4]) == 3) {
                    handRank = 8;
                    result[0] = sortedCards[1];
                    return (handRank, result);
                }

                // colore
                else {
                    handRank = 5;
                    return (handRank, sortedCards);
                }
            }
        }

        // poker
        if (handRank == 7) {
            return (handRank, result);
        }

        // tris
        else if (handRank == 3) {

            // full
            if (pairs[1] > 0) {
                handRank = 6;
                return (handRank, result);
            }

            // tris
            return (handRank, result);
        }

        // controllo scala se non ci sono coppie
        if (handRank < 3) {

            // nessuna coppia, controllo scala
            if (pairs[0] == 0) {

                // ordina carte
                sortedCards = sortHand(cardsList);

                // scala
                if (sortedCards[0] - sortedCards[4] == 4) {
                    handRank = 4;
                    result[0] = sortedCards[0];
                    return (handRank, result);
                }

                // scala (con asso valore minimo)
                else if (sortedCards[0] == 14 && sortedCards[1] == (minCard+3) && (sortedCards[1] - sortedCards[4]) == 3) {
                    handRank = 4;
                    result[0] = sortedCards[1];
                    return (handRank, result);
                }

                // carta singola
                else {
                    handRank = 0;
                    return (handRank, sortedCards);
                }
            }

            // coppia o doppia coppia
            else {

                // doppia coppia
                if (pairs[1] != 0) {
                    handRank = 2;

                    // ordina carte
                    sortedCards = sortHand(cardsList);

                    // ordino coppie per valore decrescente
                    // prima coppia maggiore
                    if (pairs[0] > pairs[1]) {
                        result[0] = pairs[0];
                        result[1] = pairs[1];
                    }
                    // seconda coppia maggiore
                    else {
                        result[0] = pairs[1];
                        result[1] = pairs[0];
                    }

                    // trovo altra carta
                    for (i = 0; i < 5; i++) {
                        if ((sortedCards[i] != pairs[0]) && (sortedCards[i] != pairs[1])) {
                            result[2] = sortedCards[i];
                        }
                    }

                    return (handRank, result);
                }

                // coppia
                else {
                    handRank = 1;
                    result[0] = pairs[0];

                    // ordina carte
                    sortedCards = sortHand(cardsList);

                    // trovo altre carte
                    uint8 j = 1;
                    for (i = 0; i < 5; i++) {
                        if (sortedCards[i] != pairs[0]) {
                            result[j] = sortedCards[i];
                            j++;
                        }
                    }

                    return (handRank, result);
                }
            }
        }

        return (handRank, result);
    }

    // calcola punteggio mano
    function calculateScore(uint8 rank, uint8[5] memory val) private pure returns (uint) {

        uint8 i;
        uint8 len;

        // punteggio base
        uint score = rank*1000000;

        for (i = 0; i < 5; i++) {
            if (val[i] != 0)
                len++;
        }

        // valore carta più alta
        if (len == 1) {
            score += val[0];
        }

        // somma pesata altre carte
        else {
            uint j = len-1;
            for (i = 0; i < len; i++) {
                score += val[i]*(14**j);
                j--;
            }
        }

        return score;
    }

    function updateUsers() private {
        for (uint8 i = 0; i < numPlayers; i++) {
            uint user_id = game.players[i].id;
            uint player_chips = game.players[i].chips;
            users[user_id].chips += player_chips;
        }
    }

    function pubResult() private {
        for (uint8 i = 0; i < numPlayers; i++) {
            uint8[5] memory player_cards = game.players[i].cards;
            uint32 score_num = game.players[i].score;
            string memory player_score = convertScore(score_num);
            emit RevealPlayer(i, player_cards, player_score);
        }
    }

    function convertScore(uint32 score) private pure returns (string memory) {
        if (score > 9000000)
            return "SCALA REALE";
        if (score > 8000000)
            return "SCALA COLORE";
        if (score > 7000000)
            return "POKER";
        if (score > 6000000)
            return "FULL";
        if (score > 5000000)
            return "COLORE";
        if (score > 4000000)
            return "SCALA";
        if (score > 3000000)
            return "TRIS";
        if (score > 2000000)
            return "DOPPIA COPPIA";
        if (score > 1000000)
            return "COPPIA";
        if (score > 0)
            return "CARTA ALTA";
        if (score == 0)
            return "FOLDED";
    }

    // PUBLIC FUNCTIONS

    function registerUser(string memory _name) public payable onlyUnregistered {
        // controllo nome disponibile
        require(!names[_name], "Nome utente non disponibile.");
        // controllo pagamento iscrizione
        require(msg.value == registration_fee, "Ether insufficienti per effettuare la registrazione.");
        addUser(_name);
    }

    function viewUser(string memory _name) public view onlyUser returns (string memory, uint, uint[3] memory) {
        // controllo nome esistente
        require(names[_name], "Nome utente non esistente.");
        uint user_id = nameToUserID[_name];
        User memory u = users[user_id];
        return (u.nickname, u.chips, [u.playedRounds, u.finishedRounds, u.wonRounds]);
    }

    function sellChips(uint _amount) public onlyUser {
        require(_amount > 0, "La quantità deve essere positiva.");
        uint user_id = addressToUserID[msg.sender];
        uint user_chips = users[user_id].chips;
        // controllo fiches sufficienti
        require(_amount <= user_chips, "Non hai fiches sufficienti da ritirare.");
        users[user_id].chips -= _amount;
        uint amount = _amount*chip_value;
        msg.sender.transfer(amount);
    }

    function buyChips(uint _amount) public payable onlyUser {
        require(_amount > 0, "La quantità deve essere positiva.");
        // controllo ether sufficienti
        require(msg.value >= chip_value, "Il costo minimo di una singola fiche è di 1 finney.");
        uint chips = msg.value/chip_value;
        require(_amount <= chips, "Ether insufficienti per comprare la quantità di fiches richieste.");
        uint user_id = addressToUserID[msg.sender];
        users[user_id].chips += _amount;
    }

    function joinGame() public onlyUser atStage(Stage.WaitingPlayers) {
        uint user_id = addressToUserID[msg.sender];
        require(!current_players[user_id], "Sei già un giocatore della partita.");
        // controllo fiches sufficienti
        require(users[user_id].chips >= buy_in, "Non hai fiches sufficienti per giocare.");
        addPlayer(user_id);
    }

    function getMyChips() public onlyUser view returns (string memory, uint) {
        uint user_id = addressToUserID[msg.sender];
        return (users[user_id].nickname, users[user_id].chips);
    }

    function getMyCards() public view returns (uint8[5] memory) {
        require(addressToUserID[msg.sender] != 0, "Non sei un utente registrato.");
        require(current_players[addressToUserID[msg.sender]], "Non stai giocando nessuna partita.");
        require(game.currentStage >= Stage.RoundStarted, "Non è possibile effettuare questa operazione in questa fase di gioco.");
        uint8 player_id = addressToPlayerID[msg.sender];
        return game.players[player_id].cards;
    }

    function changeCards(uint8[] memory _cards) public onlyPlayer atStage(Stage.RoundStarted) {
        require(_cards.length <= 4);
        uint8 player_id = addressToPlayerID[msg.sender];
        _changeCards(player_id, _cards);
    }

    function check() public onlyPlayer atStage(Stage.RoundStarted) {
        _check();
    }

    function fold() public onlyPlayer atStage(Stage.BettingTime) {
        uint8 player_id = addressToPlayerID[msg.sender];
        _fold(player_id);
    }

    function bet(uint _amount) public onlyPlayer atStage(Stage.BettingTime) {
        require(_amount > 0, "La quantità deve essere positiva.");
        // controllo giocatore
        require(game.currentBet == 0, "Non puoi effettuare questa giocata.");
        uint8 player_id = addressToPlayerID[msg.sender];
        // controllo fiches sufficienti
        require(game.players[player_id].chips >= _amount, "Non hai fiches sufficienti per questa puntata.");
        _bet(player_id, _amount);
    }

    function call() public onlyPlayer atStage(Stage.BettingTime) {
        // controllo giocatore
        require(game.currentBet != 0, "Non puoi effettuare questa giocata.");
        uint8 player_id = addressToPlayerID[msg.sender];
        // controllo fiches sufficienti
        uint p_chips = game.players[player_id].chips;
        uint p_bet = game.players[player_id].bet;
        uint g_bet = game.currentBet;
        require(p_chips >= (g_bet - p_bet), "Non hai fiches sufficienti per questa puntata.");
        _call(player_id);
    }

    function raise(uint _amount) public onlyPlayer atStage(Stage.BettingTime) {
        require(_amount > 0, "La quantità deve essere positiva.");
        // controllo giocatore
        require(game.currentBet != 0, "Non puoi effettuare questa giocata.");
        uint8 player_id = addressToPlayerID[msg.sender];
        // controllo fiches sufficienti
        uint p_chips = game.players[player_id].chips;
        uint p_bet = game.players[player_id].bet;
        uint g_bet = game.currentBet;
        require(p_chips >= ((g_bet - p_bet) + _amount), "Non hai fiches sufficienti per questa puntata.");
        _raise(player_id, _amount);
    }

    function allIn() public onlyPlayer atStage(Stage.BettingTime) {
        uint8 player_id = addressToPlayerID[msg.sender];
        // controllo fiches (call o raise)
        uint p_chips = game.players[player_id].chips;
        uint p_bet = game.players[player_id].bet;
        uint g_bet = game.currentBet;
        if (p_chips >= (g_bet - p_bet)) {
            uint amount = p_chips - (g_bet - p_bet);
            _raise(player_id, amount);
            emit PlayerAction(player_id, "ALL IN", 0);
        }
        else {
            _allIn(player_id);
        }
    }

    function getGameData() public view returns (uint, uint, uint[] memory, uint[] memory) {
        require(addressToUserID[msg.sender] != 0, "Non sei un utente registrato.");
        require(current_players[addressToUserID[msg.sender]], "Non stai giocando nessuna partita.");
        require(game.currentStage >= Stage.BettingTime, "Non è possibile effettuare questa operazione in questa fase di gioco.");
        return getGame();
    }

    function nextRound() public onlyPlayer atStage(Stage.RoundFinished) {
        _nextRound();
    }

    function newGame(uint8 _players, uint8 _rounds) public onlyOwner atStage(Stage.GameFinished) {
        require (_players >= 2 && _players <= 4);
        // cancella giocatori da lista attivi
        removePlayers();
        delete game;
        for (uint8 i = 0; i< numPlayers; i++) {
            game.inGame[i] = false;
        }
        initGame(_players, _rounds);
    }

    function withdraw() public onlyOwner {
        require(owner_reward > 0, "Non hai fiches da incassare.");
        uint amount = owner_reward;
        owner_reward = 0;
        owner_address.transfer(amount);
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == owner_address);
    }

    function isUser() public view returns (bool) {
        return (addressToUserID[msg.sender] != 0);
    }

    //-----------------------------------------------------------

    function getRandom(uint max) private returns (uint) {
        return unsafeRandom() % max;
    }

    //seed random basato su blockhash
    uint private seed = uint(blockhash(block.number-1)) % 1000;

    //valore random basato su seed
    function unsafeRandom() private returns (uint) {
        seed++;
        return uint(keccak256(abi.encodePacked(seed))) % 1000;
    }

}
