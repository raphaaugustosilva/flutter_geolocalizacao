import 'package:flutter/material.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:flutter_geolocalizacao/views/widget/carregandoWidget.dart';

class LocalizacaoView extends StatefulWidget {
  @override
  _LocalizacaoViewState createState() => _LocalizacaoViewState();
}

class _LocalizacaoViewState extends State<LocalizacaoView> {
  bool carregando = false;
  String ultimaLocalizacaoLatitude;
  String ultimaLocalizacaoLongitude;
  String ultimaLocalizacaoNome;
  String localizacaoAtualLatitude;
  String localizacaoAtualLongitude;
  String localizacaoAtualNome;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Localização", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView(
          children: <Widget>[
            _constroiBlocoResultado("Última localização conhecida", ultimaLocalizacaoLatitude, ultimaLocalizacaoLongitude, nomeLocalizacao: ultimaLocalizacaoNome),
            SizedBox(height: 30),
            _constroiBlocoResultado("Localização atual", localizacaoAtualLatitude, localizacaoAtualLongitude, nomeLocalizacao: localizacaoAtualNome),
            RaisedButton(child: Text("Obter localizações", style: TextStyle(color: Colors.black87)), color: Colors.blue, onPressed: carregando ? null : () => _recuperaLocalizacoes()),
            carregando ? carregandoWidget(height: 40, width: 40) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _constroiBlocoResultado(String nomeResultado, String latitude, String longitude, {String nomeLocalizacao}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(nomeResultado, style: TextStyle(color: Colors.blue)),
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Text("Latitude: ", style: TextStyle()),
                Text(latitude ?? "", style: TextStyle(color: Colors.blue)),
              ]),
              Row(children: <Widget>[
                Text("Longitude: ", style: TextStyle()),
                Text(longitude ?? "", style: TextStyle(color: Colors.blue)),
              ]),
              SizedBox(height: 5),
              Text(nomeLocalizacao ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Future _recuperaLocalizacoes() async {
    setState(() => carregando = true);

    GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
    var ultimaPosicaoConhecida = await geolocalizacaoHelper.recuperarUltimaPosicaoConhecida();
    if (ultimaPosicaoConhecida != null) {
      ultimaLocalizacaoLatitude = ultimaPosicaoConhecida.latitude.toString();
      ultimaLocalizacaoLongitude = ultimaPosicaoConhecida.longitude.toString();

      var listaLocalizacoesEncontradas = await geolocalizacaoHelper.recuperarLocalizacaoDeUmaPosicao(ultimaPosicaoConhecida.latitude, ultimaPosicaoConhecida.longitude);
      ultimaLocalizacaoNome = listaLocalizacoesEncontradas == null ? "" : geolocalizacaoHelper.retornaNomeLocalizacao(listaLocalizacoesEncontradas[0]);
    }

    var posicaoAtual = await geolocalizacaoHelper.recuperarPosicaoAtual();
    if (posicaoAtual != null) {
      localizacaoAtualLatitude = posicaoAtual.latitude.toString();
      localizacaoAtualLongitude = posicaoAtual.longitude.toString();

      var listaLocalizacoesEncontradas = await geolocalizacaoHelper.recuperarLocalizacaoDeUmaPosicao(posicaoAtual.latitude, posicaoAtual.longitude);
      localizacaoAtualNome = listaLocalizacoesEncontradas == null ? "" : geolocalizacaoHelper.retornaNomeLocalizacao(listaLocalizacoesEncontradas[0]);
    }

    setState(() => carregando = false);
  }
}
