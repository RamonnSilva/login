import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formulariodoacao.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  String doadorId = '';
  String email = '';
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doadorId = prefs.getString('id') ?? '';
      email = prefs.getString('email') ?? '';
      carregando = false;
    });
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
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('Doação'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoCard('assets/coracao.png', 'Doe livros e compartilhe amor!'),
                      const SizedBox(height: 16),
                      _infoCard('assets/livros.png', 'A doação promove educação.', titulo: 'Doações de Livros'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (carregando || doadorId.isEmpty)
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DonationFormPage(
                                            doadorId: doadorId, email: email)),
                                  );
                                },
                          child: const Text('Doar seu livro'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String image, String texto, {String? titulo}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          if (titulo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
