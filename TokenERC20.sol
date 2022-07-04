pragma solidity 0.8.13;

contract BaseToken {
    string public nome;
    string public simbolo;
    string decimais;
    uint256 total;
    mapping(address => uint256) saldos;
    mapping(address => mapping(address => uint256)) permitidos;

    event Transferencia(address origem, address destino, uint256 tokens);
    event Aprovacao(address dono, address aprovado, uint256 tokens);

    using Math for uint256;

    constructor(
        string memory _nome,
        string memory _simbolo,
        string memory _decimais,
        uint256 _total
    ) {
        nome = _nome;
        simbolo = _simbolo;
        decimais = _decimais;
        total = _total;
        saldos[msg.sender] = total;
    }

    function verificarTotalTokens() public view returns (uint256) {
        return total;
    }

    function verificarSaldo(address _dono) public view returns (uint256) {
        return saldos[_dono];
    }

    function aprovar(address _aprovado, uint256 _tokens) public returns (bool) {
        permitidos[msg.sender][_aprovado] = _tokens;

        emit Aprovacao(msg.sender, _aprovado, _tokens);

        return true;
    }

    function quantidadePermitida(address _dono, address _permitido)
        public
        view
        returns (uint256)
    {
        return permitidos[_dono][_permitido];
    }

    function transferirPorCorretor(
        address _dono,
        address _comprador,
        uint256 _numTokens
    ) public returns (bool) {
        require(_numTokens <= saldos[_dono]);
        require(_numTokens <= permitidos[_dono][msg.sender]);

        saldos[_dono] = saldos[_dono].sub(_numTokens);
        permitidos[_dono][msg.sender] = permitidos[_dono][msg.sender].sub(
            _numTokens
        );
        saldos[_comprador] = saldos[_comprador].add(_numTokens);

        emit Transferencia(_dono, _comprador, _numTokens);

        return true;
    }

    function transferir(address _destino, uint256 _numTokens)
        public
        returns (bool)
    {
        require(_numTokens <= saldos[msg.sender]);
        saldos[msg.sender] = saldos[msg.sender].sub(_numTokens);
        saldos[_destino] = saldos[_destino].add(_numTokens);

        emit Transferencia(msg.sender, _destino, _numTokens);

        return true;
    }
}

library Math {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
