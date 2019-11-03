import 'package:appdogas/model/usuario.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarUsuario extends StatefulWidget {
  @override
  _EditarUsuarioState createState() => _EditarUsuarioState();
}

class _EditarUsuarioState extends State<EditarUsuario> {

  String nome;
  String telefone;

  TextEditingController _controllerNome = TextEditingController();

  _recuperarDados() async {

    Usuario usuario = await UsuarioFirebase.getDadosUsuarioLogado();
        
    setState(() {
     _controllerNome.text = usuario.nome; 
    });
  }

  _editarUsuario() async {

    Usuario usuario = await UsuarioFirebase.getDadosUsuarioLogado();
    telefone = usuario.telefone;
    nome = _controllerNome.text;

    Firestore db = Firestore.instance;

    db.collection('usuarios').document(telefone).updateData({
      "nome" : nome
    });

    Navigator.pushReplacementNamed(context, "/tela_pedido");

  }

  @override
  void initState() {
    super.initState();
    _recuperarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar usuário"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controllerNome,
                decoration: InputDecoration(
                  labelText: "Nome"
                ),
              ),
              Container(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(32))
                ),
                child: FlatButton(
                  child: Text("Editar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  onPressed: _editarUsuario,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}