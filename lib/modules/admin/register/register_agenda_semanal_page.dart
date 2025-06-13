import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  bool _validarHorario(String inicio, String fim) {
    final inicioParts = inicio.split(':').map(int.parse).toList();
    final fimParts = fim.split(':').map(int.parse).toList();

    final inicioTotalMin = inicioParts[0] * 60 + inicioParts[1];
    final fimTotalMin = fimParts[0] * 60 + fimParts[1];

    return fimTotalMin > inicioTotalMin;
  }

  Future<void> _cadastrarAgenda() async {
    if (!_formKey.currentState!.validate() || _diasSelecionados.isEmpty) return;

    setState(() => _isLoading = true);

    if (!_validarHorario(
        _horaInicioController.text.trim(), _horaFimController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Horário final deve ser depois do horário inicial')),
      );
      return;
    }
    try {
      for (var dia in _diasSelecionados) {
        final existe = await FirebaseFirestore.instance
            .collection('quadras')
            .doc(widget.quadraId)
            .collection('agenda_semanal')
            .where('diaSemana', isEqualTo: dia)
            .get();

        if (existe.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Já existe um horário cadastrado para $dia')),
          );
          continue;
        }

        await FirebaseFirestore.instance
            .collection('quadras')
            .doc(widget.quadraId)
            .collection('agenda_semanal')
            .add({
          'diaSemana': dia,
          'horaInicio': _horaInicioController.text.trim(),
          'horaFim': _horaFimController.text.trim(),
          'intervaloMinutos': int.parse(_intervaloController.text.trim()),
          'criadoEm': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horários cadastrados com sucesso!')),
      );

      _formKey.currentState!.reset();
      _horaInicioController.clear();
      _horaFimController.clear();
      _intervaloController.clear();
      setState(() => _diasSelecionados.clear());
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

  Widget _buildDiaCheckbox(String dia) {
    return CheckboxListTile(
      title: Text(
        dia[0].toUpperCase() +
            dia.substring(1).toLowerCase().replaceAll('_', ' '),
        style: const TextStyle(color: Colors.white),
      ),
      value: _diasSelecionados.contains(dia),
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _diasSelecionados.add(dia);
          } else {
            _diasSelecionados.remove(dia);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.pinkAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: const Text('Agenda Semanal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Dias da Semana',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._diasSemana.map(_buildDiaCheckbox).toList(),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horaInicioController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Horário Início (ex: 15:00)'),
                validator: (v) =>
                    v!.isEmpty ? 'Informe o horário de início' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horaFimController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Horário Fim (ex: 22:00)'),
                validator: (v) =>
                    v!.isEmpty ? 'Informe o horário de fim' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _intervaloController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Intervalo em minutos (ex: 30)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || int.tryParse(v) == null
                    ? 'Digite um número válido'
                    : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarAgenda,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2598C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Adicionar Horários'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
