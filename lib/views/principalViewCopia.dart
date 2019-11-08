import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PrincipalViewCopia extends StatefulWidget {
  @override
  _PrincipalViewCopiaState createState() => _PrincipalViewCopiaState();
}

class _PrincipalViewCopiaState extends State<PrincipalViewCopia> {
  static int _distanciaParaAtualizarGPSDefault = 10;
  int _distanciaParaAtualizarGPS = _distanciaParaAtualizarGPSDefault;
  StreamSubscription<Position> _posicaoTempoRealStreamSubscription;
  final List<Position> _posicoesTempoReal = <Position>[];
  Map<int, String> _mapEnderecoTempoReal = Map<int, String>();

  TextEditingController _controladorDistanciaAtualizacaoGPS = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controladorDistanciaAtualizacaoGPS.text = _distanciaParaAtualizarGPS.toStringAsFixed(0);
  }

  @override
  void dispose() {
    if (_posicaoTempoRealStreamSubscription != null) {
      _posicaoTempoRealStreamSubscription.cancel();
      _posicaoTempoRealStreamSubscription = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Geolocalização POC", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView(
          children: <Widget>[
            //Localização em tempo real
            SizedBox(height: 30),
            Text("Localização em tempo real", style: TextStyle(color: Colors.blue)),
            _constroiRolagemHorizontal(
              height: 50,
              conteudo: Row(
                children: <Widget>[
                  Text("Distância para atualização de GPS "),
                  SizedBox(width: 10),
                  Container(
                    width: 40,
                    child: TextField(
                      controller: _controladorDistanciaAtualizacaoGPS,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "10", counter: Text("")),
                      onChanged: (valorDigitado) {
                        try {
                          _distanciaParaAtualizarGPS = int.parse(valorDigitado);
                        } catch (e) {
                          _distanciaParaAtualizarGPS = _distanciaParaAtualizarGPSDefault;
                          _controladorDistanciaAtualizacaoGPS.text = _distanciaParaAtualizarGPS.toStringAsFixed(0);
                        }
                      },
                    ),
                  ),
                  Text(" metros"),
                ],
              ),
            ),
            RaisedButton(
                color: _localizaoTempoRealRodando() ? Colors.red[700] : Colors.blue[900],
                child: Text(_localizaoTempoRealRodando() ? "Pausar" : _posicaoTempoRealStreamSubscription == null ? "Iniciar" : "Retomar", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _ativaDesativaLocalizacaoTempoReal();
                }),

            //Resultados
            //Center(child: Text("Resultados", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Obs: Clique em cada resultado para traduzir o endereço", style: TextStyle(fontSize: 12))),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(vertical: 7),
              color: Colors.blueGrey[900],
              child: Row(children: <Widget>[
                Text("Latitude / Longitude", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                    Text("Data", style: TextStyle(color: Colors.white)),
                  ]),
                ),
              ]),
            ),
            //SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
              height: 300,
              child: ListView.builder(
                itemCount: _posicoesTempoReal?.length ?? 0,
                itemBuilder: (context, indice) {
                  double latitudeCapturada = _posicoesTempoReal[indice].latitude;
                  double longitudeCapturada = _posicoesTempoReal[indice].longitude;

                  return GestureDetector(
                    child: Container(
                      color: !indice.isOdd ? Colors.blue.withOpacity(0.2) : Colors.white,
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
                      //var localizacaoRecuperada = await GeolocalizacaoHelper.instancia.recuperarLocalizacaoDeUmaPosicao(latitudeCapturada, longitudeCapturada);
                      //setState(() => _mapEnderecoTempoReal[indice] = _retornaNomeLocalizacao(localizacaoRecuperada?.first));
                    },
                  );
                  //return Text(indice.toString());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _constroiRolagemHorizontal({Widget conteudo, double height}) {
    return Container(height: height ?? 35, padding: EdgeInsets.only(left: 20), child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[conteudo]));
  }

  Widget _constroiCarregandoWidget() {
    return Container(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2));
  }

  String _retornaNomeLocalizacao(Placemark localizacaoCompleta) {
    //return localizacaoCompleta == null ? "" : "Nome:${localizacaoCompleta?.name ?? ""}, ${localizacaoCompleta?.thoroughfare ?? ""}, ${localizacaoCompleta?.subThoroughfare ?? ""}, ${localizacaoCompleta?.locality ?? ""} ${localizacaoCompleta?.subLocality ?? ""}, ${localizacaoCompleta?.administrativeArea ?? ""} ${localizacaoCompleta?.subAdministrativeArea ?? ""}, CEP: ${localizacaoCompleta?.postalCode ?? ""}, ${localizacaoCompleta?.country ?? ""}";
    return localizacaoCompleta == null ? "" : "${localizacaoCompleta?.thoroughfare ?? ""}, ${localizacaoCompleta?.subThoroughfare ?? ""}, ${localizacaoCompleta?.locality ?? ""} ${localizacaoCompleta?.subLocality ?? ""}, ${localizacaoCompleta?.administrativeArea ?? ""} ${localizacaoCompleta?.subAdministrativeArea ?? ""}, CEP: ${localizacaoCompleta?.postalCode ?? ""}, ${localizacaoCompleta?.country ?? ""}";
  }

  bool _localizaoTempoRealRodando() => !(_posicaoTempoRealStreamSubscription == null || _posicaoTempoRealStreamSubscription.isPaused);

  void _ativaDesativaLocalizacaoTempoReal() {
    // if (_posicaoTempoRealStreamSubscription == null) {
    //   GeolocacalizacaoOpcoesTempoReal geolocacalizacaoOpcoesTempoReal = GeolocacalizacaoOpcoesTempoReal(_metodoLocalizacaoSelecionado, _precisaoLocalizacaoSelecionada, _distanciaParaAtualizarGPS);
    //   final Stream<Position> posicoesTempoRealStream = GeolocalizacaoHelper.instancia.recuperarPosicaoTempoReal(geolocacalizacaoOpcoesTempoReal);
    //   _posicaoTempoRealStreamSubscription = posicoesTempoRealStream.listen((Position posicao) => setState(() => _posicoesTempoReal.add(posicao)));
    //   _posicaoTempoRealStreamSubscription.pause();
    // }

    setState(
      () {
        if (_posicaoTempoRealStreamSubscription.isPaused) {
          _posicaoTempoRealStreamSubscription.resume();
        } else {
          _posicaoTempoRealStreamSubscription.pause();
        }
      },
    );
  }
}
