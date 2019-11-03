import 'dart:async';

import 'package:appdogas/util/status_pedido.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PedidosRealizadosUsuario extends StatefulWidget {
  @override
  _PedidosRealizadosUsuarioState createState() => _PedidosRealizadosUsuarioState();
}

class _PedidosRealizadosUsuarioState extends State<PedidosRealizadosUsuario> {

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Firestore db = Firestore.instance;

  String idUsuario;
  String telefone;

  Stream<QuerySnapshot> _adicionarListenerRequisicoes() {

    final stream = db.collection("pedidos")
      .where("status", isEqualTo: StatusPedido.CONFIRMADA)  
      .where("idUsuario", isEqualTo: idUsuario)    
      .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });

  }

  _recuperarRequisicaoUsuario() async {
    //RECUPERA DADOS DO USUARIO LOGADO
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    idUsuario = firebaseUser.phoneNumber;
    //RECUPERA REQUISICAO ATIVA
    DocumentSnapshot documentSnapshot = await db
      .collection("requisicoes")
      .document(idUsuario)
      .get();
    var dadosRequisicao = documentSnapshot.data;
    if(dadosRequisicao == null) {
      _adicionarListenerRequisicoes();
    } 
  }

  @override
  void initState() {    
    super.initState();
    //RECUPERAR REQUISICAO ATIVA PARA VERIFICAR SE O MOTORISTA ESTÁ ATENDENDO ALGUMA REQUISICAO E ENVIA ELE
    //PARA TELA DE CORRIDA
    _recuperarRequisicaoUsuario();
  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 100,),
          Text("Carregando pedidos realizados..."),
          SizedBox(height: 20,),
          CircularProgressIndicator()
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text("Você ainda não fez nenhum pedido.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
    );

    return Scaffold(

      appBar: AppBar(
        title: Text("Pedidos realizados"),                
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){

          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return mensagemCarregando;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if(snapshot.hasError) {
                return Text("Erro ao carregar pedidos realizados");
              } else {
                QuerySnapshot querySnapshot = snapshot.data;
                if(querySnapshot.documents.length == 0) {
                  return mensagemNaoTemDados;
                } else {

                  return ListView.separated(
                    itemCount: querySnapshot.documents.length,
                    separatorBuilder: (context, indice) => Divider(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    itemBuilder: (context, indice) {

                      List<DocumentSnapshot> requisicoes = querySnapshot.documents.toList();
                      DocumentSnapshot item = requisicoes[indice];

                      String nomeCliente = item["cliente"]["nome"];
                      String endereco = item["destino"]["endereco"];                      
                      int qtd = item["quantidade"];
                      int valorTotal = item["valorTotal"];
                      String formaPagamento = item["formaPagamento"];
                      String data = item["dataEntregaRealizada"];
                      String hora = item["horaEntregaRealizada"];

                      return Padding(                        
                        padding: EdgeInsets.all(2),
                        child: Card(
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: ListTile(
                              title: Text("$endereco", style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[                                
                                  Text("$qtd Gás P13 13Kg - R\$ $valorTotal - $formaPagamento"),
                                  Text("Entrega realizada às $hora - $data")
                                ],
                              ),
                            ),
                          )
                        ),
                      );

                    },
                  );

                }
              }

              break;
              default:
          }

        },
      ),

    );
  }
}