pragma solidity 0.8.13;

contract RegistroDocumentos {
    mapping(uint256 => Documento) public documentos;
    mapping(address => uint256) public saldoRecebido;
    uint256 contador;
    address payable dono;
    bool private pause;

    struct Documento {
        uint256 numDoc;
        bytes32 hashDoc;
        address proprietarioDoc;
    }

    modifier apenasDono() {
        require(msg.sender == dono, "Apenas o dono!");
        _;
    }

    modifier ativarRegistro() {
        require(pause == false, "O registro esta pausado!");
        _;
    }

    event DocumentoCriado(
        uint256 numDoc,
        bytes32 hashDoc,
        address proprietarioDoc
    );

    event ComprovanteDeposito(uint256 valor, address depositante);

    constructor() {
        dono = payable(msg.sender);
        contador = 1;
        pause = false;
    }

    function depositar() public payable {
        require(msg.value >= 1 gwei, "Deposite, no minimo, 1 gwei.");
        saldoRecebido[msg.sender] += msg.value;

        emit ComprovanteDeposito(msg.value, msg.sender);
    }

    function _descontarSaldo() private {
        require(saldoRecebido[msg.sender] >= 1 gwei, "Saldo insuficiente!");
        uint256 saldoAnterior = saldoRecebido[msg.sender];
        saldoRecebido[msg.sender] = saldoAnterior - 1 gwei;
        dono.transfer(1 gwei);
    }

    function registrarDocumentos(bytes32 _hashDocumento) public ativarRegistro {
        _descontarSaldo();
        Documento storage novoDoc = documentos[contador];
        novoDoc.numDoc = contador;
        novoDoc.hashDoc = _hashDocumento;
        novoDoc.proprietarioDoc = msg.sender;
        contador++;

        emit DocumentoCriado(
            novoDoc.numDoc,
            novoDoc.hashDoc,
            novoDoc.proprietarioDoc
        );
    }

    function verificarDocumento(uint256 _numDocumento) public returns (bool) {
        _descontarSaldo();
        return documentos[_numDocumento].numDoc != 0;
    }

    function descobrirQuemRegistrou(uint256 _numDocumento)
        public
        returns (address)
    {
        _descontarSaldo();
        return documentos[_numDocumento].proprietarioDoc;
    }

    function pausar() public apenasDono returns (bool) {
        require(pause == false, "O resgisto de documentos ja esta pausado!");
        pause = true;
        return pause;
    }

    function reativar() public apenasDono returns (bool) {
        require(pause == true, "O registro de documentos ja esta ativo!");
        pause = false;
        return pause;
    }
}
