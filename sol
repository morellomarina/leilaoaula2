contract Leilao {

    struct Ofertante {
        string nome;
        address payable enderecoCarteira;
        uint oferta;
        bool jaFoiReembolsado;
    }

    address payable public contaGovernamental;
    uint public prazoFinalLeilao;

    address public maiorOfertante;
    uint public maiorLance;

    mapping(address => uint) public lancesRealizados;
    mapping(address => Ofertante) public listaOfertantes;
    Ofertante[] public ofertantes;

    bool public encerrado;

@@ -29,25 +37,38 @@ contract Leilao {
    }


    function lance() public payable {

        require(
            now <= prazoFinalLeilao,
            "Leilao encerrado."
        );

        require(
            msg.value > maiorLance,
            "Ja foram apresentados lances maiores."
        );
    function lance(string memory nomeLeiloeiro, address payable enderecoCarteiraLeiloeiro) public payable {
        require(now <= prazoFinalLeilao, "Leilao encerrado.");
        require(msg.value > maiorLance, "Ja foram apresentados lances maiores.");

        maiorOfertante = msg.sender;
        maiorLance = msg.value;

        if (maiorLance != 0) {
            lancesRealizados[maiorOfertante] = maiorLance;

        //Realizo estorno das ofertas aos perdedores
        /*
        For é composto por 3 parametros (separados por ponto virgula)
            1o  é o inicializador do indice
            2o  é a condição que será checada para saber se o continua 
                o loop ou não 
            3o  é o incrementador (ou decrementador) do indice
        */
        for (uint i=0; i<ofertantes.length; i++) {
            Ofertante memory leiloeiroPerdedor = ofertantes[i];
            if (!leiloeiroPerdedor.jaFoiReembolsado) {
                leiloeiroPerdedor.enderecoCarteira.transfer(leiloeiroPerdedor.oferta);
                leiloeiroPerdedor.jaFoiReembolsado = true;
            }
        }

        //Crio o ofertante
        Ofertante memory concorrenteVencedorTemporario = Ofertante(nomeLeiloeiro, enderecoCarteiraLeiloeiro, msg.value, false);

        //Adiciono o novo concorrente vencedor temporario no array de ofertantes
        ofertantes.push(concorrenteVencedorTemporario);

        //Adiciono o novo concorrente vencedor temporario na lista (mapa) de ofertantes
        listaOfertantes[concorrenteVencedorTemporario.enderecoCarteira] = concorrenteVencedorTemporario;

        emit novoMaiorLance (msg.sender, msg.value);
    }
