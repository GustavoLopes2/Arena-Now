import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arenanow/models/estabelecimento.dart';
import 'package:arenanow/models/foto_estabelecimento.dart';
import 'package:arenanow/services/estabelecimento_service.dart';

class RegisterEstabelecimentoPage extends StatefulWidget {
  const RegisterEstabelecimentoPage({super.key});

  @override
  State<RegisterEstabelecimentoPage> createState() =>
      _RegisterEstabelecimentoPageState();
}

class _RegisterEstabelecimentoPageState
    extends State<RegisterEstabelecimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _prazoCancelamentoController = TextEditingController();
  final _fotoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _cadastrarEstabelecimento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final adminId = FirebaseAuth.instance.currentUser!.uid;

      final estabelecimento = Estabelecimento(
        id: "",
        nome: _nomeController.text.trim(),
        endereco: _enderecoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        prazoCancelamentoHoras:
            int.parse(_prazoCancelamentoController.text.trim()),
        adminId: adminId,
        criadoEm: DateTime.now(),
      );

      final service = EstabelecimentoService();

      final id = await service.criarEstabelecimento(estabelecimento);

      if (_fotoController.text.trim().isNotEmpty) {
        await service.adicionarFotoEstabelecimento(
          id,
          FotoEstabelecimento(
            id: "",
            estabelecimentoId: id,
            url: _fotoController.text.trim(),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estabelecimento cadastrado com sucesso!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Cadastrar Estabelecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nome'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _enderecoController,
                validator: (v) => v!.isEmpty ? 'Informe o endereço' : null,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Endereço'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Descrição'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prazoCancelamentoController,
                validator: (v) => v!.isEmpty || int.tryParse(v) == null
                    ? 'Número inválido'
                    : null,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Prazo para cancelamento (horas)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fotoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('URL da foto (temporário)'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarEstabelecimento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cadastrar Estabelecimento'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
