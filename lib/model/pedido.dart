import 'package:appdogas/model/destino.dart';
import 'package:appdogas/model/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {

  String _idPedido;
  String _status;
  Usuario _cliente;
  Destino _destino;
  String _formaPagamento;
  int _quantidade;
  int _valorTotal;
  String _dataPedidoRealizado;
  String _horaPedidoRealizado;
  String _dataEntregaRealizada;
  String _horaEntregaRealizada;

  Pedido(){
    Firestore db = Firestore.instance;    
    DocumentReference ref = db.collection("requisicoes").document();
    this.idPedido = ref.documentID;
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> dadosCliente = {
      "nome"        : this.cliente.nome,
      "telefone"    : this.cliente.telefone,
      "endereco"    : this.cliente.endereco
    };

    Map<String, dynamic> dadosDestino = {
      "endereco" : this.destino.endereco
    };

    Map<String, dynamic> dadosPedido = {
      "id"                    : this.idPedido,
      "idUsuario"             : this.cliente.idUsuario,
      "status"                : this.status,
      "cliente"               : dadosCliente,
      "entregador"            : null,
      "destino"               : dadosDestino,
      "dataPedidoRealizado"   : this.dataPedidoRealizado,
      "horaPedidoRealizado"   : this.horaPedidoRealizado,
      "dataEntregaRealizada"  : "00/00/00",
      "horaEntregaRealizada"  : "00:00",
      "formaPagamento"        : this.formaPagamento,
      "quantidade"            : this.quantidade,
      "valorTotal"            : this.valorTotal
    };

    return dadosPedido;

  }

  String get horaEntregaRealizada => _horaEntregaRealizada;

  set horaEntregaRealizada(String value) {
    _horaEntregaRealizada = value;
  }

  String get dataEntregaRealizada => _dataEntregaRealizada;

  set dataEntregaRealizada(String value) {
    _dataEntregaRealizada = value;
  }

  String get horaPedidoRealizado => _horaPedidoRealizado;

  set horaPedidoRealizado(String value) {
    _horaPedidoRealizado = value;
  }

  String get dataPedidoRealizado => _dataPedidoRealizado;

  set dataPedidoRealizado(String value) {
    _dataPedidoRealizado = value;
  }

  int get valorTotal => _valorTotal;

  set valorTotal(int value) {
    _valorTotal = value;
  }

  int get quantidade => _quantidade;

  set quantidade(int value) {
    _quantidade = value;
  }

  String get formaPagamento => _formaPagamento;

  set formaPagamento(String value) {
    _formaPagamento = value;
  }

  Destino get destino => _destino;

  set destino(Destino value) {
    _destino = value;
  }

  Usuario get cliente => _cliente;

  set cliente(Usuario value) {
    _cliente = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get idPedido => _idPedido;

  set idPedido(String value) {
    _idPedido = value;
  }


}