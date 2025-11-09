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

  void _abrirDialogEdicao(BuildContext context, AgendaSemanal agenda) {
    final inicioController = TextEditingController(text: agenda.horaInicio);
    final fimController = TextEditingController(text: agenda.horaFim);
    final intervaloController =
        TextEditingController(text: agenda.intervaloMinutos.toString());

    bool validarHorario(String inicio, String fim) {
      return _toMinutes(fim) > _toMinutes(inicio);
    }

    final service = AgendaService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Editar ${agenda.diaSemana}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoEdicao(inicioController, "Hora início (HH:MM)"),
            const SizedBox(height: 10),
            _campoEdicao(fimController, "Hora fim (HH:MM)"),
            const SizedBox(height: 10),
            _campoEdicao(intervaloController, "Intervalo (min)", number: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final inicio = inicioController.text.trim();
              final fim = fimController.text.trim();
              final intervalo = int.parse(intervaloController.text.trim());

              if (!validarHorario(inicio, fim)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Horário final deve ser maior.")),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2598C),
            ),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Widget _campoEdicao(TextEditingController c, String label,
      {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF0E1A2F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          nomeQuadra,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.schedule, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "Horários cadastrados",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
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

                  agendas.sort((a, b) {
                    final ordemSemana = [
                      "DOMINGO",
                      "SEGUNDA",
                      "TERCA",
                      "QUARTA",
                      "QUINTA",
                      "SEXTA",
                      "SABADO",
                    ];
                    return ordemSemana
                        .indexOf(a.diaSemana)
                        .compareTo(ordemSemana.indexOf(b.diaSemana));
                  });

                  if (agendas.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhum horário cadastrado.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  final ordemSemana = [
                    "DOMINGO",
                    "SEGUNDA",
                    "TERCA",
                    "QUARTA",
                    "QUINTA",
                    "SEXTA",
                    "SABADO",
                  ];

                  agendas.sort(
                    (a, b) =>
                        ordemSemana.indexOf(a.diaSemana) -
                        ordemSemana.indexOf(b.diaSemana),
                  );

                  return ListView.builder(
                    itemCount: agendas.length,
                    itemBuilder: (context, index) {
                      return _cardAgenda(context, agendas[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: const Color(0xFFF2598C),
        foregroundColor: Colors.white,
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 10,
        spaceBetweenChildren: 8,
        elevation: 6,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black87),
            label: 'Adicionar horário',
            child: const Icon(Icons.access_time, color: Colors.black87),
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
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black87),
            label: 'Adicionar bloqueio',
            child: const Icon(Icons.block, color: Colors.black87),
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
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black87),
            label: 'Ver bloqueios',
            child: const Icon(Icons.list, color: Colors.black87),
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
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black87),
            label: 'Ver reservas',
            child: const Icon(Icons.event_note, color: Colors.black87),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VisualizarReservasPage(
                      quadraId: quadraId, quadraNome: nomeQuadra),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cardAgenda(BuildContext context, AgendaSemanal a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16243D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          a.diaSemana,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Das ${a.horaInicio} às ${a.horaFim}\nIntervalo: ${a.intervaloMinutos} min",
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70),
          onPressed: () => _abrirDialogEdicao(context, a),
        ),
      ),
    );
  }
}
