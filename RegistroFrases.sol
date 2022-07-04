pragma solidity 0.8.13;

contract Registro {
    string[] private frases;
    address public dono;
    uint256 private contador;
    mapping(address => bool) public autorizados;

    modifier apenasAutorizados() {
        require(
            msg.sender == dono || autorizados[msg.sender],
            "Voce nao tem autorizacao!"
        );
        _;
    }

    event FraseRemovida(
        uint256 _indice,
        string _fraseRemovida,
        string _confirmacao
    );

    event EnderecoAutorizado(address _autorizado, bool _autorizacao);

    constructor() {
        dono = msg.sender;
        contador = 0;
    }

    function autorizarEndereco(address _autorizado) public {
        require(msg.sender == dono, "Voce nao e o dono!");

        autorizados[_autorizado] = true;

        emit EnderecoAutorizado(_autorizado, autorizados[_autorizado]);
    }

    function adicionarFrase(string memory frase)
        public
        apenasAutorizados
        returns (uint256)
    {
        frases.push(frase);
        contador++;
        return contador;
    }

    function removerFrase(uint256 _indice) public apenasAutorizados {
        string memory auxiliar = frases[_indice - 1];
        delete frases[_indice - 1];
        frases[_indice - 1] = "Essa frase foi removida!";

        emit FraseRemovida(_indice, auxiliar, frases[_indice - 1]);
    }

    function totalFrases() public view returns (uint256) {
        return frases.length;
    }

    function obterFrase(uint256 _indice) public view returns (string memory) {
        require(contador != 0, "Sem ideias no momento!");

        if (_indice > contador) {
            _indice = contador;
        }

        return frases[_indice - 1];
    }
}
