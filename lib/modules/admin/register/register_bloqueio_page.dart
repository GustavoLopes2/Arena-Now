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
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: isInicio ? "Selecionar data inicial" : "Selecionar data final",
      builder: (_, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF2598C),
              onPrimary: Colors.white,
              surface: Color(0xFF1E2D45),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _selecionarHora(TextEditingController controller) async {
    final agora = TimeOfDay.now();

    final selecionado = await showTimePicker(
      context: context,
      initialTime: agora,
      helpText: "Selecionar horário",
      builder: (_, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF2598C),
              secondary: Color(0xFFF2598C),
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF1E2D45),
              dialHandColor: Color(0xFFF2598C),
              hourMinuteColor: Colors.white10,
              dayPeriodColor: Colors.white10,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionado != null) {
      final h = selecionado.hour.toString().padLeft(2, '0');
      final m = selecionado.minute.toString().padLeft(2, '0');
      controller.text = "$h:$m";
    }
  }

  bool _validarHorario(String inicio, String fim) {
    if (!inicio.contains(":") || !fim.contains(":")) return false;
    return _toMinutes(fim) > _toMinutes(inicio);
  }

  int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  Future<void> _cadastrarBloqueio() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data inicial.")),
      );
      return;
    }

    if (_tipo == "PONTUAL" && _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data final.")),
      );
      return;
    }

    if (!_validarHorario(
      _horaInicioController.text.trim(),
      _horaFimController.text.trim(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Horário final deve ser maior que o inicial.")),
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
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);

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
                  DropdownMenuItem(value: "PONTUAL", child: Text("Pontual")),
                  DropdownMenuItem(
                      value: "RECORRENTE", child: Text("Recorrente (semanal)")),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 14),
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
                const SizedBox(height: 14),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      readOnly: true,
                      onTap: () => _selecionarHora(_horaInicioController),
                      style: textStyle,
                      decoration: _inputDecoration("Início"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFimController,
                      readOnly: true,
                      onTap: () => _selecionarHora(_horaFimController),
                      style: textStyle,
                      decoration: _inputDecoration("Fim"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _motivoController,
                style: textStyle,
                decoration: _inputDecoration("Motivo do bloqueio"),
                validator: (v) => v!.isEmpty ? "Informe o motivo" : null,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
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
