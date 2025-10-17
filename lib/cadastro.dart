import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _funcaoController = "USER";
  bool _aceitouTermos = false;

  @override
  void initState() {
    super.initState();

    _telefoneController.addListener(() {
      final textoFormatado = formatarTelefone(_telefoneController.text);
      if (_telefoneController.text != textoFormatado) {
        _telefoneController.value = _telefoneController.value.copyWith(
          text: textoFormatado,
          selection: TextSelection.collapsed(offset: textoFormatado.length),
        );
      }
    });

    _dataController.addListener(() {
      final textoFormatado = formatarData(_dataController.text);
      if (_dataController.text != textoFormatado) {
        _dataController.value = _dataController.value.copyWith(
          text: textoFormatado,
          selection: TextSelection.collapsed(offset: textoFormatado.length),
        );
      }
    });

    _cepController.addListener(() {
      final textoFormatado = formatarCep(_cepController.text);
      if (_cepController.text != textoFormatado) {
        _cepController.value = _cepController.value.copyWith(
          text: textoFormatado,
          selection: TextSelection.collapsed(offset: textoFormatado.length),
        );
      }
    });

    // Novo listener para CPF
    _cpfController.addListener(() {
      final textoFormatado = formatarCpf(_cpfController.text);
      if (_cpfController.text != textoFormatado) {
        _cpfController.value = _cpfController.value.copyWith(
          text: textoFormatado,
          selection: TextSelection.collapsed(offset: textoFormatado.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _logradouroController.dispose();
    super.dispose();
  }

  String formatarTelefone(String texto) {
    var numeros = texto.replaceAll(RegExp(r'\D'), '');
    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }

    if (numeros.length <= 2) return '($numeros';
    if (numeros.length <= 7) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2)}';
    }
    if (numeros.length <= 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }
    return texto;
  }

  String formatarData(String texto) {
    var numeros = texto.replaceAll(RegExp(r'\D'), '');
    if (numeros.length > 8) {
      numeros = numeros.substring(0, 8);
    }

    if (numeros.length <= 2) return numeros;
    if (numeros.length <= 4) {
      return '${numeros.substring(0, 2)}/${numeros.substring(2)}';
    }
    if (numeros.length <= 8) {
      return '${numeros.substring(0, 2)}/${numeros.substring(2, 4)}/${numeros.substring(4)}';
    }
    return texto;
  }

  String formatarCep(String texto) {
    var numeros = texto.replaceAll(RegExp(r'\D'), '');
    if (numeros.length > 8) {
      numeros = numeros.substring(0, 8);
    }
    if (numeros.length <= 5) return numeros;
    return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
  }

  // Nova função para formatar CPF
  String formatarCpf(String texto) {
    var numeros = texto.replaceAll(RegExp(r'\D'), '');
    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }
    if (numeros.length <= 3) return numeros;
    if (numeros.length <= 6) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3)}';
    }
    if (numeros.length <= 9) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6)}';
    }
    if (numeros.length <= 11) {
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
    }
    return texto;
  }

  Future<void> _buscarCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length == 8) {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          setState(() {
            _enderecoController.text = data['logradouro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _estadoController.text = data['uf'] ?? '';
          });
        } else {
          _mostrarAlerta('CEP não encontrado.');
        }
      }
    }
  }

  void _mostrarAlerta(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _maiorDeIdade(String dataTexto) {
    try {
      final data = DateFormat('dd/MM/yyyy').parseStrict(dataTexto);
      final hoje = DateTime.now();
      final idade = hoje.difference(data).inDays ~/ 365;
      return idade >= 18;
    } catch (_) {
      return false;
    }
  }

  Future<void> _enviarCadastro() async {
    final body = {
      "nome": _nomeController.text,
      "email": _emailController.text,
      "senha": _senhaController.text,
      "cpf": _cpfController.text,
      "telefone": _telefoneController.text,
      "cep": _cepController.text,
      "endereco": _enderecoController.text,
      "cidade": _cidadeController.text,
      "estado": _estadoController.text,
      "logradouro": _logradouroController.text,
      "funcao": _funcaoController,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        _mostrarAlerta("Cadastro realizado com sucesso!");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else if (response.statusCode == 400) {
        _mostrarAlerta("Este email já está cadastrado.");
      } else {
        _mostrarAlerta("Erro ao cadastrar. Tente novamente.");
      }
    } catch (e) {
      _mostrarAlerta("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Cadastro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _campoTexto(
                    controller: _nomeController,
                    label: 'Nome completo',
                    icon: FontAwesomeIcons.user,
                    validator: _validaTexto,
                  ),
                  _campoTexto(
                    controller: _dataController,
                    label: 'Data de nascimento',
                    icon: FontAwesomeIcons.calendar,
                    inputType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a data de nascimento';
                      }
                      if (!_maiorDeIdade(value)) {
                        return 'Você precisa ter 18 anos ou mais';
                      }
                      return null;
                    },
                  ),
                  _campoTexto(
                    controller: _cpfController,
                    label: 'CPF',
                    icon: FontAwesomeIcons.idCard,
                    validator: (value) {
                      if (value == null || value.replaceAll(RegExp(r'\D'), '').length != 11) {
                        return 'CPF inválido';
                      }
                      return null;
                    },
                  ),
                  _campoTexto(
                    controller: _emailController,
                    label: 'Email',
                    icon: FontAwesomeIcons.envelope,
                    inputType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  _campoTexto(
                    controller: _telefoneController,
                    label: 'Telefone',
                    icon: FontAwesomeIcons.phone,
                    inputType: TextInputType.phone,
                    validator: _validaTexto,
                  ),
                  _campoTexto(
                    controller: _senhaController,
                    label: 'Senha',
                    icon: FontAwesomeIcons.lock,
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Senha muito curta';
                      }
                      return null;
                    },
                  ),
                  _campoTexto(
                    controller: _cepController,
                    label: 'CEP',
                    icon: FontAwesomeIcons.mapPin,
                    validator: _validaTexto,
                    onChanged: _buscarCep,
                  ),
                  _campoTexto(
                    controller: _enderecoController,
                    label: 'Endereço',
                    icon: FontAwesomeIcons.road,
                    readOnly: true,
                  ),
                  _campoTexto(
                    controller: _cidadeController,
                    label: 'Cidade',
                    icon: FontAwesomeIcons.city,
                    readOnly: true,
                  ),
                  _campoTexto(
                    controller: _estadoController,
                    label: 'Estado',
                    icon: FontAwesomeIcons.flag,
                    readOnly: true,
                  ),
                  _campoTexto(
                    controller: _logradouroController,
                    label: 'Número da casa',
                    icon: FontAwesomeIcons.houseChimney,
                    validator: _validaTexto,
                  ),
                  CheckboxListTile(
                    title: const Text('Aceito os termos de uso'),
                    value: _aceitouTermos,
                    onChanged: (value) =>
                        setState(() => _aceitouTermos = value ?? false),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _aceitouTermos) {
                        _enviarCadastro();
                      } else if (!_aceitouTermos) {
                        _mostrarAlerta('Você deve aceitar os termos.');
                      }
                    },
                    child: const Text('Cadastrar'),
                  ),
                  TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Já tem conta? Voltar para login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validaTexto(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscure,
        readOnly: readOnly,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
