import 'package:flutter/material.dart';
import 'package:flutter_geolocalizacao/helpers/geralHelper.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:flutter_geolocalizacao/views/widget/carregandoWidget.dart';

class DistanciaEntrePosicoesView extends StatefulWidget {
  @override
  _DistanciaEntrePosicoesViewState createState() => _DistanciaEntrePosicoesViewState();
}

class _DistanciaEntrePosicoesViewState extends State<DistanciaEntrePosicoesView> {
  bool carregando = false;

  static double _latitudeInicialDefault = -22.759162;
  static double _longitudeInicialDefault = -47.325246;
  static double _latitudeFinalDefault = -23.512814;
  static double _longitudeFinalDefault = -46.696745;

  final TextEditingController _controladorLatitudeInicial = TextEditingController();
  final TextEditingController _controladorLongitudeInicial = TextEditingController();
  final TextEditingController _controladorLatitudeFinal = TextEditingController();
  final TextEditingController _controladorLongitudeFinal = TextEditingController();
  String nomeLocalizacaoInicial;
  String nomeLocalizacaoFinal;
  double resultadoDistanciaMetros;

  @override
  void initState() {
    super.initState();
    _controladorLatitudeInicial.text = _latitudeInicialDefault.toString();
    _controladorLongitudeInicial.text = _longitudeInicialDefault.toString();
    _controladorLatitudeFinal.text = _latitudeFinalDefault.toString();
    _controladorLongitudeFinal.text = _longitudeFinalDefault.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Distância entre localizações", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ListView(
            children: <Widget>[
              _constroiBlocoInput("Origem:", _controladorLatitudeInicial, _controladorLongitudeInicial, nomeLocalizacao: nomeLocalizacaoInicial),
              SizedBox(height: 20),
              _constroiBlocoInput("Destino:", _controladorLatitudeFinal, _controladorLongitudeFinal, nomeLocalizacao: nomeLocalizacaoFinal),
              RaisedButton(child: Text("Calcular distância", style: TextStyle(color: Colors.white)), color: Colors.blueGrey, onPressed: carregando ? null : () => _calcularDistancia()),
              carregando ? carregandoWidget(height: 40, width: 40) : _constroiResultado(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _constroiBlocoInput(String titulo, TextEditingController controladorLatitude, TextEditingController controladorLongitude, {String nomeLocalizacao}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(titulo, style: TextStyle(color: Colors.blueGrey)),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Text("Latitude:    ", style: TextStyle()),
                SizedBox(width: 8),
                Container(
                  width: 120,
                  child: TextField(
                    controller: controladorLatitude,
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(counter: Text("")),
                  ),
                ),
              ]),
              Row(children: <Widget>[
                Text("Longitude: ", style: TextStyle()),
                SizedBox(width: 8),
                Container(
                  width: 120,
                  child: TextField(
                    controller: controladorLongitude,
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(counter: Text("")),
                  ),
                ),
              ]),
              Text(nomeLocalizacao ?? "", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Future _calcularDistancia() async {
    setState(() {
      carregando = true;
      nomeLocalizacaoInicial = null;
      nomeLocalizacaoFinal = null;
      resultadoDistanciaMetros = null;
    });

    bool converteuParaDouble = true;
    double latitudeInicialDigitada;
    double longitudeInicialDigitada;
    double latitudeFinalDigitada;
    double longitudeFinalDigitada;
    try {
      latitudeInicialDigitada = double.parse(_controladorLatitudeInicial.text);
      longitudeInicialDigitada = double.parse(_controladorLongitudeInicial.text);
      latitudeFinalDigitada = double.parse(_controladorLatitudeFinal.text);
      longitudeFinalDigitada = double.parse(_controladorLongitudeFinal.text);
    } catch (e) {
      converteuParaDouble = false;
    }

    if (converteuParaDouble) {
      GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
      resultadoDistanciaMetros = await geolocalizacaoHelper.calcularDistanciaEntreCoordenadas(latitudeInicialDigitada, longitudeInicialDigitada, latitudeFinalDigitada, longitudeFinalDigitada);

      retornaNomeLocalizacao(latitudeInicialDigitada, longitudeInicialDigitada).then((nomeLocalizacao) => setState(() => nomeLocalizacaoInicial = nomeLocalizacao));
      retornaNomeLocalizacao(latitudeFinalDigitada, longitudeFinalDigitada).then((nomeLocalizacao) => setState(() => nomeLocalizacaoFinal = nomeLocalizacao));
    } else
      await GeralHelper.instancia.exibirMensagem(context, "Atenção", "Informe os campos latitude e longitude no formato correto.\nObs: O separador deve ser '.' e não ',' ");

    setState(() => carregando = false);
  }

  Widget _constroiResultado() {
    var resultadoEmKm = (resultadoDistanciaMetros ?? 0) / 1000;
    String resultadoFormatado = resultadoEmKm.truncate() > 0 ? "${(resultadoEmKm?.truncate() ?? 0)} km" : "${(resultadoDistanciaMetros?.truncate() ?? 0)} metros";

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 20),
      child: Text(
        resultadoFormatado,
        //"${resultadoDistanciaMetros?.toStringAsFixed(0) ?? "0"} metros",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
    );
  }

  Future<String> retornaNomeLocalizacao(double latitude, double longitude) async {
    GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
    var listaLocalizacoesEncontradas = await geolocalizacaoHelper.recuperarLocalizacaoDeUmaPosicao(latitude, longitude);
    if ((listaLocalizacoesEncontradas?.length ?? 0) > 0) {
      return geolocalizacaoHelper.retornaNomeLocalizacao(listaLocalizacoesEncontradas[0]);
    } else
      return "";
  }
}
