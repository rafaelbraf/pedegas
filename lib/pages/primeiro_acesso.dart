import 'dart:developer';

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
  TextEditingController _controllerLogradouro = TextEditingController();
  TextEditingController _controllerNumero = TextEditingController();
  TextEditingController _controllerComplemento = TextEditingController();
  TextEditingController _controllerBairro = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();

  String endereco = "";

  FirebaseAuth auth = FirebaseAuth.instance;

  _validarCampos() async {

    String nome = _controllerNome.text;
    String logradouro = _controllerLogradouro.text;
    String numero = _controllerNumero.text;
    String complemento = _controllerComplemento.text;
    String bairro = _controllerBairro.text;
    String cidade = _controllerCidade.text;

    if(complemento.isEmpty) {
      complemento = "";
    }

    String endereco = "";

    if(logradouro.isNotEmpty && numero.isNotEmpty && bairro.isNotEmpty && cidade.isNotEmpty) {
      endereco = "$logradouro, $numero $complemento - $bairro";
    } 

    if(nome.isNotEmpty) {

      FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();

      Usuario usuario = Usuario();
      usuario.nome = nome;
      usuario.telefone = firebaseUser.phoneNumber;
      usuario.endereco = endereco;

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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(
                "Seu nome",
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
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe seu nome",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              Text(
                "Seu endereço",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: _controllerLogradouro,
                style: TextStyle(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Logradouro",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe o logradouro",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              TextField(
                controller: _controllerNumero,
                style: TextStyle(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Número",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe o número",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              TextField(
                controller: _controllerComplemento,
                style: TextStyle(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Complemento (opcional)",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe o complemento",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              TextField(
                controller: _controllerBairro,
                style: TextStyle(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Bairro",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe o bairro",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              TextField(
                controller: _controllerCidade,
                style: TextStyle(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Cidade",
                  labelStyle: TextStyle(fontWeight: FontWeight.normal),
                  hintText: "Informe a cidade",
                  hintStyle: TextStyle(fontWeight: FontWeight.normal),
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
        )
      ),
    );
  }
}
