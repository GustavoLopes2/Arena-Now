import 'package:flutter/material.dart';
import 'package:arenanow/models/bloqueio_quadra.dart';
import 'package:arenanow/services/bloqueio_service.dart';

class RegisterBloqueioPage extends StatefulWidget {
  final String quadraId;

  const RegisterBloqueioPage({
    super.key,
    required this.quadraId,
  });

  @override
  State<RegisterBloqueioPage> createState() => _RegisterBloqueioPageState();
}

class _RegisterBloqueioPageState extends State<RegisterBloqueioPage> {
  final _formKey = GlobalKey<FormState>();

  final _motivoController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFimController = TextEditingController();

  DateTime? _dataInicio;
  DateTime? _dataFim;

  String _tipo = "PONTUAL";

  bool _isLoading = false;

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2030),
    );
    if (data != null) setState(() => _dataInicio = data);
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: _dataInicio ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (data != null) setState(() => _dataFim = data);
  }

  Future<void> _cadastrarBloqueio() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data inicial")),
      );
      return;
    }

    if (_tipo == "PONTUAL" && _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data final")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = BloqueioService();

      if (_tipo == "PONTUAL") {
        final existe = await service.existeBloqueioNoDia(
          widget.quadraId,
          _dataInicio!,
        );

        if (existe) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Já existe um bloqueio neste dia."),
            ),
          );
          return;
        }
      }

      final bloqueio = BloqueioQuadra(
        id: "",
        quadraId: widget.quadraId,
        tipo: _tipo,
        motivo: _motivoController.text.trim(),
        horaInicio: _horaInicioController.text.trim(),
        horaFim: _horaFimController.text.trim(),
        dataInicio: _dataInicio,
        dataFim: _tipo == "PONTUAL" ? _dataFim : null,
        diaSemana: null,
        criadoEm: DateTime.now(),
      );

      await service.criarBloqueio(widget.quadraId, bloqueio);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bloqueio cadastrado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.black26,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text("Cadastrar Bloqueio"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _tipo,
                dropdownColor: const Color(0xFF1E2D45),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Tipo de Bloqueio"),
                items: const [
                  DropdownMenuItem(
                    value: "PONTUAL",
                    child: Text("Pontual"),
                  ),
                  DropdownMenuItem(
                    value: "RECORRENTE",
                    child: Text("Recorrente (semanal)"),
                  ),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _selecionarDataInicio,
                child: Text(
                  _dataInicio == null
                      ? "Selecionar data início"
                      : "Início: ${_dataInicio!.day}/${_dataInicio!.month}/${_dataInicio!.year}",
                ),
              ),
              const SizedBox(height: 12),
              if (_tipo == "PONTUAL")
                ElevatedButton(
                  onPressed: _selecionarDataFim,
                  child: Text(
                    _dataFim == null
                        ? "Selecionar data fim"
                        : "Fim: ${_dataFim!.day}/${_dataFim!.month}/${_dataFim!.year}",
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horaInicioController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Hora início (ex: 15:00)"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horaFimController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Hora fim (ex: 17:00)"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Motivo"),
                validator: (v) =>
                    v!.isEmpty ? "Informe o motivo do bloqueio" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _cadastrarBloqueio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2598C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cadastrar Bloqueio"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
