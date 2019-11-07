import 'package:geolocator/geolocator.dart';
import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';

class GeolocalizacaoHelper {
  GeolocalizacaoHelper._construtorPrivate();
  static final instancia = GeolocalizacaoHelper._construtorPrivate();

  final Geolocator _geolocator = Geolocator();
  Future<AcessoGPSDeviceEnum> verificaPermissaoDoDispositivoAcessoGPS() async {
    try {
      return (await _geolocator.isLocationServiceEnabled() == true ? AcessoGPSDeviceEnum.disponivel : AcessoGPSDeviceEnum.indisponivel);
    } catch (e) {
      print("Erro ao verificaPermissaoDoDispositivoAcessoGPS. Detalhes: $e");
      return AcessoGPSDeviceEnum.indisponivel;
    }
  }

  Future<AcessoGPSAplicativoEnum> verificaPermissaoDoAplicativoAcessoGPS() async {
    try {
      GeolocationStatus geolocationStatus = await _geolocator.checkGeolocationPermissionStatus();

      switch (geolocationStatus) {
        case GeolocationStatus.denied:
          return AcessoGPSAplicativoEnum.negado;
          break;

        case GeolocationStatus.disabled:
          return AcessoGPSAplicativoEnum.desabilitado;
          break;

        case GeolocationStatus.granted:
          return AcessoGPSAplicativoEnum.permitido;
          break;

        case GeolocationStatus.restricted:
          return AcessoGPSAplicativoEnum.restrito;
          break;

        case GeolocationStatus.unknown:
          return AcessoGPSAplicativoEnum.desconhecido;
          break;

        default:
          return AcessoGPSAplicativoEnum.desconhecido;
          break;
      }
    } catch (e) {
      print("Erro ao verificaPermissaoDoAplicativoAcessoGPS. Detalhes: $e");
      return AcessoGPSAplicativoEnum.desconhecido;
    }
  }

  Future<Position> recuperarUltimaPosicaoConhecida({PrecisaoLocalizacaoEnum precisaoLocalizacao = PrecisaoLocalizacaoEnum.alta, MetodoLocalizacaoEnum metodoLocalizacao = MetodoLocalizacaoEnum.sempre}) async {
    try {
      return await _geolocator.getLastKnownPosition(desiredAccuracy: converteParaLocationAccuracy(precisaoLocalizacao), locationPermissionLevel: converteParaGeolocationPermission(metodoLocalizacao));
    } catch (e) {
      print("Erro ao recuperarUltimaLocalizacaoConhecida. Detalhes: $e");
      return null;
    }
  }

  Future<Position> recuperarPosicaoAtual({PrecisaoLocalizacaoEnum precisaoLocalizacao = PrecisaoLocalizacaoEnum.alta, MetodoLocalizacaoEnum metodoLocalizacao = MetodoLocalizacaoEnum.sempre}) async {
    try {
      return await _geolocator.getCurrentPosition(desiredAccuracy: converteParaLocationAccuracy(precisaoLocalizacao), locationPermissionLevel: converteParaGeolocationPermission(metodoLocalizacao));
    } catch (e) {
      print("Erro ao recuperarLocalizacaoAtual. Detalhes: $e");
      return null;
    }
  }

  Future<List<Placemark>> recuperarLocalizacaoDeUmaPosicao(double latitude, double longitude, {String localizaoDeTraducao = "pt_BR"}) async {
    try {
      return await _geolocator.placemarkFromCoordinates(latitude, longitude, localeIdentifier: localizaoDeTraducao);
    } catch (e) {
      print("Erro ao recuperarLocalizacaoAtual. Detalhes: $e");
      return null;
    }
  }

  Stream<Position> recuperarPosicaoTempoReal(GeolocacalizacaoOpcoesTempoReal geolocacalizacaoOpcoesTempoReal) {
    try {
      var permissao = GeolocalizacaoHelper.instancia.converteParaGeolocationPermission(geolocacalizacaoOpcoesTempoReal.metodoLocalizacao);
      return _geolocator.getPositionStream(converteParaLocationOptions(geolocacalizacaoOpcoesTempoReal), permissao);
    } catch (e) {
      print("Erro ao recuperarPosicaoTempoReal. Detalhes: $e");
      return null;
    }
  }

  LocationAccuracy converteParaLocationAccuracy(PrecisaoLocalizacaoEnum precisaoLocalizacao) {
    switch (precisaoLocalizacao) {
      case PrecisaoLocalizacaoEnum.maisBaixa:
        return LocationAccuracy.lowest;
        break;

      case PrecisaoLocalizacaoEnum.baixa:
        return LocationAccuracy.low;
        break;

      case PrecisaoLocalizacaoEnum.media:
        return LocationAccuracy.medium;
        break;

      case PrecisaoLocalizacaoEnum.alta:
        return LocationAccuracy.high;
        break;

      case PrecisaoLocalizacaoEnum.melhor:
        return LocationAccuracy.best;
        break;

      case PrecisaoLocalizacaoEnum.melhorParaNavegacao:
        return LocationAccuracy.bestForNavigation;
        break;

      default:
        return null;
        break;
    }
  }

  GeolocationPermission converteParaGeolocationPermission(MetodoLocalizacaoEnum metodoLocalizacao) {
    switch (metodoLocalizacao) {
      case MetodoLocalizacaoEnum.sempre:
        return GeolocationPermission.location;
        break;

      case MetodoLocalizacaoEnum.foreground:
        return GeolocationPermission.locationWhenInUse;
        break;

      case MetodoLocalizacaoEnum.background:
        return GeolocationPermission.locationAlways;
        break;

      default:
        return null;
        break;
    }
  }

  LocationOptions converteParaLocationOptions(GeolocacalizacaoOpcoesTempoReal geolocacalizacaoOpcoesTempoReal) {
    return LocationOptions(accuracy: converteParaLocationAccuracy(geolocacalizacaoOpcoesTempoReal.precisaoLocalizacao), distanceFilter: geolocacalizacaoOpcoesTempoReal.distanciaParaAtualizacao, timeInterval: geolocacalizacaoOpcoesTempoReal.intervaloDeAtualizacaoMilissegundos);
  }
}
