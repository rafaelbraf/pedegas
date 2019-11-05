import 'dart:async';

import 'package:appdogas/util/status_pedido.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Aguardando extends StatefulWidget {
  @override
  _AguardandoState createState() => _AguardandoState();
}

class _AguardandoState extends State<Aguardando> {

  TextEditingController _controllerNota = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Firestore db = Firestore.instance;

  String _idPedido;

  Stream<QuerySnapshot> _adicionarListenerRequisicoes(String idPedido) {

    final stream = db.collection("pedidos")
      // .where("status", isEqualTo: StatusPedido.AGUARDANDO)
      // .where("status", isEqualTo: StatusPedido.ACEITO)
      // .where("status", isEqualTo: StatusPedido.A_CAMINHO)
      .where("id", isEqualTo: idPedido)
      .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });

  }

  _recuperarPedidoAtivo() async {

    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;

    DocumentSnapshot documentSnapshot = await db.collection("pedidos").document(firebaseUser.uid).get();    

    DocumentSnapshot snapshot = await db.collection("pedido_ativo").document(firebaseUser.phoneNumber).get();
    var novoSnapshot = snapshot.data;
    _idPedido = novoSnapshot["id_pedido"];

    var dadosRequisicao = documentSnapshot.data;
    if(dadosRequisicao == null) {
      _adicionarListenerRequisicoes(_idPedido);
    } 
  }

  _cancelarPedido() async {

    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();    
    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot = await db.collection("pedido_ativo").document(firebaseUser.phoneNumber).get();

    var dadosRequisicao = documentSnapshot.data;
    String idPedido = dadosRequisicao["id_pedido"];

    db.collection('pedidos').document(idPedido).delete();
    db.collection('pedido_ativo').document(firebaseUser.phoneNumber).delete();
    
    Navigator.pushReplacementNamed(context, "/tela_pedido");

  }

  _confirmarPedido() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Avaliação de Serviço"),
          content: Text("Deseja avaliar nosso serviço?"),
          actions: <Widget>[            
            FlatButton(
              child: Text("Cancelar", style: TextStyle(color: Colors.red),),
              onPressed: () => Navigator.pushReplacementNamed(context, "/tela_pedido")
            ),
            FlatButton(
              child: Text("Avaliar"),
              onPressed: _avaliarPedido,
            ),
          ],
        );
      }
    );

  }

  _mandarAvaliacao() async {

    String nota = _controllerNota.text;
    int notaint = int.parse(nota);

    if(notaint >= 1 && notaint <= 5) {

      db.collection('pedidos').document(_idPedido).updateData({
      "avaliacao" : notaint
      });

      Navigator.pushReplacementNamed(context, "/tela_pedido");

    } else {

      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text("Nota precisa ser de 1 a 5"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
      );

    }

    

  }

  _avaliarPedido() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Avaliação"),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("De 1 a 5"),
                Text("Avalie nosso serviço"),
                TextField(                  
                  controller: _controllerNota,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Enviar"),
              onPressed: _mandarAvaliacao
            )
          ],
        );
      }
    );

  }

  @override
  void initState() {
    super.initState();
    _recuperarPedidoAtivo();
  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 100,),
          Text("Carregando pedido..."),
          SizedBox(height: 20,),
          CircularProgressIndicator()
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text("Você ainda não fez nenhum pedido.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),),
    );

    return Scaffold(

      appBar: AppBar(
        title: Text("Meu Pedido"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () => Navigator.pushNamed(context, "/tela_ajuda"),
          ),
        ],     
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
                return Text("Erro ao carregar pedido");
              } else {
                QuerySnapshot querySnapshot = snapshot.data;
                if(querySnapshot.documents.length == 0) {
                  return mensagemNaoTemDados;
                } else {                  

                  return ListView.separated(
                    itemCount: querySnapshot.documents.length,
                    separatorBuilder: (context, indice) => Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    itemBuilder: (context, indice) {

                      List<DocumentSnapshot> requisicoes = querySnapshot.documents.toList();
                      DocumentSnapshot item = requisicoes[indice];

                      String status = item["status"];
                      String idRequisicao = item["id"];
                      //String nomeCliente = item["cliente"]["nome"];
                      //ENDEREÇO
                      String endereco = item["destino"]["endereco"];                      
                      //DATA E HORA DO PEDIDO
                      String data = item["dataPedidoRealizado"];
                      String hora = item["horaPedidoRealizado"];
                      //VALOR
                      int qtd = item["quantidade"];
                      int valorTotal = item["valorTotal"];
                      String formaPagamento = item["formaPagamento"];                      

                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Card(
                              elevation: 4.0,
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: ListTile(
                                      title: Text(
                                        "Pedido #$idRequisicao",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Status: $status"),
                                          Text("Hora: $hora"),
                                          Text("Data: $data")
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  ListTile(
                                    title: Text(
                                      "GÁS P13 13KG",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Quantidade: $qtd"),
                                        Text("Forma de Pagamento: $formaPagamento"),
                                        Text("Valor Total: R\$ ${valorTotal.toStringAsFixed(0)}"),                                        
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  ListTile(
                                    title: Text(
                                      "Entregar em",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("$endereco"),
                                  ),
                                  Container(height: 10,)
                                ],
                              )
                            ),

                            status == StatusPedido.AGUARDANDO
                            ? Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  color: Colors.red,
                                ),
                                child: FlatButton(
                                  child: Text(
                                    "Cancelar pedido", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),                    
                                  ),
                                  color: Colors.red,                                  
                                  onPressed: _cancelarPedido
                                ),
                              )
                            )
                            : Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  color: Colors.grey
                                ),
                                child: FlatButton(
                                  child: Text(
                                    "Entregador a caminho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){},
                                ),
                              )
                            ),

                            status == StatusPedido.CONFIRMADA
                            ? Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  color: Colors.green
                                ),
                                child: FlatButton(
                                  child: Text(
                                    "Confirmar entrega", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),                    
                                  ),
                                  onPressed: () {
                                    _confirmarPedido();
                                  }
                                ),
                              )
                            )
                            : Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: Colors.grey
                                ),
                                child: FlatButton(
                                  child: Text(
                                    "Confirmar entrega", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){},
                                ),
                              )
                            ),
                            
                            // Padding(
                            //   padding: EdgeInsets.all(5),
                            //   child: Container(
                            //     width: MediaQuery.of(context).size.width,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.all(
                            //         Radius.circular(5)
                            //       ),
                            //       color: Colors.red
                            //     ),
                            //     child: FlatButton(
                            //       child: Text("Cancelar pedido", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            //       onPressed: _cancelarPedido,
                            //     ),
                            //   ),
                            // )

                          ],
                        )
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