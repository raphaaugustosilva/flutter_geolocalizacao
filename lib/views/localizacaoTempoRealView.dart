import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:intl/intl.dart';

class LocalizacaoTempoRealView extends StatefulWidget {
  @override
  _LocalizacaoTempoRealViewState createState() => _LocalizacaoTempoRealViewState();
}

class _LocalizacaoTempoRealViewState extends State<LocalizacaoTempoRealView> {
  bool carregando = false;

  static int distanciaParaAtualizarGPSDefault = 2;

  StreamSubscription<Position> _posicaoTempoRealStreamSubscription;
  final List<Position> _posicoesTempoReal = <Position>[];
  final Map<int, String> _mapEnderecoTempoReal = Map<int, String>();

  TextEditingController _controladorDistanciaAtualizacaoGPS = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controladorDistanciaAtualizacaoGPS.text = distanciaParaAtualizarGPSDefault.toStringAsFixed(0);
  }

  @override
  void dispose() {
    resetarStreamSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Localização em tempo real", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _constroiConfiguracoes(),
            _posicaoTempoRealStreamSubscription == null ? RaisedButton(color: Colors.green, child: Text("Iniciar"), onPressed: () => _iniciaLocalizacaoTempoReal()) : SizedBox.shrink(),
            _posicaoTempoRealStreamSubscription != null
                ? RaisedButton(
                    color: _posicaoTempoRealStreamSubscription.isPaused ? Colors.green : Colors.orange[400],
                    child: Text(_posicaoTempoRealStreamSubscription.isPaused ? "Retomar" : "Pausar"),
                    onPressed: () => _retomaOuPausaLocalizacaoTempoReal(),
                  )
                : SizedBox.shrink(),
            _posicaoTempoRealStreamSubscription != null
                ? RaisedButton(
                    color: Colors.red[700],
                    child: Text("Resetar", style: TextStyle(color: Colors.white)),
                    onPressed: () => _resetaLocalizacaoTempoReal(),
                  )
                : SizedBox.shrink(),
            //_posicaoTempoRealStreamSubscription != null ? _constroiBlocoResultado() : SizedBox.shrink(),
            _posicaoTempoRealStreamSubscription != null ? _constroiCabecalhoResultado() : SizedBox.shrink(),
            _posicaoTempoRealStreamSubscription != null ? Expanded(child: _constroiListaResultadosTempoReal()) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _constroiConfiguracoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Configurações", style: TextStyle(color: Colors.green, fontSize: 20)),
        SizedBox(height: 5),
        Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Row(
            children: <Widget>[
              Text("Distância para atualização de GPS ", style: TextStyle()),
              SizedBox(width: 10),
              Container(
                width: 40,
                child: TextField(
                  style: TextStyle(color: Colors.green),
                  controller: _controladorDistanciaAtualizacaoGPS,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: distanciaParaAtualizarGPSDefault.toStringAsFixed(0), counter: Text("")),
                ),
              ),
              Text(" metros ", style: TextStyle()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _constroiCabecalhoResultado() {
    return Column(
      children: <Widget>[
        Center(child: Text("Obs: Clique em cada resultado para traduzir o endereço", style: TextStyle(fontSize: 12))),
        Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: Colors.blueGrey[900],
          child: Row(
            children: <Widget>[
              Text("Latitude / Longitude", style: TextStyle(color: Colors.white)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Data", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _constroiListaResultadosTempoReal() {
    return ListView.builder(
      itemCount: _posicoesTempoReal?.length ?? 0,
      itemBuilder: (context, indice) {
        double latitudeCapturada = _posicoesTempoReal[indice].latitude;
        double longitudeCapturada = _posicoesTempoReal[indice].longitude;

        return GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: !indice.isOdd ? Colors.green.withOpacity(0.2) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                      Text("Latitude: $latitudeCapturada"),
                      Text("Longitude: $longitudeCapturada"),
                    ]),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                        Text(DateFormat("dd/MM - HH:mm:ss").format(_posicoesTempoReal[indice].timestamp.toLocal()).toString(), style: TextStyle(fontSize: 14.0, color: Colors.grey[500])),
                      ]),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                //Text(endereco ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                Text(_mapEnderecoTempoReal[indice] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                SizedBox(height: 7),
              ],
            ),
          ),
          onTap: () async {
            GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
            var localizacaoRecuperada = await geolocalizacaoHelper.recuperarLocalizacaoDeUmaPosicao(latitudeCapturada, longitudeCapturada);
            setState(() => _mapEnderecoTempoReal[indice] = geolocalizacaoHelper.retornaNomeLocalizacao(localizacaoRecuperada?.first));
          },
        );
      },
    );
  }

  void _iniciaLocalizacaoTempoReal() {
    int distanciaParaAtualizarGPS;
    try {
      distanciaParaAtualizarGPS = int.parse(_controladorDistanciaAtualizacaoGPS?.text ?? "");
    } catch (e) {
      distanciaParaAtualizarGPS = distanciaParaAtualizarGPSDefault;
    }
    GeolocalizacaoHelper geolocalizacaoHelper = GeolocalizacaoHelper.dadosMemoria();
    final Stream<Position> recuperarPosicaoEmTempoRealStream = geolocalizacaoHelper.recuperarPosicaoEmTempoReal(GeolocacalizacaoOpcoesTempoReal.dadosMemoria(distanciaParaAtualizarGPS));
    _posicaoTempoRealStreamSubscription = recuperarPosicaoEmTempoRealStream.listen((Position posicao) => setState(() => _posicoesTempoReal.add(posicao)));
    setState(() {});
  }

  void _retomaOuPausaLocalizacaoTempoReal() {
    setState(() {
      if (_posicaoTempoRealStreamSubscription.isPaused)
        _posicaoTempoRealStreamSubscription.resume();
      else
        _posicaoTempoRealStreamSubscription.pause();
    });
  }

  void _resetaLocalizacaoTempoReal() {
    resetarStreamSubscription();
  }

  void resetarStreamSubscription() {
    setState(() {
      _posicaoTempoRealStreamSubscription?.cancel();
      _posicaoTempoRealStreamSubscription = null;

      _posicoesTempoReal?.clear();
      _mapEnderecoTempoReal?.clear();
    });
  }
}
