import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RedefinirSenha(),
    );
  }
}

class RedefinirSenha extends StatefulWidget {
  const RedefinirSenha({super.key});

  @override
  State<RedefinirSenha> createState() => _RedefinirSenhaState();
}

class _RedefinirSenhaState extends State<RedefinirSenha> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  Future<void> _redefinirSenha() async {
    final url = Uri.parse('http://localhost:8080/cliente/redefinir-senha');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text,
          "novaSenha": _novaSenhaController.text,
        }),
      );

      if (response.statusCode == 200) {
        _mostrarDialogoSucesso();
      } else {
        _mostrarErro("Erro: ${utf8.decode(response.bodyBytes)}");
      }
    } catch (e) {
      _mostrarErro('Erro ao conectar com o servidor.');
    }
  }

  void _mostrarDialogoSucesso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Sua senha foi redefinida com sucesso!"),
              const SizedBox(height: 16),
              Image.asset("assets/Ok.png", height: 64),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Voltar"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erro"),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.blue.shade800],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Redefinir a senha',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _campoTexto(
                            label: 'Email',
                            hint: 'Ex: exemplo@gmail.com',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o email';
                              }
                              if (!value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          _campoTexto(
                            label: 'Nova senha',
                            hint: 'Ex: abcd1234*',
                            controller: _novaSenhaController,
                            obscure: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite a nova senha';
                              }
                              if (value.length < 6) {
                                return 'Senha muito curta';
                              }
                              return null;
                            },
                          ),
                          _campoTexto(
                            label: 'Confirme a senha',
                            hint: 'Ex: abcd1234*',
                            controller: _confirmarSenhaController,
                            obscure: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirme sua senha';
                              }
                              if (value != _novaSenhaController.text) {
                                return 'As senhas não coincidem';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _redefinirSenha();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Redefinir'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required String hint,
    bool obscure = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
