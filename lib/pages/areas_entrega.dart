import 'package:flutter/material.dart';

class AreaEntrega extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Áreas de Entrega"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Bairros em que entregamos:", style: TextStyle(fontWeight: FontWeight.bold),),
              Text(" - Bairro 1"),
              Text(" - Bairro 2"),
              Text(" - Bairro 3"),
              Text(" - Bairro 4"),
              Text(" - Bairro 5"),
              Text(" - Bairro 6")
            ],
          ),
        ),
      ),
    );
  }
}