import 'package:appdogas/model/usuario.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Endereco extends StatefulWidget {
  @override
  _EnderecoState createState() => _EnderecoState();
}

class _EnderecoState extends State<Endereco> {

  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerNumero = TextEditingController();
  TextEditingController _controllerBairro = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();

  String enderecoCompleto;

  _validarCampos() {

    String endereco = _controllerEndereco.text;
    String numero = _controllerNumero.text;
    String bairro = _controllerBairro.text;
    String cidade = _controllerCidade.text;

    if(endereco.isNotEmpty) {
      if(bairro.isNotEmpty) {
        if(cidade.isNotEmpty) {
          enderecoCompleto = "$endereco, $numero - $bairro, $cidade";
          _cadastrarEndereco(enderecoCompleto);
        }
      }
    }

  }

  _cadastrarEndereco(String enderecoCompleto) async {

    Usuario usuario = await UsuarioFirebase.getDadosUsuarioLogado();
    String telefone = usuario.telefone;

    Firestore db = Firestore.instance;
    db.collection('usuarios').document(telefone).updateData({
      "endereco" : enderecoCompleto
    });

  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Endereço para entrega"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: _controllerEndereco,
                decoration: InputDecoration(
                  labelText: "Endereço"
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _controllerNumero,
                decoration: InputDecoration(
                  labelText: "Número"
                ),
              ),
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: _controllerBairro,
                decoration: InputDecoration(
                  labelText: "Bairro"
                ),
              ),
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: _controllerCidade,
                decoration: InputDecoration(
                  labelText: "Cidade"
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
                  child: Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  onPressed: (){
                    _validarCampos();
                    Navigator.pushReplacementNamed(context, "/tela_pedido");
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}