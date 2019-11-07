import 'package:flutter/material.dart';

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
}
