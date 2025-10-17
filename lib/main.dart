import 'package:flutter/material.dart';
import 'package:login/redefinirsenha.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'login.dart';
import 'cadastro.dart';

void main() async {
  await SharedPreferences.getInstance(); // Inicializa o plugin
   // Configura valores iniciais simulados
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/redefinirsenha': (context) => const RedefinirSenha()
      },
    );
  }
}
