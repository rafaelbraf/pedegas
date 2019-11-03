import 'package:firebase_auth/firebase_auth.dart';

class Usuario {

  //  DADOS CLIENTE
  String _idUsuario;
  String _nome; 
  String _tipoUsuario;
  String _telefone;
  String _endereco;

  Usuario();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "nome"                  : this.nome,
      "telefone"              : this.telefone,
      "endereco"              : this.endereco,
    };
    return map;
  }
  
  deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get telefone => _telefone;

  set telefone(String value) {
    _telefone = value;
  }

}

