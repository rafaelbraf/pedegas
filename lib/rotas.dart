import 'package:appdogas/pages/aguardando_pedido.dart';
import 'package:appdogas/pages/areas_entrega.dart';
import 'package:appdogas/pages/editar_usuario.dart';
import 'package:appdogas/pages/endereco.dart';
import 'package:appdogas/pages/home.dart';
import 'package:appdogas/pages/pedidos_realizados.dart';
import 'package:appdogas/pages/primeiro_acesso.dart';
import 'package:appdogas/pages/tela_ajuda.dart';
import 'package:appdogas/pages/tela_pedido.dart';
import 'package:flutter/material.dart';

class Rotas {

  static Route<dynamic> gerarRotas (RouteSettings settings) {

    final args = settings.arguments;

    switch(settings.name) {

      case "/":
        return MaterialPageRoute(
          builder: (_) => MyAppPage()
        );
      case "/tela_pedido":
        return MaterialPageRoute(
          builder: (_) => TelaPedido()
        );
      case '/primeiro_acesso':
        return MaterialPageRoute(
          builder: (_) => PrimeiroAcesso()
        );
      case '/endereco':
        return MaterialPageRoute(
          builder: (_) => Endereco()
        );
      case '/aguardando_pedido':
        return MaterialPageRoute(
          builder: (_) => Aguardando()
        );
      case '/editar_usuario':
        return MaterialPageRoute(
          builder: (_) => EditarUsuario()
        );
      case '/pedidos_realizados':
        return MaterialPageRoute(
          builder: (_) => PedidosRealizadosUsuario()
        );
      case '/tela_ajuda':
        return MaterialPageRoute(
          builder: (_) => Ajuda()
        );
      case '/areas_entrega': 
        return MaterialPageRoute(
          builder: (_) => AreaEntrega()
        );
        
      default:
        _erroRota();

    }

  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada"),),
          body: Center(child: Text("Tela não encontrada"),),
        );
      }
    );
  }

}