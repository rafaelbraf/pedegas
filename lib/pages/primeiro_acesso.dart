import 'package:appdogas/model/usuario.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrimeiroAcesso extends StatefulWidget {
  @override
  _PrimeiroAcessoState createState() => _PrimeiroAcessoState();
}

class _PrimeiroAcessoState extends State<PrimeiroAcesso> {

  TextEditingController _controllerNome = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  _validarCampos() async {

    String nome = _controllerNome.text;

    if(nome.isNotEmpty) {

      FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();

      Usuario usuario = Usuario();
      usuario.nome = nome;
      usuario.telefone = firebaseUser.phoneNumber;

      _cadastro(firebaseUser, usuario);

    }

  }

  _cadastro(FirebaseUser user, Usuario usuario) async {

    Firestore db = Firestore.instance;
    db.collection('usuarios').document(user.phoneNumber).setData(usuario.toMap());
    Navigator.pushReplacementNamed(context, "/tela_pedido");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Primeiro acesso"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              "Para continuar precisamos saber seu nome",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controllerNome,
              style: TextStyle(fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(fontWeight: FontWeight.normal)
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(
                  Radius.circular(5)
                )                
              ),
              child: FlatButton(
                onPressed: _validarCampos,
                child: Text("Continuar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
