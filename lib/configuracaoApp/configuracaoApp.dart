import 'package:geolocator/geolocator.dart';

class ConfiguracaoApp {
  LocationAccuracy precisao;
  int metrosParaAtualizacaoNotificacao;

  resetar() {
    this.precisao = LocationAccuracy.best;
    this.metrosParaAtualizacaoNotificacao = 1;
  }
}
