import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geolocalizacao/helpers/geralHelper.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:flutter_geolocalizacao/views/widget/carregandoWidget.dart';

class ConverterPosicaoELocalizacaoView extends StatefulWidget {
  @override
  _ConverterPosicaoELocalizacaoViewState createState() => _ConverterPosicaoELocalizacaoViewState();
}

class _ConverterPosicaoELocalizacaoViewState extends State<ConverterPosicaoELocalizacaoView> {
  bool carregando = false;
  static double _latitudeDefault = -22.759162;
  static double _longitudeDefault = -47.325246;
  static String _enderecoDefault = "Rua Fonte da Saudade, 587, Jardim São Paulo, Americana São Paulo, Brasil";

  final TextEditingController _controladorLatitude = TextEditingController();
  final TextEditingController _controladorLongitude = TextEditingController();
  final TextEditingController _controladorEndereco = TextEditingController();
  String enderecoConvertido;
  Position posicaoConvertida;
  String erroPosicaoConvertida;
  String enderecoCompletoPosicaoConvertida;

  @override
  void initState() {
    super.initState();
    _controladorLatitude.text = _latitudeDefault.toString();
    _controladorLongitude.text = _longitudeDefault.toString();
    _controladorEndereco.text = _enderecoDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Obter endereço / coordenadas", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView(
          children: <Widget>[
            _constroiBlocoConverterParaEndereco(),
            RaisedButton(child: Text("Converter para endereço", style: TextStyle(color: Colors.black87)), color: Colors.orange, onPressed: carregando ? null : () => _converterParaEndereco()),
            SizedBox(height: 50),
            _constroiBlocoConverterParaCoordenadas(),
            RaisedButton(child: Text("Converter para coordenadas", style: TextStyle(color: Colors.black87)), color: Colors.orange, onPressed: carregando ? null : () => _converterParaCoordenadas()),
            carregando ? carregandoWidget(height: 40, width: 40) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _constroiBlocoConverterParaEndereco() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Converter para endereço", style: TextStyle(color: Colors.orange)),
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
                    controller: _controladorLatitude,
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
                    controller: _controladorLongitude,
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(counter: Text("")),
                  ),
                ),
              ]),
              Row(children: <Widget>[
                Text("Resultado: ", style: TextStyle()),
                Expanded(child: Text(enderecoConvertido ?? "", style: TextStyle(color: Colors.orange))),
              ]),
              SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _constroiBlocoConverterParaCoordenadas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Converter para coordenadas", style: TextStyle(color: Colors.orange)),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Text("Endereço: ", style: TextStyle()),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controladorEndereco,
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(counter: Text("")),
                  ),
                ),
              ]),
              Row(children: <Widget>[
                Text("Resultado: ", style: TextStyle()),
                Expanded(child: Text(erroPosicaoConvertida ?? "", style: TextStyle(color: Colors.orange))),
              ]),
              Row(children: <Widget>[
                Text("        Latitude: ", style: TextStyle()),
                Text(posicaoConvertida?.latitude?.toString() ?? "", style: TextStyle(color: Colors.orange)),
              ]),
              Row(children: <Widget>[
                Text("        Longitude: ", style: TextStyle()),
                Text(posicaoConvertida?.longitude?.toString() ?? "", style: TextStyle(color: Colors.orange)),
              ]),
              Row(children: <Widget>[
                Text("        Endereço\n        completo: ", style: TextStyle()),
                Expanded(child: Text(enderecoCompletoPosicaoConvertida ?? "", style: TextStyle(color: Colors.orange))),
              ]),
              SizedBox(height: 5),
              //Text(resultado ?? "", style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ],
    );
  }

  Future _converterParaEndereco() async {
    setState(() {
      carregando = true;
      enderecoConvertido = "";
    });
    double latitudeDigitada;
    double longitudeDigitada;

    bool converteuParaDouble = true;
    try {
      latitudeDigitada = double.parse(_controladorLatitude.text);
      longitudeDigitada = double.parse(_controladorLongitude.text);
    } catch (e) {
      converteuParaDouble = false;
    }

    if (converteuParaDouble) {
      GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
      var listaLocalizacoesEncontradas = await geolocalizacaoHelper.recuperarLocalizacaoDeUmaPosicao(latitudeDigitada, longitudeDigitada);
      if ((listaLocalizacoesEncontradas?.length ?? 0) > 0) {
        enderecoConvertido = geolocalizacaoHelper.retornaNomeLocalizacao(listaLocalizacoesEncontradas[0]);
      } else
        enderecoConvertido = "Não foi possível localizar um endereço com estas coordenadas";
    } else
      await GeralHelper.instancia.exibirMensagem(context, "Atenção", "Informe a latitude e longitude no formato correto.\nObs: O separador deve ser '.' e não ',' ");

    setState(() => carregando = false);
  }

  Future _converterParaCoordenadas() async {
    setState(() {
      carregando = true;
      posicaoConvertida = null;
      enderecoCompletoPosicaoConvertida = null;
      erroPosicaoConvertida = null;
    });

    GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
    var listaLocalizacoesEncontradas = await geolocalizacaoHelper.recuperarLocalizacaoDeUmEndereco(_controladorEndereco?.text ?? "");
    if ((listaLocalizacoesEncontradas?.length ?? 0) > 0) {
      posicaoConvertida = listaLocalizacoesEncontradas[0].position;
      enderecoCompletoPosicaoConvertida = geolocalizacaoHelper.retornaNomeLocalizacao(listaLocalizacoesEncontradas[0]);
    } else {
      posicaoConvertida = null;
      erroPosicaoConvertida = "Não foram encontradas coordenadas para estas coordenadas";
    }

    setState(() => carregando = false);
  }
}
