import 'package:appdogas/model/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class MyAppPage extends StatefulWidget {    
  MyAppPage({Key key, this.title}) : super(key: key);    
  final String title;    
  
  @override    
  _MyAppPageState createState() => _MyAppPageState();    
}    
  
class _MyAppPageState extends State<MyAppPage> {    

  String _mensagemErro = "";
  bool _carregando = false;

  TextEditingController _controllerTelefone = TextEditingController(text: "+55 85 9");

  String phoneNo;    
  String smsOTP;    
  String verificationId;    
  String errorMessage = '';    
  FirebaseAuth _auth = FirebaseAuth.instance; 

  _bloquearRotacaodeTela() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]); 
  }
  

  // _logarUsuario(Usuario usuario) async {

  //   setState(() {
  //    _carregando = true;
  //   });

  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   auth.(

  //     email: usuario.email,
  //     password: usuario.senha

  //   ).then((firebaseUser) {

  //     _redirecionaPainelTipoUsuario(firebaseUser.user.uid);

  //   }).catchError((error) {
  //     _mensagemErro = "Erro ao autenticar usuário! Verifique e-mail e senha e tente novamente.";
  //   });

  //   Firestore db = Firestore.instance;
  //   db.collection('usuarios');

  // }
  
  Future<void> verifyPhone() async {    
      final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {    
          this.verificationId = verId;    
          smsOTPDialog(context).then((value) {    
          print('sign in');    
          });    
      };    
      try {    
          await _auth.verifyPhoneNumber(    
              phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP                  
              codeAutoRetrievalTimeout: (String verId) {    
              //Starts the phone number verification process for the given phone number.    
              //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.    
              this.verificationId = verId;    
              },    
              codeSent:    
                  smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.    
              timeout: const Duration(seconds: 20),    
              verificationCompleted: (AuthCredential phoneAuthCredential) {    
                print(phoneAuthCredential);    
              },    
              verificationFailed: (AuthException exceptio) {    
                print('${exceptio.message}');    
              });    
      } catch (e) {    
          handleError(e);    
      }    
  }    
  
  Future<bool> smsOTPDialog(BuildContext context) {        
      return showDialog(    
          context: context,    
          barrierDismissible: false,    
          builder: (BuildContext context) {    
              return new AlertDialog(    
              title: Text('Informe o código recebido'),    
              content: Container(    
                  height: 85,    
                  child: Column(children: [    
                  TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {    
                        this.smsOTP = value;    
                      },    
                  ),    
                  (errorMessage != ''    
                      ? Text(    
                          errorMessage,    
                          style: TextStyle(color: Colors.red),    
                          )    
                      : Container())    
                  ]),    
              ),    
              contentPadding: EdgeInsets.all(10),    
              actions: <Widget>[    
                FlatButton(    
                  color: Colors.green,
                  child: Text('Verificar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),    
                  onPressed: () {    
                      _auth.currentUser().then((user) {
                      if (user != null) { 
                          print(user);
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/tela_pedido');
                      } else {    
                          signIn();
                      }    
                    });    
                  },    
                )
              ],
              );
      });    
  }    

  cadastrarUsuario(FirebaseUser user, Usuario usuario) {

    Firestore db = Firestore.instance;

    db.collection('usuarios').document(user.uid).setData(usuario.toMap());

  }
  
  signIn() async {
      try {    
          final AuthCredential credential = PhoneAuthProvider.getCredential(    
          verificationId: verificationId,    
          smsCode: smsOTP,              
          );    
          final AuthResult authResult = await _auth.signInWithCredential(credential);  
          final FirebaseUser user = authResult.user;
          // UserUpdateInfo userUpdateInfo = UserUpdateInfo();
          // userUpdateInfo.displayName = nome;          
          // user.updateProfile(userUpdateInfo);
          // user.reload();

          // Usuario usuario = Usuario();
          // usuario.nome = nome;
          // usuario.telefone = phoneNo;

          // cadastrarUsuario(user, usuario);

          final FirebaseUser currentUser = await _auth.currentUser();              
          assert(user.uid == currentUser.uid); 
          print(user);
          Navigator.of(context).pop();    
          Navigator.of(context).pushReplacementNamed('/primeiro_acesso');    
      } catch (e) {
          handleError(e);    
      }    
  }    
  
  handleError(PlatformException error) {    
      print(error);    
      switch (error.code) {    
          case 'ERROR_INVALID_VERIFICATION_CODE':    
          FocusScope.of(context).requestFocus(new FocusNode());    
          setState(() {    
              errorMessage = 'Código inválido';    
          });    
          Navigator.of(context).pop();    
          smsOTPDialog(context).then((value) {    
              print('sign in');    
          });    
          break;    
          default:    
          setState(() {    
              errorMessage = error.message;
          });    
  
          break;    
      }    
  }

  _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/tela_pedido");
    }
  }

  @override
  void initState() {    
    super.initState();
    _verificaUsuarioLogado();
    //_bloquearRotacaodeTela();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }
  
  @override    
  Widget build(BuildContext context) {
    _bloquearRotacaodeTela();
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50),
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(            
            children: <Widget>[              
              
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "PEÇA AQUI SEU GÁS",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),                
                ),
              ),
              Text(
                "Insira seu número para começar", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _controllerTelefone,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Número",
                    labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.normal),  
                    hoverColor: Colors.green,                                     
                  ),
                  onChanged: (value) {    
                    this.phoneNo = value;    
                  },    
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(                
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(32)
                    )
                  ),
                  child: FlatButton(
                    child: Text("ENTRAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                    onPressed: verifyPhone,
                  ),
                ),
              ),
              _carregando
              ? Center(child: CircularProgressIndicator(backgroundColor: Colors.greenAccent,))
              : Container(),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Center(
                  child: Text(_mensagemErro, style: TextStyle(color: Colors.red, fontSize: 20),),
                ),
              ),
              Container(          
                height: MediaQuery.of(context).size.height,      
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "images/bottom.png"
                ),
              )
            ],
          ),
        ),
      )
    );
    // return Scaffold(
    //   body: Center(    
    //     child: Column(    
    //         mainAxisAlignment: MainAxisAlignment.center,    
    //         children: <Widget>[    
    //         Padding(    
    //             padding: EdgeInsets.all(10),    
    //             child: TextField(    
    //             decoration: InputDecoration(    
    //                 hintText: 'Enter Phone Number Eg. +910000000000'),
    //             onChanged: (value) {    
    //                 this.phoneNo = value;    
    //             },    
    //             ),    
    //         ),    
    //         (errorMessage != ''    
    //             ? Text(    
    //                 errorMessage,    
    //                 style: TextStyle(color: Colors.red),    
    //                 )    
    //             : Container()),    
    //         SizedBox(    
    //             height: 10,    
    //         ),    
    //         RaisedButton(    
    //             onPressed: () {    
    //             verifyPhone();    
    //             },    
    //             child: Text('Verificar'),    
    //             textColor: Colors.white,    
    //             elevation: 7,    
    //             color: Colors.blue,    
    //         )    
    //         ],    
    //     ),    
    //     ),    
    // );    
  }    
}  