import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:arenanow/models/quadra.dart';
import 'package:arenanow/models/foto_quadra.dart';
import 'package:arenanow/services/quadra_service.dart';
import 'package:arenanow/modules/admin/register/register_agenda_semanal_page.dart';

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
  String _modalidade = 'BEACH_TENNIS';

  XFile? _selectedImage;
  Uint8List? _imagePreview;

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selecionarImagem() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImage = file;
        _imagePreview = bytes;
      });
    }
  }

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

      final quadraService = QuadraService();
      final quadraId = await quadraService.criarQuadra(quadra);

      if (_selectedImage != null) {
        final url =
            await quadraService.uploadFotoQuadra(quadraId, _selectedImage!);

        await quadraService.salvarFotoQuadra(
          quadraId,
          FotoQuadra(id: "", quadraId: quadraId, url: url),
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
        SnackBar(content: Text('Erro ao cadastrar quadra: $e')),
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
      fillColor: const Color(0xFF1A1F2E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFF2598C), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        elevation: 0,
        title: const Text("Cadastrar Quadra",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                decoration: _inputDecoration("Nome da quadra"),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: _inputDecoration("Descrição"),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _modalidade,
                dropdownColor: const Color(0xFF1E2D45),
                decoration: _inputDecoration("Modalidade"),
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
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _selecionarImagem,
                icon: const Icon(Icons.photo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2598C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text("Selecionar foto da quadra"),
              ),
              const SizedBox(height: 16),
              if (_imagePreview != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _imagePreview!,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 26),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarQuadra,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cadastrar Quadra',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
