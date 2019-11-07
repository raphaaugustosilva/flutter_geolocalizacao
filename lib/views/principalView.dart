import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geolocalizacao/helpers/geralHelper.dart';
import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:intl/intl.dart';

class PrincipalView extends StatefulWidget {
  @override
  _PrincipalViewState createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  AcessoGPSDeviceEnum _acessoGPSDevice;
  AcessoGPSAplicativoEnum _acessoGPSAplicativo;
  List<PrecisaoLocalizacaoEnum> _precisoesLocalizacao = PrecisaoLocalizacaoEnum.values;

  PrecisaoLocalizacaoEnum _precisaoLocalizacaoSelecionada = PrecisaoLocalizacaoEnum.melhorParaNavegacao;

  List<MetodoLocalizacaoEnum> _metodosLocalizacao = MetodoLocalizacaoEnum.values;
  MetodoLocalizacaoEnum _metodoLocalizacaoSelecionado = MetodoLocalizacaoEnum.sempre;

  bool _carregandoAcessoGPS = false;

  bool _carregandoUltimaPosicaoConhecida = false;
  Position _ultimaPosicaoConhecida;
  bool _carregandoUltimaLocalizacaoConhecida = false;
  Placemark _ultimaLocalizacaoConhecida;

  bool _carregandoPosicaoAtual = false;
  Position _posicaoAtual;
  bool _carregandoLocalizacaoAtual = false;
  Placemark _localizacaoAtual;

  bool _carregandoBuscaCoordernadas = false;
  Position _coordernadaASerBuscada;
  Placemark _coordenadaBuscada;

  static double _latitudeDefault = -22.759162;
  static double _longitudeDefault = -47.325246;
  double _latitudeBuscada = _latitudeDefault;
  double _longitudeBuscada = _longitudeDefault;

  static int _distanciaParaAtualizarGPSDefault = 10;
  int _distanciaParaAtualizarGPS = _distanciaParaAtualizarGPSDefault;
  StreamSubscription<Position> _posicaoTempoRealStreamSubscription;
  final List<Position> _posicoesTempoReal = <Position>[];
  Map<int, String> _mapEnderecoTempoReal = Map<int, String>();

  TextEditingController _controladorDistanciaAtualizacaoGPS = TextEditingController();
  TextEditingController _controladorLatitudeBuscada = TextEditingController();
  TextEditingController _controladorLongitudeBuscada = TextEditingController();

  String get _acessoGPSString {
    if (_acessoGPSDevice == null) {
      return "verificando";
    }
    if (_acessoGPSDevice == AcessoGPSDeviceEnum.indisponivel) {
      return "O GPS do dispositivo \nestá indisponível \n/ desabilitado";
    } else {
      return describeEnum(_acessoGPSAplicativo);
    }
  }

