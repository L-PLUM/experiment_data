/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.0;

contract Repartelo {
    
    address[] public nOmina;
    address public Jefe;
    uint public TotalFacturado;
    bool public Bandera;
    bool public Penalty;
    uint public Referencia;
    event Depositaron (bool);
    
    constructor () payable {
        nOmina = [0xA64A9275b64676466bb76fa51E3f1ab276535D19, 0x2E9dD190177FE18Fc0195449e956C7C720C90B1f, 0x64424D2a8CE4fe420EebAD8CaB039E3568aC15AF, 0x0A9a5355EC8d316616b167E132419e9811beA5D1];
        Jefe = msg.sender;
        TotalFacturado = 0;
        Bandera = false;
        Penalty = false;
        Referencia = now;
        TotalFacturado += msg.value;
        
    }
    
    function () payable public {
        TotalFacturado += msg.value;
    }
    
    function Pertenece(address _x) internal returns (bool) {
        bool esEmpleado = false;
        for(uint i = 0; i < nOmina.length; i++) {
            if (nOmina[i] == _x) {
                esEmpleado = true;
            }
        }
        return esEmpleado;
    }
    
    function PagarNomina() public returns (uint) {
 
        uint A = ((now - Referencia)/420) % 7;
        require (A < 2);
        uint B;

        if (Penalty) {
            B = 35;
        } else {
            B = 40;
        }
        
        if (!Bandera && A == 0 &&
        (msg.sender == Jefe)) {
            uint k = B*TotalFacturado/100;
            Jefe.transfer(k);
            TotalFacturado -= k;
            k = TotalFacturado/nOmina.length;
            for (uint i=0; i < nOmina.length; i++) {
                nOmina[i].transfer(k);
                TotalFacturado -= k;
            }
            Bandera = true;
            Penalty = false;
            
        } else if (!Bandera && A == 1 &&
        (Pertenece(msg.sender))) {
            k = (B-5)*TotalFacturado/100;
            Jefe.transfer(k);
            uint h = 2*TotalFacturado/100;
            msg.sender.transfer(h);
            TotalFacturado -= (k+h);
            k = TotalFacturado/nOmina.length;
            for (uint j=0; j < nOmina.length; j++) {
                nOmina[j].transfer(k);
                TotalFacturado -= k;
            }
            Bandera = true;
            Penalty = false;
        }
        emit Depositaron (Bandera);
    }
    

    function BanderaAbajo() public {

        uint A = ((now - Referencia)/420) % 7;
        require (A >= 2 && A <= 6);
        if (Bandera && A > 1 && A <= 5 &&
        (msg.sender == Jefe)) {
            Bandera = false;
            Penalty =  false;
        } else if (Bandera && A == 6 &&
        (Pertenece(msg.sender))) {
            uint k = 2*TotalFacturado/100;
            msg.sender.transfer(k);
            Bandera = false;
            Penalty = true;
        }
    }
    
    function Despido(address Botado) public returns (address[]) {
        uint A = ((now - Referencia)/420) % 7;
        require(msg.sender == Jefe && Pertenece(Botado), "si no es empleado no lo puedes botar");
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
        } return nOmina; 
    }
    
    function Hire(address Nuevo) public returns (address[]) {
        uint A = ((now - Referencia)/420) % 7;
        if(msg.sender == Jefe) {
            nOmina.push(Nuevo);
        }
       return nOmina; 
    }
    

    function PagosGastos(address pRoveedor, uint mOnto) public {
        require(mOnto < TotalFacturado);
        if (msg.sender == Jefe) {
        pRoveedor.transfer(mOnto);
        TotalFacturado -= mOnto;
        }
    }
    
}
