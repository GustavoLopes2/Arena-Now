import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:arenanow/modules/admin/register/register_agenda_semanal_page.dart';
import 'package:arenanow/modules/admin/register/register_bloqueio_page.dart';
import 'package:arenanow/modules/admin/view/visualizar_bloqueio_page.dart';
import 'package:arenanow/modules/admin/view/visualizar_reservas_page.dart';

import 'package:arenanow/models/agenda_semanal.dart';
import 'package:arenanow/services/agenda_service.dart';

class VisualizarQuadraPage extends StatelessWidget {
  final String quadraId;
  final String nomeQuadra;

  const VisualizarQuadraPage({
    super.key,
    required this.quadraId,
    required this.nomeQuadra,
  });

  void _abrirDialogEdicao(
    BuildContext context,
    AgendaSemanal agenda,
  ) {
    final inicioController = TextEditingController(text: agenda.horaInicio);
    final fimController = TextEditingController(text: agenda.horaFim);
    final intervaloController =
        TextEditingController(text: agenda.intervaloMinutos.toString());

    bool validarHorario(String inicio, String fim) {
      final i = _toMinutes(inicio);
      final f = _toMinutes(fim);
      return f > i;
    }

    final service = AgendaService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text(
          'Editar ${agenda.diaSemana}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: inicioController,
              decoration: const InputDecoration(labelText: 'Hora Início'),
            ),
            TextField(
              controller: fimController,
              decoration: const InputDecoration(labelText: 'Hora Fim'),
            ),
            TextField(
              controller: intervaloController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Intervalo (min)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            onPressed: () async {
              final inicio = inicioController.text.trim();
              final fim = fimController.text.trim();
              final intervalo = int.parse(intervaloController.text.trim());

              if (!validarHorario(inicio, fim)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Horário final deve ser maior que o inicial',
                    ),
                  ),
                );
                return;
              }

              await service.atualizarAgenda(
                quadraId,
                agenda.id,
                horaInicio: inicio,
                horaFim: fim,
                intervaloMinutos: intervalo,
              );

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  @override
  Widget build(BuildContext context) {
    final agendaService = AgendaService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text(nomeQuadra),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Horários Cadastrados",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<AgendaSemanal>>(
                stream: agendaService.listarAgendaPorQuadra(quadraId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final agendas = snapshot.data!;

                  if (agendas.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum horário cadastrado.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: agendas.length,
                    itemBuilder: (context, index) {
                      final a = agendas[index];

                      return Card(
                        color: const Color(0xFF1E2D45),
                        child: ListTile(
                          title: Text(
                            a.diaSemana,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Das ${a.horaInicio} às ${a.horaFim} • ${a.intervaloMinutos} min",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () => _abrirDialogEdicao(context, a),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFFF2598C),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.access_time),
            label: 'Adicionar Horário',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CadastrarAgendaSemanalPage(quadraId: quadraId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.block),
            label: 'Adicionar Bloqueio',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegisterBloqueioPage(quadraId: quadraId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: 'Ver Bloqueios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListarBloqueiosPage(quadraId: quadraId),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.event_note),
            label: 'Ver Reservas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisualizarReservasPage(
                    quadraId: quadraId,
                    quadraNome: nomeQuadra,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
