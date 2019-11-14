import 'package:flutter/material.dart';

enum ResultadoMensagemEnum { ok, cancelar }

class GeralHelper {
  GeralHelper._construtorPrivate();
  static final instancia = GeralHelper._construtorPrivate();

  void escondeTeclado(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Offset recuperaPosicaoElemento(GlobalKey keyElemento) {
    final RenderBox renderBloco = keyElemento?.currentContext?.findRenderObject();
    final Offset posicao = renderBloco?.localToGlobal(Offset.zero);
    return posicao;
  }

  Size recuperaTamanhoElemento(GlobalKey keyElemento) {
    final RenderBox renderBloco = keyElemento?.currentContext?.findRenderObject();
    final Size tamanho = renderBloco?.size;
    return tamanho;
  }

  Future exibirMensagem(BuildContext context, String titulo, String mensagem) async {
    // flutter defined function
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: <Widget>[
            FlatButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<ResultadoMensagemEnum> exibirMensagemAcaoUsuario(BuildContext context, String titulo, String mensagem, String textoBotaoOK, String textoBotaoCancelar) async {
    // flutter defined function
    return await showDialog<ResultadoMensagemEnum>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: <Widget>[
            FlatButton(
              child: Text(textoBotaoCancelar),
              onPressed: () {
                Navigator.of(context).pop(ResultadoMensagemEnum.cancelar);
              },
            ),
            FlatButton(
              child: Text(textoBotaoOK),
              onPressed: () {
                Navigator.of(context).pop(ResultadoMensagemEnum.ok);
              },
            ),
          ],
        );
      },
    );
  }

  // void exibirMensagemNoSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String mensagem, {Color corSnackBar}) {
  //   final Color _corSnackBar = corSnackBar ?? Colors.black.withOpacity(0.5);
  //   scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: _corSnackBar));
  // }

  String extraiNumerosString(String texto) {
    if (texto == null) return "";

    var intRegex = RegExp("\\d+");

    if (intRegex.hasMatch(texto)) {
      return intRegex.allMatches(texto).map((m) => m[0]).join();
    } else
      return "";
  }

  double converteMpsParaKmh(double metrosPorSegundo) {
    return ((metrosPorSegundo ?? 0) * 60 * 60) / 1000;
  }
}
