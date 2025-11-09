import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/bloqueio_quadra.dart';
import 'package:arenanow/services/bloqueio_service.dart';

class EditarBloqueioPage extends StatefulWidget {
  final String quadraId;
  final String bloqueioId;
  final BloqueioQuadra dadosBloqueio;

  const EditarBloqueioPage({
    super.key,
    required this.quadraId,
    required this.bloqueioId,
    required this.dadosBloqueio,
  });

  @override
  State<EditarBloqueioPage> createState() => _EditarBloqueioPageState();
}

class _EditarBloqueioPageState extends State<EditarBloqueioPage> {
  late final TextEditingController motivoController;
  late final TextEditingController horaInicioController;
  late final TextEditingController horaFimController;

  DateTime? dataInicio;
  DateTime? dataFim;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    motivoController = TextEditingController(text: widget.dadosBloqueio.motivo);
    horaInicioController =
        TextEditingController(text: widget.dadosBloqueio.horaInicio);
    horaFimController =
        TextEditingController(text: widget.dadosBloqueio.horaFim);

    dataInicio = widget.dadosBloqueio.dataInicio;
    dataFim = widget.dadosBloqueio.dataFim;
  }

  Future<void> _selecionarData(bool isInicio) async {
    final data = await showDatePicker(
      context: context,
      initialDate: (isInicio ? dataInicio : dataFim) ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
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
          dataInicio = data;
          if (widget.dadosBloqueio.tipo == "PONTUAL") dataFim = null;
        } else {
          dataFim = data;
        }
      });
    }
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    final agora = TimeOfDay.now();

    final selecionado = await showTimePicker(
      context: context,
      initialTime: agora,
      builder: (_, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF1E2D45),
              dialHandColor: Color(0xFFF2598C),
              hourMinuteColor: Colors.white12,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF2598C),
              secondary: Color(0xFFF2598C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionado != null) {
      controller.text =
          "${selecionado.hour.toString().padLeft(2, '0')}:${selecionado.minute.toString().padLeft(2, '0')}";
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

  Future<void> _salvar() async {
    if (!_validarHorario(
      horaInicioController.text.trim(),
      horaFimController.text.trim(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Horário final deve ser maior que o inicial.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final atualizado = widget.dadosBloqueio.copyWith(
        motivo: motivoController.text.trim(),
        horaInicio: horaInicioController.text.trim(),
        horaFim: horaFimController.text.trim(),
        dataInicio: dataInicio,
        dataFim: widget.dadosBloqueio.tipo == "PONTUAL" ? dataFim : null,
      );

      await BloqueioService().atualizarBloqueio(
        widget.quadraId,
        widget.bloqueioId,
        atualizado,
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

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text("Editar Bloqueio"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: motivoController,
            style: textStyle,
            decoration: _inputDecoration("Motivo do bloqueio"),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: horaInicioController,
                  readOnly: true,
                  onTap: () => _selecionarHora(horaInicioController),
                  style: textStyle,
                  decoration: _inputDecoration("Início"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: horaFimController,
                  readOnly: true,
                  onTap: () => _selecionarHora(horaFimController),
                  style: textStyle,
                  decoration: _inputDecoration("Fim"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.dadosBloqueio.tipo == "PONTUAL") ...[
            ElevatedButton(
              onPressed: () => _selecionarData(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2598C),
              ),
              child: Text(
                dataInicio == null
                    ? "Selecionar data início"
                    : "Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selecionarData(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2598C),
              ),
              child: Text(
                dataFim == null
                    ? "Selecionar data fim"
                    : "Fim: ${DateFormat('dd/MM/yyyy').format(dataFim!)}",
              ),
            ),
          ],
          const SizedBox(height: 30),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2598C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Salvar Alterações"),
                ),
        ],
      ),
    );
  }
}
