import 'package:flutter/material.dart';

Widget carregandoWidget({double height, double width}) {
  return Center(child: Container(height: height ?? 18, width: width ?? 18, child: CircularProgressIndicator(strokeWidth: 2)));
}