  @override
  void initState() {
    super.initState();
    _verificaStatusAcessoGPS();
    _controladorDistanciaAtualizacaoGPS.text = _distanciaParaAtualizarGPS.toStringAsFixed(0);
    _controladorLatitudeBuscada.text = _latitudeBuscada.toString();
    _controladorLongitudeBuscada.text = _longitudeBuscada.toString();
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
            Text("Configurações", style: TextStyle(color: Colors.blue)),
            //Status GPS
            _constroiRolagemHorizontal(
              height: 70,
              conteudo: Row(
                children: <Widget>[
                  Text("Status GPS: "),
                  SizedBox(width: 10),
                  Text(_acessoGPSString, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  RaisedButton(
                      child: !_carregandoAcessoGPS ? Text("Verificar acesso \n ao GPS", textAlign: TextAlign.center) : _constroiCarregandoWidget(),
                      onPressed: !_carregandoAcessoGPS
                          ? () async {
                              await _verificaStatusAcessoGPS();
                            }
                          : null),
                ],
              ),
            ),
            SizedBox(height: 10),

            //Precisão da localização
            _constroiRolagemHorizontal(
              conteudo: Row(
                children: <Widget>[
                  Text("Precisão da localização: "),
                  GestureDetector(
                      child: Text("?", style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await GeralHelper.instancia.exibirMensagem(
                            context,
                            "Precisões",
                            "maisBaixa => Localização a uma distância de 3000m no iOS e 500m no Android \n\n"
                                "baixa => Localização a uma distância de 1000m no iOS e 500m no Android \n\n"
                                "media => Localização a uma distância de 100m no iOS e entre 100m e 500m no Android \n\n"
                                "alta => Localização a uma distância de 10m no iOS e entre 0m e 100m no Android \n\n"
                                "melhor => Localização a uma distância de ~0m no iOS e entre 0m e 100m no Android \n\n"
                                "melhorParaNavegacao => Localização otimizada para navegação no iOS e 'melhor' explicada anteriormente  no Android");
                      }),
                  SizedBox(width: 10),
                  DropdownButton(
                    hint: Text('Selecione a precisão'),
                    value: _precisaoLocalizacaoSelecionada,
                    onChanged: (precisaoSelecionada) {
                      setState(() => _precisaoLocalizacaoSelecionada = precisaoSelecionada);
                    },
                    items: _precisoesLocalizacao.map((location) {
                      return DropdownMenuItem(
                        child: Text(describeEnum(location)),
                        value: location,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            //Método de captura de localização
            _constroiRolagemHorizontal(
              conteudo: Row(
                children: <Widget>[
                  Text("Método de captura de localização: "),
                  GestureDetector(
                      child: Text("?", style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await GeralHelper.instancia.exibirMensagem(
                            context,
                            "Métodos de captura de sinal GPS",
                            "foreground => Apenas quando o aplicativo estiver aberto e ativo em foreground \n\n"
                                "background => Apenas quando o em background \n\n"
                                "sempre => Sempre será capturado, independente se o aplicativo estiver ativo ou não (foreground e background)");
                      }),
                  SizedBox(width: 10),
                  DropdownButton(
                    hint: Text('Selecione o método'),
                    value: _metodoLocalizacaoSelecionado,
                    onChanged: (metodoSelecionado) {
                      setState(() => _metodoLocalizacaoSelecionado = metodoSelecionado);
                    },
                    items: _metodosLocalizacao.map((location) {
                      return DropdownMenuItem(
                        child: Text(describeEnum(location)),
                        value: location,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            Text("Funções", style: TextStyle(color: Colors.blue)),
            SizedBox(height: 10),
            //Última posição conhecida
            Text("      Última localização conhecida", style: TextStyle(color: Colors.green)),
            SizedBox(height: 4),
            _constroiRolagemHorizontal(
              height: 70,
              conteudo: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Última localização conhecida: "),
                      Text(_ultimaPosicaoConhecida == null ? "" : "Lat: ${_ultimaPosicaoConhecida.latitude}\nLong: ${_ultimaPosicaoConhecida.longitude}", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                      child: !_carregandoUltimaPosicaoConhecida ? Text("Obter última\nlocalização", textAlign: TextAlign.center) : _constroiCarregandoWidget(),
                      onPressed: !_carregandoUltimaPosicaoConhecida
                          ? () async {
                              await _recuperaUltimaPosicaoConhecida();
                            }
                          : null),
                ],
              ),
            ),

            //Nome última localização conhecida
            _constroiRolagemHorizontal(
              conteudo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  !_carregandoUltimaLocalizacaoConhecida ? Text(_retornaNomeLocalizacao(_ultimaLocalizacaoConhecida), style: TextStyle(fontWeight: FontWeight.bold)) : _constroiCarregandoWidget(),
                ],
              ),
            ),
            SizedBox(height: 10),

            //Posição Atual
            SizedBox(height: 20),
            Text("      Localização atual", style: TextStyle(color: Colors.green)),
            SizedBox(height: 4),
            _constroiRolagemHorizontal(
              height: 70,
              conteudo: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Localização atual: "),
                      Text(_posicaoAtual == null ? "" : "Lat: ${_posicaoAtual.latitude}\nLong: ${_posicaoAtual.longitude}", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                      child: !_carregandoPosicaoAtual ? Text("Obter localização\natual", textAlign: TextAlign.center) : _constroiCarregandoWidget(),
                      onPressed: !_carregandoPosicaoAtual
                          ? () async {
                              await _recuperaPosicaoAtual();
                            }
                          : null),
                ],
              ),
            ),

            //Nome localização atual
            _constroiRolagemHorizontal(
              conteudo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  !_carregandoLocalizacaoAtual ? Text(_retornaNomeLocalizacao(_localizacaoAtual), style: TextStyle(fontWeight: FontWeight.bold)) : _constroiCarregandoWidget(),
                ],
              ),
            ),
            SizedBox(height: 10),

            //Nome localização atual
            SizedBox(height: 20),
            _constroiRolagemHorizontal(
              height: 200,
              conteudo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Pesquisar local através de coordenadas", style: TextStyle(color: Colors.green)),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("     Latitude: "),
                              Container(
                                width: 120,
                                child: TextField(
                                  controller: _controladorLatitudeBuscada,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(hintText: "Latitude", counter: Text("")),
                                  onChanged: (valorDigitado) {
                                    try {
                                      _latitudeBuscada = double.parse(valorDigitado);
                                    } catch (e) {
                                      _latitudeBuscada = _latitudeDefault;
                                      _controladorLatitudeBuscada.text = _latitudeBuscada.toString();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: <Widget>[
                              Text("     Longitude: "),
                              Container(
                                width: 120,
                                child: TextField(
                                  controller: _controladorLongitudeBuscada,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(hintText: "Longitude", counter: Text("")),
                                  onChanged: (valorDigitado) {
                                    try {
                                      _longitudeBuscada = double.parse(valorDigitado);
                                    } catch (e) {
                                      _longitudeBuscada = _longitudeDefault;
                                      _controladorLongitudeBuscada.text = _longitudeBuscada.toString();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      RaisedButton(
                          child: Text("Pesquisar\nlocal", textAlign: TextAlign.center),
                          onPressed: () async {
                            await _pesquisaLocalizacao(_latitudeBuscada, _longitudeBuscada);
                          }),
                    ],
                  ),
                  !_carregandoBuscaCoordernadas ? Text(_retornaNomeLocalizacao(_coordenadaBuscada), style: TextStyle(fontWeight: FontWeight.bold)) : _constroiCarregandoWidget(),
                ],
              ),
            ),
            SizedBox(width: 10),

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

                  return Container(
                    color: !indice.isOdd ? Colors.blue.withOpacity(0.2) : Colors.white,
                    child: GestureDetector(
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
                      onTap: () async {
                        var localizacaoRecuperada = await GeolocalizacaoHelper.instancia.recuperarLocalizacaoDeUmaPosicao(latitudeCapturada, longitudeCapturada);
                        setState(() => _mapEnderecoTempoReal[indice] = _retornaNomeLocalizacao(localizacaoRecuperada?.first));
                      },
                    ),
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

  Future _verificaStatusAcessoGPS() async {
    setState(() => _carregandoAcessoGPS = true);
    _acessoGPSDevice = await GeolocalizacaoHelper.instancia.verificaPermissaoDoDispositivoAcessoGPS();
    _acessoGPSAplicativo = await GeolocalizacaoHelper.instancia.verificaPermissaoDoAplicativoAcessoGPS();
    setState(() {
      _acessoGPSString;
      _carregandoAcessoGPS = false;
    });
  }

  Future _recuperaUltimaPosicaoConhecida() async {
    setState(() => _carregandoUltimaPosicaoConhecida = true);
    _ultimaPosicaoConhecida = await GeolocalizacaoHelper.instancia.recuperarUltimaPosicaoConhecida(precisaoLocalizacao: _precisaoLocalizacaoSelecionada, metodoLocalizacao: _metodoLocalizacaoSelecionado);
    setState(() => _carregandoUltimaPosicaoConhecida = false);

    if (_ultimaPosicaoConhecida != null) await _recuperaUltimaLocalizacaoConhecida(_ultimaPosicaoConhecida.latitude, _ultimaPosicaoConhecida.longitude);
  }

  Future _recuperaUltimaLocalizacaoConhecida(double latitude, double longitude) async {
    setState(() => _carregandoUltimaLocalizacaoConhecida = true);
    _ultimaLocalizacaoConhecida = await _recuperaLocalizacao(latitude, longitude);
    setState(() => _carregandoUltimaLocalizacaoConhecida = false);
  }

  Future _recuperaPosicaoAtual() async {
    setState(() => _carregandoPosicaoAtual = true);
    _posicaoAtual = await GeolocalizacaoHelper.instancia.recuperarPosicaoAtual(precisaoLocalizacao: _precisaoLocalizacaoSelecionada, metodoLocalizacao: _metodoLocalizacaoSelecionado);
    setState(() => _carregandoPosicaoAtual = false);

    if (_posicaoAtual != null) await _recuperaLocalizacaoAtual(_posicaoAtual.latitude, _posicaoAtual.longitude);
  }

  Future _recuperaLocalizacaoAtual(double latitude, double longitude) async {
    setState(() => _carregandoLocalizacaoAtual = true);
    _localizacaoAtual = await _recuperaLocalizacao(latitude, longitude);
    setState(() => _carregandoLocalizacaoAtual = false);
  }

  Future _pesquisaLocalizacao(double latitude, double longitude) async {
    setState(() => _carregandoBuscaCoordernadas = true);
    _coordenadaBuscada = await _recuperaLocalizacao(latitude, longitude);
    setState(() => _carregandoBuscaCoordernadas = false);
  }

  Future<Placemark> _recuperaLocalizacao(double latitude, double longitude) async {
    if (latitude == null || longitude == null) return null;

    var listaLocalizacoesEncontradas = await GeolocalizacaoHelper.instancia.recuperarLocalizacaoDeUmaPosicao(latitude, longitude);
    return listaLocalizacoesEncontradas == null ? null : listaLocalizacoesEncontradas[0];
  }

  String _retornaNomeLocalizacao(Placemark localizacaoCompleta) {
    //return localizacaoCompleta == null ? "" : "Nome:${localizacaoCompleta?.name ?? ""}, ${localizacaoCompleta?.thoroughfare ?? ""}, ${localizacaoCompleta?.subThoroughfare ?? ""}, ${localizacaoCompleta?.locality ?? ""} ${localizacaoCompleta?.subLocality ?? ""}, ${localizacaoCompleta?.administrativeArea ?? ""} ${localizacaoCompleta?.subAdministrativeArea ?? ""}, CEP: ${localizacaoCompleta?.postalCode ?? ""}, ${localizacaoCompleta?.country ?? ""}";
    return localizacaoCompleta == null ? "" : "${localizacaoCompleta?.thoroughfare ?? ""}, ${localizacaoCompleta?.subThoroughfare ?? ""}, ${localizacaoCompleta?.locality ?? ""} ${localizacaoCompleta?.subLocality ?? ""}, ${localizacaoCompleta?.administrativeArea ?? ""} ${localizacaoCompleta?.subAdministrativeArea ?? ""}, CEP: ${localizacaoCompleta?.postalCode ?? ""}, ${localizacaoCompleta?.country ?? ""}";
  }

  bool _localizaoTempoRealRodando() => !(_posicaoTempoRealStreamSubscription == null || _posicaoTempoRealStreamSubscription.isPaused);

  void _ativaDesativaLocalizacaoTempoReal() {
    if (_posicaoTempoRealStreamSubscription == null) {
      GeolocacalizacaoOpcoesTempoReal geolocacalizacaoOpcoesTempoReal = GeolocacalizacaoOpcoesTempoReal(_metodoLocalizacaoSelecionado, _precisaoLocalizacaoSelecionada, _distanciaParaAtualizarGPS);
      final Stream<Position> posicoesTempoRealStream = GeolocalizacaoHelper.instancia.recuperarPosicaoTempoReal(geolocacalizacaoOpcoesTempoReal);
      _posicaoTempoRealStreamSubscription = posicoesTempoRealStream.listen((Position posicao) => setState(() => _posicoesTempoReal.add(posicao)));
      _posicaoTempoRealStreamSubscription.pause();
    }

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
