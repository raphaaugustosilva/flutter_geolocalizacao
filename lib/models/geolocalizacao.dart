import 'package:flutter_geolocalizacao/database/dadosMemoria.dart';

enum AcessoGPSDeviceEnum { indisponivel, disponivel }
enum AcessoGPSAplicativoEnum { negado, desabilitado, permitido, restrito, desconhecido }

enum PrecisaoLocalizacaoEnum { maisBaixa, baixa, media, alta, melhor, melhorParaNavegacao }
// maisBaixa => Localização a uma distância de 3000m no iOS e 500m no Android
// baixa => Localização a uma distância de 1000m no iOS e 500m no Android
// media => Localização a uma distância de 100m no iOS e entre 100m e 500m no Android
// alta => Localização a uma distância de 10m no iOS e entre 0m e 100m no Android
// melhor => Localização a uma distância de ~0m no iOS e entre 0m e 100m no Android
// melhorParaNavegacao => Localização otimizada para navegação no iOS e "melhor" explicada anteriormente  no Android

enum MetodoLocalizacaoEnum { foreground, background, sempre }

class GeolocacalizacaoOpcoesTempoReal {
  MetodoLocalizacaoEnum metodoLocalizacao;
  PrecisaoLocalizacaoEnum precisaoLocalizacao;
  int distanciaParaAtualizacao;
  int intervaloDeAtualizacaoMilissegundos; //APENAS PARA ANDROID, iOS NAO SUPORTA

  GeolocacalizacaoOpcoesTempoReal(this.metodoLocalizacao, this.precisaoLocalizacao, this.distanciaParaAtualizacao, {this.intervaloDeAtualizacaoMilissegundos = 0});

  GeolocacalizacaoOpcoesTempoReal.dadosMemoria(this.distanciaParaAtualizacao, {this.intervaloDeAtualizacaoMilissegundos = 0}) {
    this.precisaoLocalizacao = DadosMemoria.instancia.precisaoLocalizacao ?? this.precisaoLocalizacao;
    this.metodoLocalizacao = DadosMemoria.instancia.metodoLocalizacao ?? this.metodoLocalizacao;
  }
}

class Geolocacalizacao {}
