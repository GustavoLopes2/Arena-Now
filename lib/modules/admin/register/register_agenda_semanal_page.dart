import 'package:flutter/material.dart';
import 'package:arenanow/models/agenda_semanal.dart';
import 'package:arenanow/services/agenda_service.dart';
import 'package:flutter/services.dart';

class CadastrarAgendaSemanalPage extends StatefulWidget {
  final String quadraId;

  const CadastrarAgendaSemanalPage({super.key, required this.quadraId});

  @override
  State<CadastrarAgendaSemanalPage> createState() =>
      _CadastrarAgendaSemanalPageState();
}

class _CadastrarAgendaSemanalPageState
    extends State<CadastrarAgendaSemanalPage> {
  final _formKey = GlobalKey<FormState>();

  final _horaInicioController = TextEditingController();
  final _horaFimController = TextEditingController();
  final _intervaloController = TextEditingController();

  final List<String> _diasSelecionados = [];
  bool _isLoading = false;

  final List<String> _diasSemana = [
    'SEGUNDA',
    'TERCA',
    'QUARTA',
    'QUINTA',
    'SEXTA',
    'SABADO',
    'DOMINGO'
  ];

  Future<void> _selecionarHora(TextEditingController controller) async {
    final agora = TimeOfDay.now();

    final selecionado = await showTimePicker(
      context: context,
      initialTime: agora,
      helpText: "Selecione o horário",
      builder: (_, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF2598C),
              secondary: Color(0xFFF2598C),
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF1E2D45),
              hourMinuteColor: Colors.white10,
              dayPeriodColor: Colors.white10,
              dialHandColor: Color(0xFFF2598C),
              entryModeIconColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionado != null) {
      final hora = selecionado.hour.toString().padLeft(2, '0');
      final min = selecionado.minute.toString().padLeft(2, '0');
      controller.text = "$hora:$min";
    }
  }

  bool _validarHorario(String inicio, String fim) {
    if (!inicio.contains(":") || !fim.contains(":")) return false;
    final i = inicio.split(':').map(int.parse).toList();
    final f = fim.split(':').map(int.parse).toList();
    return f[0] * 60 + f[1] > i[0] * 60 + i[1];
  }

  Future<void> _cadastrarAgenda() async {
    if (!_formKey.currentState!.validate() || _diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione ao menos um dia.")),
      );
      return;
    }

    final inicio = _horaInicioController.text.trim();
    final fim = _horaFimController.text.trim();

    if (!_validarHorario(inicio, fim)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Horário final deve ser depois do inicial.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = AgendaService();

      for (var dia in _diasSelecionados) {
        final existe = await service.existeAgenda(widget.quadraId, dia);

        if (existe) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Já existe agenda cadastrada para $dia")),
          );
          continue;
        }

        final agenda = AgendaSemanal(
          id: "",
          quadraId: widget.quadraId,
          diaSemana: dia,
          horaInicio: inicio,
          horaFim: fim,
          intervaloMinutos: int.parse(_intervaloController.text.trim()),
          criadoEm: DateTime.now(),
        );

        await service.criarAgenda(widget.quadraId, agenda);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Agenda cadastrada!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro: $e")));
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

  Widget _buildDiaItem(String dia) {
    final selecionado = _diasSelecionados.contains(dia);

    return GestureDetector(
      onTap: () {
        setState(() {
          selecionado
              ? _diasSelecionados.remove(dia)
              : _diasSelecionados.add(dia);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color:
              selecionado ? const Color(0xFFF2598C) : const Color(0xFF1E2D45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? Colors.pinkAccent : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selecionado ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 14),
            Text(
              dia[0] + dia.substring(1).toLowerCase(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text("Agenda Semanal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Selecione os dias:",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ..._diasSemana.map(_buildDiaItem).toList(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _horaInicioController,
                readOnly: true,
                onTap: () => _selecionarHora(_horaInicioController),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Horário Início"),
                validator: (v) =>
                    v!.isEmpty ? "Informe o horário de início" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _horaFimController,
                readOnly: true,
                onTap: () => _selecionarHora(_horaFimController),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Horário Fim"),
                validator: (v) => v!.isEmpty ? "Informe o horário final" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _intervaloController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Intervalo em minutos"),
                validator: (v) => v!.isEmpty || int.tryParse(v) == null
                    ? "Digite um número válido"
                    : null,
              ),
              const SizedBox(height: 35),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarAgenda,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Cadastrar Agenda"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
