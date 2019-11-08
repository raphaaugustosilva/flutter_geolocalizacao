import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';

class DadosMemoria {
  DadosMemoria._construtorPrivate();
  static final instancia = DadosMemoria._construtorPrivate();

  PrecisaoLocalizacaoEnum precisaoLocalizacao;
  MetodoLocalizacaoEnum metodoLocalizacao;

  void resetaDados() {
    this.precisaoLocalizacao = null;
    this.metodoLocalizacao = null;
  }
}
