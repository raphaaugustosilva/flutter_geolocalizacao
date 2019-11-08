import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_geolocalizacao/helpers/geralHelper.dart';
import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';
import 'package:flutter_geolocalizacao/database/dadosMemoria.dart';
import 'package:flutter_geolocalizacao/helpers/navegacaoHelper.dart';
import 'package:flutter_geolocalizacao/helpers/geolocalizacaoHelper.dart';
import 'package:flutter_geolocalizacao/views/widget/carregandoWidget.dart';

class PrincipalView extends StatefulWidget {
  @override
  _PrincipalViewState createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  bool carregando = false;
  bool gpsHabilitadoParaUso = false;
  bool configuracoesSalvas = false;
  String statusGPS;
  PrecisaoLocalizacaoEnum precisaoLocalizacao = PrecisaoLocalizacaoEnum.melhorParaNavegacao;
  MetodoLocalizacaoEnum metodoLocalizacao = MetodoLocalizacaoEnum.sempre;
  GeolocalizacaoHelper _geolocalizacaoHelper = GeolocalizacaoHelper();
  @override
  void initState() {
    super.initState();
    _verificaStatusAcessoGPS();
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
            Text("Configurações", style: TextStyle(color: Colors.blue, fontSize: 20)),
            SizedBox(height: 5),
            _constroiStatusGPS(),
            gpsHabilitadoParaUso ? _constroiPrecisaoLocalizacao() : SizedBox.shrink(),
            gpsHabilitadoParaUso ? _constroiMetodoCapturaLocalizacao() : SizedBox.shrink(),
            gpsHabilitadoParaUso ? _constroiSalvarConfiguracoes() : SizedBox.shrink(),
            configuracoesSalvas ? _constroiBotoes() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _constroiStatusGPS() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Row(children: <Widget>[
            Text("Status GPS: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(statusGPS ?? "", textAlign: TextAlign.start)),
          ]),
        ),
        RaisedButton(
          child: carregando ? carregandoWidget() : Text("Verificar acesso ao GPS", textAlign: TextAlign.center),
          onPressed: () async {
            if (!carregando) await _verificaStatusAcessoGPS();
          },
        )
      ],
    );
  }

  Widget _constroiPrecisaoLocalizacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Precisão da localização: ", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            DropdownButton(
              hint: Text('Selecione a precisão'),
              value: precisaoLocalizacao,
              onChanged: (precisaoSelecionada) {
                setState(() => precisaoLocalizacao = precisaoSelecionada);
              },
              items: PrecisaoLocalizacaoEnum.values.map((location) {
                return DropdownMenuItem(
                  child: Text(describeEnum(location)),
                  value: location,
                );
              }).toList(),
            ),
            SizedBox(width: 10),
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
          ],
        ),
      ],
    );
  }

  Widget _constroiMetodoCapturaLocalizacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Método captura sinal GPS \n(apenas para iOS): ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            DropdownButton(
              isExpanded: false,
              iconSize: 20,
              hint: Text('Selecione o método'),
              value: metodoLocalizacao,
              onChanged: (metodoSelecionado) {
                setState(() => metodoLocalizacao = metodoSelecionado);
              },
              items: MetodoLocalizacaoEnum.values.map((location) {
                return DropdownMenuItem(
                  child: Text(describeEnum(location)),
                  value: location,
                );
              }).toList(),
            ),
            SizedBox(width: 10),
            GestureDetector(
                child: Text("   ? ", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await GeralHelper.instancia.exibirMensagem(
                      context,
                      "Métodos de captura de sinal GPS",
                      "foreground => Apenas quando o aplicativo estiver aberto e ativo em foreground \n\n"
                          "background => Apenas quando o em background \n\n"
                          "sempre => Sempre será capturado, independente se o aplicativo estiver ativo ou não (foreground e background)");
                }),
          ],
        ),
      ],
    );
  }

  Widget _constroiSalvarConfiguracoes() {
    return RaisedButton(
        color: Colors.black,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Icon(Icons.save, color: Colors.white),
          SizedBox(width: 10),
          Text("Salvar configurações", style: TextStyle(color: Colors.white)),
        ]),
        onPressed: () async {
          DadosMemoria.instancia.precisaoLocalizacao = precisaoLocalizacao;
          DadosMemoria.instancia.metodoLocalizacao = metodoLocalizacao;

          setState(() {
            configuracoesSalvas = true;
          });
        });
  }

  Widget _constroiBotoes() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text("Funções", textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontSize: 20)),
          SizedBox(height: 10),
          RaisedButton(child: Text("Obter localização"), color: Colors.blue, onPressed: () => _navegaParaView(NavegacaoHelper.rotaLocalizacao)),
          RaisedButton(child: Text("Localização em tempo real"), color: Colors.green, onPressed: () => _navegaParaView(NavegacaoHelper.rotaLocalizacaoTempoReal)),
          RaisedButton(child: Text("Obter endereço / coordenadas"), color: Colors.orange, onPressed: () => _navegaParaView(NavegacaoHelper.rotaConverterPosicaoELocalizacao)),
          RaisedButton(child: Text("Distância entre localizações"), color: Colors.blueGrey, onPressed: () => _navegaParaView(NavegacaoHelper.rotaDistanciaEntrePosicoes)),
        ],
      ),
    );
  }

  Future _navegaParaView(String rotaASerNavegada) async {
    await _verificaStatusAcessoGPS();
    if (gpsHabilitadoParaUso) {
      Navigator.of(context).pushNamed(rotaASerNavegada);
    }
  }

  Future _verificaStatusAcessoGPS() async {
    setState(() {
      carregando = true;
      statusGPS = "Verificando ...";
      gpsHabilitadoParaUso = false;
    });

    AcessoGPSDeviceEnum acessoGPSDevice;
    AcessoGPSAplicativoEnum acessoGPSAplicativo;

    acessoGPSDevice = await _geolocalizacaoHelper.verificaPermissaoDoDispositivoAcessoGPS();
    if (acessoGPSDevice == AcessoGPSDeviceEnum.disponivel) {
      acessoGPSAplicativo = await _geolocalizacaoHelper.verificaPermissaoDoAplicativoAcessoGPS();

      if (acessoGPSAplicativo != AcessoGPSAplicativoEnum.permitido) {
        PermissionStatus permissaoAplicativo = await LocationPermissions().requestPermissions();

        if (permissaoAplicativo != PermissionStatus.granted && permissaoAplicativo != PermissionStatus.restricted) {
          if (await GeralHelper.instancia.exibirMensagemAcaoUsuario(context, "Atenção", "Para usar este aplicativo, é necessário dar permissão para acessar sua localização.\nDeseja abrir as preferências de localizaçaão agora?", "Sim", "Não") == ResultadoMensagemEnum.ok) {
            await LocationPermissions().openAppSettings();
          }
        }

        acessoGPSAplicativo = await _geolocalizacaoHelper.verificaPermissaoDoAplicativoAcessoGPS();
      }
    }
    gpsHabilitadoParaUso = acessoGPSAplicativo == AcessoGPSAplicativoEnum.permitido;

    setState(() {
      statusGPS = acessoGPSDevice == null ? "Erro ao verificar status" : acessoGPSDevice == AcessoGPSDeviceEnum.indisponivel ? "O GPS do dispositivo está indisponível / desabilitado" : describeEnum(acessoGPSAplicativo);
      carregando = false;
    });
  }
}
