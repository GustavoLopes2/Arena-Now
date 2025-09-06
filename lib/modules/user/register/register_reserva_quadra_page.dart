import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:arenanow/services/agenda_semanal_service.dart';
import 'package:arenanow/services/bloqueio_service.dart';
import 'package:arenanow/services/reserva_service.dart';

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
  final agendaService = AgendaSemanalService();
  final bloqueioService = BloqueioService();
  final reservaService = ReservaService();

  DateTime diaSelecionado = DateTime.now();
  int duracao = 60;
  bool carregando = false;

  List<String> horariosLivres = [];

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  Future<void> carregarHorarios() async {
    setState(() => carregando = true);

    final diaSemana = _mapDiaSemana(diaSelecionado);

    final agenda =
        await agendaService.buscarAgendaDia(widget.quadraId, diaSemana);
    if (agenda.isEmpty) {
      setState(() {
        horariosLivres = [];
        carregando = false;
      });
      return;
    }

    final horariosBase = agendaService.gerarHorariosPossiveis(agenda);
    final intervalo = agenda.first['intervaloMinutos'];

    final bloqueios = await bloqueioService.buscarBloqueios(widget.quadraId);
    final bloqueados = bloqueioService.gerarBloqueios(
      bloqueios,
      diaSemana,
      diaSelecionado,
      intervalo,
      _toTime,
      _formatTime,
    );

    final reservas =
        await reservaService.buscarReservasDia(widget.quadraId, diaSelecionado);
    final reservados = _gerarReservados(reservas, intervalo);

    setState(() {
      horariosLivres = horariosBase
          .where((h) => !bloqueados.contains(h) && !reservados.contains(h))
          .toList();
      carregando = false;
    });
  }

  Set<String> _gerarReservados(
    List<Map<String, dynamic>> reservas,
    int intervalo,
  ) {
    final set = <String>{};

    for (var r in reservas) {
      final hi = _toTime(r['horaInicio']);
      final hf = _toTime(r['horaFim']);

      var atual = hi;
      while (atual.isBefore(hf)) {
        set.add(_formatTime(atual));
        atual = atual.add(Duration(minutes: intervalo));
      }
    }
    return set;
  }

  String _mapDiaSemana(DateTime d) {
    const dias = [
      "SEGUNDA",
      "TERCA",
      "QUARTA",
      "QUINTA",
      "SEXTA",
      "SABADO",
      "DOMINGO"
    ];
    return dias[d.weekday - 1];
  }

  DateTime _toTime(String h) {
    final p = h.split(":");
    return DateTime(0, 0, 0, int.parse(p[0]), int.parse(p[1]));
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  Future<void> reservar(String horario) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }

    final partes = horario.split(':');
    final inicio = DateTime(
      diaSelecionado.year,
      diaSelecionado.month,
      diaSelecionado.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );

    final fim = inicio.add(Duration(minutes: duracao));

    await reservaService.criarReserva(
      quadraId: widget.quadraId,
      data: diaSelecionado,
      horaInicio: _formatTime(inicio),
      horaFim: _formatTime(fim),
      usuarioId: u.uid,
      usuarioNome: u.displayName ?? "Usuário",
      usuarioEmail: u.email,
    );

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
        elevation: 0,
        title: Text(
          widget.quadraNome,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecione o dia",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: dias.map((dia) {
                  final selecionado = dia.year == diaSelecionado.year &&
                      dia.month == diaSelecionado.month &&
                      dia.day == diaSelecionado.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() => diaSelecionado = dia);
                      carregarHorarios();
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selecionado
                            ? const Color(0xFFF2598C)
                            : const Color(0xFF1E2D45),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('dd/MM').format(dia),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: duracao,
              dropdownColor: const Color(0xFF1E2D45),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 60, child: Text("1h")),
                DropdownMenuItem(value: 90, child: Text("1h 30m")),
                DropdownMenuItem(value: 120, child: Text("2h")),
              ],
              onChanged: (v) => setState(() => duracao = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF16243D),
                labelText: 'Duração',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : horariosLivres.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum horário disponível.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          itemCount: horariosLivres.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final h = horariosLivres[i];

                            return InkWell(
                              onTap: () => reservar(h),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2D45),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white24, width: 0.7),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      h,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                        color: Colors.white54, size: 22),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
