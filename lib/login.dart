import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Sua tela home aqui

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:8080/auth/login'); // Ajuste para emulador Android
    final body = jsonEncode({
      'email': emailController.text,
      'senha': senhaController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['token'] ?? '';
        final email = emailController.text;
        final id = data['id']?.toString() ?? '';

        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token não encontrado na resposta.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', email);
        await prefs.setString('id', id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login realizado com sucesso! Bem-vindo(a), ${data['nome'] ?? ''}')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha incorretos.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha no login. Tente novamente mais tarde.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 16),
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite seu e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'Digite um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: senhaController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: const Text('Não é um membro ainda? Cadastrar-se'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/redefinir-senha');
                    },
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
