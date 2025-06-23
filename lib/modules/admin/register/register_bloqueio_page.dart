import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterBloqueioPage extends StatefulWidget {
  final String quadraId;

  const RegisterBloqueioPage({super.key, required this.quadraId});

  @override
  State<RegisterBloqueioPage> createState() => _RegisterBloqueioPageState();
}

class _RegisterBloqueioPageState extends State<RegisterBloqueioPage> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'PONTUAL';
  String _diaSemana = 'SEGUNDA';
  final _motivoController = TextEditingController();
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;
  DateTime? _dataInicio;
  DateTime? _dataFim;
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

  Future<void> _salvarBloqueio() async {
    if (!_formKey.currentState!.validate()) return;

    final horaInicioStr = _horaInicio != null
        ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
        : null;

    final horaFimStr = _horaFim != null
        ? '${_horaFim!.hour.toString().padLeft(2, '0')}:${_horaFim!.minute.toString().padLeft(2, '0')}'
        : null;

    setState(() => _isLoading = true);

    try {
      final data = {
        'tipo': _tipo,
        'horaInicio': horaInicioStr,
        'horaFim': horaFimStr,
        'motivo': _motivoController.text.trim(),
        'criadoEm': Timestamp.now(),
      };

      if (_tipo == 'PONTUAL') {
        if (_dataInicio != null) {
          data['dataInicio'] = Timestamp.fromDate(_dataInicio!);
        }
        if (_dataFim != null) {
          data['dataFim'] = Timestamp.fromDate(_dataFim!);
        }
      } else {
        data['diaSemana'] = _diaSemana;
      }

      await FirebaseFirestore.instance
          .collection('quadras')
          .doc(widget.quadraId)
          .collection('bloqueios')
          .add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bloqueio cadastrado com sucesso!')),
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

  Future<void> _pickDate(bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
        } else {
          _horaFim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Cadastrar Bloqueio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF2598C)),
              ),
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _tipo,
                  items: const [
                    DropdownMenuItem(value: 'PONTUAL', child: Text('Pontual')),
                    DropdownMenuItem(
                        value: 'RECORRENTE', child: Text('Recorrente')),
                  ],
                  dropdownColor: const Color(0xFF1E2D45),
                  style: const TextStyle(color: Colors.white),
                  decoration:
                      const InputDecoration(labelText: 'Tipo de Bloqueio'),
                  onChanged: (val) => setState(() => _tipo = val!),
                ),
                const SizedBox(height: 12),
                if (_tipo == 'RECORRENTE')
                  DropdownButtonFormField<String>(
                    value: _diaSemana,
                    items: _diasSemana
                        .map((dia) =>
                            DropdownMenuItem(value: dia, child: Text(dia)))
                        .toList(),
                    onChanged: (val) => setState(() => _diaSemana = val!),
                    dropdownColor: const Color(0xFF1E2D45),
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        const InputDecoration(labelText: 'Dia da semana'),
                  ),
                if (_tipo == 'PONTUAL')
                  Column(
                    children: [
                      ListTile(
                        title: Text(
                          _dataInicio == null
                              ? 'Selecionar data início'
                              : 'Início: ${DateFormat('dd/MM/yyyy').format(_dataInicio!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Icons.calendar_today,
                            color: Colors.white70),
                        onTap: () => _pickDate(true),
                      ),
                      ListTile(
                        title: Text(
                          _dataFim == null
                              ? 'Selecionar data fim'
                              : 'Fim: ${DateFormat('dd/MM/yyyy').format(_dataFim!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Icons.calendar_today,
                            color: Colors.white70),
                        onTap: () => _pickDate(false),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Hora Início: ${_horaInicio != null ? _horaInicio!.format(context) : 'Selecione'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.access_time, color: Colors.white70),
                  onTap: () => _pickTime(true),
                ),
                ListTile(
                  title: Text(
                    'Hora Fim: ${_horaFim != null ? _horaFim!.format(context) : 'Selecione'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.access_time, color: Colors.white70),
                  onTap: () => _pickTime(false),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motivoController,
                  style: const TextStyle(color: Colors.white),
                  decoration:
                      const InputDecoration(labelText: 'Motivo do bloqueio'),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _salvarBloqueio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2598C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cadastrar Bloqueio'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
