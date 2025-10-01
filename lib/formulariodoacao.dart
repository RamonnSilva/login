import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doacaosucesso.dart';

class DonationFormPage extends StatefulWidget {
  final String doadorId;
  final String email;

  const DonationFormPage({super.key, required this.doadorId, required this.email});

  @override
  State<DonationFormPage> createState() => _DonationFormPageState();
}

class _DonationFormPageState extends State<DonationFormPage> {
  String nome = '';
  String titulo = '';
  String genero = '';
  String autor = '';
  String descricao = '';
  String? imagemBase64;
  XFile? pickedImage;

  final _formKey = GlobalKey<FormState>();
  bool _isEnviando = false;

  @override
  void initState() {
    super.initState();
    nome = ''; // você pode preencher com o nome do usuário logado, se quiser
  }

  // Selecionar imagem da galeria
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        pickedImage = image;
        // Converte a imagem em Base64 com prefixo data:image/png;base64,
        imagemBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  // Enviar dados para o backend
  Future<void> enviarDados() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEnviando = true;
    });

    final url = Uri.parse('http://localhost:8080/doacao');

    try {
      final int? doadorIdInt = int.tryParse(widget.doadorId);
      if (doadorIdInt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID do doador inválido. Faça login novamente.')),
        );
        setState(() => _isEnviando = false);
        return;
      }

      final payload = {
        'nome': nome,
        'titulo': titulo,
        'genero': genero,
        'autor': autor,
        'descricao': descricao,
        'email': widget.email,
        'imagem': imagemBase64, // imagem em Base64 completa
        'doadorid': doadorIdInt, // id do usuário logado
      };

      print('Payload enviado: $payload'); // para debug

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final int doacaoId = responseData['id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonationSuccessDialog(doadorid: doadorIdInt),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar dados: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() {
        _isEnviando = false;
      });
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Formulário de Doação'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: nome,
                    onChanged: (value) => nome = value,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Doador',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => titulo = value,
                    decoration: const InputDecoration(
                      labelText: 'Título do Livro',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => genero = value,
                    decoration: const InputDecoration(
                      labelText: 'Gênero',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => autor = value,
                    decoration: const InputDecoration(
                      labelText: 'Autor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => descricao = value,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  pickedImage == null
                      ? const Text('Nenhuma imagem selecionada', style: TextStyle(color: Colors.white))
                      : Image.memory(
                          base64Decode(imagemBase64!.split(',')[1]),
                          height: 200,
                        ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Selecionar Imagem'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isEnviando ? null : enviarDados,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isEnviando
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : const Text('Doar Livro'),
                    ),
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
