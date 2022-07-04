pragma solidity 0.8.13;

contract CustodiaValores {
    mapping(address => mapping(address => Custodia)) custodias;
    address payable dono;

    struct Custodia {
        address solicitanteCustodia;
        address arbitroCustodia;
        address participanteCustodia;
        uint256 valorCustodia;
        uint256 comissaoArbitro;
        uint256 comissaoContrato;
        bool andamentoCustodia;
    }

    event NovaCustodia(
        address solicitante,
        address arbitro,
        address participante,
        uint256 valor,
        uint256 comissaoArbitro,
        uint256 comissaoContrato
    );

    event Pagamento(
        address recebedor,
        uint256 valor,
        address arbitro,
        uint256 comissaoArbitro,
        uint256 comissaoContrato
    );

    event Devolucao(
        address recebedor,
        uint256 valor,
        address arbitro,
        uint256 comissaoArbitro,
        uint256 comissaoContrato
    );

    modifier valorMinimo() {
        require(msg.value >= 2 ether, "Valor minimo nao atingido!");
        _;
    }

    constructor() {
        dono = payable(msg.sender);
    }

    function iniciarCustodia(
        address payable novoArbitro,
        address payable novoParticipante,
        uint256 porcentagemArbitro
    ) public payable valorMinimo {
        require(
            !custodias[msg.sender][novoParticipante].andamentoCustodia,
            "Custodia em andamento."
        );
        require(
            porcentagemArbitro <= 98,
            "Ha uma comissao de 1% para o contrato."
        );

        Custodia storage novaCust = custodias[msg.sender][novoParticipante];
        novaCust.andamentoCustodia = true;
        novaCust.comissaoArbitro = (porcentagemArbitro * msg.value) / 100;
        novaCust.comissaoContrato = msg.value / 100;
        novaCust.valorCustodia =
            msg.value -
            novaCust.comissaoArbitro -
            novaCust.comissaoContrato;
        novaCust.solicitanteCustodia = payable(msg.sender);
        novaCust.arbitroCustodia = novoArbitro;
        novaCust.participanteCustodia = novoParticipante;

        emit NovaCustodia(
            msg.sender,
            novaCust.arbitroCustodia,
            novaCust.participanteCustodia,
            msg.value,
            novaCust.comissaoArbitro,
            novaCust.comissaoContrato
        );
    }

    function pagar(address payable _solicitante, address payable _participante)
        public
    {
        require(
            msg.sender ==
                custodias[_solicitante][_participante].arbitroCustodia,
            "Apenas o arbitro."
        );
        _participante.transfer(
            custodias[_solicitante][_participante].valorCustodia
        );
        payable(msg.sender).transfer(
            custodias[_solicitante][_participante].comissaoArbitro
        );
        dono.transfer(custodias[_solicitante][_participante].comissaoContrato);
        resetCustodia(_solicitante, _participante);

        emit Pagamento(
            _participante,
            custodias[_solicitante][_participante].valorCustodia,
            msg.sender,
            custodias[_solicitante][_participante].comissaoArbitro,
            custodias[_solicitante][_participante].comissaoContrato
        );
    }

    function devolver(
        address payable _solicitante,
        address payable _participante
    ) public {
        require(
            msg.sender ==
                custodias[_solicitante][_participante].arbitroCustodia,
            "Apenas o arbitro."
        );

        _solicitante.transfer(
            custodias[_solicitante][_participante].valorCustodia
        );
        payable(msg.sender).transfer(
            custodias[_solicitante][_participante].comissaoArbitro
        );
        dono.transfer(custodias[_solicitante][_participante].comissaoContrato);
        resetCustodia(_solicitante, _participante);

        emit Devolucao(
            _solicitante,
            custodias[_solicitante][_participante].valorCustodia,
            msg.sender,
            custodias[_solicitante][_participante].comissaoArbitro,
            custodias[_solicitante][_participante].comissaoContrato
        );
    }

    function resetCustodia(
        address payable _solicitante,
        address payable _participante
    ) private {
        custodias[_solicitante][_participante].andamentoCustodia = false;
        custodias[_solicitante][_participante].comissaoArbitro = 0;
        custodias[_solicitante][_participante].comissaoContrato = 0;
        custodias[_solicitante][_participante].valorCustodia = 0;
        custodias[_solicitante][_participante].solicitanteCustodia = payable(
            address(0)
        );
        custodias[_solicitante][_participante].arbitroCustodia = payable(
            address(0)
        );
        custodias[_solicitante][_participante].participanteCustodia = payable(
            address(0)
        );
    }
}
