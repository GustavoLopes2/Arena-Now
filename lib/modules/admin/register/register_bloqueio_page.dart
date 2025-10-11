import 'package:flutter/material.dart';
import 'package:arenanow/models/bloqueio_quadra.dart';
import 'package:arenanow/services/bloqueio_service.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selecionarData(bool isInicio) async {
    final data = await showDatePicker(
      context: context,
      initialDate: isInicio ? DateTime.now() : _dataInicio ?? DateTime.now(),
      firstDate: isInicio
          ? DateTime.now()
          : _dataInicio ?? DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2030),
      helpText: isInicio ? "Selecionar data inicial" : "Selecionar data final",
    );

    if (data != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = data;
          _dataFim = null;
        } else {
          _dataFim = data;
        }
      });
    }
  }

  bool _validarHorario(String inicio, String fim) {
    if (!inicio.contains(":") || !fim.contains(":")) return false;
    final i = _toMinutes(inicio);
    final f = _toMinutes(fim);
    return f > i;
  }

  int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
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

    if (!_validarHorario(
      _horaInicioController.text.trim(),
      _horaFimController.text.trim(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Horário final deve ser maior que o inicial."),
        ),
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
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Já existe um bloqueio neste dia.")),
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
        diaSemana: _tipo == "RECORRENTE"
            ? DateFormat('EEEE').format(_dataInicio!).toUpperCase()
            : null,
        criadoEm: DateTime.now(),
      );

      await service.criarBloqueio(widget.quadraId, bloqueio);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bloqueio registrado com sucesso!")),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(color: Colors.white);

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
                decoration: _inputDecoration("Tipo de bloqueio"),
                style: textStyle,
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
                onPressed: () => _selecionarData(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2598C),
                ),
                child: Text(
                  _dataInicio == null
                      ? "Selecionar data início"
                      : "Início: ${DateFormat('dd/MM/yyyy').format(_dataInicio!)}",
                ),
              ),
              if (_tipo == "PONTUAL") ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _selecionarData(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2598C),
                  ),
                  child: Text(
                    _dataFim == null
                        ? "Selecionar data fim"
                        : "Fim: ${DateFormat('dd/MM/yyyy').format(_dataFim!)}",
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      style: textStyle,
                      decoration: _inputDecoration("Início (ex: 15:00)"),
                      validator: (v) =>
                          v!.isEmpty ? "Informe o horário inicial" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFimController,
                      style: textStyle,
                      decoration: _inputDecoration("Fim (ex: 17:00)"),
                      validator: (v) =>
                          v!.isEmpty ? "Informe o horário final" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivoController,
                style: textStyle,
                decoration: _inputDecoration("Motivo do bloqueio"),
                validator: (v) =>
                    v!.isEmpty ? "Informe o motivo do bloqueio" : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _cadastrarBloqueio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2598C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "Cadastrar Bloqueio",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
