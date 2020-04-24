/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.5.1;

/**
 *	5 из 36
 */
 
contract Leto {
    
	// Мои тестовые адреса
	// 0xC58c7F39D439C463059457177cBF71210E8A7F80		- Для ДЖЕКПОТА

	// Юрины тестовые адреса
	// 0x5d4E9475b220817DA69C35c45e34FA28aF104bbd		- Для ДЖЕКПОТА

	// For safe math operations
    using SafeMath for uint;
    
    uint private constant DAY_IN_SECONDS = 86400;
	
	// Структура для хранения участников игры
	struct Member {
		address payable addr;						// Адрес участника
		uint ticket;								// Номер билета
		uint8[5] numbers;                           // Выбранные номера
		uint8 matchNumbers;                         // Количество совпавших номеров
		uint prize;                                 // Количество совпавших номеров
	}
	
	
	// Структура для хранения игры
	struct Game {
		uint datetime;								// Время игры
		uint8[5] win_numbers;						// Выигрышные номера
		uint membersCounter;						// Количество участников (для итерации)
		uint totalFund;                             // Фонд текущей игры
		uint8 status;                               // Статус игры: 0 - создана (розыгрыш не разрешён) , 1 - розыгрыш разрешён
		mapping(uint => Member) members;		    // Участники данной игры
	}
	
	mapping(uint => Game) public games;
	
	uint private CONTRACT_STARTED_DATE = 0;
	uint private constant TICKET_PRICE = 0.01 ether;
	uint private constant GAME_INTERVAL = 5 minutes;						// На продакшене 7 days
	uint private constant MAX_NUMBER = 36;						            // Максимально возможное число -> 36
	
	uint private constant PERCENT_FUND_JACKPOT = 15;                        // Процент в фонд ДЖЕКПОТА
	uint private constant PERCENT_FUND_4 = 35;                              // Процент в фонд 4 из 5
	uint private constant PERCENT_FUND_3 = 30;                              // Процент в фонд 3 из 5
    uint private constant PERCENT_FUND_2 = 20;                              // Процент в фонд 2 из 5
    
	uint public JACKPOT = 0;
	
	// Инициализация первой игры
	uint public GAME_NUM = 0;

	uint private constant return_jackpot_period = 1 days;					// На продакшене 6 months
	uint private start_jackpot_amount = 0;

	// Технические адреса ROPSTEN
	address payable private constant ADDRESS_START_JACKPOT = 0x2811C3c93DB7d388E81b9B12B42152ba1A8eCC9c;
	address payable private constant ADDRESS_SERVICE = 0x2811C3c93DB7d388E81b9B12B42152ba1A8eCC9c;
	address payable private constant ADDRESS_PR = 0x2811C3c93DB7d388E81b9B12B42152ba1A8eCC9c;
	
	address payable private constant ADDRESS_START_JACKPOT_A = 0x5d4E9475b220817DA69C35c45e34FA28aF104bbd;

	uint private constant PERCENT_FUND_PR = 12;                             // Процент в фонд рекламы
	uint private FUND_PR = 0;                                               // Наш фонд за текущую игру
	
	// FOR Javascript VM
	// address payable private constant ADDRESS_START_JACKPOT = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
	// address payable private constant ADDRESS_SERVICE = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
	// address payable private constant ADDRESS_PR = 0x583031D1113aD414F02576BD6afaBfb302140225;
	
	// События
	event NewMember(uint _gamenum, uint _ticket, address _addr, uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5, uint _fund);
	event NewGame(uint _gamenum);
	event UpdateFund(uint _fund);
	event UpdateJackpot(uint _jackpot);
	event WinNumbers(uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5);
	event WinPrize(uint _gamenum, uint _ticket, uint _prize);

	// Entry point
	function() external payable {
	    
        // В зависимости от адреса с которого пришло поступление выполняем нужные действия
		if(msg.sender == ADDRESS_START_JACKPOT || msg.sender == ADDRESS_START_JACKPOT_A) {
			processStartingJackpot();
		} else {
			if(msg.sender == ADDRESS_SERVICE) {
				startGame();
			} else {
				processUserTicket();
			}
		}

    }
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Функция обработки если сообщение пришло с адреса стартового джекпота
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processStartingJackpot() private {
		// Если больше нуля то увеличиваем стартовый джекпот
		if(msg.value > 0) {
			JACKPOT += msg.value;
			start_jackpot_amount += msg.value;
			emit UpdateJackpot(JACKPOT);
		// Если равно НУЛЮ то возвращаем стартовый джекпот
		} else {
			if(start_jackpot_amount > 0){
				_returnStartJackpot();
			}
		}
	}
	
	// Функция проверки и возврата вложенного джекпота
	function _returnStartJackpot() private { 
		
		if(JACKPOT > start_jackpot_amount * 2 || (now - CONTRACT_STARTED_DATE) > return_jackpot_period) {
			
			if(JACKPOT > start_jackpot_amount) {
				ADDRESS_START_JACKPOT.transfer(start_jackpot_amount);
				start_jackpot_amount = 0;
			} else {
				ADDRESS_START_JACKPOT.transfer(JACKPOT);
				start_jackpot_amount = 0;
				JACKPOT = 0;
			}
			emit UpdateJackpot(JACKPOT);
			
		} 
		
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Функция обработки если сообщение пришло с адреса управления розыгрышем
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function startGame() private {
	    
	    uint8 weekday = getWeekday(now);
		uint8 hour = getHour(now);
	    
		if(GAME_NUM == 0) {
		    GAME_NUM = 1;
		    games[GAME_NUM].datetime = now;
		    games[GAME_NUM].status = 1;
		    CONTRACT_STARTED_DATE = now;
		} else {
		    // На продакшене заменить на (РОЗЫГРЫШ В ВОСКРЕСЕНЬЕ С 12-00 до 13-00) учесть -3 часа!!!
		    // if(weekday == 7 && hour == 9)) ) {
		    // if((now - games[GAME_NUM].datetime) >= GAME_INTERVAL) {
		    
		    if(msg.value == 111) {
		        processGame();
		    }
		    
		    if(msg.value == 222) {
		        games[GAME_NUM].status = 1;
		    }

		    // }
		}

	}
	
	function processGame() private {
	    
	    uint8 mn = 0;
		uint winners5 = 0;
		uint winners4 = 0;
		uint winners3 = 0;
		uint winners2 = 0;

		uint fund4 = 0;
		uint fund3 = 0;
		uint fund2 = 0;
	    
	    // Генерируем выигрышные номера
	    for(uint8 i = 0; i < 5; i++) {
	        games[GAME_NUM].win_numbers[i] = random(i);
	    }

	    // Сортируем массив выигрышных номеров
	    games[GAME_NUM].win_numbers = sortNumbers(games[GAME_NUM].win_numbers);
	    
	    // Изменяем повторяющиеся номера
	    for(uint8 i = 0; i < 4; i++) {
	        for(uint8 j = i+1; j < 5; j++) {
	            if(games[GAME_NUM].win_numbers[i] == games[GAME_NUM].win_numbers[j]) {
	                games[GAME_NUM].win_numbers[j]++;
	            }
	        }
	    }
	    
	    uint8[5] memory win_numbers;
	    win_numbers = games[GAME_NUM].win_numbers;
	    emit WinNumbers(win_numbers[0], win_numbers[1], win_numbers[2], win_numbers[3], win_numbers[4]);
	    
	    if(games[GAME_NUM].membersCounter > 0) {
	    
	        // Перебираем участников игры и определяем количество совпавших номеров у каждого билета
	        for(uint i = 1; i <= games[GAME_NUM].membersCounter; i++) {
	            
	            mn = findMatch(games[GAME_NUM].win_numbers, games[GAME_NUM].members[i].numbers);
				games[GAME_NUM].members[i].matchNumbers = mn;
				
				if(mn == 5) {
					winners5++;
				}
				if(mn == 4) {
					winners4++;
				}
				if(mn == 3) {
					winners3++;
				}
				if(mn == 2) {
					winners2++;
				}
				
	        }
	        
	        // Высчитываем фонды
	        JACKPOT = JACKPOT + games[GAME_NUM].totalFund * PERCENT_FUND_JACKPOT / 100;
			fund4 = games[GAME_NUM].totalFund * PERCENT_FUND_4 / 100;
			fund3 = games[GAME_NUM].totalFund * PERCENT_FUND_3 / 100;
			fund2 = games[GAME_NUM].totalFund * PERCENT_FUND_2 / 100;
			
			// Невыигранные фонды пересылаем в джекпот
			if(winners4 == 0) {
			    JACKPOT = JACKPOT + fund4;
			}
			if(winners3 == 0) {
			    JACKPOT = JACKPOT + fund3;
			}
			if(winners2 == 0) {
			    JACKPOT = JACKPOT + fund2;
			}

			for(uint i = 1; i <= games[GAME_NUM].membersCounter; i++) {
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 5) {
			        games[GAME_NUM].members[i].prize = JACKPOT / winners5;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 4) {
			        games[GAME_NUM].members[i].prize = fund4 / winners4;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 3) {
			        games[GAME_NUM].members[i].prize = fund3 / winners3;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize);
			    }
			    
			    if(games[GAME_NUM].members[i].matchNumbers == 2) {
			        games[GAME_NUM].members[i].prize = fund2 / winners2;
			        games[GAME_NUM].members[i].addr.transfer(games[GAME_NUM].members[i].prize);
			        emit WinPrize(GAME_NUM, games[GAME_NUM].members[i].ticket, games[GAME_NUM].members[i].prize);
			    }
			    
			}
			
			// Если джекпот разыгран, обнуляем его 
			if(winners5 != 0) {
			    JACKPOT = 0;
			}
			
	    }
	    
	    emit UpdateJackpot(JACKPOT);
	    
	    // Инициализируем следующую игру
	    GAME_NUM++;
	    games[GAME_NUM].datetime = now;
	    games[GAME_NUM].status = 0;
	    emit NewGame(GAME_NUM);
	    
	    // Отправляем наш профит
	    ADDRESS_PR.transfer(FUND_PR);
	    FUND_PR = 0;

	}
	
	// Функция поиска совпавших номеров
	function findMatch(uint8[5] memory arr1, uint8[5] memory arr2) private pure returns (uint8) {
	    
	    uint8 cnt = 0;
	    
	    for(uint8 i = 0; i < 5; i++) {
	        for(uint8 j = 0; j < 5; j++) {
	            if(arr1[i] == arr2[j]) {
	                cnt++;
	                break;
	            }
	        }
	    }
	    
	    return cnt;

	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Функция обработки если сообщение пришло с адреса игрока - Ставка пользователя
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processUserTicket() private {
		
		uint8 weekday = getWeekday(now);
		uint8 hour = getHour(now);
		
		// Проверяем, что ещё не наступило время завершения принятия билетов, иначе возвращаем баланс
		
		// На продакшене заменить на (ЗАПРЕТ НА ИГРУ В ВОСКРЕСЕНЬЕ С 11-00 до 14-00) учесть -3 часа!!!
		// if( GAME_NUM > 0 && (weekday != 7 || (weekday == 7 && (hour < 8 || hour > 11 ))) ) {
		// if(((now - games[GAME_NUM].datetime) <= (GAME_INTERVAL - GAME_PAUSE)) && GAME_NUM > 0) {
		if(games[GAME_NUM].status == 1) {
		    if(msg.value == TICKET_PRICE) {
			    createTicket();
		    } else {
			    if(msg.value < TICKET_PRICE) {
				    FUND_PR = FUND_PR + msg.value.mul(PERCENT_FUND_PR).div(100);
				    games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + msg.value.mul(100 - PERCENT_FUND_PR).div(100);
				    emit UpdateFund(games[GAME_NUM].totalFund);
			    } else {
				    msg.sender.transfer(msg.value.sub(TICKET_PRICE));
				    createTicket();
			    }
		    }
		
		} else {
		     msg.sender.transfer(msg.value);
		}
		
	}
	function createTicket() private {
		
		bool err = false;
		uint8[5] memory numbers;
		
		// Распределяем фонды
		FUND_PR = FUND_PR + TICKET_PRICE.mul(PERCENT_FUND_PR).div(100);
		games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + TICKET_PRICE.mul(100 - PERCENT_FUND_PR).div(100);
		emit UpdateFund(games[GAME_NUM].totalFund);
		
		// Парсим и проверяем msg.DATA
		(err, numbers) = ParseCheckData();
		
		uint mbrCnt;

		// Если ошибок не было, то сортируем массив номеров и записываем пользователя
		if(!err) {
		    numbers = sortNumbers(numbers);

		    // Увеличиваем счётчик игроков
		    games[GAME_NUM].membersCounter++;
		    mbrCnt = games[GAME_NUM].membersCounter;

		    // Сохраняем игрока
		    games[GAME_NUM].members[mbrCnt].addr = msg.sender;
		    games[GAME_NUM].members[mbrCnt].ticket = mbrCnt;
		    games[GAME_NUM].members[mbrCnt].numbers = numbers;
		    games[GAME_NUM].members[mbrCnt].matchNumbers = 0;
		    
		    emit NewMember(GAME_NUM, mbrCnt, msg.sender, numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], FUND_PR);
		    
		}

	}
	
	
	// Функция парсинга и проверки msg.DATA
	function ParseCheckData() private view returns (bool, uint8[5] memory) {
	    
	    bool err = false;
	    uint8[5] memory numbers;
	    
	    // Проверяем чтоб было задано 5 цифр
	    if(msg.data.length == 5) {
	        
	        // Парсим строку DATA
		    for(uint8 i = 0; i < msg.data.length; i++) {
		        numbers[i] = uint8(msg.data[i]);
		    }
		    
		    // Проверяем числа на диапазон 1 - MAX_NUMBER
		    for(uint8 i = 0; i < numbers.length; i++) {
		        if(numbers[i] < 1 || numbers[i] > MAX_NUMBER) {
		            err = true;
		            break;
		        }
		    }
		    
		    // Проверяем числа на повторение
		    if(!err) {
		    
		        for(uint8 i = 0; i < numbers.length-1; i++) {
		            for(uint8 j = i+1; j < numbers.length; j++) {
		                if(numbers[i] == numbers[j]) {
		                    err = true;
		                    break;
		                }
		            }
		            if(err) {
		                break;
		            }
		        }
		        
		    }
		    
	    } else {
	        err = true;
	    }

	    return (err, numbers);

	}
	
	// Функция сортировки массива чисел
	function sortNumbers(uint8[5] memory arrNumbers) private pure returns (uint8[5] memory) {
	    
	    uint8 temp;
	    
	    for(uint8 i = 0; i < arrNumbers.length - 1; i++) {
            for(uint j = 0; j < arrNumbers.length - i - 1; j++)
                if (arrNumbers[j] > arrNumbers[j + 1]) {
                    temp = arrNumbers[j];
                    arrNumbers[j] = arrNumbers[j + 1];
                    arrNumbers[j + 1] = temp;
                }    
	    }
        
        return arrNumbers;
        
	}
	
	// Для теста, потом можно убрать
    function getBalance() public view returns(uint) {
        uint balance = address(this).balance;
		return balance;
	}
	
	// Функция генерации случайного числа
	function random(uint8 num) internal view returns (uint8) {
	    
        return uint8(uint(blockhash(block.number - 1 - num*2)) % MAX_NUMBER + 1);
        
    } 
    
     // Функция получения текущего часа (возвращаем на 3 часа меньше мск)
    function getHour(uint timestamp) private pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }
    
    // Функция получения текущего дня недели
    function getWeekday(uint timestamp) private pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }
	
	
	// API
	
	// i - Номер игры
	function getGameInfo(uint i) public view returns (uint, uint, uint, uint8, uint8, uint8, uint8, uint8, uint8) {
	    Game memory game = games[i];
	    return (game.datetime, game.totalFund, game.membersCounter, game.win_numbers[0], game.win_numbers[1], game.win_numbers[2], game.win_numbers[3], game.win_numbers[4], game.status);
	}
	
	// i - Номер игры, j - Номер участника
	function getMemberInfo(uint i, uint j) public view returns (address, uint, uint8, uint8, uint8, uint8, uint8, uint8) {
	    Member memory mbr = games[i].members[j];
	    return (mbr.addr, mbr.ticket, mbr.matchNumbers, mbr.numbers[0], mbr.numbers[1], mbr.numbers[2], mbr.numbers[3], mbr.numbers[4]);
	}

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
