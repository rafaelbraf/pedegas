import 'dart:async';

import 'package:appdogas/model/destino.dart';
import 'package:appdogas/model/pedido.dart';
import 'package:appdogas/model/usuario.dart';
import 'package:appdogas/util/status_pedido.dart';
import 'package:appdogas/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TelaPedido extends StatefulWidget {
  @override
  _TelaPedidoState createState() => _TelaPedidoState();
}

class _TelaPedidoState extends State<TelaPedido> {

  int qtd = 1;

  int precoGasDinheiro;
  int precoGasCartao;
  int precoCalculado = 0;
  String formaPagamentoSelecionado = "Selecionar";

  String telefone;
  String endereco = "Informar endereço para entrega";
  String nome;
  String _mensagemErro = "";

  StreamSubscription<DocumentSnapshot> _streamSubscriptionRequisicoes;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Map<String, dynamic> _dadosPedido;

  Firestore db = Firestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController _controllerEndereco = TextEditingController();
  TextEditingController _controllerNumero = TextEditingController();
  TextEditingController _controllerComplemento = TextEditingController();
  TextEditingController _controllerBairro = TextEditingController();
  TextEditingController _controllerCidade = TextEditingController();

  void iniciarFirebaseListeners() {
 
    _firebaseMessaging.getToken().then((token){
      print("Firebase token " + token);
    });
 
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('mensagem recebida $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }
 
  _aumentarQuantidade() {
    setState(() {
     if(qtd >= 6) {
       qtd = 6;       
       _atualizaPrecoGas();
     } else {
       qtd++;
       _atualizaPrecoGas();
     }
    });
  }

  _diminuirQuantidade() {
    setState(() {
     if(qtd <= 1) {       
       qtd = 1;
       _atualizaPrecoGas();
     } else {      
       qtd --;
       _atualizaPrecoGas();
     }
    });
  }

  _atualizaPrecoGas() {
    if (formaPagamentoSelecionado == "Cartão") {
      setState(() {        
        precoCalculado = precoGasCartao * qtd;        
      });      
    } else {
      setState(() {
       precoCalculado = precoGasDinheiro * qtd;
      });
    } 
  }

  _atualizaPrecoGasCartao() {
    setState(() {
      formaPagamentoSelecionado = "Cartão";
      precoCalculado = precoGasCartao * qtd;
    });
  }

  _atualizaPrecoGasDinheiro() {
    setState(() {
      formaPagamentoSelecionado = "Dinheiro";
      precoCalculado = precoGasDinheiro * qtd;
    });
  }

  _recuperarDados() async {
    Usuario usuario = await UsuarioFirebase.getDadosUsuarioLogado();

    if(usuario.nome == null && usuario.telefone == null) {
      setState(() {
       nome = "Carregando nome...";
       telefone = "Carregando telefone..."; 
      });
    } else {
      setState(() {
        nome = usuario.nome;
        telefone = usuario.telefone; 
      });
    }
    
  }

  // _pesquisarEndereco() {
  //   MapBoxPlaceSearchWidget(
  //     popOnSelect: true,
  //     apiKey: "pk.eyJ1IjoicmFmYWJydW5vZiIsImEiOiJjazIzbDdiZHUyNmJvM2RtdTd6MDN3ZTZ5In0.Jfoh4ggH-ab0mc33XrOcHw",
  //     limit: 10,
  //     onSelected: (place) {
  //       setState(() {
  //        endereco = place.toString(); 
  //       });
  //     },
  //     context: context,
  //   );
  // }

  _sair() async {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sair"),
          content: Text("Tem certeza que deseja sair do app?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Sim", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
              onPressed: (){
                Usuario().deslogarUsuario();
                SystemNavigator.pop();
              },
            ),
            FlatButton(
              child: Text("Não", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );
  }

  _fazerPedido() {

    if (endereco == "Informar endereço para entrega") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Endereço não informado"),
            content: Text("Para fazer o pedido é necessário informar endereço para entrega."),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        }
      );
    } else if (precoCalculado == 0) {

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Valor do Gás"),
            content: Text("Espere o valor do gás ser carregado para que você possa fazer o pedido."),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context)
              )
            ],
          );
        }
      );

    } else {

      String cidade = _controllerCidade.text;
      
      if (endereco.isNotEmpty && cidade == "Fortaleza") {

        Destino destino = Destino();
        destino.endereco = endereco;

        showDialog(
          context: context,
          builder: (context) {

            return AlertDialog(

              title: Text("Confirmação de pedido"),
              content: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,         
                  children: <Widget>[
                    Text("Entregar em", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("$endereco"),
                    Divider(),
                    Text("Pagamento", style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("$qtd Gás P13"),
                    Text("Forma de pagamento: $formaPagamentoSelecionado"),
                    Divider(),
                    Text("Valor total: R\$ ${precoCalculado.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.red,
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  textColor: Colors.green,
                  child: Text("Confirmar"),
                  onPressed: (){
                    _salvarPedido(destino);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
        );
        
      } else {

        showDialog(
          context: context,
          builder: (context) {

            return AlertDialog(

              title: Text("OPS..."),
              content: Text("Desculpe! Mas ainda não entregamos na sua regiao, fazemos entregas apenas em Fortaleza =("),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.green,
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          }
        );

      }

    }

  }

  

  _adicionarListenerRequisicao(String idPedido) async {

    Firestore db = Firestore.instance;
    _streamSubscriptionRequisicoes = await 
    db.collection("pedidos").document( idPedido ).snapshots().listen((snapshot){

      if( snapshot.data != null ){        

        Map<String, dynamic> dados = snapshot.data;
        _dadosPedido = dados;
        String status = dados["status"];
        print("status: " + status);
        idPedido = dados["id"];
        print("id: " + idPedido.toString());

        switch( status ){
          case StatusPedido.AGUARDANDO :
            _statusAguardando();
            break;
        }
      }
    });
  }

  _statusAguardando() {
    Navigator.pushReplacementNamed(context, "/aguardando_pedido");
  }

  _salvarPedido(Destino destino) async {

    var datetime = DateTime.now();

    var dia = datetime.day;
    var mes = datetime.month;
    var ano = datetime.year;

    var hora = datetime.hour;
    var minuto = datetime.minute;
    var segundos = datetime.second; 

    Usuario cliente = await UsuarioFirebase.getDadosUsuarioLogado();    

    Destino destino = Destino();
    destino.endereco = endereco;
    
    Pedido pedido = Pedido();
    pedido.destino = destino;
    pedido.cliente = cliente;
    pedido.status = StatusPedido.AGUARDANDO;
    pedido.dataPedidoRealizado = "$dia/$mes/$ano";
    pedido.horaPedidoRealizado = "$hora:$minuto:$segundos";
    pedido.formaPagamento = formaPagamentoSelecionado;
    pedido.quantidade = qtd;
    pedido.valorTotal = precoCalculado;

    Firestore db = Firestore.instance;

    db.collection('pedidos').document(pedido.idPedido).setData(pedido.toMap());

    //Salvar requisição ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_pedido"] = pedido.idPedido;
    dadosRequisicaoAtiva["id_usuario"] = cliente.idUsuario;
    dadosRequisicaoAtiva['nome'] = cliente.nome;
    dadosRequisicaoAtiva['telefone'] = cliente.telefone;
    dadosRequisicaoAtiva['endereco'] = destino.endereco;
    dadosRequisicaoAtiva['quantidade'] = pedido.quantidade;
    dadosRequisicaoAtiva['valorTotal'] = pedido.valorTotal;
    dadosRequisicaoAtiva['formaPagamento'] = pedido.formaPagamento;
    dadosRequisicaoAtiva["status"] = StatusPedido.AGUARDANDO;

    db.collection("pedido_ativo").document(cliente.idUsuario).setData(dadosRequisicaoAtiva);

    //Adicionar listener requisicao
    if( _streamSubscriptionRequisicoes == null ){
      _adicionarListenerRequisicao( pedido.idPedido );
    }

  }

  _recuperarPedidoAtivo() async {
    CircularProgressIndicator(backgroundColor: Colors.green,);
    //RECUPERA DADOS DO USUARIO LOGADO
    FirebaseUser firebaseUser = await UsuarioFirebase.getUsuarioAtual();
    //RECUPERA REQUISICAO ATIVA
    DocumentSnapshot documentSnapshot = await db.collection("pedido_ativo").document(firebaseUser.phoneNumber).get();
    var dadosRequisicao = documentSnapshot.data;
    if(dadosRequisicao == null) {
      _adicionarListenerRequisicoes();
    } else {
      String idPedido = dadosRequisicao["id_pedido"];
      Navigator.pushReplacementNamed(context, "/aguardando_pedido", arguments: idPedido);
    }
  }

  Stream<QuerySnapshot> _adicionarListenerRequisicoes() {

    final stream = db.collection("pedidos")
      .where("status", isEqualTo: StatusPedido.AGUARDANDO)
      .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });

  }

  _lidarComTexto() {

    String logradouro = _controllerEndereco.text;
    String numero = _controllerNumero.text;
    String complemento = _controllerComplemento.text;
    String bairro = _controllerBairro.text;
    String cidade = _controllerCidade.text;

    if(logradouro.isEmpty || numero.isEmpty || bairro.isEmpty || cidade.isEmpty) {
      setState(() {
       _mensagemErro = "Preencha todos os campos com *";
      });
    } else {
      setState(() {
        endereco = "$logradouro, $numero $complemento - $bairro";
        _mensagemErro = "";
      });
    }
    Navigator.pop(context);
  }

  _alterarEndereco() async {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Alterar endereço para entrega"),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[                
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  controller: _controllerEndereco,
                  decoration: InputDecoration(
                    labelText: "Endereço*",
                    hintText: "Informe o endereço"
                  ),
                ),
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  controller: _controllerNumero,
                  decoration: InputDecoration(
                    labelText: "Número*",
                    hintText: "Informe o número"
                  ),
                ),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  controller: _controllerComplemento,
                  decoration: InputDecoration(
                    labelText: "Complemento",
                    hintText: "Informe o complemento"
                  ),
                ),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  controller: _controllerBairro,
                  decoration: InputDecoration(
                    labelText: "Bairro*",
                    hintText: "Informe o bairro"
                  ),
                ),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  controller: _controllerCidade,
                  decoration: InputDecoration(
                    labelText: "Cidade*",
                    hintText: "Informe a cidade"
                  ),
                ),
                Container(
                  child: Text(_mensagemErro, style: TextStyle(color: Colors.red),),
                )
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              height: 40,
              decoration: BoxDecoration(                
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: FlatButton(
                onPressed: () {                  
                  Navigator.pop(context);
                },
                child: Text("Cancelar", style: TextStyle(color: Colors.red),),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: FlatButton(
                onPressed: () {
                  _lidarComTexto();
                },
                child: Text("OK", style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        );

      }
    );
  }

  _editarUsuario() {
    Navigator.pushNamed(context, "/editar_usuario");
  }

  _recuperarPrecoGas() async {

    DocumentSnapshot snapshot = await db.collection('gas').document('valor').get();
    Map<String, dynamic> _dadosCartao = snapshot.data;

    String precoCartao = _dadosCartao['cartao'];
    String precoDinheiro = _dadosCartao['dinheiro'];
    
    setState(() {
     precoGasCartao = int.parse(precoCartao);
     precoGasDinheiro = int.parse(precoDinheiro);
     precoCalculado = precoGasDinheiro;
    });

  }
  

  @override
  void initState() { 
    super.initState();
    _recuperarPedidoAtivo();
    _recuperarDados();
    _recuperarPrecoGas();
    this.iniciarFirebaseListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Peça seu gás"),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.menu, color: Colors.white,),
        //   onPressed: (){},
        // ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help, color: Colors.white,),
            onPressed: (){
              Navigator.pushNamed(context, "/tela_ajuda");
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              color: Color(0xff388E3C),
                child: ListTile(
                title: Text("$nome", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                subtitle: Text("$telefone", style: TextStyle(color: Colors.white),),
                trailing: IconButton(icon: Icon(Icons.edit, color: Colors.white), onPressed: _editarUsuario,),
                onTap: _editarUsuario,
              ),
            ),
            ListTile(
              title: Text("Áreas de entrega"),
              trailing: Icon(Icons.location_city),
              onTap: () => Navigator.pushNamed(context, "/areas_entrega"),
            ),
            ListTile(
              title: Text("Pedidos realizados"),
              trailing: Icon(Icons.event_note),
              onTap: () => Navigator.pushNamed(context, "/pedidos_realizados"),
            ),
            ListTile(
              title: Text("Precisa de ajuda?"),
              trailing: Icon(Icons.help,),
              onTap: () => Navigator.pushNamed(context, "/tela_ajuda")
            ),
            ListTile(
              title: Text("Sair",),
              trailing: Icon(Icons.exit_to_app,),
              onTap: _sair,
            )
          ],
        ),
      ),
      body: Container(
        
        padding: EdgeInsets.only(right: 10, left: 10),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ConnectionStatusBar(
                color: Colors.red,
                title: Text("Sem conexão com a internet", style: TextStyle(color: Colors.white)),                
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Text(
                        "GÁS P13 13KG",
                        style: TextStyle(color: Color(0xff388E3C), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      "Residencial", 
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/gas.png",
                    scale: 2.0,
                  ),
                  Column(
                    children: <Widget>[
                      Text("Quantidade"),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,),
                            onPressed: _diminuirQuantidade
                          ),
                          Text("$qtd", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xff388E3C)),),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: _aumentarQuantidade,
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              //Divider(),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Entregar em",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Color(0xff388E3C),),
                  title: Text("$endereco"),
                  subtitle: Text("Aperte aqui para alterar endereço"),
                  onTap: _alterarEndereco,
                ),
                // child: Row(
                //   children: <Widget>[
                //     Icon(Icons.location_on, color: Colors.green,),
                //     Expanded( child: Text("$endereco"),),                    
                //   ],
                // ),
              ),
              // ListTile(
              //   leading: Icon(Icons.location_on, color: Colors.green,),
              //   title: Text("$endereco"),
              //   trailing: Icon(Icons.edit),
              //   onTap: _handlePressButton
              // ),
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   child: FlatButton(
              //     child: Text(
              //       "Alterar endereço",
              //       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              //     ),
              //     onPressed: _alterarEndereco,
              //   ),
              // ),
              //Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Pague na entrega",
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        child: Column(
                          children: <Widget>[
                            Image.asset("images/card.png", height: 40, width: 40,),
                            Text("Cartão", )
                          ],
                        ),
                        onPressed: _atualizaPrecoGasCartao
                      ),
                      FlatButton(
                        child: Column(
                          children: <Widget>[
                            Image.asset("images/money.png", height: 40, width: 40,),
                            Text("Dinheiro")
                          ],
                        ),
                        onPressed: _atualizaPrecoGasDinheiro
                      ),
                    ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[                        
                  Text("Forma de pagamento"),
                  Text("$formaPagamentoSelecionado", style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,                
                  children: <Widget>[
                    Text("Valor a pagar"),
                    Text(
                      "R\$ $precoCalculado", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff388E3C), fontSize: 18),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xff388E3C),
                    borderRadius: BorderRadius.all(
                      Radius.circular(32)
                    )
                  ),
                  child: FlatButton(
                    child: Text(
                      "Fazer pedido", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                    ),
                    onPressed: _fazerPedido,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
