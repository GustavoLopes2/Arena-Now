import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:arenanow/services/quadra_horarios_service.dart';
import 'package:arenanow/services/reserva_service.dart';

import 'package:arenanow/models/reserva_quadra.dart';

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
  bool _carregando = false;

  List<String> horariosDisponiveis = [];
  int _duracaoEmMinutos = 60;

  final horariosService = QuadraHorariosService();
  final reservaService = ReservaService();

  @override
  void initState() {
    super.initState();
    _carregarHorarios();
  }

  Future<void> _carregarHorarios() async {
    setState(() => _carregando = true);

    final lista = await horariosService.obterHorariosDisponiveis(
      widget.quadraId,
      _diaSelecionado,
    );

    setState(() {
      horariosDisponiveis = lista;
      _carregando = false;
    });
  }

  Future<void> _confirmarReserva(String horario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text(
          "Confirmar Reserva",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Deseja reservar às $horario por ${_duracaoEmMinutos ~/ 60}h"
          "${_duracaoEmMinutos % 60 != 0 ? ' ${_duracaoEmMinutos % 60}min' : ''}"
          " em ${DateFormat('dd/MM/yyyy').format(_diaSelecionado)}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado")),
      );
      return;
    }

    final partes = horario.split(':');
    final inicio = DateTime(
      _diaSelecionado.year,
      _diaSelecionado.month,
      _diaSelecionado.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    final fim = inicio.add(Duration(minutes: _duracaoEmMinutos));

    final reserva = ReservaQuadra(
      id: "",
      quadraId: widget.quadraId,
      data: _diaSelecionado,
      horaInicio: DateFormat.Hm().format(inicio),
      horaFim: DateFormat.Hm().format(fim),
      status: "CONFIRMADA",
      usuarioId: user.uid,
      usuarioNome: user.displayName ?? 'Usuário',
      usuarioEmail: user.email,
      criadoEm: DateTime.now(),
    );

    await reservaService.criarReserva(widget.quadraId, reserva);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reserva realizada com sucesso!")),
    );

    Navigator.pop(context);
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
            const Text("Selecione o dia:",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dias.map((dia) {
                  final selecionado = dia.day == _diaSelecionado.day &&
                      dia.month == _diaSelecionado.month &&
                      dia.year == _diaSelecionado.year;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selecionado
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
              dropdownColor: const Color(0xFF1E2D45),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Duração da reserva",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (v) => setState(() => _duracaoEmMinutos = v!),
            ),
            const SizedBox(height: 16),
            _carregando
                ? const Center(child: CircularProgressIndicator())
                : horariosDisponiveis.isEmpty
                    ? const Text(
                        "Nenhum horário disponível.",
                        style: TextStyle(color: Colors.white70),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: horariosDisponiveis.length,
                          itemBuilder: (ctx, i) {
                            final h = horariosDisponiveis[i];
                            return Card(
                              color: const Color(0xFF1E2D45),
                              child: ListTile(
                                title: Text(
                                  h,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => _confirmarReserva(h),
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
