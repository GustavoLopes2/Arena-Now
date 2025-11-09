import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:arenanow/models/reserva_quadra.dart';
import 'package:arenanow/services/reserva_service.dart';

class VisualizarReservasEstabelecimentoPage extends StatefulWidget {
  final String estabelecimentoId;
  final String nomeEstabelecimento;

  const VisualizarReservasEstabelecimentoPage({
    super.key,
    required this.estabelecimentoId,
    required this.nomeEstabelecimento,
  });

  @override
  State<VisualizarReservasEstabelecimentoPage> createState() =>
      _VisualizarReservasEstabelecimentoPageState();
}

class _VisualizarReservasEstabelecimentoPageState
    extends State<VisualizarReservasEstabelecimentoPage> {
  String filtroStatus = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final reservaService = ReservaService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1A2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1A2F),
        title: Text('Reservas - ${widget.nomeEstabelecimento}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<String>(
                value: filtroStatus,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E2D45),
                underline: Container(),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'TODOS', child: Text('Todos')),
                  DropdownMenuItem(
                      value: 'CONFIRMADA', child: Text('Confirmadas')),
                  DropdownMenuItem(
                      value: 'CANCELADA_USUARIO',
                      child: Text('Canceladas pelo usuário')),
                  DropdownMenuItem(
                      value: 'CANCELADA_ADMIN',
                      child: Text('Canceladas pelo admin')),
                ],
                onChanged: (val) => setState(() => filtroStatus = val!),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ReservaQuadra>>(
              stream: reservaService
                  .listarReservasDeEstabelecimento(widget.estabelecimentoId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservas = snapshot.data!;
                final agora = DateTime.now();

                List<ReservaQuadra> futuras = [];
                List<ReservaQuadra> passadas = [];

                for (var r in reservas) {
                  if (filtroStatus != 'TODOS' && r.status != filtroStatus)
                    continue;

                  final fim = DateTime(
                    r.data.year,
                    r.data.month,
                    r.data.day,
                    int.parse(r.horaFim.split(":")[0]),
                    int.parse(r.horaFim.split(":")[1]),
                  );

                  if (fim.isBefore(agora)) {
                    passadas.add(r);
                  } else {
                    futuras.add(r);
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (futuras.isNotEmpty)
                      _buildSection("Próximas Reservas", futuras),
                    if (passadas.isNotEmpty)
                      _buildSection("Reservas Anteriores", passadas),
                    if (futuras.isEmpty && passadas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            "Nenhuma reserva encontrada.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ReservaQuadra> reservas) {
    reservas.sort((a, b) => a.data.compareTo(b.data));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 18),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...reservas.map((r) => _buildReservaCard(r)),
      ],
    );
  }

  Widget _buildReservaCard(ReservaQuadra r) {
    final corStatus = _statusColor(r.status);

    final fim = DateTime(
      r.data.year,
      r.data.month,
      r.data.day,
      int.parse(r.horaFim.split(":")[0]),
      int.parse(r.horaFim.split(":")[1]),
    );

    final bool podeCancelar =
        r.status == "CONFIRMADA" && DateTime.now().isBefore(fim);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16243D),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: corStatus.withOpacity(0.18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: corStatus),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.usuarioNome,
                    style: TextStyle(
                      color: corStatus,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corStatus,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.status.replaceAll("_", " "),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info(Icons.calendar_month,
                    DateFormat('dd/MM/yyyy').format(r.data)),
                const SizedBox(height: 6),
                _info(Icons.schedule, "${r.horaInicio} - ${r.horaFim}"),
                const SizedBox(height: 6),
                _info(Icons.sports_soccer, "Quadra: ${r.nomeQuadra ?? '---'}"),
                if (podeCancelar) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _confirmarCancelamento(r.quadraId, r.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2598C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancelar Reserva"),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "CONFIRMADA":
        return Colors.greenAccent.shade400;
      case "CANCELADA_USUARIO":
        return Colors.orangeAccent.shade200;
      case "CANCELADA_ADMIN":
        return Colors.redAccent.shade200;
      default:
        return Colors.white70;
    }
  }

  Future<void> _confirmarCancelamento(String quadraId, String reservaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: const Text("Cancelar Reserva",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Deseja realmente cancelar esta reserva?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Não"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Sim, cancelar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ReservaService().cancelarReservaAdmin(quadraId, reservaId);
    }
  }
}
