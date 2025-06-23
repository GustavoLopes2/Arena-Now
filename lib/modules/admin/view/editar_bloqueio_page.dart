import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditarBloqueioPage extends StatefulWidget {
  final String quadraId;
  final String bloqueioId;
  final Map<String, dynamic> dadosBloqueio;

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
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();

  String _tipo = 'PONTUAL';
  String? _diaSemana;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dados = widget.dadosBloqueio;
    _tipo = dados['tipo'] ?? 'PONTUAL';
    _diaSemana = dados['diaSemana'];
    _motivoController.text = dados['motivo'] ?? '';

    if (dados['horaInicio'] != null) {
      final parts = (dados['horaInicio'] as String).split(':');
      _horaInicio =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (dados['horaFim'] != null) {
      final parts = (dados['horaFim'] as String).split(':');
      _horaFim =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    _dataInicio = (dados['dataInicio'] as Timestamp?)?.toDate();
    _dataFim = (dados['dataFim'] as Timestamp?)?.toDate();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final horaInicioStr = _horaInicio != null
        ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
        : null;
    final horaFimStr = _horaFim != null
        ? '${_horaFim!.hour.toString().padLeft(2, '0')}:${_horaFim!.minute.toString().padLeft(2, '0')}'
        : null;

    final Map<String, dynamic> dados = {
      'tipo': _tipo,
      'motivo': _motivoController.text.trim(),
      'horaInicio': horaInicioStr,
      'horaFim': horaFimStr,
    };

    if (_tipo == 'RECORRENTE') {
      dados['diaSemana'] = _diaSemana;
      dados.remove('dataInicio');
      dados.remove('dataFim');
    } else {
      dados['dataInicio'] =
          _dataInicio != null ? Timestamp.fromDate(_dataInicio!) : null;
      dados['dataFim'] =
          _dataFim != null ? Timestamp.fromDate(_dataFim!) : null;
      dados.remove('diaSemana');
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('quadras')
          .doc(widget.quadraId)
          .collection('bloqueios')
          .doc(widget.bloqueioId)
          .update(dados);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio
          ? (_horaInicio ?? TimeOfDay.now())
          : (_horaFim ?? TimeOfDay.now()),
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

  Future<void> _selectDate(bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicio
          ? (_dataInicio ?? DateTime.now())
          : (_dataFim ?? DateTime.now()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Editar Bloqueio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  onChanged: (value) => setState(() => _tipo = value!),
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  dropdownColor: const Color(0xFF1E2D45),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                if (_tipo == 'RECORRENTE')
                  DropdownButtonFormField<String>(
                    value: _diaSemana,
                    items: const [
                      DropdownMenuItem(
                          value: 'SEGUNDA', child: Text('Segunda')),
                      DropdownMenuItem(value: 'TERCA', child: Text('Terça')),
                      DropdownMenuItem(value: 'QUARTA', child: Text('Quarta')),
                      DropdownMenuItem(value: 'QUINTA', child: Text('Quinta')),
                      DropdownMenuItem(value: 'SEXTA', child: Text('Sexta')),
                      DropdownMenuItem(value: 'SABADO', child: Text('Sábado')),
                      DropdownMenuItem(
                          value: 'DOMINGO', child: Text('Domingo')),
                    ],
                    onChanged: (value) => setState(() => _diaSemana = value!),
                    decoration:
                        const InputDecoration(labelText: 'Dia da Semana'),
                    dropdownColor: const Color(0xFF1E2D45),
                    style: const TextStyle(color: Colors.white),
                  )
                else ...[
                  ListTile(
                    title: Text(
                      'Data Início: ${_dataInicio != null ? DateFormat('dd/MM/yyyy').format(_dataInicio!) : 'Selecione'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.calendar_today, color: Colors.white70),
                    onTap: () => _selectDate(true),
                  ),
                  ListTile(
                    title: Text(
                      'Data Fim: ${_dataFim != null ? DateFormat('dd/MM/yyyy').format(_dataFim!) : 'Selecione'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.calendar_today, color: Colors.white70),
                    onTap: () => _selectDate(false),
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Hora Início: ${_horaInicio != null ? _horaInicio!.format(context) : 'Selecione'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.access_time, color: Colors.white70),
                  onTap: () => _selectTime(true),
                ),
                ListTile(
                  title: Text(
                    'Hora Fim: ${_horaFim != null ? _horaFim!.format(context) : 'Selecione'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing:
                      const Icon(Icons.access_time, color: Colors.white70),
                  onTap: () => _selectTime(false),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motivoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                        ),
                        child: const Text('Salvar Alterações'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
