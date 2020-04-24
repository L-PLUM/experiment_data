/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.4.24;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		// Optimización del gas: esto es más barato que afirmar que 'a' no es cero, pero el
		// el beneficio se pierde si también se prueba 'b'.
		// Ver: https://github.com/OpenZeppelin/openzeppelin-Solidity/pull/522
		if (a == 0) {
			return 0;
		}
		c = a * b;  
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity lo lanza automáticamente al dividir por 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // No hay ningún caso en el que esto no se cumpla.
		return a / b;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

contract HHOtokenprueba4{
	// importar libreria safeMath para calculos matematicos
	using SafeMath for uint256;
	// variables
	bool public icoCompleted;
	string public symbol;
    string public  name;
    uint256 public decimals;
    uint256 public total_Supply; // total de token a vender
    address public owner;
    uint256 public ICOStartTime; // fecha hora inicio ito
	uint256 public ICOEndTime; // fecha hora fin ito
	uint256 public tarifaEtapaUno; // cantidad de token a entregar por 1 ETH
	address public crowdsaleAddress;  // direccion contrato venta token publico
    uint256 public tokensRaised; // cantidad de token comprados
	uint256 public etherRaised; // cantidad de ether recibido por compra de token

	// eventos
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
	
	mapping(address => uint) balances;
    mapping(address => mapping (address => uint256)) internal allowed;

    // modificadores
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCrowdsale {
		require(msg.sender == crowdsaleAddress);
		_;
	}

    modifier whenIcoCompleted {
		require(icoCompleted);
		_;
	}

    modifier afterCrowdsale {
		require(now > ICOEndTime || tokensRaised >= total_Supply);
		_;
	}

	// constructor
	constructor() public {
		symbol = "hhopr4";
        name = "hhoprueba4 Token";
        decimals = 18;
        total_Supply = 1000000000000000000000000;
		ICOStartTime = now;
		ICOEndTime = now + 1 hours;
		//tokenAddress = 0x2250F671Fc7f2642f40114Ae86C9fb424b20f8EE;
		tarifaEtapaUno = 5000;
		balances[msg.sender] = total_Supply;
		emit Transfer(address(0), msg.sender, total_Supply);
		owner = msg.sender;
		crowdsaleAddress = msg.sender;
	}

    // Funciones metodos
    /*function setCrowdsale(address _crowdsaleAddress) public onlyOwner {
		require(_crowdsaleAddress != address(0));
		crowdsaleAddress = _crowdsaleAddress;
	}*/
	
    function () public payable {
    	comprar();
	}
	// funcion para compra token
	function buyTokens(address _receiver, uint256 _amount) public onlyCrowdsale {
		require(_receiver != address(0));
		require(_amount > 0);
		transfer(_receiver, _amount);
	}
	// funcion para obtener total token
	function totalSupply() public view returns (uint256) {
		return total_Supply;
	}

	// funcion para obtener saldo de la cuenta del propietario
	function balanceOf(address tokenOwner) public view returns (uint256) {
		return balances[tokenOwner];
	}

	// funcion para tranferir token desde cuenta del propietario a cuenta comprador
	function transfer(address _to, uint tokens) public returns (bool success) {
		require(tokens <= balances[msg.sender]);
		require(_to != address(0));
		balances[msg.sender] = balances[msg.sender].sub(tokens);
		balances[_to] = balances[_to].add(tokens);
		emit Transfer(msg.sender, _to, tokens); // llamada a evento
		return true;
	}

	// tranferir token desde una cuenta a otra
	function transferFrom(address _from, address _to, uint tokens) public afterCrowdsale returns (bool success) {
		require(tokens <= balances[_from]);
		require(tokens <= allowed[_from][msg.sender]);
		require(_to != address(0));

		balances[_from] = balances[_from].sub(tokens);
		balances[_to] = balances[_to].add(tokens);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(tokens);
		emit Transfer(_from, _to, tokens);
		return true;
	}

	// aprobar transferencia de token
	function approve(address _spender, uint _tokens) public afterCrowdsale returns (bool success) {
		allowed[msg.sender][_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	// cantidad de token aprovados por el propietario que pueden ser tranferidos a la cuenta del comprador
	function allowance(address tokenOwner, address spender) public view returns (uint256) {
		return allowed[tokenOwner][spender];
	}

	function emergencyExtract() external onlyOwner {
		owner.transfer(address(this).balance);
	}

	// funcion para calcular cantidad de token a entregar para la etapa segun cantidad eth recibido
	function calcularTokensEtapa(uint256 weiPaid) internal view returns(uint256 calculatedTokens){
		require(weiPaid > 0);
		calculatedTokens = weiPaid * (10 ** decimals) / 1 ether * tarifaEtapaUno;
	}

	// funcion para compra de token
	function comprar() public payable {
		require(tokensRaised < total_Supply);
		require(now < ICOEndTime && now > ICOStartTime);
		uint256 tokensToBuy;
		uint256 etherUsed = msg.value;
		tokensToBuy = calcularTokensEtapa(etherUsed);

		// Compruebe si hemos alcanzado y superado el objetivo de financiación para reembolsar los tokens y el ether excedentes
		if(tokensRaised + tokensToBuy > total_Supply) {
			uint256 exceedingTokens = tokensRaised + tokensToBuy - total_Supply;
			uint256 exceedingEther;
			// Convierte los excedentes a ether y devuelve ese ether
			exceedingEther = exceedingTokens * 1 ether / tarifaEtapaUno / decimals;
			msg.sender.transfer(exceedingEther);
			// Cambiar los tokens para comprar al nuevo número
			tokensToBuy -= exceedingTokens;
			// Actualizar el contador de éter usado.
			etherUsed -= exceedingEther;
		}

		// Enviar las fichas al comprador.
		buyTokens(msg.sender, tokensToBuy);
		tokensRaised += tokensToBuy;
		etherRaised += etherUsed;
	}

	// extraer el eth cuando ico este terminada
	function extractEther() public whenIcoCompleted onlyOwner {
		owner.transfer(address(this).balance);
	}

}
