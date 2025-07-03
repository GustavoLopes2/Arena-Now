import 'package:flutter/material.dart';
import 'package:arenanow/modules/admin/register/register_agenda_semanal_page.dart';
import 'package:arenanow/models/quadra.dart';
import 'package:arenanow/models/foto_quadra.dart';
import 'package:arenanow/services/quadra_service.dart';

class RegisterQuadraPage extends StatefulWidget {
  final String estabelecimentoId;

  const RegisterQuadraPage({super.key, required this.estabelecimentoId});

  @override
  State<RegisterQuadraPage> createState() => _RegisterQuadraPageState();
}

class _RegisterQuadraPageState extends State<RegisterQuadraPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _fotoController = TextEditingController();

  String _modalidade = 'BEACH_TENNIS';
  bool _isLoading = false;

  Future<void> _cadastrarQuadra() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quadra = Quadra(
        id: "",
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        modalidade: _modalidade,
        estabelecimentoId: widget.estabelecimentoId,
        criadoEm: DateTime.now(),
      );

      final service = QuadraService();

      final quadraId = await service.criarQuadra(quadra);

      if (_fotoController.text.trim().isNotEmpty) {
        await service.salvarFotoQuadra(
          quadraId,
          FotoQuadra(
            id: "",
            quadraId: quadraId,
            url: _fotoController.text.trim(),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quadra cadastrada com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CadastrarAgendaSemanalPage(quadraId: quadraId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar quadra: ${e.toString()}'),
        ),
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
        title: const Text('Cadastrar Quadra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nome da quadra'),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Descrição'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _modalidade,
                dropdownColor: const Color(0xFF1E2D45),
                decoration: _inputDecoration('Modalidade'),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                    value: 'BEACH_TENNIS',
                    child: Text('Beach Tennis'),
                  ),
                  DropdownMenuItem(
                    value: 'FUTEBOL_SOCIETY',
                    child: Text('Futebol Society'),
                  ),
                ],
                onChanged: (value) => setState(() => _modalidade = value!),
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
                        onPressed: _cadastrarQuadra,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cadastrar Quadra'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
