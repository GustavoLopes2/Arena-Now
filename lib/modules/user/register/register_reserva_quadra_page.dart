import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservarQuadraPage extends StatefulWidget {
  final String quadraId;
  final String quadraNome;

  const ReservarQuadraPage({
    super.key,
    required this.quadraId,
    required this.quadraNome,
  });

  @override
  State<ReservarQuadraPage> createState() => _ReservarQuadraPageState();
}

class _ReservarQuadraPageState extends State<ReservarQuadraPage> {
  DateTime _diaSelecionado = DateTime.now();
  List<String> horariosDisponiveis = [];
  bool _carregando = false;
  int _duracaoEmMinutos = 60;

  @override
  void initState() {
    super.initState();
    _carregarHorarios();
  }

  Future<void> _carregarHorarios() async {
    setState(() => _carregando = true);

    String _mapDiaSemana(DateTime date) {
      final dias = [
        'SEGUNDA',
        'TERCA',
        'QUARTA',
        'QUINTA',
        'SEXTA',
        'SABADO',
        'DOMINGO',
      ];
      return dias[date.weekday - 1];
    }

    final String diaSemana = _mapDiaSemana(_diaSelecionado);

    final agendaSnap = await FirebaseFirestore.instance
        .collection('quadras')
        .doc(widget.quadraId)
        .collection('agenda_semanal')
        .where('diaSemana', isEqualTo: diaSemana)
        .get();

    final bloqueiosSnap = await FirebaseFirestore.instance
        .collection('quadras')
        .doc(widget.quadraId)
        .collection('bloqueios')
        .get();

    final reservasSnap = await FirebaseFirestore.instance
        .collection('quadras')
        .doc(widget.quadraId)
        .collection('reservas')
        .where('data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                _diaSelecionado.year,
                _diaSelecionado.month,
                _diaSelecionado.day)))
        .where('data',
            isLessThan: Timestamp.fromDate(DateTime(_diaSelecionado.year,
                _diaSelecionado.month, _diaSelecionado.day + 1)))
        .get();

    final List<String> horarios = [];
    int intervalo = 30;

    for (var doc in agendaSnap.docs) {
      final inicio = doc['horaInicio'];
      final fim = doc['horaFim'];
      intervalo = doc['intervaloMinutos'];

      final hInicio = _toTime(inicio);
      final hFim = _toTime(fim);

      var atual = hInicio;

      while (atual.isBefore(hFim)) {
        final label = _formatTime(atual);
        horarios.add(label);
        atual = atual.add(Duration(minutes: intervalo));
      }
    }

    final bloqueados = <String>{};
    for (var b in bloqueiosSnap.docs) {
      final tipo = b['tipo'];
      final horaInicio = b['horaInicio'];
      final horaFim = b['horaFim'];
      final dia = b['diaSemana'];
      final dataInicio = (b['dataInicio'] as Timestamp?)?.toDate();
      final dataFim = (b['dataFim'] as Timestamp?)?.toDate();

      bool bloqueia = false;
      if (tipo == 'RECORRENTE' && dia == diaSemana) {
        bloqueia = true;
      } else if (tipo == 'PONTUAL' &&
          dataInicio != null &&
          dataFim != null &&
          !_diaSelecionado.isBefore(dataInicio) &&
          !_diaSelecionado.isAfter(dataFim)) {
        bloqueia = true;
      }

      if (bloqueia) {
        final hInicio = _toTime(horaInicio);
        final hFim = _toTime(horaFim);
        var atual = hInicio;
        while (atual.isBefore(hFim)) {
          bloqueados.add(_formatTime(atual));
          atual = atual.add(Duration(minutes: intervalo));
        }
      }
    }

    final Set<String> reservados = {};
    for (final doc in reservasSnap.docs) {
      final r = doc.data() as Map<String, dynamic>;
      final inicioStr = (r['horaInicio'] as String).trim();
      final fimStr = (r['horaFim'] as String).trim();

      DateTime atual = _toTime(inicioStr);
      final fim = _toTime(fimStr);

      while (atual.isBefore(fim)) {
        reservados.add(_formatTime(atual));
        atual = atual.add(Duration(minutes: intervalo));
      }
    }

    setState(() {
      horariosDisponiveis = horarios
          .where((h) => !bloqueados.contains(h) && !reservados.contains(h))
          .toList();
      _carregando = false;
    });
  }

  DateTime _toTime(String hora) {
    final parts = hora.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selecionarHorario(String horario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text('Confirmar Reserva',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja reservar às $horario por ${_duracaoEmMinutos ~/ 60}h'
          '${_duracaoEmMinutos % 60 != 0 ? ' ${_duracaoEmMinutos % 60}min' : ''} '
          'em ${DateFormat('dd/MM/yyyy').format(_diaSelecionado)}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
        return;
      }

      final partes = horario.split(':');
      final horaInicio = DateTime(
        _diaSelecionado.year,
        _diaSelecionado.month,
        _diaSelecionado.day,
        int.parse(partes[0]),
        int.parse(partes[1]),
      );
      final horaFim = horaInicio.add(Duration(minutes: _duracaoEmMinutos));

      await FirebaseFirestore.instance
          .collection('quadras')
          .doc(widget.quadraId)
          .collection('reservas')
          .add({
        'data': Timestamp.fromDate(_diaSelecionado),
        'horaInicio': DateFormat.Hm().format(horaInicio),
        'horaFim': DateFormat.Hm().format(horaFim),
        'status': 'CONFIRMADA',
        'usuarioId': user.uid,
        'usuarioNome': user.displayName ?? 'Usuário',
        'usuarioEmail': user.email,
        'criadoEm': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva realizada com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dias = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text(widget.quadraNome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecione o dia:',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dias.map((dia) {
                  final isSelected = dia.day == _diaSelecionado.day &&
                      dia.month == _diaSelecionado.month &&
                      dia.year == _diaSelecionado.year;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFF2598C)
                            : const Color(0xFF1E2D45),
                      ),
                      onPressed: () {
                        setState(() => _diaSelecionado = dia);
                        _carregarHorarios();
                      },
                      child: Text(DateFormat('dd/MM').format(dia)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _duracaoEmMinutos,
              items: const [
                DropdownMenuItem(value: 60, child: Text('1h')),
                DropdownMenuItem(value: 90, child: Text('1h30')),
                DropdownMenuItem(value: 120, child: Text('2h')),
                DropdownMenuItem(value: 150, child: Text('2h30')),
                DropdownMenuItem(value: 180, child: Text('3h')),
              ],
              onChanged: (value) => setState(() => _duracaoEmMinutos = value!),
              dropdownColor: const Color(0xFF1E2D45),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Duração da reserva',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            _carregando
                ? const Center(child: CircularProgressIndicator())
                : horariosDisponiveis.isEmpty
                    ? const Text(
                        'Nenhum horário disponível.',
                        style: TextStyle(color: Colors.white70),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: horariosDisponiveis.length,
                          itemBuilder: (context, index) {
                            final h = horariosDisponiveis[index];
                            return Card(
                              color: const Color(0xFF1E2D45),
                              child: ListTile(
                                title: Text(
                                  h,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white70),
                                onTap: () => _selecionarHorario(h),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
