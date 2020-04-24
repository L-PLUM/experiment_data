/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.0;

contract PagoNomina {
    
    address[] public nOmina;
    address public Jefe;
    bool public Bandera;
    bool public Penalty;
    uint public Referencia;
    mapping (uint => string) public Semana;
    uint constant Xtn = 180;
    
    function HoyEs() public constant returns (string) {
        uint _x = ((now - Referencia)/Xtn) % 7;
        return Semana[_x];
    }

    constructor () payable {
        nOmina = [0xA64A9275b64676466bb76fa51E3f1ab276535D19, 0x2E9dD190177FE18Fc0195449e956C7C720C90B1f, 0x64424D2a8CE4fe420EebAD8CaB039E3568aC15AF, 0x0A9a5355EC8d316616b167E132419e9811beA5D1];
        Jefe = msg.sender;
        Bandera = false;
        Penalty = false;
        Referencia = now;
        Semana[0] = "lunes";
        Semana[1] = "martes";
        Semana[2] = "miercoles";
        Semana[3] = "jueves";
        Semana[4] = "viernes";
        Semana[5] = "sabado";
        Semana[6] = "domingo";

    }
    
    function () payable {

    }

    function Pertenece(address _x) internal constant returns (bool) {
        bool esEmpleado = false;
        for(uint i = 0; i < nOmina.length; i++) {
            if (nOmina[i] == _x) {
                esEmpleado = true;
            }
        }
        return esEmpleado;
    }
    
    function PagarNomina() public {
        
        uint A = ((now - Referencia)/Xtn) % 7;
        require (A < 2);
        uint B;

        if (Penalty) {
            B = 35;
        } else {
            B = 40;
        }
        uint C = address(this).balance;
        if (A == 0) {
            require(msg.sender == Jefe && !Bandera);
            uint k = B*C/100;
            Jefe.transfer(k);
            C -= k;
            k = C/nOmina.length;
            for (uint i=0; i < nOmina.length; i++) {
                nOmina[i].transfer(k);
            }
            Bandera = true;
            Penalty = false;
        } else if (A == 1) {
            require(Pertenece(msg.sender) && !Bandera);
            k = (B-5)*C/100;
            Jefe.transfer(k);
            uint h = 2*C/100;
            msg.sender.transfer(h);
            C -= (k+h);
            k = C/nOmina.length;
            for (uint j=0; j < nOmina.length; j++) {
                nOmina[j].transfer(k);
            }
            Bandera = true;
            Penalty = false;
        }
    }

    function BanderaAbajo() public {
        uint A = ((now - Referencia)/Xtn) % 7;
        require (A >= 2 && A <= 6);
        uint C = address(this).balance;
        if (A > 1 && A <= 5) {
            require(msg.sender == Jefe && Bandera);
            Bandera = false;
            Penalty =  false;
        } else if (A == 6) {
            require(Pertenece(msg.sender) && Bandera);
            uint k = 2*C/100;
            msg.sender.transfer(k);
            Bandera = false;
            Penalty = true;
        }
    }
    
    function Despido(address Botado) public {
        require(msg.sender == Jefe && Pertenece(Botado));
        for (uint i = 0; i < nOmina.length; i++) {
            if (nOmina[i] == Botado && i < nOmina.length-1) {
                for (uint j = i; j < nOmina.length-1; j++) {
                    nOmina[j] = nOmina[j+1];

                } 
                delete nOmina[nOmina.length-1];
                nOmina.length--;

            } else if (nOmina[i] == Botado && i == nOmina.length-1) {
                delete nOmina[nOmina.length-1];
                nOmina.length--;

                } 
        } 
    }
    
    function Hire(address Nuevo) public {
        require(msg.sender == Jefe && !Pertenece(Nuevo));
            nOmina.push(Nuevo);
            nOmina.length++;
    }
    

    function PagosGastos(address pRoveedor, uint mOnto) public {
        require(msg.sender == Jefe && mOnto < address(this).balance);
        pRoveedor.transfer(mOnto);
    }
    
}
