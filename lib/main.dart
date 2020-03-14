import 'package:appdogas/pages/home.dart';
import 'package:appdogas/pages/splashscreen.dart';
import 'package:appdogas/rotas.dart';
import 'package:flutter/material.dart';

final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff388E3C),
  accentColor: Color(0xff43A047) 
);

void main() => runApp(MaterialApp(
  title: "PedeGás",
  home: SplashScreen(),
  theme: temaPadrao,
  initialRoute: "/",
  onGenerateRoute: Rotas.gerarRotas,
  debugShowCheckedModeBanner: false,
));