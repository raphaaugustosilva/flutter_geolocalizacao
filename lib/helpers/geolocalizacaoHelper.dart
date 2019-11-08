import 'package:geolocator/geolocator.dart';
import 'package:flutter_geolocalizacao/models/geolocalizacao.dart';
import 'package:flutter_geolocalizacao/database/dadosMemoria.dart';

class GeolocalizacaoHelper {
  PrecisaoLocalizacaoEnum precisaoLocalizacao = PrecisaoLocalizacaoEnum.alta;
  MetodoLocalizacaoEnum metodoLocalizacao = MetodoLocalizacaoEnum.sempre;

  GeolocalizacaoHelper({this.precisaoLocalizacao, this.metodoLocalizacao});

  GeolocalizacaoHelper.dadosMemoria() {
    this.precisaoLocalizacao = DadosMemoria.instancia.precisaoLocalizacao ?? this.precisaoLocalizacao;
    this.metodoLocalizacao = DadosMemoria.instancia.metodoLocalizacao ?? this.metodoLocalizacao;
  }

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

  Future<Position> recuperarUltimaPosicaoConhecida() async {
    try {
      return await _geolocator.getLastKnownPosition(desiredAccuracy: converteParaLocationAccuracy(this.precisaoLocalizacao), locationPermissionLevel: converteParaGeolocationPermission(this.metodoLocalizacao));
    } catch (e) {
      print("Erro ao recuperarUltimaLocalizacaoConhecida. Detalhes: $e");
      return null;
    }
  }

  Future<Position> recuperarPosicaoAtual() async {
    try {
      return await _geolocator.getCurrentPosition(desiredAccuracy: converteParaLocationAccuracy(this.precisaoLocalizacao), locationPermissionLevel: converteParaGeolocationPermission(this.metodoLocalizacao));
    } catch (e) {
      print("Erro ao recuperarPosicaoAtual. Detalhes: $e");
      return null;
    }
  }

  Future<List<Placemark>> recuperarLocalizacaoDeUmaPosicao(double latitude, double longitude, {String localizaoDeTraducao = "pt_BR"}) async {
    try {
      return await _geolocator.placemarkFromCoordinates(latitude, longitude, localeIdentifier: localizaoDeTraducao);
    } catch (e) {
      print("Erro ao recuperarLocalizacaoDeUmaPosicao. Detalhes: $e");
      return null;
    }
  }

  Future<List<Placemark>> recuperarLocalizacaoDeUmEndereco(String endereco, {String localizaoDeTraducao = "pt_BR"}) async {
    try {
      return await _geolocator.placemarkFromAddress(endereco, localeIdentifier: localizaoDeTraducao);
    } catch (e) {
      print("Erro ao recuperarPosicaoDeUmEndereco. Detalhes: $e");
      return null;
    }
  }

  Stream<Position> recuperarPosicaoEmTempoReal(GeolocacalizacaoOpcoesTempoReal geolocacalizacaoOpcoesTempoReal) {
    try {
      var permissao = converteParaGeolocationPermission(geolocacalizacaoOpcoesTempoReal.metodoLocalizacao);
      return _geolocator.getPositionStream(converteParaLocationOptions(geolocacalizacaoOpcoesTempoReal), permissao);
    } catch (e) {
      print("Erro ao recuperarPosicaoEmTempoReal. Detalhes: $e");
      return null;
    }
  }

  Future<double> calcularDistanciaEntreCoordenadas(double latitudeInicial, double longitudeInicial, double latitudeFinal, double longitudeFinal) {
    try {
      return _geolocator.distanceBetween(latitudeInicial, longitudeInicial, latitudeFinal, longitudeFinal);
    } catch (e) {
      print("Erro ao calcularDistanciaEntreCoordenadas. Detalhes: $e");
      return null;
    }
  }

  String retornaNomeLocalizacao(Placemark localizacaoCompleta) {
    return localizacaoCompleta == null ? "" : "${localizacaoCompleta?.thoroughfare ?? ""}, ${localizacaoCompleta?.subThoroughfare ?? ""}, ${localizacaoCompleta?.locality ?? ""} ${localizacaoCompleta?.subLocality ?? ""}, ${localizacaoCompleta?.administrativeArea ?? ""} ${localizacaoCompleta?.subAdministrativeArea ?? ""}, CEP: ${localizacaoCompleta?.postalCode ?? ""}, ${localizacaoCompleta?.country ?? ""}";
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
