import 'package:appdogas/model/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class UsuarioFirebase {

  static Future<FirebaseUser> getUsuarioAtual() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.currentUser();
  }

  static Future<Usuario> getDadosUsuarioLogado() async {

    FirebaseUser firebaseUser = await getUsuarioAtual();
    String telefoneUsuario = firebaseUser.phoneNumber;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot = await db.collection("usuarios")
        .document( telefoneUsuario )
        .get();

    Map<String, dynamic> dados = snapshot.data;
    String nome = dados["nome"];
    String telefone = dados["telefone"];
    String endereco = dados['endereco'];

    Usuario usuario = Usuario();
    usuario.idUsuario = telefoneUsuario;
    usuario.nome = nome;
    usuario.telefone = telefone; 
    usuario.endereco = endereco;

    return usuario;

  }

  static atualizarDadosLocalizacao(String idRequisicao, double lat, double lon) async {

    Firestore db = Firestore.instance;

    Usuario entregador = await getDadosUsuarioLogado();
    //entregador.latitude = lat;
    //entregador.longitude = lon;

    db.collection("requisicoes")
    .document( idRequisicao )
    .updateData({
      "entregador" : entregador.toMap()
    });

  }

}