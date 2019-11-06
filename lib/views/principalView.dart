import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PrincipalView extends StatefulWidget {
  @override
  _PrincipalViewState createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  bool permissaoAcessoGPS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Geolocalização", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("Status GPS: "),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text("Precisão da localização: "),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text("Última localização conhecida: "),
              SizedBox(width: 10),
              RaisedButton(child: Text("Obter última localização"), onPressed: () {}),
            ],
          ),
          Text("Nome última localização conhecida"),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text("Localização atual: "),
              SizedBox(width: 10),
              RaisedButton(child: Text("Obter localização"), onPressed: () {}),
            ],
          ),
          SizedBox(height: 10),
          Text("Localização em tempo real"),
          Row(
            children: <Widget>[
              Text("Distância para atualização de GPS"),
              SizedBox(width: 10),
              Text("10"),
              Text(" metros"),
              RaisedButton(child: Text("Iniciar"), onPressed: () {}),
            ],
          ),
          Text("Resultados"),
          // ListView.builder(
          //   itemCount: 4,
          //   itemBuilder: (context, indice) {
          //     return Text(indice.toString());
          //   },
          // )
        ],
      ),
    );
  }
}
