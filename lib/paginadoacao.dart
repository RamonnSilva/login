import 'package:flutter/material.dart';
import 'formulariodoacao.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _infoCard(
                        context,
                        image: 'assets/coracao.png',
                        texto:
                            'Ao doar livros, estamos compartilhando o amor pela leitura com os outros.',
                      ),
                      const SizedBox(height: 16),
                      _infoCard(
                        context,
                        image: 'assets/livros.png',
                        texto:
                            'A doação de livros promove o acesso à educação em comunidades carentes.',
                        titulo: 'Doações de Livros',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DonationFormPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  Widget _infoCard(BuildContext context,
      {required String image, required String texto, String? titulo}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image,
                height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          if (titulo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
